/// Quiz generati dalle slide: scelta multipla, completamento, vero/falso.
library;

import 'dart:math';

import 'ripasso.dart';
import 'slide.dart';

enum TipoDomanda { sceltaMultipla, completamento, veroFalso }

class Domanda {
  const Domanda({
    required this.tipo,
    required this.testo,
    required this.opzioni,
    required this.giusta,
    required this.documentoId,
    required this.pagina,
    this.frase = '',
  });
  final TipoDomanda tipo;
  final String testo;
  final List<String> opzioni;
  final int giusta;
  final int documentoId;
  final int? pagina;

  /// La frase da cui nasce la domanda (con ____ al posto della risposta): serve per escluderla.
  final String frase;
}

class MaterialeDocumento {
  const MaterialeDocumento({required this.documentoId, required this.testoPerPagina});
  final int documentoId;
  final Map<int, String> testoPerPagina;
}

class MaterialeInsufficiente implements Exception {
  const MaterialeInsufficiente();
  @override
  String toString() => 'Importa più slide per generare un quiz.';
}

int votoSimulazione(int giuste, int totale) => totale == 0 ? 0 : (30 * giuste / totale).round();

bool superata(int voto) => voto >= 18;

/// Una frase con un "buco" e la parola che lo riempie, presa da una pagina.
class _Buco {
  const _Buco(this.frase, this.risposta, this.documentoId, this.pagina);
  final String frase;
  final String risposta;
  final int documentoId;
  final int? pagina;
}

/// [escluse]: coppie (documento, frase) segnate come sbagliate, da non usare più.
List<Domanda> generaQuiz(List<MaterialeDocumento> materiale, {required int quante, required Random caso, Set<(int, String)> escluse = const {}}) {
  final termini = <String>[];
  final daContesto = <_Buco>[];
  final daDefinizioni = <_Buco>[];

  for (final m in materiale) {
    final glossarioDoc = glossario(m.testoPerPagina);
    for (final t in glossarioDoc) {
      if (!termini.contains(t.termine)) termini.add(t.termine);
      final pagina = t.pagine.first;
      final righe = (m.testoPerPagina[pagina] ?? '').split('\n').map((r) => r.trim()).toList();
      final riga = righe.skip(1).firstWhere((r) => r.toLowerCase().contains(t.termine), orElse: () => '');
      if (riga.isEmpty) continue;
      final pos = riga.toLowerCase().indexOf(t.termine);
      daContesto.add(_Buco(riga.replaceRange(pos, pos + t.termine.length, '____'), riga.substring(pos, pos + t.termine.length), m.documentoId, pagina));
    }
    for (final c in carteDaDocumento(m.testoPerPagina)) {
      if (c.origine == OrigineCarta.definizione && c.fronte.contains('____')) {
        daDefinizioni.add(_Buco(c.fronte, c.retro, m.documentoId, c.pagina));
      }
    }
  }
  if (termini.length < 4) throw const MaterialeInsufficiente();
  daContesto.removeWhere((b) => escluse.contains((b.documentoId, b.frase)));
  daDefinizioni.removeWhere((b) => escluse.contains((b.documentoId, b.frase)));

  List<String>? distrattori(_Buco b, int quanti) {
    final scelti = ([...termini]..shuffle(caso)).where((t) => t.toLowerCase() != b.risposta.toLowerCase()).take(quanti).toList();
    return scelti.length == quanti ? scelti : null;
  }

  Domanda? aScelta(_Buco b, TipoDomanda tipo, String domanda) {
    final altri = distrattori(b, 3);
    if (altri == null) return null;
    final opzioni = [b.risposta, ...altri]..shuffle(caso);
    return Domanda(
      tipo: tipo,
      testo: '$domanda\n«${b.frase}»',
      opzioni: opzioni,
      giusta: opzioni.indexOf(b.risposta),
      documentoId: b.documentoId,
      pagina: b.pagina,
      frase: b.frase,
    );
  }

  Domanda? veroFalso(_Buco b) {
    final vera = caso.nextBool();
    final parola = vera ? b.risposta : distrattori(b, 1)?.first;
    if (parola == null) return null;
    final frase = b.frase.replaceFirst('____', parola);
    if (!vera) {
      final testoPagina = materiale.firstWhere((m) => m.documentoId == b.documentoId).testoPerPagina[b.pagina] ?? '';
      if (testoPagina.toLowerCase().contains(frase.toLowerCase())) return null;
    }
    return Domanda(
      tipo: TipoDomanda.veroFalso,
      testo: 'Vero o falso?\n«$frase»',
      opzioni: const ['Vero', 'Falso'],
      giusta: vera ? 0 : 1,
      documentoId: b.documentoId,
      pagina: b.pagina,
      frase: b.frase,
    );
  }

  final perTipo = <TipoDomanda, List<Domanda>>{
    TipoDomanda.sceltaMultipla: [for (final b in daContesto) ?aScelta(b, TipoDomanda.sceltaMultipla, 'Quale termine completa la frase?')],
    TipoDomanda.completamento: [for (final b in daDefinizioni) ?aScelta(b, TipoDomanda.completamento, 'Completa la definizione:')],
    TipoDomanda.veroFalso: [
      for (final b in [...daDefinizioni, ...daContesto]) ?veroFalso(b),
    ],
  };
  for (final l in perTipo.values) {
    l.shuffle(caso);
  }

  // A turno un tipo per volta, così il quiz è vario.
  final scelte = <Domanda>[];
  var giro = 0;
  while (scelte.length < quante && perTipo.values.any((l) => giro < l.length)) {
    for (final tipo in TipoDomanda.values) {
      final l = perTipo[tipo]!;
      if (giro < l.length && scelte.length < quante) scelte.add(l[giro]);
    }
    giro++;
  }
  return scelte;
}
