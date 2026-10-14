import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../domain/formati.dart';
import '../../domain/notifiche_piano.dart';
import '../../domain/preferenze.dart';
import 'backup_azioni.dart';

const kVersione = '0.5.0';

class ImpostazioniPage extends ConsumerWidget {
  const ImpostazioniPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(preferenzeProvider).value ?? Preferenze.predefinite;
    Future<void> salva(String chiave, String valore) => ref.read(repositoryProvider).salvaPreferenza(chiave, valore);
    final touchId = ref.watch(touchIdDisponibileProvider).value ?? false;
    final scadenza = ref.watch(scadenzaFirmaProvider).value?.toLocal();

    return ListView(
      children: [
        const TitoloPagina(sopra: 'auri', testoTitolo: 'Impostazioni'),
        const SizedBox(height: 20),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Il tuo corso di laurea', style: titolo(20, peso: FontWeight.w700)),
              const SizedBox(height: 12),
              _CampoNome(valore: p.nomeCorsoDiLaurea, salva: (v) => salva(Preferenze.kNome, v)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('CFU totali', style: testo(15, peso: FontWeight.w600)),
                  const Spacer(),
                  for (final v in [120, 180, 300, 360])
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(label: Text('$v'), selected: p.cfuTotali == v, onSelected: (_) => salva(Preferenze.kCfuTotali, '$v')),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Valore della lode', style: testo(15, peso: FontWeight.w600)),
                  const Spacer(),
                  SegmentedButton<int>(
                    segments: [
                      for (final v in [30, 31, 32, 33]) ButtonSegment(value: v, label: Text('$v')),
                    ],
                    selected: {p.valoreLode},
                    onSelectionChanged: (s) => salva(Preferenze.kLode, '${s.first}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Avvisi degli appelli', style: titolo(20, peso: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Valgono per i nuovi appelli; puoi cambiarli per ogni appello.', style: testo(14, colore: AuriColori.grigio)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < opzioniPreavviso.length; i++)
                    FilterChip(
                      label: Text(etichetteOpzioniPreavviso[i]),
                      selected: leggiPreavvisi(p.preavvisi).contains(opzioniPreavviso[i]),
                      onSelected: (s) {
                        final scelti = leggiPreavvisi(p.preavvisi).toSet();
                        s ? scelti.add(opzioniPreavviso[i]) : scelti.remove(opzioniPreavviso[i]);
                        salva(Preferenze.kPreavvisi, scriviPreavvisi(opzioniPreavviso.where(scelti.contains).toList()));
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sicurezza', style: titolo(20, peso: FontWeight.w700)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Blocca auri con Touch ID'),
                subtitle: touchId
                    ? const Text('Se Touch ID non riesce puoi usare il codice dell\'iPad')
                    : const Text('Touch ID non è configurato su questo iPad: attivalo in Impostazioni → Touch ID e codice.'),
                value: p.bloccoAttivo && touchId,
                onChanged: touchId ? (v) => salva(Preferenze.kBlocco, '$v') : null,
              ),
              if (p.bloccoAttivo && touchId)
                Row(
                  children: [
                    const Text('Richiedi lo sblocco dopo'),
                    const Spacer(),
                    DropdownButton<int>(
                      value: [1, 5, 15, 30].contains(p.minutiRiblocco) ? p.minutiRiblocco : 5,
                      items: [
                        for (final m in [1, 5, 15, 30]) DropdownMenuItem(value: m, child: Text('$m minuti')),
                      ],
                      onChanged: (m) => salva(Preferenze.kMinuti, '$m'),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Backup', style: titolo(20, peso: FontWeight.w700)),
              Text('Le slide PDF non sono nel backup: dopo un ripristino vanno reimportate.', style: testo(13, colore: AuriColori.grigio)),
              const SizedBox(height: 6),
              Text(
                p.ultimoBackup == null ? 'Non hai ancora fatto un backup.' : 'Ultimo backup: ${dataLunga(p.ultimoBackup!)} ${p.ultimoBackup!.year}',
                style: testo(14, colore: AuriColori.grigio),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Builder(
                    builder: (ctx) => FilledButton.icon(
                      onPressed: () {
                        final box = ctx.findRenderObject()! as RenderBox;
                        esportaBackup(ctx, ref, box.localToGlobal(Offset.zero) & box.size);
                      },
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Esporta backup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => ripristinaBackup(context, ref),
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Ripristina backup'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App', style: titolo(20, peso: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(scadenza == null ? 'Firma: non disponibile' : 'Firma valida fino a: ${giornoSettimana(scadenza)} ${dataLunga(scadenza)}'),
              Text('Versione $kVersione', style: testo(14, colore: AuriColori.grigio)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Il campo segue il valore salvato (es. dopo un ripristino), senza disturbare mentre scrive.
class _CampoNome extends StatefulWidget {
  const _CampoNome({required this.valore, required this.salva});
  final String valore;
  final ValueChanged<String> salva;
  @override
  State<_CampoNome> createState() => _CampoNomeState();
}

class _CampoNomeState extends State<_CampoNome> {
  late final _testo = TextEditingController(text: widget.valore);

  @override
  void didUpdateWidget(_CampoNome prima) {
    super.didUpdateWidget(prima);
    // Mentre scrive si salva il testo senza spazi ai lati: non va riscritto per quello.
    if (widget.valore != _testo.text.trim()) {
      _testo.value = TextEditingValue(
        text: widget.valore,
        selection: TextSelection.collapsed(offset: widget.valore.length),
      );
    }
  }

  @override
  void dispose() {
    _testo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _testo,
    decoration: const InputDecoration(labelText: 'Nome del corso di laurea'),
    onChanged: (v) => widget.salva(v.trim()),
  );
}
