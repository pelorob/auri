import 'package:drift/drift.dart';

import '../domain/modelli.dart';
import '../domain/notifiche_piano.dart';
import '../domain/ripasso.dart';

part 'database.g.dart';

/// Versione dello schema; i backup con versione maggiore non si possono aprire.
const kVersioneSchema = 7;

@DataClassName('Corso')
class Corsi extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().withLength(min: 1, max: 120)();
  // ignore: recursive_getters
  IntColumn get cfu => integer().check(cfu.isBiggerThanValue(0))();
  IntColumn get anno => integer().withDefault(const Constant(1))();
  IntColumn get semestre => integer().nullable()();
  TextColumn get docente => text().nullable()();
  TextColumn get colore => text().withDefault(const Constant('#5B3DE6'))();
  IntColumn get valutazione => intEnum<Valutazione>()();
}

@DataClassName('Esito')
class Esiti extends Table {
  IntColumn get corsoId => integer().references(Corsi, #id, onDelete: KeyAction.cascade)();
  IntColumn get voto => integer().nullable()();
  BoolColumn get lode => boolean().withDefault(const Constant(false))();
  DateTimeColumn get data => dateTime()();

  @override
  Set<Column> get primaryKey => {corsoId};
}

@DataClassName('Appello')
class Appelli extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get corsoId => integer().references(Corsi, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dataOra => dateTime()();
  IntColumn get tipo => intEnum<TipoAppello>()();
  TextColumn get aula => text().nullable()();
  BoolColumn get iscritta => boolean().withDefault(const Constant(false))();
  TextColumn get preavvisi => text().withDefault(const Constant(preavvisiPredefiniti))();
  TextColumn get note => text().nullable()();
}

@DataClassName('Impostazione')
class Impostazioni extends Table {
  TextColumn get chiave => text()();
  TextColumn get valore => text()();

  @override
  Set<Column> get primaryKey => {chiave};
}

@DataClassName('Documento')
class Documenti extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get corsoId => integer().references(Corsi, #id, onDelete: KeyAction.cascade)();
  TextColumn get titolo => text()();
  TextColumn get nomeFile => text()();
  IntColumn get numeroPagine => integer()();
  DateTimeColumn get importatoIl => dateTime()();
}

@DataClassName('Pagina')
class Pagine extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentoId => integer().references(Documenti, #id, onDelete: KeyAction.cascade)();
  IntColumn get numero => integer()();
  TextColumn get titolo => text()();
  TextColumn get testo => text()();
}

/// Indice di ricerca a tutto testo sulle pagine, tenuto allineato dai trigger.
const _sqlRicerca = [
  "CREATE VIRTUAL TABLE pagine_fts USING fts5(titolo, testo, content='pagine', content_rowid='id', tokenize='unicode61 remove_diacritics 2')",
  'CREATE TRIGGER pagine_ai AFTER INSERT ON pagine BEGIN '
      'INSERT INTO pagine_fts(rowid, titolo, testo) VALUES (new.id, new.titolo, new.testo); END',
  'CREATE TRIGGER pagine_ad AFTER DELETE ON pagine BEGIN '
      "INSERT INTO pagine_fts(pagine_fts, rowid, titolo, testo) VALUES ('delete', old.id, old.titolo, old.testo); END",
  'CREATE TRIGGER pagine_au AFTER UPDATE ON pagine BEGIN '
      "INSERT INTO pagine_fts(pagine_fts, rowid, titolo, testo) VALUES ('delete', old.id, old.titolo, old.testo); "
      'INSERT INTO pagine_fts(rowid, titolo, testo) VALUES (new.id, new.titolo, new.testo); END',
];

@DataClassName('Carta')
class Carte extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get corsoId => integer().references(Corsi, #id, onDelete: KeyAction.cascade)();
  IntColumn get documentoId => integer().nullable().references(Documenti, #id, onDelete: KeyAction.setNull)();
  IntColumn get pagina => integer().nullable()();
  TextColumn get fronte => text()();
  TextColumn get retro => text()();
  IntColumn get origine => intEnum<OrigineCarta>()();
  IntColumn get ripetizioni => integer().withDefault(const Constant(0))();
  IntColumn get intervallo => integer().withDefault(const Constant(0))();
  RealColumn get facilita => real().withDefault(const Constant(2.5))();
  DateTimeColumn get prossima => dateTime().nullable()();
  BoolColumn get esclusa => boolean().withDefault(const Constant(false))();
}

@DataClassName('Revisione')
class Revisioni extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cartaId => integer().references(Carte, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get data => dateTime()();
  IntColumn get risposta => intEnum<Risposta>()();
}

@DataClassName('Simulazione')
class Simulazioni extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get corsoId => integer().references(Corsi, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get data => dateTime()();
  IntColumn get domande => integer()();
  IntColumn get giuste => integer()();
  IntColumn get voto => integer()();
}

@DataClassName('Sessione')
class Sessioni extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get corsoId => integer().nullable().references(Corsi, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get inizio => dateTime()();
  IntColumn get minuti => integer()();
}

@DataClassName('PaginaStudiata')
class PagineStudiate extends Table {
  IntColumn get documentoId => integer().references(Documenti, #id, onDelete: KeyAction.cascade)();
  IntColumn get pagina => integer()();
  DateTimeColumn get data => dateTime()();

  @override
  Set<Column> get primaryKey => {documentoId, pagina};
}

@DataClassName('Tratto')
class Tratti extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentoId => integer().references(Documenti, #id, onDelete: KeyAction.cascade)();
  IntColumn get pagina => integer()();
  IntColumn get colore => integer()();
  RealColumn get spessore => real()();
  BoolColumn get evidenziatore => boolean().withDefault(const Constant(false))();
  TextColumn get punti => text()();
}

/// Domande dei quiz segnate come sbagliate: la frase da cui nascono non viene più usata.
@DataClassName('DomandaEsclusa')
class DomandeEscluse extends Table {
  IntColumn get documentoId => integer().references(Documenti, #id, onDelete: KeyAction.cascade)();
  TextColumn get frase => text()();

  @override
  Set<Column> get primaryKey => {documentoId, frase};
}

@DriftDatabase(tables: [Corsi, Esiti, Appelli, Impostazioni, Documenti, Pagine, Carte, Revisioni, Simulazioni, Sessioni, PagineStudiate, Tratti, DomandeEscluse])
class AuriDb extends _$AuriDb {
  AuriDb(super.e);

  @override
  int get schemaVersion => kVersioneSchema;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final sql in _sqlRicerca) {
        await customStatement(sql);
      }
    },
    onUpgrade: (m, da, a) async {
      if (da < 2) {
        await m.createTable(documenti);
        await m.createTable(pagine);
        for (final sql in _sqlRicerca) {
          await customStatement(sql);
        }
      }
      if (da < 3) {
        await m.createTable(carte);
        await m.createTable(revisioni);
      }
      if (da < 4) {
        await m.createTable(simulazioni);
      }
      if (da < 5) {
        await m.createTable(sessioni);
        await m.createTable(pagineStudiate);
      }
      if (da < 6) {
        await m.createTable(tratti);
      }
      if (da < 7) {
        await m.createTable(domandeEscluse);
      }
    },
    beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
