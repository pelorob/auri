/// Tratti a mano libera sulle slide, salvati in coordinate relative alla pagina (0–1).
library;

import 'dart:ui';

String scriviPunti(List<Offset> punti) => punti.map((p) => '${p.dx.toStringAsFixed(4)},${p.dy.toStringAsFixed(4)}').join(';');

List<Offset> leggiPunti(String testo) {
  final out = <Offset>[];
  for (final parte in testo.split(';')) {
    final xy = parte.split(',');
    if (xy.length != 2) continue;
    final x = double.tryParse(xy[0]), y = double.tryParse(xy[1]);
    if (x != null && y != null) out.add(Offset(x, y));
  }
  return out;
}

/// Toglie i punti più vicini di [distanzaMinima] al precedente tenuto (primo e ultimo restano).
List<Offset> semplifica(List<Offset> punti, {double distanzaMinima = 0.002}) {
  if (punti.length < 3) return [...punti];
  final out = [punti.first];
  for (var i = 1; i < punti.length - 1; i++) {
    if ((punti[i] - out.last).distance >= distanzaMinima) out.add(punti[i]);
  }
  out.add(punti.last);
  return out;
}

Offset normalizza(Offset punto, Rect pagina) => Offset((punto.dx - pagina.left) / pagina.width, (punto.dy - pagina.top) / pagina.height);

Offset denormalizza(Offset punto, Rect pagina) => Offset(pagina.left + punto.dx * pagina.width, pagina.top + punto.dy * pagina.height);

double _distanzaDalSegmento(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final lung2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lung2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lung2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// La gomma tocca il tratto se passa entro [raggio] da uno dei suoi segmenti.
bool toccato(List<Offset> tratto, Offset punto, {double raggio = 0.015}) {
  if (tratto.length == 1) return (tratto.first - punto).distance <= raggio;
  for (var i = 0; i < tratto.length - 1; i++) {
    if (_distanzaDalSegmento(punto, tratto[i], tratto[i + 1]) <= raggio) return true;
  }
  return false;
}
