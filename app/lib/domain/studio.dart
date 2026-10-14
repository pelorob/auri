/// Piano di studio, Pomodoro e statistiche.
library;

import 'avvisi.dart';
import 'ripasso.dart';

class PianoStudio {
  const PianoStudio({required this.totalePagine, required this.fatte, required this.giorniRimasti, required this.paginePerOggi});
  final int totalePagine;
  final int fatte;

  /// Giorni di studio da oggi (compreso) al giorno prima dell'esame.
  final int giorniRimasti;
  final int paginePerOggi;

  double get percentuale => totalePagine == 0 ? 0 : (fatte / totalePagine).clamp(0.0, 1.0);
}

PianoStudio pianoStudio({required int totalePagine, required int fatte, required DateTime oggi, required DateTime esame}) {
  final rimaste = (totalePagine - fatte).clamp(0, totalePagine);
  final giorni = giorniTra(oggi, esame);
  final perOggi = giorni <= 0 ? rimaste : (rimaste / giorni).ceil();
  return PianoStudio(totalePagine: totalePagine, fatte: fatte, giorniRimasti: giorni < 0 ? 0 : giorni, paginePerOggi: perOggi);
}

List<DateTime> giorniDiRipasso(DateTime oggi, DateTime esame) => [
  for (var i = 0; i < giorniTra(oggi, esame); i++) DateTime(oggi.year, oggi.month, oggi.day + i),
];

String formattaTimer(int secondi) => '${secondi ~/ 60}:${(secondi % 60).toString().padLeft(2, '0')}';

typedef SessioneStudio = ({int? corsoId, DateTime inizio, int minuti});

/// Minuti di studio per corso negli ultimi [giorni] giorni (oggi compreso).
Map<int, int> minutiPerCorso(Iterable<SessioneStudio> sessioni, {required DateTime oggi, required int giorni}) {
  final out = <int, int>{};
  for (final s in sessioni) {
    final fa = giorniTra(s.inizio, oggi);
    if (s.corsoId == null || fa < 0 || fa >= giorni) continue;
    out[s.corsoId!] = (out[s.corsoId!] ?? 0) + s.minuti;
  }
  return out;
}

/// Numero di revisioni per giorno negli ultimi [giorni] giorni; l'ultimo elemento è oggi.
List<int> revisioniPerGiorno(Iterable<DateTime> date, {required DateTime oggi, int giorni = 14}) {
  final conti = List<int>.filled(giorni, 0);
  for (final d in date) {
    final fa = giorniTra(d, oggi);
    if (fa >= 0 && fa < giorni) conti[giorni - 1 - fa]++;
  }
  return conti;
}

/// Id delle carte con più risposte "non la sapevo", dalla più sbagliata.
List<int> argomentiDeboli(Iterable<({int cartaId, Risposta risposta})> revisioni, {int massimo = 5}) {
  final errori = <int, int>{};
  for (final r in revisioni) {
    if (r.risposta == Risposta.nonLaSapevo) errori[r.cartaId] = (errori[r.cartaId] ?? 0) + 1;
  }
  final ordinati = errori.keys.toList()..sort((a, b) => errori[b]!.compareTo(errori[a]!));
  return ordinati.take(massimo).toList();
}
