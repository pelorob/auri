#!/bin/bash
# Compila auri per l'iPad su un Mac e mette auri.ipa sulla Scrivania.
#
#   ./scripts/compila-su-mac.sh               compila auri.ipa
#   ./scripts/compila-su-mac.sh --simulatore  in più fa il giro di prova sul simulatore (foto sulla Scrivania)
#
# Si può lanciare tutte le volte che serve: installa solo quello che manca e scarica l'ultima versione del codice.
set -euo pipefail

ROSSO=$'\033[31m'; VERDE=$'\033[32m'; GRASSETTO=$'\033[1m'; NORMALE=$'\033[0m'
passo() { echo; echo "${GRASSETTO}▶ $1${NORMALE}"; }
ok() { echo "${VERDE}✓ $1${NORMALE}"; }
stop() { echo; echo "${ROSSO}✗ $1${NORMALE}"; exit 1; }

SIMULATORE=0
[ "${1:-}" = "--simulatore" ] && SIMULATORE=1

RADICE="$(cd "$(dirname "$0")/.." && pwd)"
SCRIVANIA="$HOME/Desktop"

passo "Controllo Xcode"
if ! xcodebuild -version >/dev/null 2>&1; then
  stop "Xcode non è installato (o non è mai stato aperto).
  1. Installa Xcode dall'App Store (è gratis, ma pesa molto: serve tempo).
  2. Aprilo una volta e accetta quello che chiede.
  3. Rilancia questo script."
fi
if [ "$(xcode-select -p)" = "/Library/Developer/CommandLineTools" ]; then
  echo "Imposto Xcode come strumento predefinito (chiede la password del Mac)."
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
fi
if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  echo "Completo la prima configurazione di Xcode (chiede la password del Mac)."
  sudo xcodebuild -license accept
  sudo xcodebuild -runFirstLaunch
fi
ok "$(xcodebuild -version | head -1)"

passo "Controllo Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
fi
if ! command -v brew >/dev/null 2>&1; then
  echo "Installo Homebrew (chiede la password del Mac e di premere Invio)."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
fi
command -v brew >/dev/null 2>&1 || stop "Homebrew non si è installato: chiudi il Terminale, riaprilo e rilancia lo script."
ok "Homebrew"

passo "Controllo CocoaPods"
command -v pod >/dev/null 2>&1 || brew install cocoapods
ok "CocoaPods $(pod --version)"

passo "Controllo Flutter"
if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "$HOME/flutter/bin/flutter" ]; then
    echo "Scarico Flutter in $HOME/flutter (qualche minuto)."
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
  fi
  export PATH="$HOME/flutter/bin:$PATH"
fi
flutter --version --suppress-analytics >/dev/null 2>&1 || true
ok "$(flutter --version 2>/dev/null | head -1)"

passo "Scarico l'ultima versione di auri"
cd "$RADICE"
if [ -n "$(git status --porcelain)" ]; then
  echo "Ci sono file modificati in questa cartella: non aggiorno, compilo quello che c'è."
else
  git pull --ff-only || echo "Non riesco ad aggiornare (sei senza internet?): compilo la versione che c'è già."
fi
VERSIONE=$(grep '^version:' app/pubspec.yaml | sed 's/version: *//; s/+.*//')
ok "auri $VERSIONE ($(git log -1 --format='%h, %cd' --date=short))"

cd "$RADICE/app"
passo "Preparo le librerie"
flutter pub get

passo "Compilo per l'iPad (5-10 minuti la prima volta)"
flutter build ios --release --no-codesign
rm -rf Payload auri.ipa
mkdir Payload
cp -R build/ios/iphoneos/Runner.app Payload/
zip -qr auri.ipa Payload
rm -rf Payload
cp auri.ipa "$SCRIVANIA/auri-$VERSIONE.ipa"
ok "Fatto: sulla Scrivania c'è auri-$VERSIONE.ipa"

if [ "$SIMULATORE" = 1 ]; then
  passo "Giro di prova sul simulatore"
  UDID=$(xcrun simctl list devices available -j | python3 -c "
import json, sys
d = json.load(sys.stdin)['devices']
ipad = [x for r in d.values() for x in r if x['name'].startswith('iPad')]
scelti = [x for x in ipad if 'A16' in x['name']] or [x for x in ipad if x['name'].startswith('iPad (')] or ipad
print(scelti[0]['udid'] if scelti else '')
")
  if [ -z "$UDID" ]; then
    echo "Manca il simulatore dell'iPad: lo scarico (qualche GB)."
    xcodebuild -downloadPlatform iOS
    stop "Simulatore scaricato: rilancia lo script con --simulatore."
  fi
  xcrun simctl boot "$UDID" 2>/dev/null || true
  xcrun simctl bootstatus "$UDID" -b
  FOTO="$SCRIVANIA/auri-foto-$VERSIONE"
  rm -rf "$FOTO"
  if flutter test integration_test/app_test.dart -d "$UDID" --dart-define=FOTO_DIR="$FOTO"; then
    ok "Giro di prova superato. Le foto sono sulla Scrivania, in auri-foto-$VERSIONE"
  else
    stop "Il giro di prova non è passato. Salva quello che vedi qui sopra (o una foto dello schermo) per capire cosa non va."
  fi
fi

echo
echo "${GRASSETTO}Ora manda auri-$VERSIONE.ipa all'iPad (AirDrop) e aprilo con SideStore.${NORMALE}"
