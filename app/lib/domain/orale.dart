/// Esame orale: domande dalle carte e valutazione della risposta detta a voce.
library;

import 'ripasso.dart';
import 'slide.dart';

class DomandaOrale {
  const DomandaOrale(this.domanda, this.attesa);
  final String domanda;
  final String attesa;
}

final _pagina = RegExp(r'\s*\(pag\. \d+\)$');

DomandaOrale domandaOrale({required String fronte, required String retro, required OrigineCarta origine}) {
  final attesa = retro.replaceAll(_pagina, '').trim();
  if (origine == OrigineCarta.glossario) return DomandaOrale("Che cos'è $fronte?", attesa);
  if (fronte.contains('____')) return DomandaOrale('Quale termine manca? ${fronte.replaceAll('____', '…')}', attesa);
  return DomandaOrale(fronte, attesa);
}

final _parola = RegExp(r'[\p{L}]+', unicode: true);

/// Parole significative (radici) di un testo, senza parole comuni, nell'ordine in cui compaiono.
List<(String radice, String parola)> _chiavi(String testo) {
  final viste = <String>{};
  final out = <(String, String)>[];
  for (final m in _parola.allMatches(testo)) {
    final parola = m[0]!;
    final minuscola = parola.toLowerCase();
    if (minuscola.length < 3 || paroleVuote.contains(minuscola)) continue;
    final r = radice(parola);
    if (viste.add(r)) out.add((r, minuscola));
  }
  return out;
}

List<String> paroleChiave(String testo) => [for (final (r, _) in _chiavi(testo)) r];

enum Giudizio { ottimo, quasi, daRipassare }

class Valutazione {
  const Valutazione({required this.copertura, required this.giudizio, required this.mancanti});
  final double copertura;
  final Giudizio giudizio;

  /// Parole chiave della risposta attesa che non sono state dette.
  final List<String> mancanti;
}

Valutazione valutaRisposta({required String attesa, required String detta}) {
  final attese = _chiavi(attesa);
  final dette = paroleChiave(detta).toSet();
  final mancanti = [
    for (final (r, parola) in attese)
      if (!dette.contains(r)) parola,
  ];
  final copertura = attese.isEmpty ? 0.0 : (attese.length - mancanti.length) / attese.length;
  final giudizio = copertura >= 0.7 ? Giudizio.ottimo : (copertura >= 0.4 ? Giudizio.quasi : Giudizio.daRipassare);
  return Valutazione(copertura: copertura, giudizio: giudizio, mancanti: mancanti);
}
