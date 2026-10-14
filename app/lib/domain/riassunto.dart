/// Riassunto estrattivo con TextRank: sceglie le frasi più "centrali" del documento.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'slide.dart';

class Frase {
  const Frase(this.testo, this.pagina);
  final String testo;
  final int pagina;
}

final _fineFrase = RegExp(r'(?<=[.!?;])\s+');
final _parola = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Frasi del documento (senza il titolo di ogni pagina e senza frasi di meno di 4 parole), in ordine.
List<Frase> frasiDelDocumento(Map<int, String> testoPerPagina) {
  final out = <Frase>[];
  for (final n in testoPerPagina.keys.toList()..sort()) {
    final righe = testoPerPagina[n]!.split('\n').map((r) => r.trim()).where((r) => r.isNotEmpty).skip(1);
    for (final riga in righe) {
      for (final f in riga.split(_fineFrase)) {
        if (_parola.allMatches(f).length >= 4) out.add(Frase(f.trim(), n));
      }
    }
  }
  return out;
}

int frasiPerRiassunto(int totale) => totale <= 3 ? totale : (totale * 0.15).round().clamp(3, 25);

Set<String> _radici(String frase) => {
  for (final m in _parola.allMatches(frase.toLowerCase()))
    if (!paroleVuote.contains(m[0]) && m[0]!.length > 2) radice(m[0]!),
};

List<Frase> riassunto(Map<int, String> testoPerPagina, {int? quante}) {
  final frasi = frasiDelDocumento(testoPerPagina);
  if (frasi.isEmpty) return const [];
  final n = frasi.length;
  final radici = [for (final f in frasi) _radici(f.testo)];
  // Collegamenti tra frasi con radici in comune (solo quelli che esistono, non una tabella n×n):
  // con 300 pagine le frasi sono migliaia e la tabella completa sarebbe enorme e lenta.
  final perRadice = <String, List<int>>{};
  for (var i = 0; i < n; i++) {
    if (radici[i].length < 2) continue;
    for (final r in radici[i]) {
      (perRadice[r] ??= []).add(i);
    }
  }
  final vicini = List.generate(n, (_) => <(int, double)>[]);
  final comuni = List<int>.filled(n, 0);
  for (var i = 0; i < n; i++) {
    if (radici[i].length < 2) continue;
    final toccate = <int>[];
    for (final r in radici[i]) {
      for (final j in perRadice[r]!) {
        if (j <= i) continue;
        if (comuni[j]++ == 0) toccate.add(j);
      }
    }
    for (final j in toccate) {
      final w = comuni[j] / (math.log(radici[i].length) + math.log(radici[j].length));
      vicini[i].add((j, w));
      vicini[j].add((i, w));
      comuni[j] = 0;
    }
  }
  // In array compatti: i giri qui sotto li percorrono molte volte.
  final inizio = Int32List(n + 1);
  for (var i = 0; i < n; i++) {
    inizio[i + 1] = inizio[i] + vicini[i].length;
  }
  final verso = Int32List(inizio[n]);
  final peso = Float64List(inizio[n]);
  final uscite = Float64List(n);
  for (var i = 0; i < n; i++) {
    var k = inizio[i];
    for (final (j, w) in vicini[i]) {
      verso[k] = j;
      peso[k++] = w;
      uscite[i] += w;
    }
  }
  var punteggi = Float64List(n)..fillRange(0, n, 1);
  const d = 0.85;
  for (var giro = 0; giro < 30; giro++) {
    final nuovi = Float64List(n)..fillRange(0, n, 1 - d);
    for (var j = 0; j < n; j++) {
      if (uscite[j] == 0) continue;
      final quota = d * punteggi[j] / uscite[j];
      for (var k = inizio[j]; k < inizio[j + 1]; k++) {
        nuovi[verso[k]] += peso[k] * quota;
      }
    }
    var scarto = 0.0;
    for (var i = 0; i < n; i++) {
      scarto = math.max(scarto, (nuovi[i] - punteggi[i]).abs());
    }
    punteggi = nuovi;
    if (scarto < 1e-6) break; // i punteggi non cambiano più
  }
  final k = quante ?? frasiPerRiassunto(n);
  final migliori = (List.generate(n, (i) => i)..sort((a, b) => punteggi[b].compareTo(punteggi[a]))).take(k).toList()..sort();
  return [for (final i in migliori) frasi[i]];
}
