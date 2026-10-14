import 'package:auri/app/providers.dart';
import 'package:auri/app/tema.dart';
import 'package:auri/data/database.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/preferenze.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

final ora = DateTime(2026, 10, 13, 10);

Corso corso(int id, String nome, int cfu, {Valutazione v = Valutazione.voto, String colore = '#5B3DE6'}) =>
    Corso(id: id, nome: nome, cfu: cfu, anno: 1, colore: colore, valutazione: v);

Esito esito(int corsoId, int? voto, DateTime data, {bool lode = false}) => Esito(corsoId: corsoId, voto: voto, lode: lode, data: data);

final corsiEsempio = [
  CorsoConEsito(corso(1, 'Fondamenti di Informatica', 12), esito(1, 30, DateTime(2026, 2, 15), lode: true)),
  CorsoConEsito(corso(2, 'Programmazione', 9), esito(2, 29, DateTime(2026, 7, 8))),
  CorsoConEsito(corso(3, 'Economia Aziendale', 6, colore: '#FF7A2F'), esito(3, 28, DateTime(2026, 6, 24))),
  CorsoConEsito(corso(4, 'Algebra Lineare', 6, colore: '#14B8A6'), esito(4, 27, DateTime(2026, 1, 30))),
  CorsoConEsito(corso(5, 'Statistica', 6, colore: '#14B8A6'), esito(5, 26, DateTime(2026, 6, 12))),
  CorsoConEsito(corso(6, 'Fisica I', 9, colore: '#FF7A2F'), esito(6, 25, DateTime(2026, 2, 20))),
  CorsoConEsito(corso(7, 'Inglese B2', 3, v: Valutazione.idoneita, colore: '#8A87A0'), esito(7, null, DateTime(2025, 12, 10))),
  CorsoConEsito(corso(8, 'Analisi Matematica I', 12), null),
  CorsoConEsito(corso(9, 'Basi di Dati', 9, colore: '#FF7A2F'), null),
];

final appelliEsempio = [
  AppelloConCorso(
    Appello(
      id: 1,
      corsoId: 8,
      dataOra: DateTime(2026, 10, 27, 9),
      tipo: TipoAppello.scritto,
      aula: 'Aula B2',
      iscritta: true,
      preavvisi: '7@9:00,1@9:00,0@7:30',
    ),
    corsiEsempio[7].corso,
  ),
  AppelloConCorso(
    Appello(
      id: 2,
      corsoId: 9,
      dataOra: DateTime(2026, 11, 4, 10),
      tipo: TipoAppello.scritto,
      aula: 'Lab 3',
      iscritta: false,
      preavvisi: '7@9:00,1@9:00,0@7:30',
    ),
    corsiEsempio[8].corso,
  ),
];

Widget conDati(
  Widget figlio, {
  List<CorsoConEsito>? corsi,
  List<AppelloConCorso>? appelli,
  Preferenze preferenze = const Preferenze(primoAvvioFatto: true),
  DateTime? scadenza,
  List<Override> altri = const [],
}) => ProviderScope(
  overrides: [
    corsiProvider.overrideWith((ref) => Stream.value(corsi ?? corsiEsempio)),
    appelliProvider.overrideWith((ref) => Stream.value(appelli ?? appelliEsempio)),
    preferenzeProvider.overrideWith((ref) => Stream.value(preferenze)),
    orologioProvider.overrideWithValue(() => ora),
    scadenzaFirmaProvider.overrideWith((ref) async => scadenza),
    ...altri,
  ],
  child: MaterialApp(
    theme: temaAuri(),
    home: Scaffold(body: figlio),
  ),
);

Future<void> schermoIpad(WidgetTester t) async {
  t.view.physicalSize = const Size(1180, 820);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}
