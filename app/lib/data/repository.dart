import 'package:drift/drift.dart';

import '../domain/preferenze.dart';
import '../domain/quiz.dart';
import '../domain/ripasso.dart';
import '../domain/slide.dart';
import 'database.dart';

class CorsoConEsito {
  const CorsoConEsito(this.corso, this.esito);
  final Corso corso;
  final Esito? esito;
  bool get superato => esito != null;
}

class AppelloConCorso {
  const AppelloConCorso(this.appello, this.corso);
  final Appello appello;
  final Corso corso;
}

class DocumentoConCorso {
  const DocumentoConCorso(this.documento, this.corso);
  final Documento documento;
  final Corso corso;
}

class RisultatoRicerca {
  const RisultatoRicerca({required this.documento, required this.corso, required this.pagina, required this.estratto});
  final Documento documento;
  final Corso corso;
  final int pagina;

  /// Frase della pagina con le parole trovate tra [ e ].
  final String estratto;
}

typedef PaginaNuova = ({int numero, String titolo, String testo});

class Repository {
  Repository(this.db);
  final AuriDb db;

  Stream<List<CorsoConEsito>> guardaCorsi() {
    final q = db.select(db.corsi).join([leftOuterJoin(db.esiti, db.esiti.corsoId.equalsExp(db.corsi.id))])
      ..orderBy([OrderingTerm.asc(db.corsi.anno), OrderingTerm.asc(db.corsi.nome)]);
    return q.watch().map((righe) => [for (final r in righe) CorsoConEsito(r.readTable(db.corsi), r.readTableOrNull(db.esiti))]);
  }

  Future<int> salvaCorso(CorsiCompanion c) => db.into(db.corsi).insertOnConflictUpdate(c);

  Future<List<Documento>> documentiDelCorso(int corsoId) => (db.select(db.documenti)..where((t) => t.corsoId.equals(corsoId))).get();

  Future<void> eliminaCorso(int id) => (db.delete(db.corsi)..where((t) => t.id.equals(id))).go();

  Future<void> registraEsito(EsitiCompanion e) => db.into(db.esiti).insertOnConflictUpdate(e);

  Future<bool> haEsito(int corsoId) async => (await (db.select(db.esiti)..where((t) => t.corsoId.equals(corsoId))).getSingleOrNull()) != null;

  Future<void> eliminaEsito(int corsoId) => (db.delete(db.esiti)..where((t) => t.corsoId.equals(corsoId))).go();

  Stream<List<AppelloConCorso>> guardaAppelli() {
    final q = db.select(db.appelli).join([innerJoin(db.corsi, db.corsi.id.equalsExp(db.appelli.corsoId))])..orderBy([OrderingTerm.asc(db.appelli.dataOra)]);
    return q.watch().map((righe) => [for (final r in righe) AppelloConCorso(r.readTable(db.appelli), r.readTable(db.corsi))]);
  }

  Future<int> salvaAppello(AppelliCompanion a) => db.into(db.appelli).insertOnConflictUpdate(a);

  Future<void> eliminaAppello(int id) => (db.delete(db.appelli)..where((t) => t.id.equals(id))).go();

  Future<void> impostaIscritta(int id, bool iscritta) =>
      (db.update(db.appelli)..where((t) => t.id.equals(id))).write(AppelliCompanion(iscritta: Value(iscritta)));

  Stream<Preferenze> guardaPreferenze() => db.select(db.impostazioni).watch().map((righe) => Preferenze.daMappa({for (final r in righe) r.chiave: r.valore}));

  Future<void> salvaPreferenza(String chiave, String valore) =>
      db.into(db.impostazioni).insertOnConflictUpdate(ImpostazioniCompanion.insert(chiave: chiave, valore: valore));

  Stream<List<DocumentoConCorso>> guardaDocumenti() {
    final q = db.select(db.documenti).join([innerJoin(db.corsi, db.corsi.id.equalsExp(db.documenti.corsoId))])
      ..orderBy([OrderingTerm.asc(db.corsi.nome), OrderingTerm.asc(db.documenti.titolo)]);
    return q.watch().map((righe) => [for (final r in righe) DocumentoConCorso(r.readTable(db.documenti), r.readTable(db.corsi))]);
  }

  /// Salva documento e pagine in un'unica transazione; restituisce l'id del documento.
  Future<int> salvaDocumento(DocumentiCompanion documento, List<PaginaNuova> pagine) => db.transaction(() async {
    final id = await db.into(db.documenti).insert(documento);
    await db.batch(
      (b) => b.insertAll(db.pagine, [for (final p in pagine) PagineCompanion.insert(documentoId: id, numero: p.numero, titolo: p.titolo, testo: p.testo)]),
    );
    return id;
  });

  Future<void> eliminaDocumento(int id) => (db.delete(db.documenti)..where((t) => t.id.equals(id))).go();

  Future<Documento?> documento(int id) => (db.select(db.documenti)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Pagina>> pagineDi(int documentoId) =>
      (db.select(db.pagine)
            ..where((t) => t.documentoId.equals(documentoId))
            ..orderBy([(t) => OrderingTerm.asc(t.numero)]))
          .get();

  Future<List<RisultatoRicerca>> cerca(String testoUtente, {int limite = 50}) async {
    final query = queryRicerca(testoUtente);
    if (query == null) return const [];
    final righe = await db
        .customSelect(
          "SELECT p.numero AS numero, p.documento_id AS documento, snippet(pagine_fts, 1, '[', ']', '…', 12) AS estratto "
          'FROM pagine_fts JOIN pagine p ON p.id = pagine_fts.rowid '
          'WHERE pagine_fts MATCH ? ORDER BY rank LIMIT ?',
          variables: [Variable.withString(query), Variable.withInt(limite)],
          readsFrom: {db.pagine},
        )
        .get();
    if (righe.isEmpty) return const [];
    final idDocumenti = righe.map((r) => r.read<int>('documento')).toSet();
    final documenti = {
      for (final r in await (db.select(db.documenti).join([
        innerJoin(db.corsi, db.corsi.id.equalsExp(db.documenti.corsoId)),
      ])..where(db.documenti.id.isIn(idDocumenti))).get())
        r.readTable(db.documenti).id: DocumentoConCorso(r.readTable(db.documenti), r.readTable(db.corsi)),
    };
    return [
      for (final r in righe)
        RisultatoRicerca(
          documento: documenti[r.read<int>('documento')]!.documento,
          corso: documenti[r.read<int>('documento')]!.corso,
          pagina: r.read<int>('numero'),
          estratto: r.read<String>('estratto'),
        ),
    ];
  }

  /// Carte attive (non escluse) di un corso, o di tutti i corsi se [corsoId] è null.
  Stream<List<Carta>> guardaCarte(int? corsoId) {
    final q = db.select(db.carte)..where((t) => t.esclusa.equals(false));
    if (corsoId != null) q.where((t) => t.corsoId.equals(corsoId));
    q.orderBy([(t) => OrderingTerm.asc(t.id)]);
    return q.watch();
  }

  /// Crea le carte di un documento; salta quelle con un fronte già presente nel corso. Restituisce quante ne ha create.
  Future<int> generaCarte(int documentoId) => db.transaction(() async {
    final doc = (await documento(documentoId))!;
    final pagine = await pagineDi(documentoId);
    final nuove = carteDaDocumento({for (final p in pagine) p.numero: p.testo});
    final esistenti = {for (final c in await (db.select(db.carte)..where((t) => t.corsoId.equals(doc.corsoId))).get()) c.fronte};
    var create = 0;
    for (final c in nuove) {
      if (!esistenti.add(c.fronte)) continue;
      await db
          .into(db.carte)
          .insert(
            CarteCompanion.insert(
              corsoId: doc.corsoId,
              documentoId: Value(documentoId),
              pagina: Value(c.pagina),
              fronte: c.fronte,
              retro: c.retro,
              origine: c.origine,
            ),
          );
      create++;
    }
    return create;
  });

  Future<int> salvaCarta(CarteCompanion c) => db.into(db.carte).insertOnConflictUpdate(c);

  /// Lo stato SM-2 si rilegge dal database: la [Carta] passata può essere una copia vecchia
  /// (una carta non saputa torna in coda nella stessa sessione).
  Future<void> rispondi(Carta carta, Risposta r, DateTime ora) => db.transaction(() async {
    final c = await (db.select(db.carte)..where((t) => t.id.equals(carta.id))).getSingle();
    final s = sm2(StatoCarta(ripetizioni: c.ripetizioni, intervallo: c.intervallo, facilita: c.facilita, prossima: c.prossima), r, ora);
    await (db.update(db.carte)..where((t) => t.id.equals(c.id))).write(
      CarteCompanion(ripetizioni: Value(s.ripetizioni), intervallo: Value(s.intervallo), facilita: Value(s.facilita), prossima: Value(s.prossima)),
    );
    await db.into(db.revisioni).insert(RevisioniCompanion.insert(cartaId: c.id, data: ora, risposta: r));
  });

  Future<void> escludiCarta(int id) => (db.update(db.carte)..where((t) => t.id.equals(id))).write(const CarteCompanion(esclusa: Value(true)));

  Future<void> eliminaCarta(int id) => (db.delete(db.carte)..where((t) => t.id.equals(id))).go();

  /// Testo per pagina di tutti i PDF del corso, per generare i quiz.
  Future<List<MaterialeDocumento>> materialeCorso(int corsoId) async {
    final docs = await (db.select(db.documenti)..where((t) => t.corsoId.equals(corsoId))).get();
    return [
      for (final d in docs) MaterialeDocumento(documentoId: d.id, testoPerPagina: {for (final p in await pagineDi(d.id)) p.numero: p.testo}),
    ];
  }

  /// Esclude dai quiz la frase da cui nasce una domanda strana (vale per ogni tipo di domanda).
  Future<void> escludiDomanda(int documentoId, String frase) =>
      db.into(db.domandeEscluse).insertOnConflictUpdate(DomandeEscluseCompanion.insert(documentoId: documentoId, frase: frase));

  Future<Set<(int, String)>> domandeEscluse() async => {for (final d in await db.select(db.domandeEscluse).get()) (d.documentoId, d.frase)};

  /// Data dell'ultimo ripasso di ogni carta che ne ha almeno uno.
  Future<Map<int, DateTime>> ultimiRipassi() async {
    final ultima = db.revisioni.data.max();
    final righe = await (db.selectOnly(db.revisioni)
          ..addColumns([db.revisioni.cartaId, ultima])
          ..groupBy([db.revisioni.cartaId]))
        .get();
    return {for (final r in righe) r.read(db.revisioni.cartaId)!: r.read(ultima)!};
  }

  Future<int> salvaSimulazione({required int corsoId, required DateTime data, required int domande, required int giuste, required int voto}) =>
      db.into(db.simulazioni).insert(SimulazioniCompanion.insert(corsoId: corsoId, data: data, domande: domande, giuste: giuste, voto: voto));

  Stream<List<Simulazione>> guardaSimulazioni(int? corsoId) {
    final q = db.select(db.simulazioni);
    if (corsoId != null) q.where((t) => t.corsoId.equals(corsoId));
    q.orderBy([(t) => OrderingTerm.asc(t.data)]);
    return q.watch();
  }

  Future<int> salvaSessione({required int? corsoId, required DateTime inizio, required int minuti}) =>
      db.into(db.sessioni).insert(SessioniCompanion.insert(corsoId: Value(corsoId), inizio: inizio, minuti: minuti));

  Stream<List<Sessione>> guardaSessioni() => (db.select(db.sessioni)..orderBy([(t) => OrderingTerm.asc(t.inizio)])).watch();

  Future<void> segnaStudiata(int documentoId, int pagina, bool studiata, DateTime ora) async {
    if (studiata) {
      await db.into(db.pagineStudiate).insertOnConflictUpdate(PagineStudiateCompanion.insert(documentoId: documentoId, pagina: pagina, data: ora));
    } else {
      await (db.delete(db.pagineStudiate)..where((t) => t.documentoId.equals(documentoId) & t.pagina.equals(pagina))).go();
    }
  }

  Stream<List<PaginaStudiata>> guardaPagineStudiate() => db.select(db.pagineStudiate).watch();

  /// Pagine dei PDF di ogni corso.
  Future<Map<int, int>> pagineTotaliPerCorso() async {
    final out = <int, int>{};
    for (final d in await db.select(db.documenti).get()) {
      out[d.corsoId] = (out[d.corsoId] ?? 0) + d.numeroPagine;
    }
    return out;
  }

  Stream<List<Revisione>> guardaRevisioni() => (db.select(db.revisioni)..orderBy([(t) => OrderingTerm.asc(t.data)])).watch();

  Future<int> salvaTratto({
    required int documentoId,
    required int pagina,
    required int colore,
    required double spessore,
    required bool evidenziatore,
    required String punti,
  }) => db
      .into(db.tratti)
      .insert(
        TrattiCompanion.insert(documentoId: documentoId, pagina: pagina, colore: colore, spessore: spessore, evidenziatore: Value(evidenziatore), punti: punti),
      );

  Stream<List<Tratto>> guardaTratti(int documentoId) => (db.select(db.tratti)..where((t) => t.documentoId.equals(documentoId))).watch();

  Future<void> eliminaTratto(int id) => (db.delete(db.tratti)..where((t) => t.id.equals(id))).go();

  /// Sostituisce il testo di una pagina (es. letto con l'OCR); titolo e ricerca si aggiornano.
  /// Testo letto con l'OCR. Il titolo si ricava dal testo solo se la pagina non ne aveva già uno
  /// (quelli presi dai segnalibri del PDF restano).
  Future<void> aggiornaTestoPagina(int documentoId, int numero, String testo) async {
    final dove = db.pagine.documentoId.equals(documentoId) & db.pagine.numero.equals(numero);
    final attuale = await (db.select(db.pagine)..where((_) => dove)).getSingleOrNull();
    final senzaTitolo = attuale == null || attuale.titolo.trim().isEmpty;
    await (db.update(db.pagine)..where((_) => dove)).write(
      PagineCompanion(testo: Value(testo), titolo: senzaTitolo ? Value(titoloPagina(testo)) : const Value.absent()),
    );
  }
}
