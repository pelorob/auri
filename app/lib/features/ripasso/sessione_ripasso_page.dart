import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/formati.dart';
import '../../domain/ripasso.dart';

/// Ripasso delle carte in scadenza oggi (di un corso, o di tutti se [corsoId] è null).
class SessioneRipassoPage extends ConsumerStatefulWidget {
  const SessioneRipassoPage({super.key, this.corsoId});
  final int? corsoId;

  @override
  ConsumerState<SessioneRipassoPage> createState() => _SessioneRipassoPageState();
}

class _SessioneRipassoPageState extends ConsumerState<SessioneRipassoPage> {
  List<Carta>? _coda;
  int _indice = 0;
  int _fatte = 0;
  bool _girata = false;
  bool _occupato = false;
  Map<int, DateTime> _ultimi = const {};

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final ora = ref.read(orologioProvider)();
    final tutte = await ref.read(repositoryProvider).guardaCarte(widget.corsoId).first;
    final ultimi = await ref.read(repositoryProvider).ultimiRipassi();
    if (!mounted) return;
    _ultimi = ultimi;
    setState(() => _coda = tutte.where((c) => daRipassare(c.prossima, ora)).toList()..shuffle());
  }

  Future<void> _rispondi(Risposta r) async {
    if (_occupato) return; // un doppio tocco non registra due revisioni
    _occupato = true;
    final c = _coda![_indice];
    final ora = ref.read(orologioProvider)();
    try {
      await ref.read(repositoryProvider).rispondi(c, r, ora);
    } finally {
      _occupato = false;
    }
    if (!mounted) return;
    setState(() {
      _ultimi = {..._ultimi, c.id: ora};
      _fatte++;
      // Le carte non sapute tornano in fondo alla coda di oggi.
      if (r == Risposta.nonLaSapevo) _coda!.add(c);
      _indice++;
      _girata = false;
    });
  }

  Future<void> _escludi() async {
    await ref.read(repositoryProvider).escludiCarta(_coda![_indice].id);
    if (!mounted) return;
    setState(() {
      _coda!.removeAt(_indice);
      _girata = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final coda = _coda;
    return Scaffold(
      backgroundColor: AuriColori.sfondo,
      appBar: AppBar(
        backgroundColor: AuriColori.sfondo,
        title: Text(coda == null || _indice >= coda.length ? 'Ripasso' : 'Carta ${_indice + 1} di ${coda.length}'),
        actions: [
          if (coda != null && _indice < coda.length)
            PopupMenuButton<String>(
              onSelected: (_) => _escludi(),
              itemBuilder: (_) => const [PopupMenuItem(value: 'escludi', child: Text('Carta sbagliata, non mostrarla più'))],
            ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 640,
          child: coda == null
              ? const CircularProgressIndicator()
              : _indice >= coda.length
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_fatte == 0 ? 'Niente da ripassare oggi' : 'Fatto!', style: titolo(44)),
                    const SizedBox(height: 8),
                    if (_fatte > 0) Text('Hai ripassato $_fatte ${_fatte == 1 ? 'carta' : 'carte'}.', style: testo(18, colore: AuriColori.grigio)),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Chiudi')),
                  ],
                )
              : _carta(coda[_indice]),
        ),
      ),
    );
  }

  Widget _carta(Carta c) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Scheda(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (c.pagina != null) Etichetta('pag. ${c.pagina}'),
                Text(
                  _ultimi[c.id] == null ? 'Prima volta' : 'Ultimo ripasso: ${giorniFa(_ultimi[c.id]!, ref.read(orologioProvider)())}',
                  style: testo(13, colore: AuriColori.grigio),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(c.fronte, style: titolo(28, peso: FontWeight.w700)),
            if (_girata) ...[
              const Divider(height: 40),
              Text(
                c.retro,
                style: testo(20, peso: FontWeight.w600, colore: AuriColori.viola),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),
      if (!_girata)
        FilledButton(onPressed: () => setState(() => _girata = true), child: const Text('Mostra risposta'))
      else
        Row(
          children: [
            for (final (r, etichetta, colore) in const [
              (Risposta.nonLaSapevo, 'Non la sapevo', AuriColori.arancio),
              (Risposta.difficile, 'Difficile', AuriColori.grigio),
              (Risposta.giusta, 'Giusta', AuriColori.viola),
              (Risposta.facile, 'Facile', AuriColori.verde),
            ]) ...[
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: colore),
                  onPressed: () => _rispondi(r),
                  child: Text(etichetta, textAlign: TextAlign.center),
                ),
              ),
              if (r != Risposta.facile) const SizedBox(width: 10),
            ],
          ],
        ),
    ],
  );
}
