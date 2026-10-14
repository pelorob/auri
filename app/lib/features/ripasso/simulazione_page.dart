import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../domain/quiz.dart';

/// Simulazione d'esame scritta: [quante] domande, 1 minuto ciascuna, voto in trentesimi.
class SimulazionePage extends ConsumerStatefulWidget {
  const SimulazionePage({super.key, required this.corsoId, required this.quante});
  final int corsoId;
  final int quante;

  @override
  ConsumerState<SimulazionePage> createState() => _SimulazionePageState();
}

class _SimulazionePageState extends ConsumerState<SimulazionePage> {
  List<Domanda>? _domande;
  String? _errore;
  final _risposte = <int?>[];
  int _secondi = 0;
  Timer? _timer;
  bool _finita = false;
  Map<int, String> _titoliDocumenti = const {};
  final _escluseOra = <Domanda>{};

  @override
  void initState() {
    super.initState();
    _prepara();
  }

  Future<void> _prepara() async {
    final repo = ref.read(repositoryProvider);
    final materiale = await repo.materialeCorso(widget.corsoId);
    final titoli = {for (final m in materiale) m.documentoId: (await repo.documento(m.documentoId))?.titolo ?? ''};
    final escluse = await repo.domandeEscluse();
    if (!mounted) return;
    try {
      final d = generaQuiz(materiale, quante: widget.quante, caso: ref.read(casoProvider)(), escluse: escluse);
      if (d.isEmpty) throw const MaterialeInsufficiente();
      setState(() {
        _domande = d;
        _titoliDocumenti = titoli;
        _secondi = d.length * 60;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _secondi--);
        if (_secondi <= 0) _termina();
      });
    } on MaterialeInsufficiente catch (e) {
      setState(() => _errore = e.toString());
    }
  }

  void _rispondi(int scelta) {
    _risposte.add(scelta);
    if (_risposte.length >= _domande!.length) {
      _termina();
    } else {
      setState(() {});
    }
  }

  /// Domanda strana durante il quiz: non conta, e la sua frase non verrà più usata.
  Future<void> _escludiCorrente() async {
    final d = _domande!;
    final q = d[_risposte.length];
    await ref.read(repositoryProvider).escludiDomanda(q.documentoId, q.frase);
    if (!mounted || _finita) return;
    setState(() => _domande = [...d]..remove(q));
    if (_domande!.isEmpty) {
      _timer?.cancel();
      setState(() => _errore = 'Non sono rimaste domande: riprova con un altro quiz.');
    } else if (_risposte.length >= _domande!.length) {
      _termina();
    }
  }

  Future<void> _escludiDopo(Domanda q) async {
    await ref.read(repositoryProvider).escludiDomanda(q.documentoId, q.frase);
    if (mounted) setState(() => _escluseOra.add(q));
  }

  Future<void> _termina() async {
    if (_finita) return;
    _timer?.cancel();
    final d = _domande!;
    final giuste = [
      for (var i = 0; i < d.length; i++)
        if (i < _risposte.length && _risposte[i] == d[i].giusta) i,
    ].length;
    setState(() => _finita = true);
    await ref
        .read(repositoryProvider)
        .salvaSimulazione(
          corsoId: widget.corsoId,
          data: ref.read(orologioProvider)(),
          domande: d.length,
          giuste: giuste,
          voto: votoSimulazione(giuste, d.length),
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _domande;
    return Scaffold(
      backgroundColor: AuriColori.sfondo,
      appBar: AppBar(
        backgroundColor: AuriColori.sfondo,
        title: const Text('Simulazione d\'esame'),
        actions: [
          if (d != null && !_finita)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Pillola('${_secondi ~/ 60}:${(_secondi % 60).toString().padLeft(2, '0')}', sfondo: AuriColori.lime),
            ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 720,
          child: _errore != null
              ? Text(
                  _errore!,
                  style: titolo(24, colore: AuriColori.grigio),
                  textAlign: TextAlign.center,
                )
              : d == null
              ? const Center(child: CircularProgressIndicator())
              : _finita
              ? _risultato(d)
              : _domanda(d[_risposte.length], _risposte.length + 1, d.length),
        ),
      ),
    );
  }

  Widget _domanda(Domanda q, int numero, int totale) {
    final righe = q.testo.split('\n');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Etichetta('Domanda $numero di $totale'),
        const SizedBox(height: 12),
        Scheda(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                righe.first,
                style: testo(16, peso: FontWeight.w700, colore: AuriColori.grigio),
              ),
              const SizedBox(height: 10),
              Text(righe.skip(1).join('\n'), style: titolo(24, peso: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < q.opzioni.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FilledButton(
              key: ValueKey('opzione-$numero-$i'),
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AuriColori.inchiostro, alignment: Alignment.centerLeft),
              onPressed: () => _rispondi(i),
              child: Text(q.opzioni[i]),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _escludiCorrente,
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text('Domanda sbagliata, non mostrarla più'),
          ),
        ),
      ],
    );
  }

  Widget _risultato(List<Domanda> d) {
    final giuste = [
      for (var i = 0; i < d.length; i++)
        if (i < _risposte.length && _risposte[i] == d[i].giusta) i,
    ].length;
    final voto = votoSimulazione(giuste, d.length);
    final errori = [
      for (var i = 0; i < d.length; i++)
        if (i >= _risposte.length || _risposte[i] != d[i].giusta) d[i],
    ];
    return ListView(
      shrinkWrap: true,
      children: [
        Center(
          child: Text('$voto', style: titolo(96, colore: superata(voto) ? AuriColori.viola : AuriColori.arancio)),
        ),
        Center(child: Text(superata(voto) ? 'Superato' : 'Non superato', style: titolo(26))),
        Center(
          child: Text('$giuste giuste su ${d.length}', style: testo(16, colore: AuriColori.grigio)),
        ),
        const SizedBox(height: 24),
        if (errori.isNotEmpty) ...[
          const Etichetta('Da ripassare'),
          const SizedBox(height: 8),
          for (final q in errori)
            Scheda(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.testo.split('\n').skip(1).join(' '), style: testo(15, peso: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Risposta giusta: ${q.opzioni[q.giusta]}',
                    style: testo(14, colore: AuriColori.viola, peso: FontWeight.w700),
                  ),
                  Text('${_titoliDocumenti[q.documentoId] ?? ''} · pag. ${q.pagina}', style: testo(13, colore: AuriColori.grigio)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _escluseOra.contains(q)
                        ? Text('Non la vedrai più', style: testo(13, colore: AuriColori.grigio))
                        : TextButton(onPressed: () => _escludiDopo(q), child: const Text('Domanda sbagliata, non mostrarla più')),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
        Center(
          child: FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Chiudi')),
        ),
      ],
    );
  }
}
