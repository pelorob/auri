/// Flashcard: ripetizione programmata (SM-2) e generazione dalle slide.
library;

import 'dart:math' as math;

import 'slide.dart';

enum Risposta {
  nonLaSapevo(1),
  difficile(3),
  giusta(4),
  facile(5);

  const Risposta(this.qualita);
  final int qualita;
}

class StatoCarta {
  const StatoCarta({required this.ripetizioni, required this.intervallo, required this.facilita, required this.prossima});
  final int ripetizioni;
  final int intervallo;
  final double facilita;
  final DateTime? prossima;

  static const nuova = StatoCarta(ripetizioni: 0, intervallo: 0, facilita: 2.5, prossima: null);
}

/// Algoritmo SM-2: nuovo stato dopo una risposta data in [ora].
StatoCarta sm2(StatoCarta s, Risposta r, DateTime ora) {
  final q = r.qualita;
  final facilita = math.max(1.3, s.facilita + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  final int ripetizioni;
  final int intervallo;
  if (q < 3) {
    ripetizioni = 0;
    intervallo = 1;
  } else {
    ripetizioni = s.ripetizioni + 1;
    intervallo = switch (ripetizioni) {
      1 => 1,
      2 => 6,
      _ => (s.intervallo * s.facilita).round(),
    };
  }
  return StatoCarta(ripetizioni: ripetizioni, intervallo: intervallo, facilita: facilita, prossima: DateTime(ora.year, ora.month, ora.day + intervallo));
}

/// Una carta va ripassata se la sua data è oggi o già passata (o se non ha ancora data).
bool daRipassare(DateTime? prossima, DateTime ora) =>
    prossima == null || !DateTime(prossima.year, prossima.month, prossima.day).isAfter(DateTime(ora.year, ora.month, ora.day));

enum OrigineCarta { glossario, definizione, manuale }

class CartaNuova {
  const CartaNuova({required this.fronte, required this.retro, required this.origine, this.pagina});
  final String fronte;
  final String retro;
  final OrigineCarta origine;
  final int? pagina;
}

const _articoli = {'il', 'lo', 'la', 'i', 'gli', 'le', 'l', 'un', 'uno', 'una'};
final _siDefinisce = RegExp(r'^(si (?:definisce|dice|chiama))\s+(.+)$', caseSensitive: false);
final _eUn = RegExp(r"^(?:(il|lo|la|l'|l’|i|gli|le)\s*)?(.{2,50}?)\s+(è|e’|e')\s+(un|una|uno)\s", caseSensitive: false);

/// Termine da nascondere in una definizione, ricavato dalla forma della frase.
String? _termineDallaFrase(String frase) {
  final m = _siDefinisce.firstMatch(frase);
  if (m != null) {
    final parole = m[2]!.split(RegExp(r'\s+'));
    final scelte = <String>[];
    for (final w in parole) {
      final pulita = w.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
      if (pulita.isEmpty || pulita.length == 1 || _articoli.contains(pulita.toLowerCase()) || pulita != w) break;
      scelte.add(w);
      if (scelte.length == 4) break;
    }
    return scelte.isEmpty ? null : scelte.join(' ');
  }
  final e = _eUn.firstMatch(frase);
  return e?[2]?.trim();
}

List<CartaNuova> carteDaDocumento(Map<int, String> testoPerPagina) {
  final carte = <CartaNuova>[];
  final fronti = <String>{};
  void aggiungi(CartaNuova c) {
    if (c.fronte.trim().isEmpty || c.retro.trim().isEmpty || !fronti.add(c.fronte)) return;
    carte.add(c);
  }

  final termini = glossario(testoPerPagina);
  final perLunghezza = [...termini]..sort((a, b) => b.termine.length.compareTo(a.termine.length));

  for (final d in definizioni(testoPerPagina)) {
    final minuscola = d.testo.toLowerCase();
    final dalGlossario = perLunghezza.where((t) => minuscola.contains(t.termine)).firstOrNull?.termine;
    final termine = dalGlossario ?? _termineDallaFrase(d.testo);
    final posizione = termine == null ? -1 : minuscola.indexOf(termine.toLowerCase());
    if (termine != null && posizione >= 0) {
      final originale = d.testo.substring(posizione, posizione + termine.length);
      aggiungi(
        CartaNuova(
          fronte: d.testo.replaceRange(posizione, posizione + termine.length, '____'),
          retro: originale,
          origine: OrigineCarta.definizione,
          pagina: d.pagina,
        ),
      );
    } else {
      aggiungi(
        CartaNuova(fronte: 'Spiega: ${titoloPagina(testoPerPagina[d.pagina] ?? '')}', retro: d.testo, origine: OrigineCarta.definizione, pagina: d.pagina),
      );
    }
  }

  for (final t in termini) {
    final pagina = t.pagine.first;
    final righe = (testoPerPagina[pagina] ?? '').split('\n').map((r) => r.trim()).toList();
    final contesto = righe.skip(1).firstWhere((r) => r.toLowerCase().contains(t.termine), orElse: () => '');
    if (contesto.isEmpty) continue;
    aggiungi(CartaNuova(fronte: t.termine, retro: '$contesto (pag. $pagina)', origine: OrigineCarta.glossario, pagina: pagina));
  }
  return carte;
}
