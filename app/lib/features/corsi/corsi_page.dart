import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/repository.dart';
import '../../domain/formati.dart';
import '../../domain/modelli.dart';
import '../calendario/appello_form.dart';
import '../libretto/voto_form.dart';
import 'corso_form.dart';

class CorsiPage extends ConsumerWidget {
  const CorsiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final corsi = ref.watch(corsiProvider).value ?? const [];
    final appelli = ref.watch(appelliProvider).value ?? const [];
    final ora = ref.watch(orologioProvider)();
    String stato(CorsoConEsito c) {
      if (c.superato) return 'Superato · ${c.esito!.voto == null ? 'Idoneo' : '${c.esito!.voto}${c.esito!.lode ? 'L' : ''}'}';
      final prossimo = appelli.where((a) => a.corso.id == c.corso.id && a.appello.dataOra.isAfter(ora)).firstOrNull;
      return prossimo == null ? 'Da sostenere' : 'Appello ${dataLunga(prossimo.appello.dataOra)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitoloPagina(
          sopra: '${corsi.length} corsi',
          testoTitolo: 'Corsi',
          azione: FilledButton.icon(onPressed: () => mostraFormCorso(context), icon: const Icon(Icons.add_rounded), label: const Text('Nuovo corso')),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: corsi.isEmpty
              ? Center(
                  child: Text('Aggiungi il tuo primo corso', style: titolo(24, colore: AuriColori.grigio)),
                )
              : GridView.extent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    for (final c in corsi)
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => _dettaglio(context, ref, c, appelli.where((a) => a.corso.id == c.corso.id).toList()),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(color: coloreDaHex(c.corso.colore), shape: BoxShape.circle),
                                ),
                                const Spacer(),
                                Text(
                                  c.corso.nome,
                                  style: titolo(20, peso: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text('${c.corso.cfu} CFU · ${c.corso.anno}° anno', style: testo(13, colore: AuriColori.grigio)),
                                const SizedBox(height: 8),
                                Pillola(stato(c), sfondo: c.superato ? AuriColori.violaTenue : AuriColori.sfondo),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _dettaglio(BuildContext context, WidgetRef ref, CorsoConEsito c, List<AppelloConCorso> appelliCorso) {
    final pdf = (ref.read(documentiProvider).value ?? const []).where((d) => d.corso.id == c.corso.id).length;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c.corso.nome, style: titolo(26)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${c.corso.cfu} CFU · ${c.corso.anno}° anno${c.corso.docente == null ? '' : ' · ${c.corso.docente}'}'),
            const SizedBox(height: 8),
            Text(c.superato ? 'Superato il ${dataLunga(c.esito!.data)}' : 'Da sostenere'),
            if (pdf > 0) Text('$pdf PDF di slide'),
            if (appelliCorso.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Etichetta('Appelli'),
              const SizedBox(height: 6),
              for (final a in appelliCorso)
                Text(
                  '${a.appello.tipo.etichetta[0].toUpperCase()}${a.appello.tipo.etichetta.substring(1)} · ${dataLunga(a.appello.dataOra)} · ${oraMinuti(a.appello.dataOra)}',
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: ctx,
                builder: (c2) => AlertDialog(
                  title: const Text('Eliminare il corso?'),
                  content: const Text('Verranno eliminati anche i suoi appelli e il voto.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text('Annulla')),
                    FilledButton(onPressed: () => Navigator.pop(c2, true), child: const Text('Elimina')),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(importazioneProvider).eliminaCorso(c.corso.id);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Elimina'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              mostraFormAppello(context, corsoIniziale: c.corso);
            },
            child: const Text('Nuovo appello'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              mostraFormVoto(context, corso: c.corso);
            },
            child: Text(c.superato ? 'Modifica voto' : 'Registra voto'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              mostraFormCorso(context, corso: c.corso);
            },
            child: const Text('Modifica'),
          ),
        ],
      ),
    );
  }
}
