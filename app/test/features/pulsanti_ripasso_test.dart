import 'dart:async';
import 'dart:math';

import 'package:auri/app/providers.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/quiz.dart';
import 'package:auri/domain/ripasso.dart';
import 'package:auri/domain/slide.dart';
import 'package:auri/features/ripasso/cuffia_page.dart';
import 'package:auri/features/ripasso/orale_page.dart';
import 'package:auri/features/ripasso/ripasso_page.dart';
import 'package:auri/features/ripasso/sessione_ripasso_page.dart';
import 'package:auri/features/ripasso/simulazione_page.dart';
import 'package:auri/services/voce.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/esempio.dart';

/// Repository vero, ma con risposte ed esclusioni che si possono tenere in sospeso.
class _RepoLento extends Repository {
  _RepoLento(super.db);
  Completer<void>? bloccoRisposta;
  Completer<void>? bloccoDomanda;
  final escluseOra = <String>[];

  @override
  Future<void> rispondi(Carta carta, Risposta r, DateTime ora) async {
    await bloccoRisposta?.future;
    return super.rispondi(carta, r, ora);
  }

  @override
  Future<void> escludiDomanda(int documentoId, String frase) async {
    escluseOra.add(frase);
    await bloccoDomanda?.future;
  }
}

class _Voce implements Voce {
  final dette = <String>[];
  Completer<void>? bloccoFerma;
  @override
  Future<void> parla(String testo) async => dette.add(testo);
  @override
  Future<void> ferma() => bloccoFerma?.future ?? Future.value();
}

class _Ascolto implements Ascolto {
  _Ascolto(this.risposta, {this.permesso = true});
  final String risposta;
  final bool permesso;
  var iniziato = false;
  @override
  Future<bool> prepara() async => permesso;
  @override
  Future<void> inizia(void Function(String) aggiornamento) async {
    iniziato = true;
    aggiornamento(risposta);
  }

  @override
  Future<String> fine() async => risposta;
  @override
  Future<void> annulla() async {}
}

const _testi = [
  'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  'Legge di Ohm\nLa corrente elettrica scorre nei circuiti in serie.\nLe resistenze in serie si sommano.',
  'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
  'Circuiti\nIl condensatore è un componente che accumula carica nei circuiti.\nLa tensione ai capi del condensatore cresce.',
];

void main() {
  late AuriDb db;
  late _RepoLento repo;
  late int fisica;
  late int chimica;
  late List<CorsoConEsito> corsiDb;
  late _Voce voce;

  const domandaA = 'Unità della resistenza?';

  setUp(() async {
    db = AuriDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = _RepoLento(db);
    voce = _Voce();
    fisica = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Fisica II', cfu: 9, valutazione: Valutazione.voto));
    chimica = await repo.salvaCorso(CorsiCompanion.insert(nome: 'Chimica', cfu: 6, valutazione: Valutazione.voto));
    await repo.salvaCarta(CarteCompanion.insert(corsoId: fisica, fronte: domandaA, retro: 'ohm', origine: OrigineCarta.manuale));
    await repo.salvaCarta(
      CarteCompanion.insert(corsoId: fisica, fronte: 'Carta di domani', retro: 'x', origine: OrigineCarta.manuale, prossima: Value(DateTime(2026, 10, 20))),
    );
    corsiDb = await repo.guardaCorsi().first;
  });
  tearDown(() => db.close());

  Widget app(Widget w, {Ascolto? ascolto}) => conDati(
    w,
    corsi: corsiDb,
    altri: [
      repositoryProvider.overrideWithValue(repo),
      carteProvider.overrideWith((ref) => repo.guardaCarte(null)),
      documentiProvider.overrideWith((ref) => repo.guardaDocumenti()),
      casoProvider.overrideWithValue(() => Random(42)),
      voceProvider.overrideWithValue(voce),
      ascoltoProvider.overrideWithValue(ascolto ?? _Ascolto('ohm')),
    ],
  );

  /// Pagina di partenza con un pulsante che apre [pagina]: serve per verificare "Chiudi".
  Widget daAprire(Widget pagina) => Builder(
    builder: (context) => TextButton(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => pagina)),
      child: const Text('apri'),
    ),
  );

  Future<void> attendi(WidgetTester t) async {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await t.pump();
  }

  /// Tocca e lascia lavorare il database.
  Future<void> tocca(WidgetTester t, Finder f) async {
    await t.runAsync(() async {
      await t.tap(f);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await t.pump();
  }

  Future<void> apriPagina(WidgetTester t) async {
    await t.tap(find.text('apri'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await attendi(t);
  }

  Future<Carta> cartaDb(WidgetTester t, String fronte) async => (await t.runAsync(() => db.select(db.carte).get()))!.firstWhere((c) => c.fronte == fronte);

  Future<int> nuovaCartaDiOggi(WidgetTester t, String fronte) async =>
      (await t.runAsync(() => repo.salvaCarta(CarteCompanion.insert(corsoId: fisica, fronte: fronte, retro: 'r', origine: OrigineCarta.manuale))))!;

  group('pagina Ripasso', () {
    testWidgets('"Ripassa tutto" apre la sessione di tutti i corsi', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(const RipassoPage()));
      await attendi(t);
      await t.tap(find.text('Ripassa tutto'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      await attendi(t);
      final s = t.widget<SessioneRipassoPage>(find.byType(SessioneRipassoPage));
      expect(s.corsoId, isNull);
      expect(find.text(domandaA), findsOneWidget);
    });

    testWidgets('"Nuova carta": corso, fronte, retro e Salva creano la carta', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(const RipassoPage()));
      await attendi(t);
      await t.tap(find.widgetWithText(FilledButton, 'Nuova carta'));
      await t.pumpAndSettle();
      await t.tap(find.byType(DropdownButtonFormField<int>));
      await t.pumpAndSettle();
      await t.tap(find.text('Chimica').last);
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'Domanda (fronte)'), '  Simbolo del sodio?  ');
      await t.enterText(find.widgetWithText(TextField, 'Risposta (retro)'), 'Na');
      await tocca(t, find.text('Salva'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Carta creata'), findsOneWidget);
      final c = await cartaDb(t, 'Simbolo del sodio?');
      expect(c.corsoId, chimica);
      expect(c.retro, 'Na');
      expect(c.origine, OrigineCarta.manuale);
    });

    testWidgets('"Nuova carta": Annulla non crea niente', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(const RipassoPage()));
      await attendi(t);
      await t.tap(find.widgetWithText(FilledButton, 'Nuova carta'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'Domanda (fronte)'), 'Domanda');
      await t.enterText(find.widgetWithText(TextField, 'Risposta (retro)'), 'Risposta');
      await tocca(t, find.text('Annulla'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect((await t.runAsync(() => db.select(db.carte).get()))!.length, 2);
    });

    testWidgets('"Nuova carta" senza risposta: avviso e la finestra resta aperta', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(const RipassoPage()));
      await attendi(t);
      await t.tap(find.widgetWithText(FilledButton, 'Nuova carta'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextField, 'Domanda (fronte)'), 'Solo la domanda');
      await tocca(t, find.text('Salva'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Scrivi la domanda e la risposta.'), findsOneWidget);
      // Quello che aveva scritto non si perde: completa e salva.
      await t.enterText(find.widgetWithText(TextField, 'Risposta (retro)'), 'Ecco');
      await tocca(t, find.text('Salva'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect((await cartaDb(t, 'Solo la domanda')).retro, 'Ecco');
    });

    for (final (tooltip, tipo) in const [('Ripasso in cuffia', CuffiaPage), ('Esame orale', OralePage)]) {
      testWidgets('icona "$tooltip" apre la sua pagina per il corso', (t) async {
        await schermoIpad(t);
        await t.pumpWidget(app(const RipassoPage()));
        await attendi(t);
        await t.tap(find.byTooltip(tooltip));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        await attendi(t);
        final pagina = t.widget(find.byType(tipo));
        expect(pagina is CuffiaPage ? pagina.corsoId : (pagina as OralePage).corsoId, fisica);
        await t.pumpWidget(const SizedBox());
      });
    }
  });

  group('sessione di ripasso', () {
    testWidgets('"Non la sapevo": la carta torna in fondo e lo stato SM-2 è salvato', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(SessioneRipassoPage(corsoId: fisica)));
      await attendi(t);
      expect(find.text('Carta 1 di 1'), findsOneWidget);
      await t.tap(find.text('Mostra risposta'));
      await t.pump();
      await tocca(t, find.text('Non la sapevo'));
      expect(find.text('Carta 2 di 2'), findsOneWidget);
      expect(find.text(domandaA), findsOneWidget);
      expect(find.text('Mostra risposta'), findsOneWidget);
      final c = await cartaDb(t, domandaA);
      expect(c.ripetizioni, 0);
      expect(c.intervallo, 1);
      expect(c.facilita, closeTo(1.96, 1e-9));
      expect(c.prossima, DateTime(2026, 10, 14));
      final r = (await t.runAsync(() => db.select(db.revisioni).get()))!;
      expect(r.single.risposta, Risposta.nonLaSapevo);
    });

    for (final (etichetta, risposta, facilita) in const [('Difficile', Risposta.difficile, 2.36), ('Facile', Risposta.facile, 2.6)]) {
      testWidgets('"$etichetta": revisione salvata e sessione finita', (t) async {
        await schermoIpad(t);
        await t.pumpWidget(app(SessioneRipassoPage(corsoId: fisica)));
        await attendi(t);
        await t.tap(find.text('Mostra risposta'));
        await t.pump();
        await tocca(t, find.text(etichetta));
        expect(find.text('Fatto!'), findsOneWidget);
        final c = await cartaDb(t, domandaA);
        expect(c.ripetizioni, 1);
        expect(c.facilita, closeTo(facilita, 1e-9));
        expect(c.prossima, DateTime(2026, 10, 14));
        expect((await t.runAsync(() => db.select(db.revisioni).get()))!.single.risposta, risposta);
      });
    }

    testWidgets('⋮ "Carta sbagliata": esclusa nel database e non più mostrata', (t) async {
      await schermoIpad(t);
      await nuovaCartaDiOggi(t, 'Seconda carta');
      await t.pumpWidget(app(SessioneRipassoPage(corsoId: fisica)));
      await attendi(t);
      final prima = find.text(domandaA).evaluate().isNotEmpty ? domandaA : 'Seconda carta';
      final seconda = prima == domandaA ? 'Seconda carta' : domandaA;
      await t.tap(find.byType(PopupMenuButton<String>));
      await t.pumpAndSettle();
      await tocca(t, find.text('Carta sbagliata, non mostrarla più'));
      await t.pumpAndSettle();
      expect((await cartaDb(t, prima)).esclusa, isTrue);
      expect(find.text(prima), findsNothing);
      expect(find.text(seconda), findsOneWidget);
      await t.tap(find.text('Mostra risposta'));
      await t.pump();
      await tocca(t, find.text('Giusta'));
      expect(find.text('Fatto!'), findsOneWidget);
      expect(find.text(prima), findsNothing);
    });

    testWidgets('⋮ "Carta sbagliata" mentre si salva una risposta: la carta esclusa non torna', (t) async {
      await schermoIpad(t);
      await nuovaCartaDiOggi(t, 'Seconda carta');
      await t.pumpWidget(app(SessioneRipassoPage(corsoId: fisica)));
      await attendi(t);
      repo.bloccoRisposta = Completer<void>();
      await t.tap(find.text('Mostra risposta'));
      await t.pump();
      await t.tap(find.text('Non la sapevo'));
      await t.pump();
      await t.tap(find.byType(PopupMenuButton<String>));
      await t.pumpAndSettle();
      await tocca(t, find.text('Carta sbagliata, non mostrarla più'));
      await t.pumpAndSettle();
      repo.bloccoRisposta!.complete();
      for (var i = 0; i < 20 && find.text('Mostra risposta').evaluate().isEmpty; i++) {
        await attendi(t);
      }
      // Fino alla fine della sessione non compare mai una carta esclusa.
      for (var i = 0; i < 5 && find.text('Mostra risposta').evaluate().isNotEmpty; i++) {
        final escluse = [
          for (final c in (await t.runAsync(() => db.select(db.carte).get()))!)
            if (c.esclusa) c.fronte,
        ];
        for (final f in escluse) {
          expect(find.text(f), findsNothing, reason: '"$f" è esclusa ma viene mostrata');
        }
        await t.tap(find.text('Mostra risposta'));
        await t.pump();
        await tocca(t, find.text('Giusta'));
        await attendi(t); // la prima risposta, partita fuori da runAsync, può tenere occupato il database
        await attendi(t);
      }
      expect(find.text('Fatto!'), findsOneWidget);
    });

    testWidgets('"Chiudi" a fine sessione torna indietro', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(daAprire(SessioneRipassoPage(corsoId: fisica))));
      await apriPagina(t);
      await t.tap(find.text('Mostra risposta'));
      await t.pump();
      await tocca(t, find.text('Giusta'));
      await t.tap(find.text('Chiudi'));
      await t.pumpAndSettle();
      expect(find.byType(SessioneRipassoPage), findsNothing);
      expect(find.text('apri'), findsOneWidget);
    });
  });

  group('simulazione', () {
    Future<void> conPdf(WidgetTester t) => t.runAsync(
      () => repo.salvaDocumento(
        DocumentiCompanion.insert(corsoId: fisica, titolo: 'Elettricità', nomeFile: 'a.pdf', numeroPagine: 4, importatoIl: DateTime(2026, 10, 13)),
        [for (var i = 0; i < 4; i++) (numero: i + 1, titolo: titoloPagina(_testi[i]), testo: _testi[i])],
      ),
    );

    List<Domanda> attese(int quante) => generaQuiz(
      [
        MaterialeDocumento(documentoId: 1, testoPerPagina: {for (var i = 0; i < 4; i++) i + 1: _testi[i]}),
      ],
      quante: quante,
      caso: Random(42),
    );

    testWidgets('"Chiudi" sul risultato torna indietro', (t) async {
      await schermoIpad(t);
      await conPdf(t);
      await t.pumpWidget(app(daAprire(SimulazionePage(corsoId: fisica, quante: 2))));
      await apriPagina(t);
      await t.tap(find.byKey(const ValueKey('opzione-1-0')));
      await t.pump();
      await t.tap(find.byKey(const ValueKey('opzione-2-0')));
      await attendi(t);
      await t.tap(find.text('Chiudi'));
      await t.pumpAndSettle();
      expect(find.byType(SimulazionePage), findsNothing);
      expect(find.text('apri'), findsOneWidget);
    });

    testWidgets('bandierina toccata due volte: una sola domanda esclusa', (t) async {
      await schermoIpad(t);
      await conPdf(t);
      await t.pumpWidget(app(SimulazionePage(corsoId: fisica, quante: 3)));
      await attendi(t);
      repo.bloccoDomanda = Completer<void>();
      await t.tap(find.text('Domanda sbagliata, non mostrarla più'));
      await t.pump();
      await t.tap(find.text('Domanda sbagliata, non mostrarla più'));
      await t.pump();
      repo.bloccoDomanda!.complete();
      await t.pump();
      expect(repo.escluseOra.length, 1);
      expect(find.text('DOMANDA 1 DI 2'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('bandierina e poi risposta prima che finisca il salvataggio: risposte non sfasate', (t) async {
      await schermoIpad(t);
      await conPdf(t);
      final d = attese(3);
      await t.pumpWidget(app(SimulazionePage(corsoId: fisica, quante: 3)));
      await attendi(t);
      repo.bloccoDomanda = Completer<void>();
      await t.tap(find.text('Domanda sbagliata, non mostrarla più'));
      await t.pump();
      await t.tap(find.byKey(const ValueKey('opzione-1-0')));
      await t.pump();
      repo.bloccoDomanda!.complete();
      await t.pump();
      // La domanda esclusa sparisce e la seconda diventa la prima, senza risposte attribuite.
      expect(find.text('DOMANDA 1 DI 2'), findsOneWidget);
      expect(find.text(d[1].testo.split('\n').skip(1).join('\n')), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  });

  group('cuffia', () {
    Future<void> apriCuffia(WidgetTester t) async {
      await nuovaCartaDiOggi(t, 'Seconda carta');
      await t.pumpWidget(app(CuffiaPage(corsoId: fisica, pausa: Duration.zero)));
      await attendi(t);
    }

    testWidgets('"Avanti" passa alla carta dopo, poi "Ricomincia" torna alla prima', (t) async {
      await schermoIpad(t);
      await apriCuffia(t);
      expect(find.text('CARTA 1 DI 2'), findsOneWidget);
      expect(find.text(domandaA), findsOneWidget);
      await t.tap(find.text('Avanti'));
      await t.pump();
      expect(find.text('CARTA 2 DI 2'), findsOneWidget);
      expect(find.text('Seconda carta'), findsOneWidget);
      await t.tap(find.text('Avanti'));
      await t.pump();
      expect(find.text('Fine delle carte'), findsOneWidget);
      await t.tap(find.text('Ricomincia'));
      await t.pump();
      expect(find.text('CARTA 1 DI 2'), findsOneWidget);
      expect(find.text(domandaA), findsOneWidget);
    });

    testWidgets('"Avanti" e uscita prima che la voce si fermi: nessun errore', (t) async {
      await schermoIpad(t);
      await apriCuffia(t);
      voce.bloccoFerma = Completer<void>();
      await t.tap(find.text('Avanti'));
      await t.pump();
      await t.pumpWidget(const SizedBox());
      voce.bloccoFerma!.complete();
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  group('esame orale', () {
    Future<void> rispondi(WidgetTester t) async {
      await t.tap(find.text('Rispondi a voce'));
      await attendi(t);
      await t.tap(find.text('Ho finito'));
      await attendi(t);
    }

    testWidgets('"Rileggi la domanda" la legge di nuovo', (t) async {
      await schermoIpad(t);
      await t.pumpWidget(app(OralePage(corsoId: fisica)));
      await attendi(t);
      final letta = voce.dette.single;
      await t.tap(find.byTooltip('Rileggi la domanda'));
      await t.pump();
      expect(voce.dette, [letta, letta]);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('"Prossima domanda" e "Chiudi" alla fine', (t) async {
      await schermoIpad(t);
      await nuovaCartaDiOggi(t, 'Seconda carta');
      await t.pumpWidget(app(daAprire(OralePage(corsoId: fisica))));
      await apriPagina(t);
      expect(find.text('DOMANDA 1 DI 3'), findsOneWidget);
      final primaLetta = voce.dette.single;
      await rispondi(t);
      await t.tap(find.text('Prossima domanda'));
      await attendi(t);
      expect(find.text('DOMANDA 2 DI 3'), findsOneWidget);
      expect(voce.dette.length, 2);
      expect(voce.dette.last, isNot(primaLetta));
      await rispondi(t);
      await t.tap(find.text('Prossima domanda'));
      await attendi(t);
      await rispondi(t);
      await t.tap(find.text('Prossima domanda'));
      await attendi(t);
      expect(find.text('delle parole chiave citate in media'), findsOneWidget);
      await t.tap(find.text('Chiudi'));
      await t.pumpAndSettle();
      expect(find.byType(OralePage), findsNothing);
      expect(find.text('apri'), findsOneWidget);
    });

    testWidgets('microfono negato: "Apri impostazioni" apre le impostazioni dell\'app', (t) async {
      await schermoIpad(t);
      final aperti = <Object?>[];
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), (call) async {
        aperti.add((call.arguments as Map)['url']);
        return true;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), null));
      await t.pumpWidget(app(OralePage(corsoId: fisica), ascolto: _Ascolto('', permesso: false)));
      await attendi(t);
      await t.tap(find.text('Rispondi a voce'));
      await attendi(t);
      await t.tap(find.text('Apri impostazioni'));
      await t.pump();
      expect(aperti, ['app-settings:']);
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('"Rispondi a voce" e uscita prima che la voce si fermi: nessun errore, microfono spento', (t) async {
      await schermoIpad(t);
      final ascolto = _Ascolto('ohm');
      await t.pumpWidget(app(OralePage(corsoId: fisica), ascolto: ascolto));
      await attendi(t);
      voce.bloccoFerma = Completer<void>();
      await t.tap(find.text('Rispondi a voce'));
      await t.pump();
      await t.pumpWidget(const SizedBox());
      voce.bloccoFerma!.complete();
      await t.pump();
      expect(t.takeException(), isNull);
      expect(ascolto.iniziato, isFalse);
    });
  });
}
