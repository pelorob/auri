import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../domain/orale.dart';
import '../../services/voce.dart';

/// Simulazione d'esame orale: domanda letta ad alta voce, risposta a voce, confronto con le parole chiave.
class OralePage extends ConsumerStatefulWidget {
  const OralePage({super.key, required this.corsoId, this.massimo = 10});
  final int corsoId;
  final int massimo;

  @override
  ConsumerState<OralePage> createState() => _OralePageState();
}

enum _Fase { domanda, ascolto, valutata }

class _OralePageState extends ConsumerState<OralePage> {
  late final Voce _voce;
  late final Ascolto _ascolto;
  List<DomandaOrale>? _domande;
  int _indice = 0;
  _Fase _fase = _Fase.domanda;
  String _detto = '';
  Valutazione? _valutazione;
  bool _senzaMicrofono = false;
  final _coperture = <double>[];
  bool _chiudendo = false;

  @override
  void initState() {
    super.initState();
    _voce = ref.read(voceProvider);
    _ascolto = ref.read(ascoltoProvider);
    _carica();
  }

  Future<void> _carica() async {
    final carte = await ref.read(repositoryProvider).guardaCarte(widget.corsoId).first;
    final domande = [for (final c in carte..shuffle()) domandaOrale(fronte: c.fronte, retro: c.retro, origine: c.origine)].take(widget.massimo).toList();
    if (!mounted) return;
    setState(() => _domande = domande);
    if (domande.isNotEmpty) await _voce.parla(domande.first.domanda);
  }

  Future<void> _rispondi() async {
    if (!await _ascolto.prepara()) {
      if (mounted) setState(() => _senzaMicrofono = true);
      return;
    }
    await _voce.ferma();
    setState(() {
      _fase = _Fase.ascolto;
      _detto = '';
    });
    await _ascolto.inizia((testo) {
      if (mounted) setState(() => _detto = testo);
    });
  }

  Future<void> _finito() async {
    if (_chiudendo) return; // un doppio tocco su "Ho finito" non conta due volte
    _chiudendo = true;
    final String detto;
    try {
      detto = await _ascolto.fine();
    } finally {
      _chiudendo = false;
    }
    if (_fase != _Fase.ascolto) return;
    final v = valutaRisposta(attesa: _domande![_indice].attesa, detta: detto);
    _coperture.add(v.copertura);
    if (mounted) {
      setState(() {
        _detto = detto;
        _valutazione = v;
        _fase = _Fase.valutata;
      });
    }
  }

  Future<void> _prossima() async {
    setState(() {
      _indice++;
      _fase = _Fase.domanda;
      _valutazione = null;
      _detto = '';
    });
    if (_indice < _domande!.length) await _voce.parla(_domande![_indice].domanda);
  }

  @override
  void dispose() {
    _voce.ferma();
    if (_fase == _Fase.ascolto) _ascolto.annulla(); // il microfono non resta acceso
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _domande;
    return Scaffold(
      backgroundColor: AuriColori.sfondo,
      appBar: AppBar(backgroundColor: AuriColori.sfondo, title: const Text('Esame orale')),
      body: Center(
        child: SizedBox(
          width: 680,
          child: d == null
              ? const CircularProgressIndicator()
              : d.isEmpty
              ? Text(
                  'Crea prima qualche flashcard per questo corso',
                  style: titolo(24, colore: AuriColori.grigio),
                  textAlign: TextAlign.center,
                )
              : _indice >= d.length
              ? _riepilogo()
              : _schermataDomanda(d[_indice], _indice + 1, d.length),
        ),
      ),
    );
  }

  Widget _riepilogo() {
    final media = _coperture.isEmpty ? 0.0 : _coperture.reduce((a, b) => a + b) / _coperture.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${(media * 100).round()}%', style: titolo(80, colore: AuriColori.viola)),
        Text('delle parole chiave citate in media', style: testo(16, colore: AuriColori.grigio)),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Chiudi')),
      ],
    );
  }

  Widget _schermataDomanda(DomandaOrale q, int numero, int totale) {
    final v = _valutazione;
    return ListView(
      shrinkWrap: true,
      children: [
        Etichetta('Domanda $numero di $totale'),
        const SizedBox(height: 10),
        Scheda(
          padding: const EdgeInsets.all(30),
          child: Row(
            children: [
              Expanded(
                child: Text(q.domanda, style: titolo(26, peso: FontWeight.w700)),
              ),
              IconButton(tooltip: 'Rileggi la domanda', onPressed: () => _voce.parla(q.domanda), icon: const Icon(Icons.volume_up_rounded)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_senzaMicrofono)
          Scheda(
            colore: AuriColori.lime,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(child: Text('Per rispondere a voce serve il permesso del microfono e del riconoscimento vocale.')),
                TextButton(onPressed: () => launchUrl(Uri.parse('app-settings:')), child: const Text('Apri impostazioni')),
              ],
            ),
          ),
        if (_detto.isNotEmpty) ...[
          const SizedBox(height: 12),
          Scheda(
            padding: const EdgeInsets.all(20),
            child: Text(_detto, style: testo(18)),
          ),
        ],
        const SizedBox(height: 16),
        if (_fase == _Fase.domanda) FilledButton.icon(onPressed: _rispondi, icon: const Icon(Icons.mic_rounded), label: const Text('Rispondi a voce')),
        if (_fase == _Fase.ascolto)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AuriColori.arancio),
            onPressed: _finito,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Ho finito'),
          ),
        if (_fase == _Fase.valutata && v != null) ...[
          Center(
            child: Text(switch (v.giudizio) {
              Giudizio.ottimo => 'Ottimo',
              Giudizio.quasi => 'Quasi',
              Giudizio.daRipassare => 'Da ripassare',
            }, style: titolo(34, colore: v.giudizio == Giudizio.daRipassare ? AuriColori.arancio : AuriColori.viola)),
          ),
          Center(
            child: Text('${(v.copertura * 100).round()}% delle parole chiave', style: testo(15, colore: AuriColori.grigio)),
          ),
          if (v.mancanti.isNotEmpty)
            Center(
              child: Text('Mancavano: ${v.mancanti.join(', ')}', style: testo(15, peso: FontWeight.w600)),
            ),
          const SizedBox(height: 10),
          Scheda(
            padding: const EdgeInsets.all(18),
            child: Text('Risposta attesa: ${q.attesa}', style: testo(15, colore: AuriColori.viola)),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _prossima, child: const Text('Prossima domanda')),
        ],
      ],
    );
  }
}
