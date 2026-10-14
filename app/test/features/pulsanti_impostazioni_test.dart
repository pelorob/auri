import 'dart:async';
import 'dart:io';

import 'package:auri/app/providers.dart';
import 'package:auri/app/tema.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:auri/features/impostazioni/backup_azioni.dart';
import 'package:auri/features/impostazioni/impostazioni_page.dart';
import 'package:auri/features/impostazioni/primo_avvio_page.dart';
import 'package:auri/services/backup.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

class RepoFinto extends Repository {
  RepoFinto(super.db);
  final salvate = <String, String>{};
  @override
  Future<void> salvaPreferenza(String chiave, String valore) async => salvate[chiave] = valore;
}

class SistemaFinto extends SistemaBackup {
  String? file = '/backup/auri-backup.auri';
  bool condivisa = true;
  Object? erroreCopia;
  final condivisi = <(String, Rect)>[];
  int scelte = 0;

  @override
  Future<File> creaCopia(AuriDb db) async {
    if (erroreCopia != null) throw erroreCopia!;
    return File('/tmp/auri-backup.auri');
  }

  @override
  Future<bool> condividi(File file, Rect origine) async {
    condivisi.add((file.path, origine));
    return condivisa;
  }

  @override
  Future<String?> scegliFile() async {
    scelte++;
    return file;
  }
}

class DbFinto extends DbNotifier {
  DbFinto(this.db, this.ripristinati, this.errore);
  final AuriDb db;
  final List<String> ripristinati;
  final Object? errore;
  @override
  Future<AuriDb> build() async => db;
  @override
  Future<void> ripristina(File backup) async {
    ripristinati.add(backup.path);
    if (errore != null) throw errore!;
  }
}

void main() {
  late AuriDb db;
  late RepoFinto repo;
  late SistemaFinto sistema;
  late List<String> ripristinati;
  setUp(() {
    db = AuriDb(NativeDatabase.memory());
    repo = RepoFinto(db);
    sistema = SistemaFinto();
    ripristinati = [];
  });
  tearDown(() => db.close());

  List<Override> finti({bool touchId = false, Object? erroreRipristino}) => [
    repositoryProvider.overrideWithValue(repo),
    touchIdDisponibileProvider.overrideWith((ref) async => touchId),
    sistemaBackupProvider.overrideWithValue(sistema),
    dbProvider.overrideWith(() => DbFinto(db, ripristinati, erroreRipristino)),
  ];

  Future<void> apri(WidgetTester t, {Preferenze preferenze = const Preferenze(primoAvvioFatto: true), bool touchId = false, Object? erroreRipristino}) async {
    await schermoIpad(t);
    await t.pumpWidget(
      conDati(
        const ImpostazioniPage(),
        preferenze: preferenze,
        altri: finti(touchId: touchId, erroreRipristino: erroreRipristino),
      ),
    );
    // Nell'app il database è già aperto quando si arriva qui.
    ProviderScope.containerOf(t.element(find.byType(ImpostazioniPage))).read(dbProvider);
    await t.pumpAndSettle();
  }

  Future<void> tocca(WidgetTester t, Finder f) async {
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  group('impostazioni', () {
    testWidgets('i CFU totali si scelgono con i chip', (t) async {
      await apri(t);
      await tocca(t, find.widgetWithText(ChoiceChip, '300'));
      expect(repo.salvate[Preferenze.kCfuTotali], '300');
    });

    testWidgets('il valore della lode si sceglie dai segmenti', (t) async {
      await apri(t);
      await tocca(t, find.descendant(of: find.byType(SegmentedButton<int>), matching: find.text('32')));
      expect(repo.salvate[Preferenze.kLode], '32');
    });

    testWidgets('l\'interruttore Touch ID attiva il blocco', (t) async {
      await apri(t, touchId: true);
      await tocca(t, find.byType(Switch));
      expect(repo.salvate[Preferenze.kBlocco], 'true');
    });

    testWidgets('l\'interruttore Touch ID con blocco attivo lo spegne', (t) async {
      await apri(t, touchId: true, preferenze: const Preferenze(primoAvvioFatto: true, bloccoAttivo: true));
      await tocca(t, find.byType(Switch));
      expect(repo.salvate[Preferenze.kBlocco], 'false');
    });

    testWidgets('i minuti di riblocco si scelgono dal menu', (t) async {
      await apri(t, touchId: true, preferenze: const Preferenze(primoAvvioFatto: true, bloccoAttivo: true));
      await tocca(t, find.byType(DropdownButton<int>));
      await t.tap(find.text('15 minuti').last);
      await t.pumpAndSettle();
      expect(repo.salvate[Preferenze.kMinuti], '15');
    });

    testWidgets('"Esporta backup" condivide la copia e segna la data', (t) async {
      await apri(t);
      await tocca(t, find.text('Esporta backup'));
      expect(sistema.condivisi.single.$1, '/tmp/auri-backup.auri');
      expect(sistema.condivisi.single.$2.isEmpty, isFalse); // il popover parte dal pulsante
      expect(repo.salvate.containsKey(Preferenze.kUltimoBackup), isTrue);
    });

    testWidgets('esportazione annullata: la data dell\'ultimo backup non cambia', (t) async {
      sistema.condivisa = false;
      await apri(t);
      await tocca(t, find.text('Esporta backup'));
      expect(sistema.condivisi, hasLength(1));
      expect(repo.salvate.containsKey(Preferenze.kUltimoBackup), isFalse);
    });

    testWidgets('esportazione fallita: avviso', (t) async {
      sistema.erroreCopia = const FileSystemException('disco pieno');
      await apri(t);
      await tocca(t, find.text('Esporta backup'));
      expect(find.text('Esportazione non riuscita: riprova.'), findsOneWidget);
      expect(repo.salvate, isEmpty);
    });

    testWidgets('"Ripristina backup": Annulla non tocca i dati', (t) async {
      await apri(t);
      await tocca(t, find.text('Ripristina backup'));
      expect(find.text('Ripristinare il backup?'), findsOneWidget);
      await t.tap(find.text('Annulla'));
      await t.pumpAndSettle();
      expect(ripristinati, isEmpty);
      expect(find.text('Ripristinare il backup?'), findsNothing);
    });

    testWidgets('"Ripristina backup" confermato ripristina e lo dice', (t) async {
      await apri(t);
      await tocca(t, find.text('Ripristina backup'));
      await t.tap(find.text('Ripristina'));
      await t.pumpAndSettle();
      expect(ripristinati, ['/backup/auri-backup.auri']);
      expect(find.text('Backup ripristinato'), findsOneWidget);
    });

    testWidgets('nessun file scelto: niente conferma', (t) async {
      sistema.file = null;
      await apri(t);
      await tocca(t, find.text('Ripristina backup'));
      expect(sistema.scelte, 1);
      expect(find.text('Ripristinare il backup?'), findsNothing);
    });

    testWidgets('file non valido: spiega il motivo', (t) async {
      await apri(t, erroreRipristino: const BackupNonValido('Questo file non è un backup di auri.'));
      await tocca(t, find.text('Ripristina backup'));
      await t.tap(find.text('Ripristina'));
      await t.pumpAndSettle();
      expect(find.text('Questo file non è un backup di auri.'), findsOneWidget);
    });

    testWidgets('errore durante il ripristino: rassicura che i dati sono intatti', (t) async {
      await apri(t, erroreRipristino: const FileSystemException('rotto'));
      await tocca(t, find.text('Ripristina backup'));
      await t.tap(find.text('Ripristina'));
      await t.pumpAndSettle();
      expect(find.text("Ripristino non riuscito: i tuoi dati sono rimasti com'erano."), findsOneWidget);
    });

    testWidgets('il nome segue il valore salvato (es. dopo un ripristino) ma non disturba mentre scrive', (t) async {
      await schermoIpad(t);
      final pref = StreamController<Preferenze>();
      addTearDown(pref.close);
      await t.pumpWidget(
        ProviderScope(
          overrides: [preferenzeProvider.overrideWith((ref) => pref.stream), scadenzaFirmaProvider.overrideWith((ref) async => null), ...finti()],
          child: MaterialApp(
            theme: temaAuri(),
            home: const Scaffold(body: ImpostazioniPage()),
          ),
        ),
      );
      pref.add(const Preferenze(primoAvvioFatto: true, nomeCorsoDiLaurea: 'Fisica'));
      await t.pumpAndSettle();
      final campo = find.widgetWithText(TextFormField, 'Nome del corso di laurea');
      String testo() => t.widget<EditableText>(find.descendant(of: campo, matching: find.byType(EditableText))).controller.text;
      expect(testo(), 'Fisica');

      pref.add(const Preferenze(primoAvvioFatto: true, nomeCorsoDiLaurea: 'Ingegneria Informatica'));
      await t.pumpAndSettle();
      expect(testo(), 'Ingegneria Informatica');

      await t.enterText(campo, 'Medicina ');
      expect(repo.salvate[Preferenze.kNome], 'Medicina');
      pref.add(const Preferenze(primoAvvioFatto: true, nomeCorsoDiLaurea: 'Medicina'));
      await t.pumpAndSettle();
      expect(testo(), 'Medicina ');
    });
  });

  group('primo avvio', () {
    Future<void> apriPrimo(WidgetTester t, {bool touchId = true}) async {
      await schermoIpad(t);
      await t.pumpWidget(
        conDati(
          const PrimoAvvioPage(),
          preferenze: const Preferenze(),
          altri: finti(touchId: touchId),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('tutti i passi: nome, CFU, lode e Touch ID vengono salvati', (t) async {
      await apriPrimo(t);
      await t.enterText(find.byType(TextField), '  Ingegneria Informatica ');
      await t.tap(find.widgetWithText(ChoiceChip, '300'));
      await t.pump();
      await t.tap(find.text('Avanti'));
      await t.pumpAndSettle();
      await t.tap(find.text('32'));
      await t.pump();
      await t.tap(find.text('Avanti'));
      await t.pumpAndSettle();
      await t.tap(find.byType(Switch));
      await t.pump();
      await t.tap(find.text('Inizia'));
      await t.pumpAndSettle();
      expect(repo.salvate, containsPair(Preferenze.kNome, 'Ingegneria Informatica'));
      expect(repo.salvate, containsPair(Preferenze.kCfuTotali, '300'));
      expect(repo.salvate, containsPair(Preferenze.kLode, '32'));
      expect(repo.salvate, containsPair(Preferenze.kBlocco, 'true'));
      expect(repo.salvate, containsPair(Preferenze.kPrimoAvvioFatto, 'true'));
    });

    testWidgets('senza Touch ID l\'interruttore è spento e disattivato', (t) async {
      await apriPrimo(t, touchId: false);
      await t.tap(find.text('Avanti'));
      await t.pumpAndSettle();
      await t.tap(find.text('Avanti'));
      await t.pumpAndSettle();
      expect(t.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged, isNull);
    });

    testWidgets('"Salta" tiene quello che ha già scritto', (t) async {
      await apriPrimo(t);
      await t.enterText(find.byType(TextField), 'Economia');
      await t.tap(find.widgetWithText(ChoiceChip, '120'));
      await t.pump();
      await t.tap(find.text('Avanti'));
      await t.pumpAndSettle();
      await t.tap(find.text('31'));
      await t.pump();
      await t.tap(find.text('Salta'));
      await t.pumpAndSettle();
      expect(repo.salvate, containsPair(Preferenze.kNome, 'Economia'));
      expect(repo.salvate, containsPair(Preferenze.kCfuTotali, '120'));
      expect(repo.salvate, containsPair(Preferenze.kLode, '31'));
      expect(repo.salvate, containsPair(Preferenze.kBlocco, 'false'));
      expect(repo.salvate, containsPair(Preferenze.kPrimoAvvioFatto, 'true'));
    });

    testWidgets('"Salta" subito: valori predefiniti e primo avvio finito', (t) async {
      await apriPrimo(t);
      await t.tap(find.text('Salta'));
      await t.pumpAndSettle();
      expect(repo.salvate, containsPair(Preferenze.kCfuTotali, '180'));
      expect(repo.salvate, containsPair(Preferenze.kLode, '30'));
      expect(repo.salvate, containsPair(Preferenze.kPrimoAvvioFatto, 'true'));
    });
  });
}
