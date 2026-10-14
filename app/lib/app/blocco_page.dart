import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'blocco.dart';
import 'providers.dart';
import 'tema.dart';

class BloccoPage extends ConsumerStatefulWidget {
  const BloccoPage({super.key});
  @override
  ConsumerState<BloccoPage> createState() => _BloccoPageState();
}

class _BloccoPageState extends ConsumerState<BloccoPage> {
  bool _inCorso = false;
  bool _fallita = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sblocca());
  }

  Future<void> _sblocca() async {
    // Una richiesta alla volta: quella automatica e il tocco sul pulsante non si sovrappongono.
    if (_inCorso) return;
    setState(() {
      _inCorso = true;
      _fallita = false;
    });
    try {
      final touchId = ref.read(touchIdProvider);
      // Senza Touch ID e senza codice non si può autenticare: non lasciarla chiusa fuori.
      final ok = !await touchId.disponibile() || await touchId.autentica();
      if (!mounted) return;
      if (ok) {
        ref.read(bloccoProvider.notifier).sblocca();
      } else {
        setState(() => _fallita = true);
      }
    } finally {
      if (mounted) setState(() => _inCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AuriColori.viola,
      child: Stack(
        children: [
          Positioned(
            left: -160,
            top: -200,
            child: Container(
              width: 520,
              height: 520,
              decoration: const BoxDecoration(color: AuriColori.viola2, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: -120,
            bottom: -160,
            child: Container(
              width: 380,
              height: 380,
              decoration: const BoxDecoration(color: AuriColori.viola3, shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('auri', style: titolo(64, colore: Colors.white)),
                Text('I tuoi esami, al sicuro.', style: testo(18, colore: AuriColori.violaChip)),
                const SizedBox(height: 28),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
                  child: const Icon(Icons.fingerprint_rounded, size: 80, color: AuriColori.viola),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 24,
                  child: _fallita
                      ? Text(
                          'Non riconosciuta, riprova',
                          style: testo(15, peso: FontWeight.w600, colore: AuriColori.lime),
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AuriColori.lime, foregroundColor: AuriColori.inchiostro, minimumSize: const Size(260, 56)),
                  onPressed: _inCorso ? null : _sblocca,
                  child: const Text('Sblocca con Touch ID'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _inCorso ? null : _sblocca,
                  child: Text(
                    'Usa il codice dell\'iPad',
                    style: testo(15, peso: FontWeight.w600, colore: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mette la schermata di blocco sopra a tutto, dialoghi compresi.
class StratoBlocco extends ConsumerWidget {
  const StratoBlocco({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloccata = ref.watch(bloccoProvider);
    return Stack(
      children: [
        child,
        if (bloccata) const Positioned.fill(child: Material(child: BloccoPage())),
        // In background (e nell'anteprima delle app recenti) i dati non si vedono.
        if (!bloccata && ref.watch(coperturaProvider))
          Positioned.fill(
            child: ColoredBox(
              key: const Key('copertura'),
              color: AuriColori.viola,
              child: Center(
                child: Text('auri', style: titolo(64, colore: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }
}
