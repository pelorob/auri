# auri: prepararla sul tuo Mac

Le versioni nuove di auri si possono preparare direttamente sul tuo Mac: il risultato è il file **auri.ipa**, che poi installi sull'iPad con SideStore, come al solito.

La prima volta servono circa **1-2 ore**, quasi tutte di attesa (Xcode è molto grande). Le volte successive bastano **un comando e 5-10 minuti**.

---

## Cosa ti serve

- il tuo **Mac**, con almeno **40 GB liberi** e un macOS recente
- la connessione a internet (meglio il Wi-Fi di casa: si scaricano diversi GB)

---

## Parte 1: Installare Xcode (una volta sola, 30-60 minuti di attesa)

1. Apri l'**App Store** sul Mac, cerca **Xcode** e installalo. È gratis, ma pesa molto: lascialo scaricare con calma.
2. Quando ha finito, **apri Xcode** una volta. Se ti chiede di installare componenti aggiuntivi, accetta. Se ti chiede quali piattaforme vuoi, scegli **iOS**.
3. Poi puoi chiudere Xcode: non serve usarlo.

---

## Parte 2: Scaricare auri (una volta sola, 2 minuti)

Si usa il **Terminale**: lo trovi in **Launchpad** → **Altro** → **Terminale**, oppure cercandolo con Spotlight (⌘ + spazio, scrivi "Terminale").

Copia questa riga, incollala nel Terminale e premi **Invio**:

```
git clone https://github.com/pelorob/auri.git ~/auri
```

> Se il Mac chiede di installare gli "strumenti per sviluppatori da riga di comando", accetta e, quando hanno finito, ripeti il comando.

---

## Parte 3: Preparare auri.ipa (ogni volta che c'è una versione nuova)

Nel Terminale:

```
~/auri/scripts/compila-su-mac.sh
```

Lo script fa tutto da solo: controlla che non manchi niente (la prima volta installa ancora un paio di strumenti e ti può chiedere la password del Mac), scarica l'ultima versione di auri e la prepara.

Quando vedi **"Fatto: sulla Scrivania c'è auri-…ipa"**, hai finito.

> Se compare una ✗ rossa, leggi il messaggio: di solito dice cosa fare. Se non è chiaro, fai una foto dello schermo e chiedi aiuto.

---

## Parte 4: Installarla sull'iPad

1. Sul Mac, tasto destro sul file **auri-….ipa** sulla Scrivania → **Condividi** → **AirDrop** → il tuo iPad.
2. Sull'iPad, quando ti chiede con cosa aprirlo, scegli **SideStore**.
3. SideStore la installa (o aggiorna quella che hai già: **i tuoi dati restano**).

---

## Facoltativo: il giro di prova

Puoi far provare tutta l'app a un iPad "finto" (il simulatore) prima di installarla:

```
~/auri/scripts/compila-su-mac.sh --simulatore
```

Si apre il simulatore e l'app si usa da sola per qualche minuto: non toccare niente. Alla fine sulla Scrivania trovi la cartella **auri-foto-…** con le schermate.
