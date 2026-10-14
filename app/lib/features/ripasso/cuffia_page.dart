import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/orale.dart';
import '../../domain/ripasso.dart';
import '../../services/voce.dart';

/// Ripasso in cuffia: legge il fronte, aspetta, legge la risposta, passa alla carta dopo.
class CuffiaPage extends ConsumerStatefulWidget {
  const CuffiaPage({super.key, this.corsoId, this.pausa = const Duration(seconds: 4)});
  final int? corsoId;
  final Duration pausa;

  @override
  ConsumerState<CuffiaPage> createState() => _CuffiaPageState();
}

class _CuffiaPageState extends ConsumerState<CuffiaPage> {
  List<Carta>? _carte;
  int _indice = 0;
  bool _inCorso = false;

  /// Cambia a ogni avvio e pausa: un ciclo vecchio che si risveglia dopo una pausa si ferma.
  int _giro = 0;
  bool _mostraRetro = false;
  late final Voce _voce;

  @override
  void initState() {
    super.initState();
    _voce = ref.read(voceProvider);
    _carica();
  }

  Future<void> _carica() async {
    final ora = ref.read(orologioProvider)();
    final tutte = await ref.read(repositoryProvider).guardaCarte(widget.corsoId).first;
    final oggi = tutte.where((c) => daRipassare(c.prossima, ora)).toList();
    if (mounted) setState(() => _carte = oggi.isEmpty ? tutte : oggi);
  }

  Future<void> _ascolta() async {
    final voce = _voce;
    final giro = ++_giro;
    bool attivo() => giro == _giro && _inCorso && mounted;
    setState(() => _inCorso = true);
    while (attivo() && _indice < _carte!.length) {
      final c = _carte![_indice];
      setState(() => _mostraRetro = false);
      await voce.parla(c.fronte);
      if (!attivo()) return;
      await Future<void>.delayed(widget.pausa);
      if (!attivo()) return;
      setState(() => _mostraRetro = true);
      await voce.parla(domandaOrale(fronte: c.fronte, retro: c.retro, origine: c.origine).attesa);
      if (!attivo()) return;
      setState(() => _indice++);
    }
    if (giro == _giro && mounted) setState(() => _inCorso = false);
  }

  Future<void> _pausa() async {
    _giro++;
    setState(() => _inCorso = false);
    await _voce.ferma();
  }

  @override
  void dispose() {
    _inCorso = false;
    _voce.ferma();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carte = _carte;
    final finite = carte != null && _indice >= carte.length;
    return Scaffold(
      backgroundColor: AuriColori.sfondo,
      appBar: AppBar(backgroundColor: AuriColori.sfondo, title: const Text('Ripasso in cuffia')),
      body: Center(
        child: SizedBox(
          width: 640,
          child: carte == null
              ? const CircularProgressIndicator()
              : carte.isEmpty
              ? Text(
                  'Nessuna carta da ascoltare',
                  style: titolo(24, colore: AuriColori.grigio),
                  textAlign: TextAlign.center,
                )
              : finite
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Fine delle carte', style: titolo(36)),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: () => setState(() => _indice = 0), child: const Text('Ricomincia')),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Etichetta('Carta ${_indice + 1} di ${carte.length}'),
                    const SizedBox(height: 10),
                    Scheda(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(carte[_indice].fronte, style: titolo(26, peso: FontWeight.w700)),
                          if (_mostraRetro) ...[
                            const Divider(height: 32),
                            Text(
                              carte[_indice].retro,
                              style: testo(18, colore: AuriColori.viola, peso: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _inCorso ? _pausa : _ascolta,
                          icon: Icon(_inCorso ? Icons.pause_rounded : Icons.headphones_rounded),
                          label: Text(_inCorso ? 'Pausa' : 'Ascolta'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await _pausa();
                            setState(() => _indice++);
                          },
                          icon: const Icon(Icons.skip_next_rounded),
                          label: const Text('Avanti'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
