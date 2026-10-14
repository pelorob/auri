import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/modelli.dart';
import '../../domain/validazione.dart';

Future<void> mostraFormCorso(BuildContext context, {Corso? corso}) => showDialog(
  context: context,
  builder: (_) => Dialog(
    child: SizedBox(width: 520, child: FormCorso(corso: corso)),
  ),
);

class FormCorso extends ConsumerStatefulWidget {
  const FormCorso({super.key, this.corso});
  final Corso? corso;
  @override
  ConsumerState<FormCorso> createState() => _FormCorsoState();
}

class _FormCorsoState extends ConsumerState<FormCorso> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.corso?.nome);
  late final _cfu = TextEditingController(text: widget.corso?.cfu.toString());
  late final _docente = TextEditingController(text: widget.corso?.docente);
  late int _anno = widget.corso?.anno ?? 1;
  late int? _semestre = widget.corso?.semestre;
  late String _colore = widget.corso?.colore ?? paletteCorsi.first;
  late Valutazione _valutazione = widget.corso?.valutazione ?? Valutazione.voto;
  bool _salvando = false;

  Future<void> _salva() async {
    if (_salvando || !_form.currentState!.validate()) return;
    // Un secondo tocco mentre salva non deve creare un corso doppio.
    setState(() => _salvando = true);
    try {
      await _scrivi();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _scrivi() async {
    final repo = ref.read(repositoryProvider);
    final vecchio = widget.corso;
    if (vecchio != null && vecchio.valutazione != _valutazione && await repo.haEsito(vecchio.id)) {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Cambiare il tipo di valutazione?'),
          content: const Text('Il voto registrato verrà tolto: dovrai registrarlo di nuovo.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Continua')),
          ],
        ),
      );
      if (ok != true) return;
      await repo.eliminaEsito(vecchio.id);
    }
    final c = CorsiCompanion(
      id: widget.corso == null ? const Value.absent() : Value(widget.corso!.id),
      nome: Value(_nome.text.trim()),
      cfu: Value(int.parse(_cfu.text.trim())),
      anno: Value(_anno),
      semestre: Value(_semestre),
      docente: Value(_docente.text.trim().isEmpty ? null : _docente.text.trim()),
      colore: Value(_colore),
      valutazione: Value(_valutazione),
    );
    await repo.salvaCorso(c);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.corso == null ? 'Nuovo corso' : 'Modifica corso', style: titolo(26)),
              const SizedBox(height: 18),
              TextFormField(
                key: const Key('nome'),
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: validaNome,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('cfu'),
                      controller: _cfu,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CFU'),
                      validator: validaCfu,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _anno,
                      decoration: const InputDecoration(labelText: 'Anno'),
                      items: [for (var a = 1; a <= 6; a++) DropdownMenuItem(value: a, child: Text('$a° anno'))],
                      onChanged: (v) => setState(() => _anno = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: _semestre,
                      decoration: const InputDecoration(labelText: 'Semestre'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('—')),
                        DropdownMenuItem(value: 1, child: Text('1°')),
                        DropdownMenuItem(value: 2, child: Text('2°')),
                      ],
                      onChanged: (v) => setState(() => _semestre = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _docente,
                decoration: const InputDecoration(labelText: 'Docente (facoltativo)'),
              ),
              const SizedBox(height: 16),
              SegmentedButton<Valutazione>(
                segments: const [
                  ButtonSegment(value: Valutazione.voto, label: Text('Con voto')),
                  ButtonSegment(value: Valutazione.idoneita, label: Text('Idoneità')),
                ],
                selected: {_valutazione},
                onSelectionChanged: (s) => setState(() => _valutazione = s.first),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: [
                  for (final hex in paletteCorsi)
                    Semantics(
                      label: 'Colore $hex',
                      selected: hex == _colore,
                      button: true,
                      child: InkWell(
                        onTap: () => setState(() => _colore = hex),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: coloreDaHex(hex),
                            shape: BoxShape.circle,
                            border: Border.all(color: hex == _colore ? AuriColori.inchiostro : Colors.transparent, width: 3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Annulla')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _salvando ? null : _salva, child: const Text('Salva')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
