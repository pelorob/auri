import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/formati.dart';
import '../../domain/modelli.dart';
import '../../domain/validazione.dart';

Future<void> mostraFormVoto(BuildContext context, {Corso? corso}) => showDialog(
  context: context,
  builder: (_) => Dialog(
    child: SizedBox(width: 480, child: FormVoto(corso: corso)),
  ),
);

class FormVoto extends ConsumerStatefulWidget {
  const FormVoto({super.key, this.corso});
  final Corso? corso;
  @override
  ConsumerState<FormVoto> createState() => _FormVotoState();
}

class _FormVotoState extends ConsumerState<FormVoto> {
  Corso? _corso;
  int? _voto = 27;
  bool _lode = false;
  DateTime _data = DateTime.now();
  String? _errore;
  bool _salvataggio = false;

  @override
  void initState() {
    super.initState();
    _scegli(widget.corso);
  }

  /// Imposta il corso e, se ha già un voto, lo mostra (così non lo si sovrascrive per sbaglio).
  void _scegli(Corso? corso) {
    _corso = corso;
    final esistente = ref.read(corsiProvider).value?.where((c) => c.corso.id == corso?.id).firstOrNull?.esito;
    _voto = esistente?.voto ?? 27;
    _lode = esistente?.lode ?? false;
    _data = esistente?.data ?? DateTime.now();
  }

  bool get _aVoto => _corso?.valutazione != Valutazione.idoneita;

  Future<void> _salva() async {
    if (_salvataggio) return;
    if (_corso == null) return setState(() => _errore = 'Scegli il corso');
    if (_aVoto && validaVoto(_voto) != null) return setState(() => _errore = validaVoto(_voto));
    // Un secondo tocco mentre salva non deve registrare (né chiudere) due volte.
    setState(() => _salvataggio = true);
    try {
      await ref
          .read(repositoryProvider)
          .registraEsito(
            EsitiCompanion(
              corsoId: Value(_corso!.id),
              voto: Value(_aVoto ? _voto : null),
              lode: Value(_aVoto && _lode && lodeAmmessa(_voto)),
              data: Value(_data),
            ),
          );
      if (mounted) Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _salvataggio = false);
    }
  }

  Future<void> _togli() async {
    final corso = _corso!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Togliere il voto?'),
        content: Text('Il voto di ${corso.nome} verrà cancellato dal libretto.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Togli')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(repositoryProvider).eliminaEsito(corso.id);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final corsi = ref.watch(corsiProvider).value ?? const [];
    final esisteEsito = corsi.any((c) => c.corso.id == _corso?.id && c.superato);
    final scelta = corsi.any((c) => c.corso.id == _corso?.id) ? _corso?.id : null;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Registra voto', style: titolo(26)),
          const SizedBox(height: 18),
          DropdownButtonFormField<int>(
            initialValue: scelta,
            decoration: const InputDecoration(labelText: 'Corso'),
            items: [for (final c in corsi) DropdownMenuItem(value: c.corso.id, child: Text(c.corso.nome))],
            onChanged: (id) => setState(() => _scegli(corsi.firstWhere((c) => c.corso.id == id).corso)),
          ),
          const SizedBox(height: 16),
          if (_aVoto) ...[
            Row(
              children: [
                Text('Voto', style: testo(15, peso: FontWeight.w700)),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Abbassa',
                  onPressed: () => setState(() {
                    _voto = ((_voto ?? 18) - 1).clamp(18, 30);
                    if (!lodeAmmessa(_voto)) _lode = false;
                  }),
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 70,
                  child: Text('$_voto', key: const Key('voto'), textAlign: TextAlign.center, style: titolo(40)),
                ),
                IconButton.filled(
                  tooltip: 'Alza',
                  onPressed: () => setState(() => _voto = ((_voto ?? 18) + 1).clamp(18, 30)),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Lode'),
              value: _lode && lodeAmmessa(_voto),
              onChanged: lodeAmmessa(_voto) ? (v) => setState(() => _lode = v) : null,
            ),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Data'),
            trailing: Text(dataLunga(_data), style: testo(15, peso: FontWeight.w700)),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _data, firstDate: DateTime(2015), lastDate: DateTime(2100));
              if (d != null) setState(() => _data = d);
            },
          ),
          if (_errore != null) Text(_errore!, style: testo(14, colore: AuriColori.arancio)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (esisteEsito) TextButton(onPressed: _togli, child: const Text('Togli il voto')),
              const Spacer(),
              TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Annulla')),
              const SizedBox(width: 8),
              FilledButton(onPressed: _salvataggio ? null : _salva, child: const Text('Salva')),
            ],
          ),
        ],
      ),
    );
  }
}
