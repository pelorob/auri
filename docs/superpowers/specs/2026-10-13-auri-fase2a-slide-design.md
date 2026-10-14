# auri: fase 2a, slide PDF (documento di progetto)

- **Data:** 13 ottobre 2026
- **Stato:** approvato (l'utente ha chiesto di partire dalla parte slide, che non dipende dalla prova di trascrizione)
- **Documento principale:** [2026-10-13-auri-app-studio-design.md](2026-10-13-auri-app-studio-design.md), §7 fase 2

## 1. Obiettivo

La studentessa importa le slide PDF dei corsi. Per ogni PDF l'app costruisce da sola un **indice**, un **glossario** e l'elenco delle **definizioni**. Una **ricerca** trova qualsiasi parola in tutte le slide.

La parte "lezioni registrate" della fase 2 resta in attesa dei risultati della fase 0.

## 2. Decisioni

| Tema | Decisione | Motivo |
|---|---|---|
| Lettura dei PDF | **pdfrx** (PDFium): visualizzatore ed estrazione del testo | Funziona offline su iPad e anche nei test sul PC (verificato) |
| Ricerca | **SQLite FTS5**, tokenizer `unicode61 remove_diacritics 2`, ricerca per **radice** (si toglie la vocale finale e si cerca il prefisso: "resistenze" → `resistenz*`) | FTS5 è incluso in SQLite (verificato) e la radice copre singolare e plurale |
| Indice | 1) la struttura del PDF (*outline*) se presente; 2) altrimenti la **prima riga di ogni pagina** come titolo, unendo le pagine consecutive con lo stesso titolo | Nelle slide il titolo è quasi sempre la prima riga |
| Glossario | Termini di 1–3 parole, **senza parole vuote italiane**, presenti in **almeno 2 pagine**, ordinati per numero di pagine e poi di occorrenze. Massimo 40 | Una versione semplice dell'idea di YAKE, senza dipendenze esterne |
| Definizioni | Frasi che contengono "Definizione", "Teorema", "Proprietà", "si definisce", "si dice", "si chiama" o "X è …" all'inizio di una riga | Le formule tipiche delle slide universitarie |
| Dove sono i file | I PDF vengono **copiati** in `Documenti/slide/` dell'app | L'originale può sparire (cartella temporanea, iCloud) |
| Backup | Il backup comprende il **database** (testi, indice, ricerca), **non i PDF** | I PDF possono pesare centinaia di MB. Sul backup si scrive "i PDF vanno reimportati" |

## 3. Dati (schema versione 2)

- **Documento**: id, corsoId (con cancellazione a cascata), titolo, nomeFile, numero di pagine, data di importazione.
- **Pagina**: id, documentoId (con cancellazione a cascata), numero, titolo, testo.
- **pagine_fts**: tabella virtuale FTS5 (testo, titolo), allineata alle pagine tramite trigger.
- **Migrazione 1 → 2**: si creano le nuove tabelle. I backup in versione 1 restano validi e vengono aggiornati all'apertura.

## 4. Schermate

- **Menu**: nuova voce **"Slide"**. "Lezioni" e "Ripasso" restano "presto".
- **Slide**: in alto un campo **Cerca nelle slide**. Sotto, i PDF raggruppati per corso. Pulsante **Importa PDF**: si sceglie il file, poi il corso.
- **Risultati della ricerca**: per ogni pagina trovata, documento, numero di pagina e **frase evidenziata**. Toccandola si apre il PDF a quella pagina.
- **Documento**: a sinistra le schede **Indice | Glossario | Definizioni**, a destra il PDF. Toccando una voce si salta alla pagina.
- **Dettaglio corso**: mostra quanti PDF ha il corso.
- **Eliminare un PDF**: con conferma, cancella file, pagine e indice.

## 5. Errori

- File non PDF, PDF protetto da password o danneggiato: messaggio "Non riesco a leggere questo PDF", nessun dato salvato.
- PDF senza testo (slide scansionate come immagini): si importa lo stesso, ma indice, glossario e ricerca restano vuoti, con l'avviso "Questo PDF contiene solo immagini: la ricerca non trova nulla" (il riconoscimento del testo è previsto nella fase 4).
- Importazione lunga: indicatore di avanzamento per pagina.

## 6. Test

- Dominio, con test automatici: radice e query di ricerca, indice da prime righe, glossario (parole vuote, almeno 2 pagine, limite), definizioni.
- Dati: migrazione 1 → 2, FTS5 allineato con inserimenti e cancellazioni, cancellazione a cascata corso → documenti → pagine.
- Importazione: PDF di prova `test/fixtures/ohm.pdf` (3 pagine) estratto con pdfrx nei test.
- Schermate: elenco, risultati della ricerca, schede del documento.
- Simulatore: aggiungere al giro completo l'importazione del PDF di prova e una ricerca.

## 7. Fuori da questa fase

Lezioni registrate e trascrizione (2b), schermo diviso slide↔trascrizione (2b), riconoscimento del testo da immagini (fase 4), annotazioni con la Pencil (fase 4), ricerca che tollera gli errori di battitura (dopo, se serve).
