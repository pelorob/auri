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
                              x.totali == 0 ? 'Nessuna flashcard' : '${x.oggi} da ripassare · ${x.totali} carte',
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
    var corsoId = corsi.first.corso.id;
    final fronte = TextEditingController();
    final retro = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, aggiorna) => AlertDialog(
          title: const Text('Nuova carta'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: corsoId,
                  decoration: const InputDecoration(labelText: 'Corso'),
                  items: [for (final x in corsi) DropdownMenuItem(value: x.corso.id, child: Text(x.corso.nome))],
                  onChanged: (v) => aggiorna(() => corsoId = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fronte,
                  decoration: const InputDecoration(labelText: 'Domanda (fronte)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: retro,
                  decoration: const InputDecoration(labelText: 'Risposta (retro)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salva')),
          ],
        ),
      ),
    );
    if (ok != true || fronte.text.trim().isEmpty || retro.text.trim().isEmpty) return;
    await ref
        .read(repositoryProvider)
        .salvaCarta(
          CarteCompanion.insert(
            corsoId: corsoId,
            fronte: fronte.text.trim(),
            retro: retro.text.trim(),
            origine: OrigineCarta.manuale,
            pagina: const Value(null),
          ),
        );
  }
}
