# Piano C: fase 2a, slide PDF

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax. Ogni attività segue il ciclo TDD: prima il test che fallisce, poi il codice.

**Goal:** importare PDF per corso, con indice, glossario e definizioni automatici, e ricerca in tutte le slide.

**Architecture:** analisi del testo pura in `lib/domain/slide.dart`; tabelle `documenti`/`pagine` + FTS5 in drift (schema 2); servizio `ImportazioneSlide` che usa pdfrx; pagine `features/slide/`.

**Tech Stack:** pdfrx 2.6, drift + FTS5, Riverpod.

**Spec:** `docs/superpowers/specs/2026-10-13-auri-fase2a-slide-design.md`

## Global Constraints
- Testi in italiano, al femminile. Stile e colori della fase 1 (`AuriColori`, `titolo()`, `testo()`).
- Nessuna rete: tutto locale.
- `kVersioneSchema = 2`. I backup in versione 1 restano accettati.
- I PDF vengono copiati in `Documenti/slide/<id>.pdf`.

## Review Focus
1. **PDF senza testo** (immagini): importazione riuscita, indice vuoto, avviso visibile. Test nel Task 4.
2. **Query con caratteri speciali** (`"`, `*`, `-`, apostrofi) nella ricerca: nessuna eccezione FTS5, al limite nessun risultato. Test nel Task 1.
3. **Eliminare un corso con PDF**: niente pagine o righe FTS orfane. Test nel Task 2 (il file su disco va rimosso dal servizio, Task 3).
4. **Backup v1 ripristinato dopo l'aggiornamento**: migrazione a v2 all'apertura. Test nel Task 2.
5. **PDF molto lungo** (300 pagine): l'importazione mostra l'avanzamento e non blocca l'interfaccia. Il codice gestisce l'avanzamento nel Task 3. Il tempo reale si misura sull'iPad.

---

### Task 1: Analisi del testo (dominio)
**Files:** `app/lib/domain/slide.dart`, `app/test/domain/slide_test.dart`
**Produces:**
- `String radice(String parola)`: minuscolo, senza accenti, toglie la vocale finale se la parola ha più di 4 lettere ("resistenze" → "resistenz", "ohm" → "ohm").
- `String? queryRicerca(String testoUtente)`: parole → `"radice"*` unite da spazio (AND). Toglie i caratteri non alfanumerici. Restituisce null se resta vuoto.
- `List<VoceIndice> indiceDaPagine(List<String> titoliPagina)` con `VoceIndice(titolo, pagina)`: unisce le pagine consecutive uguali e salta i titoli vuoti.
- `String titoloPagina(String testo)`: prima riga non vuota, al massimo 80 caratteri.
- `List<TermineGlossario> glossario(Map<int,String> testoPerPagina, {int massimo = 40})` con `TermineGlossario(termine, pagine)`.
- `List<Definizione> definizioni(Map<int,String> testoPerPagina)` con `Definizione(testo, pagina)`.
- `const paroleVuote` (italiano).

**Test:** radice ("resistenze", "Elettrica", "ohm", "perché"); query ('legge ohm' → `"legg"* "ohm"*`, '"*-' → null, "l'energia" senza eccezioni); indice (pagine consecutive unite, vuote saltate); glossario sul PDF di prova ("resistenza" e "legge ohm" presenti, nessuna parola vuota, un termine presente in una sola pagina escluso, limite rispettato); definizioni ("Si definisce resistenza…" pagina 1, "Definizione: P = V * I." pagina 3).

### Task 2: Schema 2: documenti, pagine, FTS5
**Files:** `app/lib/data/database.dart` (tabelle `Documenti`, `Pagine`, migrazione, trigger FTS), `app/lib/data/repository.dart` (+ metodi), `app/test/data/slide_repository_test.dart`
**Produces:** `DocumentiCompanion`, `PagineCompanion`; nel Repository:
`Stream<List<DocumentoConCorso>> guardaDocumenti()`, `Future<int> salvaDocumento(DocumentiCompanion d, List<PagineCompanion> pagine)` (una transazione), `Future<void> eliminaDocumento(int id)`, `Future<List<Pagina>> pagineDi(int documentoId)`, `Future<List<RisultatoRicerca>> cerca(String testoUtente, {int limite = 50})` con `RisultatoRicerca(documento, corso, pagina, estratto)` ed estratto con `[` `]` attorno alle parole trovate.
**Test:** salva + cerca "resistenze" trova la pagina 1 e 2 (radice); estratto evidenziato; elimina documento → la ricerca non trova più nulla; elimina corso → documenti, pagine e FTS vuoti; query vuota o con soli simboli → lista vuota; migrazione: database creato con lo schema 1 (SQL scritto a mano con `user_version` 1) aperto con AuriDb → tabelle nuove presenti e dati vecchi intatti.

### Task 3: Importazione con pdfrx
**Files:** `app/lib/services/importazione_slide.dart`, `app/test/services/importazione_slide_test.dart`
**Produces:** `class ImportazioneSlide { ImportazioneSlide(Repository repo, Future<Directory> Function() cartellaSlide); Future<int> importa(File pdf, {required int corsoId, String? titolo, void Function(int fatte, int totali)? avanzamento}); Future<void> elimina(int documentoId); }` e `class PdfNonLeggibile implements Exception`.
Copia il file in `cartellaSlide/<id>.pdf` solo dopo che la lettura è riuscita. Indice dall'outline se c'è, altrimenti `indiceDaPagine`. Titolo predefinito: il nome del file senza estensione.
**Test (pdfrx sul PC, senza `pdfrxFlutterInitialize`):** importa `ohm.pdf` → 3 pagine, titoli, file copiato, avanzamento chiamato 3 volte; file non PDF → `PdfNonLeggibile`, nessun documento salvato e nessun file copiato; elimina → file rimosso e documento sparito.

### Task 4: Schermate Slide e Documento
**Files:** `app/lib/features/slide/slide_page.dart`, `app/lib/features/slide/documento_page.dart`, `app/lib/app/shell.dart` (voce "Slide"), `app/lib/app/providers.dart` (`documentiProvider`, `importazioneProvider`), `app/test/features/slide_test.dart`
**Produces:** `SlidePage` (ricerca + elenco per corso + Importa PDF), `DocumentoPage(documentoId)` (schede Indice/Glossario/Definizioni + `PdfViewer.file`), `Sezione.slide`.
**Test:** menu con "Slide"; elenco raggruppato per corso; ricerca che mostra un risultato con estratto e pagina (repository in memoria); PDF senza testo → avviso; schede del documento mostrano "Legge di Ohm" nell'indice, "resistenza" nel glossario e "Si definisce resistenza R = V / I." nelle definizioni. In questi test il visualizzatore PDF viene sostituito da un segnaposto tramite un provider, perché il widget nativo non gira nei test.

### Task 5: Collegamenti finali
**Files:** `app/lib/main.dart` (`pdfrxFlutterInitialize()`), `app/lib/features/corsi/corsi_page.dart` (numero di PDF nel dettaglio), `app/lib/features/impostazioni/impostazioni_page.dart` (nota "i PDF non sono nel backup"), `app/integration_test/app_test.dart` (importa `ohm.pdf` dagli asset di test, cerca "resistenze", foto), `app/pubspec.yaml` (asset del test di integrazione)
**Test:** suite completa più il giro sul simulatore con le foto dell'importazione e della ricerca.
