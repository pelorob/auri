# Piano A: strumenti, scheletro, compilazione iPad e fase 0

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preparare il PC, creare il progetto Flutter `auri` con la compilazione per iPad in cloud, leggere la scadenza della firma, e fornire l'app di prova della trascrizione con le guide per l'installazione su iPad.

**Architecture:** Repository git nella cartella del progetto, app Flutter in `app/`. GitHub Actions: i test girano su Ubuntu (economico) e la compilazione iOS non firmata su macOS, producendo `auri.ipa` che SideStore firma con l'Apple ID gratuito. La prova della trascrizione vive in un ramo separato `spike/fase0` e non viene mai unita.

**Tech Stack:** Flutter stable (Dart), GitHub Actions (`subosito/flutter-action@v2`), Swift (platform channel), `speech_to_text`, `record`.

**Spec:** `docs/superpowers/specs/2026-10-13-auri-app-studio-design.md` (§2, §5, §6.6)

## Global Constraints

- Dispositivo: iPad 11ª generazione (A16), solo iPad (`TARGETED_DEVICE_FAMILY = 2`), orizzontale e verticale.
- Installazione con SideStore + Apple ID gratuito. Nessun Mac locale: la compilazione iOS avviene solo su GitHub Actions `macos-latest`.
- Bundle ID: `it.auri.auri`. Nome visualizzato: `auri`.
- Nessun server, nessuna chiave API, nessuna IA in cloud.
- Testi all'utente in italiano, al femminile.
- Repository GitHub **privato** sull'account `pelorob`. I minuti macOS sono limitati, quindi la build iOS parte solo a mano (`workflow_dispatch`) o con un tag `v*`, mai a ogni push.

## Review Focus

1. **App avviata su Windows o nei test (nessun file `embedded.mobileprovision`)**: la lettura della scadenza deve restituire `null` senza eccezioni. Test nel Task 3.
2. **Profilo con plist malformato o senza `ExpirationDate`**: `null`, nessun crash. Test nel Task 3 (risposta nulla e stringa non valida dal canale).
3. **Riconoscimento vocale che si ferma da solo dopo una pausa**: la prova deve riavviarlo finché la registrazione è attiva e contare i riavvii. Codice nel Task 4.
4. **Permesso microfono o riconoscimento negato**: la prova mostra un messaggio chiaro invece di restare muta. Codice nel Task 4.
5. **Build iOS con firma richiesta per errore**: il workflow deve usare `--no-codesign`, altrimenti fallisce su CI senza certificati. Verifica nel Task 2.

---

### Task 1: Strumenti sul PC e repository git

**Files:**
- Create: `.gitignore`
- Create: `README.md`

**Interfaces:**
- Produces: comando `flutter` disponibile nel PATH, repository git inizializzato.

- [ ] **Step 1: Scaricare Flutter stable per Windows**

```powershell
$rel = Invoke-RestMethod https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json
$hash = $rel.current_release.stable
$r = $rel.releases | Where-Object { $_.hash -eq $hash } | Select-Object -First 1
"Versione: $($r.version)"
$zip = "$env:TEMP\flutter.zip"
Invoke-WebRequest "$($rel.base_url)/$($r.archive)" -OutFile $zip
New-Item -ItemType Directory -Force C:\Users\pellegatti\Tools | Out-Null
Expand-Archive $zip -DestinationPath C:\Users\pellegatti\Tools -Force
```

- [ ] **Step 2: Aggiungere Flutter al PATH dell'utente e verificarlo**

```powershell
$bin = 'C:\Users\pellegatti\Tools\flutter\bin'
$p = [Environment]::GetEnvironmentVariable('Path','User')
if ($p -notlike "*$bin*") { [Environment]::SetEnvironmentVariable('Path', "$p;$bin", 'User') }
$env:Path += ";$bin"
flutter config --no-analytics
flutter --version
```
Expected: la versione stabile corrente (3.x), senza errori.

- [ ] **Step 3: Inizializzare git con un'identità locale (email noreply di GitHub)**

```powershell
git init -b main
$u = gh api user | ConvertFrom-Json
git config user.name $u.login
git config user.email "$($u.id)+$($u.login)@users.noreply.github.com"
```

- [ ] **Step 4: Creare `.gitignore` e `README.md`**

`.gitignore`:
```gitignore
.superpowers/
dist/
*.ipa
.DS_Store
Thumbs.db
```

`README.md`:
```markdown
# auri

App di studio personale per iPad (Flutter). Documenti:
- Progetto: docs/superpowers/specs/2026-10-13-auri-app-studio-design.md
- Piani: docs/superpowers/plans/
- Mockup: mockup/auri-mockup.html
```

- [ ] **Step 5: Commit**

```bash
git add .gitignore README.md docs mockup
git commit -m "chore: repository, documento di progetto, piani e mockup"
```

---

### Task 2: Scheletro Flutter `auri` e compilazione iPad su GitHub Actions

**Files:**
- Create: `app/` (con `flutter create`)
- Modify: `app/lib/main.dart`
- Modify: `app/test/widget_test.dart`
- Modify: `app/ios/Runner.xcodeproj/project.pbxproj` (famiglia di dispositivi)
- Modify: `app/ios/Runner/Info.plist` (nome, orientamenti)
- Create: `.github/workflows/ipad.yml`

**Interfaces:**
- Produces: app `auri` con classe `AuriApp` in `app/lib/main.dart` e workflow `Build iPad` che produce l'artefatto `auri-ipa` contenente `auri.ipa`.

- [ ] **Step 1: Creare il progetto**

```powershell
flutter create --org it.auri --project-name auri --platforms ios,windows app
```

- [ ] **Step 2: Scrivere il test (fallisce perché il testo non esiste ancora)**

`app/test/widget_test.dart`:
```dart
import 'package:auri/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra il saluto di auri', (tester) async {
    await tester.pumpWidget(const AuriApp());
    expect(find.text('Ciao auri'), findsOneWidget);
  });
}
```

Run: `cd app; flutter test`
Expected: FAIL (`AuriApp` non definita).

- [ ] **Step 3: App minima**

`app/lib/main.dart`:
```dart
import 'package:flutter/material.dart';

void main() => runApp(const AuriApp());

class AuriApp extends StatelessWidget {
  const AuriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'auri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF5B3DE6), useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Ciao auri', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800))),
      ),
    );
  }
}
```

Run: `flutter test`
Expected: PASS.

- [ ] **Step 4: Solo iPad, nome e orientamenti**

```powershell
(Get-Content ios/Runner.xcodeproj/project.pbxproj -Raw) -replace 'TARGETED_DEVICE_FAMILY = "1,2";','TARGETED_DEVICE_FAMILY = 2;' | Set-Content ios/Runner.xcodeproj/project.pbxproj -NoNewline -Encoding utf8
Select-String -Path ios/Runner.xcodeproj/project.pbxproj -Pattern 'TARGETED_DEVICE_FAMILY'
```
Expected: tutte le righe mostrano `TARGETED_DEVICE_FAMILY = 2;`. Se il template non contiene la riga, aggiungere `TARGETED_DEVICE_FAMILY = 2;` nei tre blocchi `buildSettings` del target Runner (Debug, Release, Profile).

In `ios/Runner/Info.plist` impostare `CFBundleDisplayName` a `auri` e verificare che `UISupportedInterfaceOrientations~ipad` contenga tutte e quattro le orientazioni (il template le include già).

- [ ] **Step 5: Workflow**

`.github/workflows/ipad.yml`:
```yaml
name: Build iPad

on:
  workflow_dispatch:
  push:
    tags: ['v*']

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: app
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter test

  ipa:
    needs: test
    runs-on: macos-latest
    timeout-minutes: 40
    defaults:
      run:
        working-directory: app
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      - name: Crea auri.ipa
        run: |
          rm -rf Payload auri.ipa
          mkdir Payload
          cp -R build/ios/iphoneos/Runner.app Payload/
          zip -qr auri.ipa Payload
      - uses: actions/upload-artifact@v4
        with:
          name: auri-ipa
          path: app/auri.ipa
          retention-days: 30
```

- [ ] **Step 6: Commit, repository privato e prima build**

```powershell
git add app .github
git commit -m "feat: scheletro Flutter auri (solo iPad) e build IPA su GitHub Actions"
gh repo create auri --private --source . --push
gh workflow run "Build iPad" --ref main
Start-Sleep 5
$id = (gh run list --workflow "Build iPad" --limit 1 --json databaseId | ConvertFrom-Json)[0].databaseId
gh run watch $id --exit-status
gh run download $id -n auri-ipa -D dist
Get-Item dist/auri.ipa
```
Expected: run completato e `dist/auri.ipa` presente (alcune decine di MB).

---

### Task 3: Lettura della scadenza della firma (componente definitivo)

**Files:**
- Create: `app/lib/services/scadenza_firma.dart`
- Modify: `app/ios/Runner/AppDelegate.swift`
- Modify: `app/lib/main.dart` (riga provvisoria "Firma valida fino a")
- Test: `app/test/services/scadenza_firma_test.dart`

**Interfaces:**
- Produces: `class ScadenzaFirmaService { const ScadenzaFirmaService([MethodChannel channel]); Future<DateTime?> leggi(); }` e la costante `const kCanaleFirma = 'auri/firma'`. Metodo nativo `scadenza` → `String?` ISO-8601 (UTC) oppure `null`.

- [ ] **Step 1: Test che falliscono**

`app/test/services/scadenza_firma_test.dart`:
```dart
import 'package:auri/services/scadenza_firma.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canale = MethodChannel(kCanaleFirma);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(canale, null));

  test('restituisce la data quando il nativo risponde ISO-8601', () async {
    messenger.setMockMethodCallHandler(canale, (call) async {
      expect(call.method, 'scadenza');
      return '2026-10-25T08:30:00Z';
    });
    final d = await const ScadenzaFirmaService().leggi();
    expect(d, DateTime.utc(2026, 10, 25, 8, 30));
  });

  test('null quando il nativo risponde null (nessun profilo)', () async {
    messenger.setMockMethodCallHandler(canale, (call) async => null);
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });

  test('null quando la stringa non è una data', () async {
    messenger.setMockMethodCallHandler(canale, (call) async => 'boh');
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });

  test('null quando il canale non esiste (Windows, test)', () async {
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });

  test('null quando il nativo lancia un errore', () async {
    messenger.setMockMethodCallHandler(canale, (call) async => throw PlatformException(code: 'x'));
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });
}
```

Run: `flutter test test/services/scadenza_firma_test.dart`
Expected: FAIL (file inesistente).

- [ ] **Step 2: Servizio Dart**

`app/lib/services/scadenza_firma.dart`:
```dart
import 'package:flutter/services.dart';

const kCanaleFirma = 'auri/firma';

/// Legge la data di scadenza della firma dell'app (profilo di SideStore).
/// Restituisce null se non disponibile: Windows, test, App Store, errori.
class ScadenzaFirmaService {
  const ScadenzaFirmaService([this._canale = const MethodChannel(kCanaleFirma)]);

  final MethodChannel _canale;

  Future<DateTime?> leggi() async {
    try {
      final s = await _canale.invokeMethod<String>('scadenza');
      return s == null ? null : DateTime.tryParse(s);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
```

Run: `flutter test test/services/scadenza_firma_test.dart`
Expected: PASS (5 test).

- [ ] **Step 3: Lato iOS in `AppDelegate.swift`**

Aprire `app/ios/Runner/AppDelegate.swift`. Aggiungere in fondo al file questa funzione (fuori dalla classe):

```swift
func auriScadenzaFirma() -> String? {
  guard let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let text = String(data: data, encoding: .isoLatin1),
        let start = text.range(of: "<?xml"),
        let end = text.range(of: "</plist>") else { return nil }
  let xml = String(text[start.lowerBound..<end.upperBound])
  guard let plistData = xml.data(using: .isoLatin1),
        let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
        let date = plist["ExpirationDate"] as? Date else { return nil }
  let f = ISO8601DateFormatter()
  f.timeZone = TimeZone(identifier: "UTC")
  return f.string(from: date)
}

func auriRegistraCanaleFirma(_ messenger: FlutterBinaryMessenger) {
  let channel = FlutterMethodChannel(name: "auri/firma", binaryMessenger: messenger)
  channel.setMethodCallHandler { call, result in
    if call.method == "scadenza" { result(auriScadenzaFirma()) } else { result(FlutterMethodNotImplemented) }
  }
}
```

Poi registrare il canale secondo il template generato:
- **Variante A**: il file contiene `didInitializeImplicitFlutterEngine` (template recente con UIScene). Dentro quel metodo, dopo `GeneratedPluginRegistrant.register(...)`, aggiungere:
  ```swift
  auriRegistraCanaleFirma(engineBridge.applicationRegistrar.messenger())
  ```
- **Variante B**: il file contiene solo `application(_:didFinishLaunchingWithOptions:)`. Prima del `return super.application(...)` aggiungere:
  ```swift
  if let controller = window?.rootViewController as? FlutterViewController {
    auriRegistraCanaleFirma(controller.binaryMessenger)
  }
  ```

La verifica avviene solo sull'iPad (Task 5): su Windows il codice Swift non si compila.

- [ ] **Step 4: Mostrare provvisoriamente la scadenza nella schermata di saluto**

Sostituire `home:` in `app/lib/main.dart` con:
```dart
      home: Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Ciao auri', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            FutureBuilder<DateTime?>(
              future: const ScadenzaFirmaService().leggi(),
              builder: (context, s) => Text(
                s.data == null ? 'Scadenza firma: non disponibile' : 'Firma valida fino a: ${s.data!.toLocal()}',
              ),
            ),
          ]),
        ),
      ),
```
con `import 'services/scadenza_firma.dart';` in cima.

Run: `flutter test`
Expected: PASS (il test del saluto trova ancora `Ciao auri`).

- [ ] **Step 5: Commit**

```bash
git add app
git commit -m "feat: lettura della scadenza della firma (canale nativo auri/firma)"
git push
```

---

### Task 4: App di prova della trascrizione (ramo `spike/fase0`, DA BUTTARE)

**Files (solo nel ramo `spike/fase0`):**
- Create: `app/lib/spike/prova_trascrizione.dart`
- Modify: `app/lib/main.dart` (pulsante "Prova trascrizione")
- Modify: `app/ios/Runner/Info.plist` (permessi e audio in background)
- Modify: `app/pubspec.yaml` (`speech_to_text`, `record`, `path_provider`)

**Interfaces:**
- Consumes: `AuriApp` (Task 2).
- Produces: nulla di riutilizzabile. Il ramo non va unito a `main`.

- [ ] **Step 1: Ramo e dipendenze**

```powershell
git switch -c spike/fase0
cd app
flutter pub add speech_to_text record path_provider
```

- [ ] **Step 2: Permessi in `ios/Runner/Info.plist`** (dentro il `<dict>` principale)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>auri usa il microfono per registrare e trascrivere le lezioni.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>auri trascrive le lezioni sull'iPad, senza inviarle a nessuno.</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

- [ ] **Step 3: Schermata di prova**

`app/lib/spike/prova_trascrizione.dart`:
```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// PROVA DELLA FASE 0, da buttare. Misura: continuità, riavvii, qualità, schermo spento.
class ProvaTrascrizione extends StatefulWidget {
  const ProvaTrascrizione({super.key});
  @override
  State<ProvaTrascrizione> createState() => _ProvaTrascrizioneState();
}

class _ProvaTrascrizioneState extends State<ProvaTrascrizione> {
  final _stt = SpeechToText();
  final _rec = AudioRecorder();
  final _righe = <String>[];
  String _parziale = '';
  String _stato = 'pronta';
  bool _attiva = false;
  bool _conAudio = false;
  int _riavvii = 0;
  DateTime? _inizio;
  Timer? _orologio;

  Future<void> _avvia() async {
    final ok = await _stt.initialize(onStatus: _onStatus, onError: (e) => setState(() => _stato = 'errore: ${e.errorMsg}'));
    if (!ok) {
      setState(() => _stato = 'Permesso negato o riconoscimento non disponibile: controlla Impostazioni > auri');
      return;
    }
    final locali = await _stt.locales();
    final it = locali.any((l) => l.localeId.startsWith('it'));
    if (!it) setState(() => _stato = 'Attenzione: italiano non trovato tra le lingue del riconoscimento');
    if (_conAudio && await _rec.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      await _rec.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: '${dir.path}/prova-${DateTime.now().millisecondsSinceEpoch}.m4a');
    }
    setState(() { _attiva = true; _inizio = DateTime.now(); _riavvii = 0; _righe.clear(); });
    _orologio = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    await _ascolta();
  }

  Future<void> _ascolta() async {
    if (!_attiva) return;
    await _stt.listen(
      onResult: _onResult,
      localeId: 'it_IT',
      listenFor: const Duration(minutes: 30),
      pauseFor: const Duration(seconds: 30),
      listenOptions: SpeechListenOptions(onDevice: true, partialResults: true, listenMode: ListenMode.dictation, cancelOnError: false),
    );
  }

  void _onStatus(String s) {
    setState(() => _stato = s);
    if (_attiva && (s == 'done' || s == 'notListening')) {
      _riavvii++;
      Future.delayed(const Duration(milliseconds: 300), _ascolta);
    }
  }

  void _onResult(SpeechRecognitionResult r) {
    setState(() {
      if (r.finalResult) {
        final t = DateTime.now().difference(_inizio!);
        _righe.add('[${t.inMinutes.toString().padLeft(2, '0')}:${(t.inSeconds % 60).toString().padLeft(2, '0')}] ${r.recognizedWords}');
        _parziale = '';
      } else {
        _parziale = r.recognizedWords;
      }
    });
  }

  Future<void> _ferma() async {
    _attiva = false;
    _orologio?.cancel();
    await _stt.stop();
    if (await _rec.isRecording()) await _rec.stop();
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/trascrizione-${DateTime.now().millisecondsSinceEpoch}.txt');
    await f.writeAsString('Riavvii: $_riavvii\nDurata: ${DateTime.now().difference(_inizio!)}\n\n${_righe.join('\n')}');
    setState(() => _stato = 'salvata: ${f.path.split('/').last}');
  }

  @override
  Widget build(BuildContext context) {
    final durata = _inizio == null ? Duration.zero : DateTime.now().difference(_inizio!);
    return Scaffold(
      appBar: AppBar(title: const Text('Prova trascrizione (fase 0)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            FilledButton(onPressed: _attiva ? _ferma : _avvia, child: Text(_attiva ? 'Ferma e salva' : 'Registra')),
            const SizedBox(width: 16),
            if (!_attiva) Row(children: [Checkbox(value: _conAudio, onChanged: (v) => setState(() => _conAudio = v!)), const Text('Registra anche l\'audio')]),
          ]),
          const SizedBox(height: 12),
          Text('Stato: $_stato · Durata: ${durata.inMinutes} min ${durata.inSeconds % 60} s · Riavvii: $_riavvii'),
          const Divider(),
          Expanded(child: ListView(reverse: true, children: [
            if (_parziale.isNotEmpty) Text(_parziale, style: const TextStyle(color: Colors.grey)),
            ..._righe.reversed.map(Text.new),
          ])),
        ]),
      ),
    );
  }
}
```

I nomi `SpeechListenOptions` e `ListenMode` sono quelli di `speech_to_text` 7.x. Se la versione installata li segnala come inesistenti, controllare l'esempio nel README del pacchetto installato e adattare solo la chiamata `listen`.

- [ ] **Step 4: Pulsante dalla schermata di saluto**

In `app/lib/main.dart`, nella `Column` della home, aggiungere dopo il `FutureBuilder`:
```dart
            const SizedBox(height: 24),
            Builder(builder: (context) => FilledButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProvaTrascrizione())),
              child: const Text('Prova trascrizione'),
            )),
```
con `import 'spike/prova_trascrizione.dart';`. Togliere il `const` da `home: Scaffold(` se presente.

Run: `flutter analyze; flutter test`
Expected: nessun errore, test PASS.

- [ ] **Step 5: Commit e build del ramo**

```powershell
cd ..
git add app
git commit -m "spike: prova di trascrizione dal vivo (fase 0, da buttare)"
git push -u origin spike/fase0
gh workflow run "Build iPad" --ref spike/fase0
Start-Sleep 5
$id = (gh run list --workflow "Build iPad" --branch spike/fase0 --limit 1 --json databaseId | ConvertFrom-Json)[0].databaseId
gh run watch $id --exit-status
gh run download $id -n auri-ipa -D dist/spike
git switch main
```
Expected: `dist/spike/auri.ipa` presente.

---

### Task 5: Guide per l'iPad e scheda dei risultati della fase 0

**Files:**
- Create: `docs/guide/installazione-ipad.md`
- Create: `docs/fase0-risultati.md`

**Interfaces:**
- Consumes: `dist/spike/auri.ipa` (Task 4).

- [ ] **Step 1: Guida d'installazione** (per la studentessa, in italiano semplice)

`docs/guide/installazione-ipad.md`:
```markdown
# Installare auri sull'iPad

Serve: l'iPad, il PC Windows di casa, un Apple ID (quello dell'iPad va bene), il cavo USB-C, il Wi-Fi.

## 1. Attivare la Modalità sviluppatore (una volta sola)
Impostazioni → Privacy e sicurezza → **Modalità sviluppatore** → attiva → l'iPad si riavvia → conferma "Attiva".
Se la voce non c'è ancora, compare dopo il primo tentativo di installazione con SideStore.

## 2. Installare SideStore (una volta sola, con il PC)
Segui la guida ufficiale per Windows: https://docs.sidestore.io (sezione "Installation").
La procedura cambia nel tempo: fai sempre riferimento a quella pagina.
Alla fine sull'iPad trovi l'app **SideStore**, accedi con il tuo Apple ID.

## 3. Installare auri
1. Copia `auri.ipa` sull'iPad (iCloud Drive, email a te stessa, o "Condividi" dal PC).
2. Apri **SideStore** → scheda **My Apps** → **+** → scegli `auri.ipa`.
3. Attendi la fine: auri compare nella schermata Home.

## 4. Rinnovo automatico ogni settimana
L'app va rinnovata ogni 7 giorni. Facciamolo fare all'iPad:
1. Apri **Comandi** → **Automazione** → **+** → **Ora del giorno**.
2. Ore **5:00**, **Settimanale**, **domenica**. Scegli **Esegui immediatamente** (non "Chiedi").
3. Azione: cerca **SideStore** → **Refresh All** (o "Aggiorna tutte le app").
4. Lascia l'iPad **in carica e sul Wi-Fi** il sabato notte.

## 5. Se auri non si apre
- Apri **SideStore** → **My Apps** → **Refresh All**. Fatto: i dati ci sono ancora.
- Se non si apre neanche SideStore: serve il PC, ripeti il passo 2. I dati di auri restano.

## 6. Aggiornare auri a una nuova versione
Come al passo 3, con il nuovo `auri.ipa`: i dati restano.
```

- [ ] **Step 2: Scheda dei risultati**

`docs/fase0-risultati.md`:
```markdown
# Fase 0: risultati

## Installazione
- [ ] SideStore installato il: ____
- [ ] auri si apre
- [ ] "Firma valida fino a" mostra una data: ____
- [ ] Rinnovo manuale riuscito il: ____

## Automazione (2 settimane)
| Domenica | Rinnovo automatico riuscito? (data in "Firma valida fino a") |
|---|---|
| 1ª | |
| 2ª | |

## Trascrizione (lezione vera ≥ 60 min)
| Prova | Durata | Riavvii | Buchi evidenti? | Qualità (1–5) | Schermo spento ok? | Batteria usata | Con audio? |
|---|---|---|---|---|---|---|---|
| 1 | | | | | | | |
| 2 | | | | | | | |

## Decisione
- [ ] Trascrizione dal vivo OK → fase 2 come da progetto
- [ ] Non OK → strada A / B / C (§5.2 del documento di progetto)
```

- [ ] **Step 3: Commit**

```bash
git add docs/guide docs/fase0-risultati.md
git commit -m "docs: guida d'installazione su iPad e scheda risultati fase 0"
git push
```

- [ ] **Step 4: Consegna all'utente** (passo manuale)

Indicare all'utente il percorso di `dist/spike/auri.ipa` e della guida. Le prove sull'iPad le fa l'utente, che compila `docs/fase0-risultati.md`.
