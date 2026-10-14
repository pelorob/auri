# auri: app di studio per iPad (documento di progetto)

- **Data:** 13 ottobre 2026
- **Stato:** in revisione
- **Mockup:** [mockup/auri-mockup.html](../../../mockup/auri-mockup.html)

---

## 1. Obiettivo

Un'app personale che aiuta una studentessa universitaria a organizzare esami, voti e studio. Funziona **solo sul suo iPad**, **senza internet**, **senza costi** e **senza intelligenza artificiale in cloud**.

**Utente:** una sola persona, una studentessa universitaria.

**Successo significa:**
- l'app è installata sull'iPad e si apre ogni giorno senza problemi;
- media, base di laurea e date degli esami sono sempre corrette e aggiornate;
- le notifiche degli appelli arrivano puntuali;
- nelle fasi successive le lezioni registrate diventano testo ricercabile e materiale di ripasso.

## 2. Vincoli e decisioni prese

| Tema | Decisione | Motivo |
|---|---|---|
| Dispositivo | **Solo iPad 11ª generazione (A16, 2025)**, schermo 11" (1180×820 punti), orientamento orizzontale come principale e verticale supportato | È l'unico dispositivo che userà |
| Sblocco biometrico | **Touch ID** (tasto in alto). Questo modello **non ha Face ID** | Hardware del dispositivo |
| Tecnologia | **Flutter** (linguaggio Dart) | Si sviluppa e si prova su PC Windows, e un servizio in cloud compila la versione per iPad. Non serve un Mac |
| Installazione | **SideStore** con **Apple ID gratuito**, senza App Store | Costo zero |
| Compilazione iOS | **GitHub Actions** (Mac in cloud). Se i minuti gratuiti finiscono, **Codemagic** | Non c'è un Mac a disposizione |
| Dati | Tutti **sull'iPad**, in un database SQLite locale | Uso personale, offline, nessun GDPR |
| Server / account | **Nessuno** | Non servono |
| IA | **Nessuna IA in cloud, nessuna chiave API.** Si usano il riconoscimento vocale e la sintesi vocale **integrati in iPadOS** e algoritmi classici di analisi del testo | Decisione dell'utente |
| Lingua | Interfaccia e contenuti in **italiano**, testi rivolti all'utente al **femminile** | Utente finale |
| Stile grafico | Giovanile: viola `#5B3DE6`, lime `#D6F35B`, inchiostro `#19142E`, sfondo `#F2F1FA`. Titoli in *Bricolage Grotesque*, testo in *DM Sans*. Angoli molto arrotondati | Approvato sul mockup |

### Limiti noti di SideStore con Apple ID gratuito
- L'app va **rinnovata ogni 7 giorni**. Il rinnovo lo fa SideStore dall'iPad stesso, con due livelli di sicurezza:
  1. un'**automazione dell'app Comandi** ogni domenica alle 5:00 (iPad in carica e su Wi-Fi) che lancia "Aggiorna tutte le app" di SideStore senza chiedere conferma. Funziona in background e **non sempre riesce**: va verificata nella fase 0;
  2. un **avviso di scadenza dentro auri** (§6.6) quando l'automazione non è andata a buon fine. Basta allora aprire SideStore e toccare "Aggiorna".
- Se il rinnovo salta, l'app **non si apre** finché non viene rinnovata. **I dati non si perdono.**
- Si possono avere al massimo **3 app** installate così, e SideStore conta come una.
- La **configurazione iniziale** richiede il PC Windows una volta sola.
- I dettagli della procedura cambiano nel tempo: si segue la guida ufficiale di SideStore al momento dell'installazione.

## 3. Struttura dell'app

| Sezione | Contenuto | Fase |
|---|---|---|
| **Oggi** (Home) | Prossimo esame con conto alla rovescia, media, avanzamento CFU, prossimi appelli, ultimi voti | 1 |
| **Corsi** | Elenco dei corsi. Ogni corso raccoglie appelli, voto, poi slide, lezioni e ripasso | 1 (base), poi 2–3 |
| **Calendario** | Mese con gli esami e lista degli appelli con notifiche e stato d'iscrizione | 1 |
| **Libretto** | Voti, CFU, medie, base di laurea, simulatore "E se…", obiettivo di laurea | 1 |
| **Lezioni** | Registrazione con trascrizione dal vivo | 2 |
| **Slide** | PDF con indice, glossario, ricerca | 2 |
| **Ripasso** | Flashcard, quiz, simulazione d'esame scritta e orale, ripasso in cuffia | 3 |
| **Impostazioni** | CFU totali, valore della lode, blocco con Touch ID, preavvisi, backup | 1 |

Navigazione: **menu laterale** in orizzontale, che diventa una **barra in basso** in verticale. Le sezioni delle fasi future compaiono nel menu come "presto" finché non sono pronte.

## 4. Fasi

Ogni fase si chiude con un'app installata e usabile. **Questo documento descrive in dettaglio le fasi 0 e 1.** Le fasi 2–4 sono descritte a grandi linee e avranno ciascuna il proprio documento di progetto prima di essere sviluppate.

| Fase | Contenuto |
|---|---|
| **0: Prova tecnica** | Catena di installazione e prova della trascrizione dal vivo. Codice da buttare |
| **1: Base** | Corsi, Libretto e medie, Calendario esami con notifiche, blocco con Touch ID, backup, avviso di scadenza della firma |
| **2: Lezioni e slide** | Registrazione e trascrizione robusta, PDF, schermo diviso slide↔trascrizione, ricerca globale |
| **3: Ripasso** | Flashcard con SM-2, quiz automatici, simulazione d'esame scritta, **simulazione d'esame orale**, **ripasso in cuffia** |
| **4: Extra** | Riassunti estrattivi, piano di studio intelligente, Pomodoro, statistiche con grafici, esportazione delle schede in PDF, annotazioni con Apple Pencil |

---

## 5. Fase 0: prova tecnica

**Scopo:** prima di costruire l'app, verificare i due punti che potrebbero bloccare tutto. Il codice di questa fase è **da buttare**.

### 5.1 Catena di installazione
1. Creare un'app Flutter minima ("Ciao auri").
2. Compilarla con GitHub Actions su macOS: `flutter build ios --release --no-codesign`, poi impacchettare `Runner.app` in `Payload/` dentro un file `.ipa`.
3. Installare SideStore sull'iPad seguendo la guida ufficiale.
4. Installare il file `.ipa` con SideStore e verificare che l'app si apra.
5. Verificare che il rinnovo dei 7 giorni funzioni dall'iPad, a mano.
6. Configurare l'**automazione di Comandi** (ogni domenica alle 5:00, "Aggiorna tutte le app" di SideStore, esecuzione senza conferma) e osservarla per **2 settimane**: annotare ogni settimana se il rinnovo è avvenuto da solo.
7. Verificare che l'app di prova riesca a leggere la **data di scadenza della propria firma**, perché serve per l'avviso del §6.6.

**Superata se:** l'app si apre sull'iPad, è stato fatto almeno un rinnovo con successo e la data di scadenza viene letta correttamente. L'automazione non è un requisito per superare la fase. Se non è affidabile resta l'avviso, e si valuta il piano B (account Apple Developer).

Al termine si scrive una **guida passo passo** in italiano per l'utente: installazione di SideStore, automazione, cosa fare se l'app non si apre.

### 5.2 Trascrizione dal vivo in italiano
App di prova con un pulsante "Registra" che usa il riconoscimento vocale di iPadOS (pacchetto `speech_to_text`, preferendo il riconoscimento **sul dispositivo**) e salva insieme l'audio.

Da misurare durante una **lezione vera di almeno 60 minuti**:
- il riconoscimento si interrompe nelle pause? Il **riavvio automatico** funziona senza perdere frasi?
- la qualità del testo in italiano è sufficiente per cercare e ripassare?
- continua a **schermo spento**?
- quanta batteria consuma in un'ora?

**Superata se:** in 60 minuti si ottiene un testo continuo e leggibile, al massimo con brevi buchi nei riavvii.

**Se non è superata**, si sceglie una di queste strade prima della fase 2:
- **A:** registrare solo l'audio durante la lezione e trascriverlo dopo, sul dispositivo e a blocchi, con il riconoscimento di iPadOS applicato ai file;
- **B:** valutare un motore offline più pesante (whisper.cpp) da usare sul dispositivo;
- **C:** rinunciare alla trascrizione e tenere audio con segnalibri.

---

## 6. Fase 1: base

### 6.1 Dati

Database SQLite sull'iPad (pacchetto `drift`).

**Corso**
| Campo | Tipo | Note |
|---|---|---|
| id | intero | |
| nome | testo | obbligatorio |
| cfu | intero | > 0 |
| anno | intero | 1–6 |
| semestre | intero | 1 o 2, opzionale |
| docente | testo | opzionale |
| colore | testo (hex) | scelto da una palette di 6 colori |
| valutazione | `voto` o `idoneita` | |

**Esito** (al massimo uno per corso)
| Campo | Tipo | Note |
|---|---|---|
| corsoId | riferimento al corso | univoco |
| voto | intero 18–30 | nullo se la valutazione è a idoneità |
| lode | sì/no | solo con voto 30 |
| data | data | |

Un corso con un Esito è **superato**, senza è **da sostenere**. Lo stato non viene salvato a parte, così non può mai essere incoerente.

**Appello**
| Campo | Tipo | Note |
|---|---|---|
| id | intero | |
| corsoId | riferimento al corso | |
| dataOra | data e ora | |
| tipo | `scritto`, `orale` o `altro` | |
| aula | testo | opzionale |
| iscritta | sì/no | default no |
| preavvisi | elenco | default: 7 giorni prima alle 9:00, 1 giorno prima alle 9:00, mattina dell'esame alle 7:30 |
| note | testo | opzionale |

**Impostazioni**
| Chiave | Default |
|---|---|
| nomeCorsoDiLaurea | vuoto |
| cfuTotali | 180 |
| valoreLode | 30 (si può scegliere 30, 31, 32 o 33) |
| bloccoAttivo | no |
| minutiPrimaDelRiblocco | 5 |

### 6.2 Calcoli del libretto

In questo paragrafo "esami con voto" indica i corsi **superati** con valutazione a `voto`.

| Valore | Formula | Mostrato come |
|---|---|---|
| Media ponderata | Σ(voto × CFU) / Σ CFU degli esami con voto. Un 30 e lode vale `valoreLode` | 2 decimali, virgola (27,75) |
| Media aritmetica | Σ voto / numero di esami con voto | 2 decimali |
| Base di laurea | media ponderata × 110 / 30 | 1 decimale, "/110" |
| CFU ottenuti | Σ CFU di **tutti** i corsi superati, comprese le idoneità | intero, "/cfuTotali" |
| Simulatore "E se…" | come la media ponderata, aggiungendo un esame da sostenere con un voto ipotetico (18–30) | nuova media, differenza (+/−), nuova base |
| Media necessaria | con obiettivo *T* (100, 105 o 110): `(T × 30/110 × (CFU con voto + CFU mancanti) − Σ(voto × CFU)) / CFU mancanti`, dove CFU mancanti = cfuTotali − CFU ottenuti | 2 decimali |

**Casi limite:**
- nessun esame con voto → medie e base mostrano "—";
- media necessaria > 30 → "oltre 30", con l'invito a scegliere un obiettivo più basso;
- media necessaria < 18 → "18", cioè basta passare gli esami;
- nessun CFU mancante → la sezione obiettivo è nascosta;
- i calcoli usano numeri decimali pieni, e l'arrotondamento avviene **solo quando il numero viene mostrato**.

### 6.3 Notifiche
- Sono **notifiche locali** dell'iPad (pacchetto `flutter_local_notifications`), senza server e anche offline.
- Il permesso si chiede la prima volta che si salva un appello.
- iPadOS tiene in coda al massimo **64 notifiche**. A ogni apertura dell'app e a ogni modifica di un appello, l'app cancella e riprogramma le **60 più vicine** nel tempo.
- Testo di esempio: *"Analisi Matematica I: scritto tra 7 giorni (27 ottobre, 9:00, Aula B2)"*.
- Le notifiche di un appello passato non vengono programmate.

### 6.4 Blocco con Touch ID
- Si attiva o disattiva nelle impostazioni (pacchetto `local_auth`).
- L'app chiede lo sblocco **all'avvio** e quando torna in primo piano dopo più di `minutiPrimaDelRiblocco` minuti.
- **Ripiego con il codice dell'iPad** sempre consentito, così non si resta mai chiusi fuori.
- Se Touch ID non è configurato sull'iPad, l'opzione è disattivata e un messaggio spiega perché.

### 6.5 Backup
Con l'installazione tramite SideStore, **se l'app viene cancellata si perdono i dati**. Per questo il backup è già nella fase 1:
- **Esporta backup**: crea un file `auri-backup-AAAA-MM-GG.auri` (una copia del database) e apre il menu di condivisione di iPadOS per salvarlo su iCloud Drive, File o altrove.
- **Ripristina backup**: si sceglie un file `.auri` dall'app File. L'app chiede conferma ("sostituirà tutti i dati attuali") e poi lo ripristina.
- Una volta a settimana, se non è stato fatto un backup negli ultimi 7 giorni, compare un **promemoria in Home**.

### 6.6 Avviso di scadenza della firma
- All'avvio e a ogni ritorno in primo piano, l'app legge la **data di scadenza della propria firma** dal profilo incluso nel pacchetto (`embedded.mobileprovision`, campo `ExpirationDate`), tramite un piccolo componente nativo iOS (platform channel).
- **Mancano 3 giorni o meno** → in Home compare una scheda ben visibile: *"auri scade tra N giorni: apri SideStore e tocca Aggiorna"*.
- **Il giorno prima della scadenza alle 9:00** → notifica locale con lo stesso testo. Viene riprogrammata a ogni avvio in base alla nuova data, quindi dopo un rinnovo riuscito si sposta da sola.
- Se la data non si riesce a leggere, ad esempio con un'installazione diversa da SideStore, l'avviso semplicemente non compare.
- Nelle **Impostazioni** si vede sempre: *"Firma valida fino a: domenica 25 ottobre"*.

### 6.7 Schermate

Riferimento visivo: il mockup ([mockup/auri-mockup.html](../../../mockup/auri-mockup.html)).

**Oggi (Home)**
- Saluto con la data.
- Scheda "Prossimo esame": corso, tipo, data, ora, aula e **giorni mancanti** in grande. Senza appelli futuri: *"Nessun esame in vista: aggiungi un appello"*.
- Scheda "Media ponderata" con la base di laurea. Toccandola si apre il Libretto.
- Anello dei CFU.
- Prossimi 3 appelli ("Tutti" apre il Calendario).
- Ultimi 3 voti ("Libretto" apre il Libretto).
- Pulsante **Aggiungi**: menu con *Corso*, *Appello*, *Voto*.
- Scheda di avviso quando la firma sta per scadere (§6.6) o quando manca il backup settimanale (§6.5).
- ⚠️ La barra "Piano di ripasso 64%" del mockup appartiene alla **fase 4**: nella fase 1 non c'è.

**Corsi**
- Griglia di schede colorate: nome, CFU, stato (superato con voto, oppure prossimo appello).
- Scheda di dettaglio di un corso con i suoi dati, appelli ed esito. Si può modificare ed eliminare, con conferma.

**Libretto**
- Elenco "Superati" (con voto o "Idoneo") e "Da sostenere".
- Riquadro con medie, base di laurea e CFU.
- Simulatore **"E se…"**: si sceglie un esame da sostenere e si regola il voto con − e +.
- **Obiettivo di laurea**: tasti 100, 105, 110 e media necessaria.
- **Registra voto**: si sceglie il corso e si inseriscono voto, lode e data. Per i corsi a idoneità basta la data.

**Calendario**
- Vista mensile, con il lunedì come primo giorno, frecce per cambiare mese, oggi evidenziato ed esami in viola.
- Toccando un giorno con un esame si apre l'appello.
- A destra la lista degli appelli futuri con giorni mancanti, preavvisi e pulsante **Iscritta / Non iscritta**.
- **Nuovo appello**: si scelgono corso, data, ora, tipo, aula e preavvisi.
- ⚠️ I "giorni di ripasso" colorati del mockup appartengono alla **fase 4**.

**Blocco**: logo, icona dell'impronta, **"Sblocca con Touch ID"** e "Usa il codice dell'iPad".

**Impostazioni**: nome del corso di laurea, CFU totali, valore della lode, blocco e minuti, preavvisi predefiniti, esporta e ripristina backup, data di scadenza della firma, versione dell'app.

**Primo avvio**: tre passaggi brevi (nome del corso di laurea e CFU totali, valore della lode, attivazione del blocco sì/no), saltabili e modificabili poi dalle impostazioni.

### 6.8 Struttura del codice

```
lib/
  main.dart
  app/            tema, colori, caratteri, navigazione
  data/           database drift, tabelle, repository
  domain/         calcoli del libretto (funzioni pure, senza Flutter)
  features/
    oggi/
    corsi/
    libretto/
    calendario/
    impostazioni/
    blocco/
  services/       notifiche, touch_id, backup, scadenza_firma
ios/Runner/       componente nativo per leggere la scadenza della firma
test/
```

- **Riverpod** per lo stato.
- I **calcoli** stanno in `domain/` come funzioni pure: ricevono dati e restituiscono numeri, quindi si testano facilmente.
- Pacchetti: `drift`, `sqlite3_flutter_libs`, `flutter_riverpod`, `flutter_local_notifications`, `timezone`, `local_auth`, `share_plus`, `file_picker`, `intl` (formato italiano), `google_fonts` (con i font **inclusi nell'app**, perché è offline).

### 6.9 Gestione degli errori
- Campi obbligatori mancanti o valori non validi (CFU ≤ 0, voto fuori da 18–30): il salvataggio è bloccato e il campo mostra un messaggio chiaro.
- Lode solo con 30: con un voto diverso l'opzione è disattivata.
- Eliminazioni (corso, appello, voto) sempre con conferma. Eliminare un corso elimina anche i suoi appelli ed esiti, e lo si dice nella conferma.
- Permesso delle notifiche negato: banner nel Calendario con il pulsante "Apri impostazioni".
- Backup non valido o danneggiato: il ripristino si annulla e i dati attuali **restano intatti**.

### 6.10 Test
- **Test automatici sui calcoli** (`domain/`): media ponderata e aritmetica, lode con valori diversi, idoneità escluse dalla media ma incluse nei CFU, base di laurea, simulatore, media necessaria e tutti i casi limite del §6.2.
- **Test automatici sul database**: creazione, modifica ed eliminazione a cascata, e un esito al massimo per corso.
- **Test sulla pianificazione delle notifiche**: solo appelli futuri, massimo 60, nell'ordine giusto.
- **Test sull'avviso di scadenza**: con 4, 3, 1 e 0 giorni rimanenti e con la data non disponibile.
- **Test delle schermate** per Libretto e Home con dati di esempio.
- **Prova manuale sull'iPad** a ogni versione: installazione, Touch ID, una notifica reale, esportazione e ripristino del backup.
- Durante lo sviluppo l'interfaccia si prova anche come **app Windows** sul PC. Touch ID, notifiche e backup si provano solo sull'iPad.

---

## 7. Fasi 2–4 a grandi linee

Ognuna avrà il proprio documento di progetto prima dello sviluppo.

**Fase 2: Lezioni e slide**
- Registrazione con trascrizione dal vivo, secondo l'esito della fase 0. Continua a schermo spento, riprende dopo un'interruzione e funziona con microfoni esterni e Bluetooth.
- Audio salvato insieme al testo con i tempi, segnalibri e note.
- Importazione dei PDF dall'app File, indice automatico, glossario con YAKE, definizioni riconosciute dal testo.
- Schermo diviso: slide da un lato, trascrizione dall'altro, collegate tra loro.
- Ricerca globale con SQLite FTS5 e uno stemmer italiano, che tollera gli errori di battitura.

**Fase 3: Ripasso**
- Flashcard con ripetizione programmata SM-2.
- Quiz automatici dalle definizioni: completamento, scelta multipla, abbinamento, vero/falso.
- Simulazione d'esame scritta con timer e voto.
- **Simulazione d'esame orale**: la domanda viene letta con la sintesi vocale di iPadOS, la risposta a voce viene trascritta e confrontata con le parole chiave attese.
- **Ripasso in cuffia**: lettura ad alta voce di flashcard e definizioni.

**Fase 4: Extra**
- Riassunti estrattivi con TextRank.
- Piano di studio giornaliero che si ripianifica.
- Pomodoro.
- Statistiche con grafici.
- Esportazione delle schede di ripasso in PDF.
- Annotazioni con Apple Pencil (USB-C o 1ª generazione) sulle slide.

## 8. Fuori dal progetto

- Trovare compagni, condivisione e qualunque funzione online.
- Android, Windows e Mac come piattaforme di destinazione. Windows serve solo per lo sviluppo.
- IA in cloud e chiavi API.
- Sincronizzazione automatica con iCloud, che richiederebbe l'account Apple Developer a pagamento.
- Widget e Live Activity.
- Funzioni scartate per ora, ma aggiungibili in futuro: importazione di calendari .ics, esportazione nel Calendario di iPadOS, scadenze universitarie (tasse, iscrizioni), regole di laurea specifiche dell'ateneo, importazione del libretto da PDF, "Apri con…", formule LaTeX, importazione da Anki/CSV.

## 9. Rischi

| Rischio | Probabilità | Mitigazione |
|---|---|---|
| La trascrizione dal vivo si interrompe su lezioni lunghe | Media | Fase 0 dedicata, con strade alternative già definite (§5.2) |
| Il rinnovo di SideStore salta e l'app non si apre | Media | Automazione settimanale di Comandi + avviso di scadenza in auri (§6.6). I dati restano comunque. Se scade anche SideStore, si reinstalla dal PC. Piano B: account Apple Developer (99 $/anno), con firma valida 1 anno |
| Cambia la procedura di SideStore o di iPadOS | Media | Si segue la guida ufficiale al momento. Il backup protegge i dati |
| I minuti gratuiti di GitHub Actions per macOS finiscono | Bassa | Si compila solo per le versioni pronte. Codemagic come alternativa |
| L'app viene cancellata e si perdono i dati | Bassa | Backup nella fase 1 con promemoria settimanale |
