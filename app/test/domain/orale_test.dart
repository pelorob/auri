import 'package:auri/domain/orale.dart';
import 'package:auri/domain/ripasso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('domande orali dalle carte', () {
    test('glossario: "Che cos\'è …?" e risposta senza "(pag. N)"', () {
      final d = domandaOrale(fronte: 'tensione', retro: 'La tensione è la differenza di potenziale. (pag. 3)', origine: OrigineCarta.glossario);
      expect(d.domanda, "Che cos'è tensione?");
      expect(d.attesa, 'La tensione è la differenza di potenziale.');
    });
    test('definizione con buco: chiede il termine', () {
      final d = domandaOrale(fronte: 'Si definisce ____ R = V / I.', retro: 'resistenza', origine: OrigineCarta.definizione);
      expect(d.domanda, 'Quale termine manca? Si definisce … R = V / I.');
      expect(d.attesa, 'resistenza');
    });
    test('"Spiega:" resta così', () {
      final d = domandaOrale(fronte: 'Spiega: Potenza elettrica', retro: 'Definizione: P = V * I.', origine: OrigineCarta.definizione);
      expect(d.domanda, 'Spiega: Potenza elettrica');
    });
  });

  group('valutazione della risposta a voce', () {
    test('parole chiave: niente parole comuni, per radice', () {
      expect(paroleChiave('La tensione è la differenza di potenziale elettrico'), ['tension', 'differenz', 'potenzial', 'elettric']);
    });

    test('risposta completa: Ottimo', () {
      final v = valutaRisposta(
        attesa: 'La tensione è la differenza di potenziale elettrico',
        detta: 'è la differenza di potenziale elettrico, cioè la tensione',
      );
      expect(v.copertura, 1.0);
      expect(v.giudizio, Giudizio.ottimo);
      expect(v.mancanti, isEmpty);
    });

    test('risposta parziale: Quasi, con le parole mancanti', () {
      final v = valutaRisposta(attesa: 'La tensione è la differenza di potenziale elettrico', detta: 'la differenza di tensioni');
      expect(v.copertura, 0.5);
      expect(v.giudizio, Giudizio.quasi);
      expect(v.mancanti, ['potenziale', 'elettrico']);
    });

    test('risposta vuota o sbagliata: Da ripassare', () {
      expect(valutaRisposta(attesa: 'La tensione è la differenza di potenziale', detta: '').giudizio, Giudizio.daRipassare);
      expect(valutaRisposta(attesa: 'La tensione è la differenza di potenziale', detta: 'non lo so').giudizio, Giudizio.daRipassare);
    });

    test('attesa senza parole chiave (es. una formula): basta dirla per intero', () {
      final v = valutaRisposta(attesa: 'P = V * I', detta: 'p uguale v per i');
      expect(v.copertura, 0.0);
      expect(v.giudizio, Giudizio.daRipassare);
    });
  });
}
