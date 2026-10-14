# auri: stato del progetto (14 ottobre 2026)

Punto di ripartenza per la prossima sessione di lavoro.

## Fatto

| Fase | Contenuto | Stato |
|---|---|---|
| 1 | Corsi, Libretto e medie, Calendario con notifiche, Touch ID, backup, avviso di scadenza della firma | ✅ provata sul simulatore |
| 2a | Slide PDF: importazione, indice, glossario, definizioni, ricerca FTS5 | ✅ provata sul simulatore |
| 3a | Flashcard dalle slide più quelle manuali, SM-2 | ✅ |
| 3b | Quiz automatici, simulazione d'esame scritta | ✅ |
| 3c | Ripasso in cuffia (sintesi vocale), esame orale (riconoscimento vocale) | ✅ da provare sull'iPad |
| 4a | Sezione Studio: Pomodoro, piano di studio, statistiche; piano anche in Home e Calendario | ✅ |
| 4b | Riassunto (TextRank) e scheda di ripasso in PDF | ✅ |
| 4c | Annotazioni con Apple Pencil; OCR con Apple Vision per le slide scansionate | ✅ provata sul simulatore (Vision legge "Legge di Ohm") |

- Test: **339 superati**, nessuno saltato. Giro completo sul simulatore superato con la 0.5.0.
- Verifica di tutti i pulsanti (14/10): un inventario ha trovato circa 120 elementi interattivi. Ora ognuno ha un test che lo tocca e ne controlla l'effetto (file `test/features/pulsanti_*_test.dart`), e sono stati corretti una ventina di difetti: conferme mancanti, doppi tocchi che duplicavano, tastiera che copriva lo schermo, due esami nello stesso giorno, scheda PDF senza gestione errori, plurali sbagliati. Le parti native (condivisione, scelta file, Touch ID, Impostazioni di iOS) sono sostituite da finti nei test.
- Revisione indipendente delle fasi 2a–4c fatta il 14/10: 13 problemi trovati, **tutti corretti** con un test ciascuno. I principali:
  - SM-2 partiva da una copia vecchia della carta: una carta sbagliata e poi indovinata saltava a settimane;
  - "Ho studiato questa pagina" segnava la pagina sbagliata dopo uno scorrimento;
  - Pomodoro fermo con l'iPad bloccato e senza notifica;
  - ripasso in cuffia con due letture sovrapposte;
  - microfono acceso dopo l'uscita dall'esame orale;
  - pulsante OCR assente nei PDF solo in parte scansionati;
  - file PDF rimasti sul disco dopo l'eliminazione del corso;
  - riassunto lento sui PDF lunghi (ora circa 9 volte più veloce).
- Schema del database: **versione 7** (`domande_escluse`), con migrazioni da 1 a 7 testate.

## File per l'iPad (cartella `dist/`, non versionata)

- `dist/v0.3.0/auri.ipa`: fasi 1–3
- `dist/v0.4.0/auri.ipa`: fasi 1–4a
- `dist/v0.5.0/auri.ipa`: **tutte le fasi 1–4c, versione da installare**
- `dist/foto/galleria.html`: le 22 schermate del giro sul simulatore
- `dist/spike/auri.ipa`: app di prova della trascrizione (fase 0)


## Da fare, in ordine

1. Compilazione: `gh workflow run "Build iPad" -f runner=macos-15-intel`; prova sul simulatore: `gh workflow run simulatore.yml`. Il repository è **pubblico** dal 14/10 (storia azzerata, nessun riferimento personale), quindi Actions è gratuito. Il backup della storia vecchia è in `dist/backup-storia.bundle`. In alternativa si compila su un Mac: `docs/compilare-sul-mac.md`.
2. Da verificare sull'iPad: il volume della sintesi vocale dopo il riconoscimento vocale (la sessione audio ora viene impostata prima di ogni frase) e la notifica di fine Pomodoro.
3. **Fase 2b** (registrazione e trascrizione delle lezioni): aspetta i risultati della prova sull'iPad (`docs/fase0-risultati.md`).

## Da fare con l'iPad

Guida: `docs/guida-utente.md`
- installare SideStore e auri;
- prova della trascrizione con l'app di prova;
- verifica del rinnovo automatico durante l'uso normale: la data di scadenza in Impostazioni deve spostarsi in avanti da sola ogni settimana (se manca poco compare l'avviso in Home);
- collaudo: `docs/collaudo-fase1.md`.

## Note tecniche utili

- Flutter in `C:\Users\pellegatti\Tools\flutter\bin` (3.47.7). La piattaforma Windows è stata rimossa: lo sviluppo si fa con i test.
- I test che usano PDFium hanno il tag `pdfium` e sono esclusi sul Linux di GitHub.
- I Mac arm64 di GitHub sono spesso saturi: usare `runner=macos-15-intel`.
- Repository **pubblico**: github.com/pelorob/auri. Non scrivere nel repository dati o riferimenti personali.
- Documenti di progetto in `docs/superpowers/specs/`, piani in `docs/superpowers/plans/`.
