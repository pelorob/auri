import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/features/calendario/appello_form.dart';
import 'package:auri/features/impostazioni/impostazioni_page.dart';
import 'package:auri/features/libretto/voto_form.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

void main() {
  late AuriDb db;
  late Repository repo;
  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = Repository(db);
    await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fondamenti di Informatica', cfu: 12, valutazione: Valutazione.voto));
  });
  tearDown(() => db.close());

  testWidgets('nuovo appello: il permesso notifiche si chiede PRIMA di salvare', (t) async {
    await schermoIpad(t);
    int? appelliAlPermesso;
    await t.pumpWidget(
      conDati(
        FormAppello(corsoIniziale: corsiEsempio[0].corso),
        altri: [
          repositoryProvider.overrideWithValue(repo),
          richiestaPermessoNotificheProvider.overrideWithValue(() async {
            appelliAlPermesso = (await db.select(db.appelli).get()).length;
            return true;
          }),
        ],
      ),
    );
    await t.pump();
    await t.runAsync(() async {
      await t.tap(find.text('Salva'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await t.pump();
    expect(appelliAlPermesso, 0);
    expect((await t.runAsync(() => db.select(db.appelli).get()))!.length, 1);
  });

  testWidgets('impostazioni: si possono cambiare i preavvisi predefiniti', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const ImpostazioniPage(), altri: [repositoryProvider.overrideWithValue(repo)]));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('La mattina'));
    await t.runAsync(() async {
      await t.tap(find.text('La mattina'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    final p = await t.runAsync(() => repo.guardaPreferenze().first);
    expect(p!.preavvisi, '7@9:00,1@9:00');
  });

  testWidgets('registra voto: scegliendo un corso già superato mostra il suo voto, non 27', (t) async {
    await schermoIpad(t);
    await t.pumpWidget(conDati(const FormVoto()));
    await t.pumpAndSettle();
    await t.tap(find.byType(DropdownButtonFormField<int>));
    await t.pumpAndSettle();
    await t.tap(find.text('Programmazione').last);
    await t.pumpAndSettle();
    expect(t.widget<Text>(find.byKey(const Key('voto'))).data, '29');
  });
}
