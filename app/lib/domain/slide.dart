/// Analisi del testo delle slide: ricerca per radice, indice, glossario e definizioni.
library;

const _accenti = {'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'í': 'i', 'ò': 'o', 'ó': 'o', 'ù': 'u', 'ú': 'u'};
const _vocali = 'aeiou';
final _parola = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Parole troppo comuni per essere termini del glossario.
const paroleVuote = {
  'il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'uno', 'una', 'l', 'd', 'di', 'a', 'da', 'in', 'con', 'su', 'per', 'tra', 'fra', //
  'e', 'ed', 'o', 'od', 'che', 'non', 'si', 'del', 'dello', 'della', 'dei', 'degli', 'delle', 'al', 'allo', 'alla', 'ai', //
  'agli', 'alle', 'dal', 'dallo', 'dalla', 'dai', 'dagli', 'dalle', 'nel', 'nello', 'nella', 'nei', 'negli', 'nelle', 'sul', //
  'sullo', 'sulla', 'sui', 'sugli', 'sulle', 'come', 'anche', 'più', 'piu', 'meno', 'questo', 'questa', 'questi', 'queste', //
  'quello', 'quella', 'quelli', 'quelle', 'sono', 'essere', 'è', 'ha', 'hanno', 'ma', 'se', 'sia', 'tutto', 'tutti', 'ogni', //
  'molto', 'può', 'possono', 'ecc', 'etc', 'cui', 'dove', 'quando', 'quindi', 'esempio', 'esempi', 'altro', 'altri', 'loro', //
  'suo', 'sua', 'suoi', 'sue', 'nostro', 'nostra', 'vi', 'ci', 'ne', 'mentre', 'dopo', 'prima', 'già', 'poi', //
};

/// Preposizioni ammesse al centro di un termine di tre parole ("legge di Ohm").
const _centroAmmesso = {'di', 'del', 'della', 'dello', 'dei', 'degli', 'delle', 'a', 'al', 'in', 'da'};

String _normale(String s) {
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    b.write(_accenti[c] ?? c);
  }
  return b.toString();
}

/// Radice di una parola: minuscolo, senza accenti, senza vocale finale se lunga.
String radice(String parola) {
  final n = _normale(parola);
  return n.length > 4 && _vocali.contains(n[n.length - 1]) ? n.substring(0, n.length - 1) : n;
}

/// Query FTS5 per il testo scritto dall'utente; null se non contiene parole.
String? queryRicerca(String testoUtente) {
  final parole = _parola.allMatches(testoUtente).map((m) => radice(m[0]!)).where((p) => p.isNotEmpty).toList();
  if (parole.isEmpty) return null;
  return parole.map((p) => '"$p"*').join(' ');
}

String titoloPagina(String testo) {
  final riga = testo.split('\n').map((r) => r.trim()).firstWhere((r) => r.isNotEmpty, orElse: () => '');
  return riga.length > 80 ? riga.substring(0, 80) : riga;
}

class VoceIndice {
  const VoceIndice(this.titolo, this.pagina);
  final String titolo;
  final int pagina;
}

/// Indice dai titoli delle pagine (posizione 0 = pagina 1).
List<VoceIndice> indiceDaPagine(List<String> titoliPagina) {
  final out = <VoceIndice>[];
  String? precedente;
  for (var i = 0; i < titoliPagina.length; i++) {
    final t = titoliPagina[i].trim();
    if (t.isNotEmpty && t != precedente) out.add(VoceIndice(t, i + 1));
    if (t.isNotEmpty) precedente = t;
  }
  return out;
}

class TermineGlossario {
  const TermineGlossario(this.termine, this.pagine);
  final String termine;
  final List<int> pagine;
}

List<TermineGlossario> glossario(Map<int, String> testoPerPagina, {int massimo = 40}) {
  final pagine = <String, Set<int>>{};
  final occorrenze = <String, int>{};
  for (final MapEntry(key: n, value: testo) in testoPerPagina.entries) {
    for (final riga in testo.split('\n')) {
      final p = _parola.allMatches(riga.toLowerCase()).map((m) => m[0]!).toList();
      for (var i = 0; i < p.length; i++) {
        for (var lung = 1; lung <= 3 && i + lung <= p.length; lung++) {
          final parti = p.sublist(i, i + lung);
          if (paroleVuote.contains(parti.first) || paroleVuote.contains(parti.last)) continue;
          if (lung == 1 && parti.first.length < 4) continue;
          if (lung == 2 && parti.any(paroleVuote.contains)) continue;
          if (lung == 3 && !_centroAmmesso.contains(parti[1])) continue;
          if (parti.any((x) => RegExp(r'^\d+$').hasMatch(x))) continue;
          final termine = parti.join(' ');
          (pagine[termine] ??= {}).add(n);
          occorrenze[termine] = (occorrenze[termine] ?? 0) + 1;
        }
      }
    }
  }
  final candidati = pagine.keys.where((t) => pagine[t]!.length >= 2).toList()
    ..sort((a, b) {
      final c = pagine[b]!.length.compareTo(pagine[a]!.length);
      if (c != 0) return c;
      final o = occorrenze[b]!.compareTo(occorrenze[a]!);
      if (o != 0) return o;
      final l = b.split(' ').length.compareTo(a.split(' ').length);
      return l != 0 ? l : a.compareTo(b);
    });
  // Una parola già compresa in un termine più lungo con le stesse pagine non aggiunge nulla.
  final scelti = <String>[];
  for (final t in candidati) {
    final assorbito = candidati.any(
      (altro) => altro != t && altro.split(' ').length > t.split(' ').length && ' $altro '.contains(' $t ') && pagine[altro]!.length == pagine[t]!.length,
    );
    if (!assorbito) scelti.add(t);
    if (scelti.length == massimo) break;
  }
  return [for (final t in scelti) TermineGlossario(t, pagine[t]!.toList()..sort())];
}

class Definizione {
  const Definizione(this.testo, this.pagina);
  final String testo;
  final int pagina;
}

final _definizione = RegExp(
  r"^((definizione|teorema|propriet[aà]|lemma|corollario)\b|si (definisce|dice|chiama)\b|\S.{0,60}?\s(è|e’|e')\s(un|una|uno)\s)",
  caseSensitive: false,
);

List<Definizione> definizioni(Map<int, String> testoPerPagina) {
  final out = <Definizione>[];
  final numeri = testoPerPagina.keys.toList()..sort();
  for (final n in numeri) {
    for (final riga in testoPerPagina[n]!.split('\n')) {
      final r = riga.trim();
      if (_definizione.hasMatch(r)) out.add(Definizione(r, n));
    }
  }
  return out;
}

/// Divide un estratto di ricerca in parti normali ed evidenziate (quelle tra [ e ]).
List<(String, bool)> segmentiEstratto(String estratto) {
  final out = <(String, bool)>[];
  final re = RegExp(r'\[([^\]]*)\]');
  var da = 0;
  for (final m in re.allMatches(estratto)) {
    if (m.start > da) out.add((estratto.substring(da, m.start), false));
    out.add((m[1]!, true));
    da = m.end;
  }
  if (da < estratto.length) out.add((estratto.substring(da), false));
  return out;
}
