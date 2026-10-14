# auri: fasi 3 e 4, ripasso ed extra (documento di progetto)

- **Data:** 13 ottobre 2026
- **Stato:** approvato (l'utente ha chiesto di fare le fasi 3 e 4)
- **Documenti collegati:** [progetto principale](2026-10-13-auri-app-studio-design.md), [fase 2a slide](2026-10-13-auri-fase2a-slide-design.md)

Tutto resta **offline, gratuito e senza IA in cloud**. Le domande e i quiz nascono dal materiale importato (glossario, definizioni e testo delle slide) con regole fisse.

## Blocchi e ordine

| Blocco | Contenuto | Schema DB |
|---|---|---|
| 3a | Flashcard + SM-2 | v3: `carte` |
| 3b | Quiz automatici + simulazione scritta | v4: `simulazioni` |
| 3c | Ripasso in cuffia + esame orale | — |
| 4a | Pomodoro, piano di studio, statistiche | v5: `sessioni`, `pagine_studiate`, `revisioni` |
| 4b | Riassunti + schede PDF | — |
| 4c | Annotazioni Pencil + OCR | v6: `tratti` |

Ogni blocco si chiude con: test verdi, prova sul simulatore e compilazione per iPad.

---

## 3a: Flashcard

**Carta**: corso, documento e pagina d'origine (facoltativi), fronte, retro, origine (`glossario`, `definizione`, `manuale`), più lo stato SM-2: ripetizioni, intervallo in giorni, facilità (iniziale 2,5), prossima data, ultima revisione.

**Generazione da un PDF** (pulsante "Crea flashcard" nella pagina del documento):
- **da una definizione** che contiene un termine del glossario: fronte = la definizione con il termine sostituito da "____", retro = il termine. Se nessun termine compare: fronte = "Spiega: <titolo della pagina>", retro = la definizione;
- **da un termine del glossario**: fronte = il termine, retro = la prima riga della sua prima pagina che lo contiene, più "pag. N";
- i doppioni (stesso fronte nello stesso corso) non vengono ricreati.

**SM-2** (versione standard). Risposte: "Non la sapevo" = 1, "Difficile" = 3, "Giusta" = 4, "Facile" = 5.
- Con qualità < 3: ripetizioni = 0, intervallo = 1.
- Altrimenti: 1ª ripetizione → 1 giorno, 2ª → 6 giorni, poi intervallo × facilità (arrotondato).
- Facilità += 0,1 − (5 − q)(0,08 + (5 − q) × 0,02), con minimo 1,3.

**Schermata Ripasso** (la voce del menu non è più "presto"): per ogni corso le carte **da ripassare oggi** e il totale, il pulsante **Ripassa** (carta che si gira con un tocco, poi i 4 pulsanti) e il pulsante **Nuova carta**.

## 3b: Quiz e simulazione scritta

**Tipi di domanda**, generati con un seme casuale (riproducibile nei test):
- **Scelta multipla**: "Quale termine completa la frase?" Si usa una frase della slide che contiene un termine del glossario, con il termine tolto. Il termine giusto è mescolato con 3 termini del glossario dello stesso corso.
- **Vero/falso**: una definizione presa così com'è (vero) oppure con il termine sostituito da un altro termine del glossario (falso).
- **Completamento**: una definizione con il termine nascosto, risposta da scegliere fra 4.

**Simulazione d'esame scritta**: si scelgono il corso e il numero di domande (10, 20 o 30). Il timer è di 1 minuto per domanda. Alla fine:
- **voto = arrotondato(30 × giuste / totale)**, con "Non superato" se sotto 18;
- elenco degli errori con la pagina della slide da ripassare;
- il risultato viene salvato in `simulazioni` (corso, data, domande, giuste, voto).

Servono almeno **4 termini nel glossario del corso**. Se sono meno, compare il messaggio "Importa più slide per generare un quiz".

## 3c: Voce

- **Sintesi vocale** con `flutter_tts` (voce italiana di iPadOS, offline).
- **Ripasso in cuffia**: legge il fronte, aspetta 4 secondi, legge il retro e passa alla carta successiva. Pulsanti Play/Pausa/Avanti. Si ferma quando finiscono le carte da ripassare.
- **Esame orale**: legge una domanda ("Che cos'è la *X*?" dal glossario, oppure "Spiega: *titolo*" da una definizione). Poi ascolta la risposta con `speech_to_text` (it_IT, sul dispositivo) e la confronta con le **parole chiave attese**, cioè le parole non comuni della risposta corretta, confrontate per radice.
  - **Copertura** = parole chiave citate / parole chiave attese.
  - Giudizio: ≥ 70% "Ottimo", ≥ 40% "Quasi", altrimenti "Da ripassare".
  - Si vede anche quali parole mancano.
- Se il permesso del microfono viene negato: messaggio e pulsante per aprire le impostazioni.

## 4a: Pomodoro, piano di studio, statistiche

**Pomodoro**: 25 minuti di studio e 5 di pausa (modificabili 15–50 / 5–15), legato a un corso. A fine fase arriva una notifica locale (riservate le notifiche con id 900000–900099). Ogni sessione completata viene salvata in `sessioni` (corso, inizio, minuti).

**Piano di studio** per il prossimo esame di ogni corso:
- totale = pagine dei PDF del corso; fatte = pagine segnate come studiate (`pagine_studiate`);
- **pagine per oggi = arrotondato per eccesso((totale − fatte) / giorni rimasti prima dell'esame)**, dove il giorno dell'esame è escluso;
- se resta indietro, il conto si rifà da solo ogni giorno;
- nella pagina del documento, pulsante **"Ho studiato questa pagina"**;
- in **Home**, sulla scheda del prossimo esame, la barra "Piano di ripasso N%" e "Oggi: X pagine";
- nel **Calendario**, i giorni di ripasso fino all'esame sono colorati.

**Statistiche** (nuova voce del menu):
- minuti di studio per corso, ultimi 7 e 30 giorni (barre);
- carte ripassate per giorno, ultimi 14 giorni (registrate in `revisioni`);
- andamento delle simulazioni (voti nel tempo);
- **argomenti deboli**: le carte con più risposte "Non la sapevo".

I grafici sono widget semplici disegnati da me, senza librerie esterne.

## 4b: Riassunti e schede PDF

- **Riassunto estrattivo** di un PDF con **TextRank**: le frasi del documento sono i nodi, la somiglianza è data dalle parole in comune (per radice, senza parole comuni) normalizzate per la lunghezza delle frasi. Si fanno 30 iterazioni con smorzamento 0,85 e si tengono le migliori, circa il 15% delle frasi (minimo 3, massimo 25), nell'ordine originale. Si vede nella nuova scheda **"Riassunto"** della pagina del documento.
- **Scheda di ripasso in PDF** (pacchetto `pdf`, tutto in Dart): titolo, indice, riassunto, glossario e definizioni, con i colori di auri. Si condivide dal menu di sistema dell'iPad (stampa, File, iCloud Drive).

## 4c: Pencil e OCR

- **Annotazioni**: un livello di disegno sopra ogni pagina del PDF (`pageOverlaysBuilder` di pdfrx). Pulsanti penna, evidenziatore, gomma e colore. I tratti si salvano per pagina in `tratti` (punti normalizzati 0–1, quindi indipendenti dallo zoom). Con la Pencil scrive la penna, con il dito si scorre.
- **OCR** per le slide scansionate: la pagina viene trasformata in immagine con pdfrx e letta con il riconoscimento del testo sul dispositivo (Apple Vision tramite plugin, oppure ML Kit come ripiego). Si attiva con il pulsante "Leggi il testo dalle immagini" nell'avviso dei PDF senza testo. Il testo trovato entra in pagine, ricerca, glossario e quiz.

## Rischi

| Rischio | Mitigazione |
|---|---|
| Domande automatiche a volte strane | Pulsante "Domanda sbagliata, non mostrarla più" (carta o domanda esclusa) |
| La sintesi o il riconoscimento vocale non sono disponibili in italiano | Messaggio chiaro. La parte orale si verifica sull'iPad insieme alla fase 0 |
| Plugin OCR pesante o incompatibile | Blocco per ultimo. Se crea problemi lo si rimanda senza toccare il resto |
| Schema DB che cresce | Una migrazione per blocco, ognuna con il suo test |
