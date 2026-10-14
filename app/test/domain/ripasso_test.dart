import 'package:auri/domain/ripasso.dart';
import 'package:auri/domain/slide.dart';
import 'package:flutter_test/flutter_test.dart';

const pdfOhm = {
  1: 'Legge di Ohm\nLa resistenza elettrica e’ il rapporto tra tensione e corrente.\nSi definisce resistenza R = V / I.',
  2: 'Legge di Ohm\nEsempi di circuiti in serie e in parallelo.\nLe resistenze in serie si sommano.',
  3: 'Potenza elettrica\nLa potenza e’ il prodotto di tensione e corrente.\nDefinizione: P = V * I.',
};

void main() {
  final oggi = DateTime(2026, 10, 13, 15);

  group('SM-2', () {
    const nuova = StatoCarta.nuova;

    test('prima risposta giusta: 1 giorno', () {
      final s = sm2(nuova, Risposta.giusta, oggi);
      expect(s.ripetizioni, 1);
      expect(s.intervallo, 1);
      expect(s.prossima, DateTime(2026, 10, 14));
    });

    test('seconda giusta: 6 giorni, terza: intervallo × facilità', () {
      final s1 = sm2(nuova, Risposta.giusta, oggi);
      final s2 = sm2(s1, Risposta.giusta, oggi);
      expect(s2.intervallo, 6);
      final s3 = sm2(s2, Risposta.giusta, oggi);
      expect(s3.intervallo, (6 * s2.facilita).round());
    });

    test('facilità: "facile" sale, "difficile" scende, minimo 1,3', () {
      expect(sm2(nuova, Risposta.facile, oggi).facilita, closeTo(2.6, 1e-9));
      expect(sm2(nuova, Risposta.giusta, oggi).facilita, closeTo(2.5, 1e-9));
      expect(sm2(nuova, Risposta.difficile, oggi).facilita, closeTo(2.36, 1e-9));
      var s = nuova;
      for (var i = 0; i < 20; i++) {
        s = sm2(s, Risposta.nonLaSapevo, oggi);
      }
      expect(s.facilita, 1.3);
    });

    test('"non la sapevo": si ricomincia, domani', () {
      final avanti = sm2(sm2(nuova, Risposta.giusta, oggi), Risposta.giusta, oggi);
      final s = sm2(avanti, Risposta.nonLaSapevo, oggi);
      expect(s.ripetizioni, 0);
      expect(s.intervallo, 1);
      expect(s.prossima, DateTime(2026, 10, 14));
    });

    test('da ripassare: oggi o prima', () {
      expect(daRipassare(DateTime(2026, 10, 13), oggi), isTrue);
      expect(daRipassare(DateTime(2026, 10, 12), oggi), isTrue);
      expect(daRipassare(DateTime(2026, 10, 14), oggi), isFalse);
    });
  });

  group('generazione delle carte', () {
    final carte = carteDaDocumento(pdfOhm);

    test('dalle definizioni: termine nascosto se è nel glossario', () {
      final def = carte.where((c) => c.origine == OrigineCarta.definizione).toList();
      expect(def.length, 2);
      expect(def.first.pagina, 1);
      expect(def.first.fronte, isNot(contains('Ohm')));
      expect(def.map((c) => c.fronte), anyElement(contains('____')));
    });

    test('dal glossario: termine sul fronte, frase e pagina sul retro', () {
      final t = carte.firstWhere((c) => c.origine == OrigineCarta.glossario && c.fronte == 'tensione');
      expect(t.retro, contains('tensione'));
      expect(t.retro, endsWith('(pag. 1)'));
      expect(t.pagina, 1);
    });

    test('nessun doppione e nessuna carta vuota', () {
      final fronti = carte.map((c) => c.fronte).toList();
      expect(fronti.toSet().length, fronti.length);
      expect(carte.every((c) => c.fronte.trim().isNotEmpty && c.retro.trim().isNotEmpty), isTrue);
    });

    test('"si definisce X …": nasconde X', () {
      final c = carteDaDocumento({5: 'Circuiti RC\nSi definisce costante di tempo il prodotto RC.'});
      expect(c.single.fronte, 'Si definisce ____ il prodotto RC.');
      expect(c.single.retro, 'costante di tempo');
    });

    test('"X è un …": nasconde il soggetto', () {
      final c = carteDaDocumento({7: 'Componenti\nIl condensatore è un componente che accumula carica.'});
      expect(c.single.fronte, 'Il ____ è un componente che accumula carica.');
      expect(c.single.retro, 'condensatore');
    });

    test('definizione senza termine riconoscibile: "Spiega: titolo"', () {
      final c = carteDaDocumento({3: 'Potenza elettrica\nDefinizione: P = V * I.'});
      expect(c.single.fronte, 'Spiega: Potenza elettrica');
      expect(c.single.retro, 'Definizione: P = V * I.');
    });

    test('il glossario usato è quello del dominio slide', () {
      expect(glossario(pdfOhm).map((t) => t.termine), contains('tensione'));
    });
  });
}
