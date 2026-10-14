import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/ripasso.dart';
import 'cuffia_page.dart';
import 'orale_page.dart';
import 'sessione_ripasso_page.dart';
import 'simulazione_page.dart';
import '../../domain/formati.dart';

class RipassoPage extends ConsumerWidget {
  const RipassoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ora = ref.watch(orologioProvider)();
    final carte = ref.watch(carteProvider).value ?? const <Carta>[];
    final corsi = ref.watch(corsiProvider).value ?? const [];
    final documenti = ref.watch(documentiProvider).value ?? const [];
    final daFare = carte.where((c) => daRipassare(c.prossima, ora)).length;

    void apri(int? corsoId) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SessioneRipassoPage(corsoId: corsoId)));

    final conCarte = [
      for (final c in corsi)
        (
          corso: c.corso,
          totali: carte.where((x) => x.corsoId == c.corso.id).length,
          oggi: carte.where((x) => x.corsoId == c.corso.id && daRipassare(x.prossima, ora)).length,
          slide: documenti.any((d) => d.corso.id == c.corso.id),
        ),
    ].where((x) => x.totali > 0 || x.slide).toList();

    Future<void> simula(int corsoId) async {
      final quante = await showDialog<int>(
        context: context,
        builder: (c) => SimpleDialog(
          title: const Text('Quante domande?'),
          children: [
            for (final n in const [10, 20, 30]) SimpleDialogOption(onPressed: () => Navigator.pop(c, n), child: Text('$n domande')),
          ],
        ),
      );
      if (quante == null || !context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SimulazionePage(corsoId: corsoId, quante: quante),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitoloPagina(
          sopra: daFare == 1 ? '1 carta da ripassare oggi' : '$daFare carte da ripassare oggi',
          testoTitolo: 'Ripasso',
          azione: Row(
            children: [
              if (daFare > 0) ...[
                OutlinedButton.icon(onPressed: () => apri(null), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Ripassa tutto')),
                const SizedBox(width: 10),
              ],
              FilledButton.icon(onPressed: () => _nuovaCarta(context, ref), icon: const Icon(Icons.add_rounded), label: const Text('Nuova carta')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: conCarte.isEmpty
              ? Center(
                  child: Text(
                    'Nessuna flashcard: aprila una slide e tocca "Crea flashcard", oppure scrivine una.',
                    style: titolo(22, colore: AuriColori.grigio),
                    textAlign: TextAlign.center,
                  ),
                )
              : GridView.extent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.35,
                  children: [
                    for (final x in conCarte)
                      Scheda(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    x.corso.nome,
                                    style: titolo(20, peso: FontWeight.w700),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (x.totali > 0) ...[
                                  IconButton(
                                    tooltip: 'Ripasso in cuffia',
                                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CuffiaPage(corsoId: x.corso.id))),
                                    icon: const Icon(Icons.headphones_rounded),
                                  ),
                                  IconButton(
                                    tooltip: 'Esame orale',
                                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OralePage(corsoId: x.corso.id))),
                                    icon: const Icon(Icons.mic_none_rounded),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              x.totali == 0 ? 'Nessuna flashcard' : '${x.oggi} da ripassare · ${quanti(x.totali, 'carta', 'carte')}',
                              style: testo(14, colore: AuriColori.grigio),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: x.oggi == 0 ? null : () => apri(x.corso.id),
                                    child: Text(x.oggi == 0 ? 'Tutto ripassato' : 'Ripassa'),
                                  ),
                                ),
                                if (x.slide) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => simula(x.corso.id),
                                      child: const Text("Simulazione d'esame", textAlign: TextAlign.center),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _nuovaCarta(BuildContext context, WidgetRef ref) async {
    final corsi = ref.read(corsiProvider).value ?? const [];
    if (corsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prima crea un corso.')));
      return;
    }
    final carta = await showDialog<({int corsoId, String fronte, String retro})>(
      context: context,
      builder: (_) => _DialogoNuovaCarta(corsi: [for (final x in corsi) x.corso]),
    );
    if (carta == null) return;
    await ref
        .read(repositoryProvider)
        .salvaCarta(
          CarteCompanion.insert(corsoId: carta.corsoId, fronte: carta.fronte, retro: carta.retro, origine: OrigineCarta.manuale, pagina: const Value(null)),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carta creata')));
  }
}

/// Finestra "Nuova carta": si chiude solo con domanda e risposta scritte (o con Annulla).
class _DialogoNuovaCarta extends StatefulWidget {
  const _DialogoNuovaCarta({required this.corsi});
  final List<Corso> corsi;

  @override
  State<_DialogoNuovaCarta> createState() => _DialogoNuovaCartaState();
}

class _DialogoNuovaCartaState extends State<_DialogoNuovaCarta> {
  late int _corsoId = widget.corsi.first.id;
  final _fronte = TextEditingController();
  final _retro = TextEditingController();
  bool _incompleta = false;

  @override
  void dispose() {
    _fronte.dispose();
    _retro.dispose();
    super.dispose();
  }

  void _salva() {
    final fronte = _fronte.text.trim();
    final retro = _retro.text.trim();
    if (fronte.isEmpty || retro.isEmpty) {
      setState(() => _incompleta = true);
      return;
    }
    Navigator.pop(context, (corsoId: _corsoId, fronte: fronte, retro: retro));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nuova carta'),
    content: SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _corsoId,
            decoration: const InputDecoration(labelText: 'Corso'),
            items: [for (final c in widget.corsi) DropdownMenuItem(value: c.id, child: Text(c.nome))],
            onChanged: (v) => setState(() => _corsoId = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fronte,
            decoration: const InputDecoration(labelText: 'Domanda (fronte)'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _retro,
            decoration: const InputDecoration(labelText: 'Risposta (retro)'),
            maxLines: 3,
          ),
          if (_incompleta) ...[
            const SizedBox(height: 12),
            Text(
              'Scrivi la domanda e la risposta.',
              style: testo(14, colore: AuriColori.arancio, peso: FontWeight.w600),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
      FilledButton(onPressed: _salva, child: const Text('Salva')),
    ],
  );
}
