import 'package:auri/domain/ripasso.dart';
import 'package:auri/domain/studio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final oggi = DateTime(2026, 10, 13, 10);
  final esame = DateTime(2026, 10, 27, 9);

  group('piano di studio', () {
    test('pagine al giorno fino al giorno prima dell\'esame', () {
      final p = pianoStudio(totalePagine: 140, fatte: 0, oggi: oggi, esame: esame);
      expect(p.giorniRimasti, 14);
      expect(p.paginePerOggi, 10);
      expect(p.percentuale, 0);
    });

    test('se resta indietro, il carico si ricalcola per eccesso', () {
      final p = pianoStudio(totalePagine: 140, fatte: 30, oggi: DateTime(2026, 10, 20), esame: esame);
      expect(p.giorniRimasti, 7);
      expect(p.paginePerOggi, 16); // 110 / 7 = 15,7 → 16
      expect(p.percentuale, closeTo(30 / 140, 1e-9));
    });

    test('giorno dell\'esame o dopo: tutto quello che manca, oggi', () {
      expect(pianoStudio(totalePagine: 50, fatte: 20, oggi: esame, esame: esame).paginePerOggi, 30);
    });

    test('tutto studiato: zero pagine, 100%', () {
      final p = pianoStudio(totalePagine: 50, fatte: 50, oggi: oggi, esame: esame);
      expect(p.paginePerOggi, 0);
      expect(p.percentuale, 1.0);
    });

    test('nessuna pagina: percentuale 0, niente divisioni per zero', () {
      expect(pianoStudio(totalePagine: 0, fatte: 0, oggi: oggi, esame: esame).percentuale, 0);
    });

    test('giorni di ripasso: da oggi al giorno prima dell\'esame', () {
      final g = giorniDiRipasso(oggi, esame);
      expect(g.length, 14);
      expect(g.first, DateTime(2026, 10, 13));
      expect(g.last, DateTime(2026, 10, 26));
    });
  });

  test('timer del Pomodoro', () {
    expect(formattaTimer(25 * 60), '25:00');
    expect(formattaTimer(65), '1:05');
    expect(formattaTimer(0), '0:00');
  });

  group('statistiche', () {
    final sessioni = [
      (corsoId: 1, inizio: DateTime(2026, 10, 12, 9), minuti: 25),
      (corsoId: 1, inizio: DateTime(2026, 10, 1, 9), minuti: 25),
      (corsoId: 2, inizio: DateTime(2026, 10, 13, 9), minuti: 50),
      (corsoId: 2, inizio: DateTime(2026, 9, 1, 9), minuti: 25),
    ];

    test('minuti per corso negli ultimi N giorni', () {
      expect(minutiPerCorso(sessioni, oggi: oggi, giorni: 7), {1: 25, 2: 50});
      expect(minutiPerCorso(sessioni, oggi: oggi, giorni: 30), {1: 50, 2: 50});
    });

    test('revisioni per giorno, ultimi 14 giorni, il più vecchio prima', () {
      final r = revisioniPerGiorno([DateTime(2026, 10, 13, 8), DateTime(2026, 10, 13, 9), DateTime(2026, 10, 11, 9), DateTime(2026, 9, 1)], oggi: oggi);
      expect(r.length, 14);
      expect(r.last, 2);
      expect(r[11], 1);
      expect(r.reduce((a, b) => a + b), 3);
    });

    test('argomenti deboli: carte con più "non la sapevo"', () {
      final d = argomentiDeboli([
        (cartaId: 1, risposta: Risposta.nonLaSapevo),
        (cartaId: 1, risposta: Risposta.nonLaSapevo),
        (cartaId: 2, risposta: Risposta.nonLaSapevo),
        (cartaId: 3, risposta: Risposta.giusta),
      ], massimo: 5);
      expect(d, [1, 2]);
    });
  });
}
