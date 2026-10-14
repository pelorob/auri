# auri: come installarla e usarla

Ciao! Questa è **auri**, l'app che ti aiuta con esami, voti e studio.
Funziona **solo sul tuo iPad**, **senza internet** e **senza abbonamenti**. I tuoi dati restano sull'iPad.

Non passa dall'App Store, quindi l'installazione è un po' diversa dal solito. Si fa **una volta sola** e richiede circa **30 minuti**. Poi basta un piccolo controllo alla settimana, che si può anche rendere automatico.

---

## Cosa ti serve

- il tuo **iPad**
- il tuo **Mac** (oppure il PC di casa con Windows)
- il **cavo** per collegare l'iPad al PC
- il tuo **Apple ID** (email e password che usi sull'iPad)
- il file **auri.ipa**: lo prepari tu sul Mac seguendo `compilare-sul-mac.md`, oppure lo ricevi già pronto

---

## Parte 1: Preparare l'iPad (5 minuti, una volta sola)

1. Apri **Impostazioni** → **Privacy e sicurezza**.
2. Scorri fino in fondo e tocca **Modalità sviluppatore**.
3. Attivala. L'iPad chiede di riavviarsi: conferma.
4. Dopo il riavvio compare un messaggio: tocca **Attiva** e inserisci il codice dell'iPad.

> Se "Modalità sviluppatore" non c'è ancora, nessun problema: comparirà dopo la Parte 2. Torna qui a quel punto.

---

## Parte 2: Installare SideStore (20 minuti, una volta sola, con il Mac o il PC)

**SideStore** è l'app che permette di installare auri senza l'App Store.

1. Sul Mac (o sul PC) apri la guida ufficiale: **https://docs.sidestore.io** → sezione **Installation**, e scegli la versione per **macOS** (o **Windows**).
2. Segui i passaggi della guida, nell'ordine. Ti servono il cavo, l'Apple ID e, a volte, il codice dell'iPad.
3. Se la guida ti chiede di installare dall'App Store un'app "VPN" (per esempio **LocalDevVPN**), installala: serve a SideStore per funzionare senza PC nelle settimane successive.
4. Alla fine sull'iPad trovi l'app **SideStore**. Aprila ed entra con il tuo **Apple ID**.

> La guida ufficiale cambia ogni tanto: segui sempre quella. Se un passaggio non è chiaro, fermati e chiedi aiuto prima di andare avanti.

---

## Parte 3: Installare auri (2 minuti)

1. Metti il file **auri.ipa** sull'iPad: aprilo dall'email, oppure salvalo nell'app **File** (iCloud Drive).
2. Apri **SideStore** → scheda **My Apps** → tocca **+** in alto.
3. Scegli il file **auri.ipa** e aspetta che finisca.
4. Sulla schermata Home compare **auri**. Aprila!

---

## Parte 4: Il rinnovo settimanale (importante!)

Le app installate così vanno **rinnovate ogni 7 giorni**. Se te ne dimentichi auri non si apre, ma **i tuoi dati non si perdono**.

### Rinnovo automatico (fallo una volta)
1. Apri l'app **Comandi** → in basso **Automazione** → **+** (oppure **Nuova automazione**).
2. Scegli **Ora del giorno**: **5:00**, **Settimanale**, solo **domenica**.
3. Scegli **Esegui immediatamente** (non "Chiedi prima").
4. Tocca **Nuova automazione vuota** → **Aggiungi azione** → cerca **SideStore** → scegli **Refresh All** (o "Aggiorna tutte").
5. Fatto. Il sabato sera lascia l'iPad **in carica e collegato al Wi-Fi**.

### Se auri ti avvisa
Quando mancano 3 giorni alla scadenza, auri mostra in Home il messaggio **"auri scade tra N giorni"**. Fai così:
- apri **SideStore** → **My Apps** → **Refresh All**. Bastano pochi secondi.

### Se auri non si apre
- Apri **SideStore** → **My Apps** → **Refresh All**.
- Se non si apre neanche SideStore, serve il PC: rifai la Parte 2. **I dati di auri restano.**

---

## Parte 5: Il primo avvio di auri

auri ti fa 3 domande, che potrai cambiare quando vuoi da **Impostazioni**:
1. il tuo **corso di laurea** e i **CFU totali** (di solito 180 per la triennale, 120 per la magistrale);
2. **quanto vale la lode** nel tuo ateneo (di solito 30);
3. se vuoi **bloccare auri con il Touch ID** (il dito sul tasto in alto).

Quando chiede il permesso per le **notifiche**, rispondi **Consenti**: servono per gli avvisi degli esami.

---

## Come si usa: le sezioni

| Sezione | Cosa fai |
|---|---|
| **Oggi** | Vedi il prossimo esame, quanti giorni mancano, la tua media e cosa studiare oggi |
| **Corsi** | Aggiungi i tuoi corsi con **Nuovo corso** (nome, CFU, anno, se è a voto o a idoneità) |
| **Calendario** | Aggiungi gli appelli con **Nuovo**: data, ora, aula e quando avvisarti. Tocca **Iscritta** quando ti iscrivi |
| **Libretto** | Registri i voti con **Registra voto**. Con **"E se…"** provi un voto ipotetico, con **Obiettivo di laurea** vedi la media che ti serve |
| **Slide** | **Importa PDF** delle slide e scegli il corso. Puoi **cercare** una parola in tutte le slide. Aprendo un PDF trovi a sinistra **Indice, Glossario e Definizioni** |
| **Ripasso** | **Flashcard**: aprendo un PDF tocca **Crea flashcard**, poi qui tocca **Ripassa**. Ogni giorno auri ti propone quelle da ripassare. Ci sono anche **Simulazione d'esame** (quiz con voto), 🎧 **ripasso in cuffia** e 🎤 **esame orale** (rispondi a voce) |
| **Studio** | Il **Pomodoro** (25 minuti di studio e 5 di pausa), il **piano di studio** (quante pagine fare oggi per arrivare pronta all'esame) e le **statistiche** |
| **Impostazioni** | Touch ID, avvisi, **backup** |

### Un buon modo per iniziare
1. **Corsi** → aggiungi i corsi di quest'anno.
2. **Libretto** → registra i voti degli esami già fatti.
3. **Calendario** → aggiungi i prossimi appelli.
4. **Slide** → importa i PDF del prossimo esame.
5. Apri un PDF → **Crea flashcard** → in **Ripasso** tocca **Ripassa** ogni giorno.
6. Mentre studi una slide, tocca **"Ho studiato questa pagina"**: il piano in **Studio** e in **Oggi** si aggiorna.

---

## Il backup (fallo ogni settimana!)

auri tiene tutto sull'iPad. Se l'app venisse cancellata, i dati si perderebbero. Quindi:
1. **Impostazioni** → **Esporta backup**.
2. Scegli **Salva su File** → **iCloud Drive** → **Salva**.

Se dopo 7 giorni non hai fatto il backup, auri te lo ricorda in Home.

**Per recuperare i dati:** **Impostazioni** → **Ripristina backup** → scegli il file `auri-backup-…`.
> I **PDF delle slide non sono nel backup** (sono troppo grandi): dopo un ripristino vanno reimportati.

---

## Se qualcosa non va

| Problema | Cosa fare |
|---|---|
| auri non si apre | SideStore → My Apps → **Refresh All** |
| Non arrivano gli avvisi degli esami | Impostazioni dell'iPad → **auri** → **Notifiche** → attiva |
| L'esame orale non sente la voce | Impostazioni dell'iPad → **auri** → attiva **Microfono** e **Riconoscimento vocale** |
| Touch ID non funziona | Usa **"Usa il codice dell'iPad"** sotto il pulsante |
| Una flashcard è sbagliata | Durante il ripasso tocca **⋮** → **Carta sbagliata, non mostrarla più** |
| Una domanda del quiz non ha senso | Tocca **Domanda sbagliata, non mostrarla più** sotto la domanda (non conta nel voto), oppure nei risultati |
| Un PDF "contiene solo immagini" | È una scansione: la ricerca non funziona su quel PDF (lo sistemeremo più avanti) |

Per qualsiasi altro problema, annota cosa è successo (e, se puoi, fai uno **screenshot**: tasto in alto + tasto volume su).

---

## Un favore: due prove per migliorare auri

1. **Prova della registrazione in aula.** Riceverai un'altra app di prova. Durante una lezione vera tocca **Registra**, e alla fine **Ferma e salva**. Poi raccontagli: quanto era preciso il testo? Si è mai fermato? Quanta batteria ha consumato?
   > Prima di installarla fai un **backup di auri** (Impostazioni → Esporta backup), perché la prova prende il posto di auri per un po'.
2. **Il rinnovo automatico.** Per due settimane, il lunedì guarda in **auri → Impostazioni** la riga **"Firma valida fino a"**. Se la data è andata avanti di una settimana, il rinnovo automatico funziona.

Buono studio! 🎓
