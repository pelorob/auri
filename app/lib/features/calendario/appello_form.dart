import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/formati.dart';
import '../../domain/modelli.dart';
import '../../domain/notifiche_piano.dart';

Future<void> mostraFormAppello(BuildContext context, {Appello? appello, Corso? corsoIniziale}) => showDialog(
  context: context,
  builder: (_) => Dialog(
    child: SizedBox(
      width: 520,
      child: FormAppello(appello: appello, corsoIniziale: corsoIniziale),
    ),
  ),
);

const _opzioni = opzioniPreavviso;
const _etichetteOpzioni = etichetteOpzioniPreavviso;

class FormAppello extends ConsumerStatefulWidget {
  const FormAppello({super.key, this.appello, this.corsoIniziale});
  final Appello? appello;
  final Corso? corsoIniziale;
  @override
  ConsumerState<FormAppello> createState() => _FormAppelloState();
}

class _FormAppelloState extends ConsumerState<FormAppello> {
  late int? _corsoId = widget.appello?.corsoId ?? widget.corsoIniziale?.id;
  late DateTime _quando =
      widget.appello?.dataOra ?? DateTime.now().add(const Duration(days: 14)).copyWith(hour: 9, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  late TipoAppello _tipo = widget.appello?.tipo ?? TipoAppello.scritto;
  late final _aula = TextEditingController(text: widget.appello?.aula);
  late final _note = TextEditingController(text: widget.appello?.note);
  late Set<Preavviso> _preavvisi;
  String? _errore;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final pref = ref.read(preferenzeProvider).value;
    _preavvisi = leggiPreavvisi(widget.appello?.preavvisi ?? pref?.preavvisi ?? preavvisiPredefiniti).toSet();
  }

  Future<void> _salva() async {
    if (_salvando) return;
    if (_corsoId == null) return setState(() => _errore = 'Scegli il corso');
    // Un secondo tocco mentre salva non deve creare un appello doppio.
    setState(() => _salvando = true);
    try {
      await _scrivi();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _scrivi() async {
    // Prima il permesso: così la riprogrammazione dopo il salvataggio può già programmare le notifiche.
    await ref.read(richiestaPermessoNotificheProvider)();
    await ref
        .read(repositoryProvider)
        .salvaAppello(
          AppelliCompanion(
            id: widget.appello == null ? const Value.absent() : Value(widget.appello!.id),
            corsoId: Value(_corsoId!),
            dataOra: Value(_quando),
            tipo: Value(_tipo),
            aula: Value(_aula.text.trim().isEmpty ? null : _aula.text.trim()),
            note: Value(_note.text.trim().isEmpty ? null : _note.text.trim()),
            iscritta: Value(widget.appello?.iscritta ?? false),
            preavvisi: Value(scriviPreavvisi(_opzioni.where(_preavvisi.contains).toList())),
          ),
        );
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final corsi = ref.watch(corsiProvider).value ?? const [];
    final scelta = corsi.any((c) => c.corso.id == _corsoId) ? _corsoId : null;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.appello == null ? 'Nuovo appello' : 'Modifica appello', style: titolo(26)),
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(
              initialValue: scelta,
              decoration: const InputDecoration(labelText: 'Corso'),
              items: [for (final c in corsi) DropdownMenuItem(value: c.corso.id, child: Text(c.corso.nome))],
              onChanged: (v) => setState(() => _corsoId = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Giorno'),
                    subtitle: Text('${giornoSettimana(_quando)} ${dataLunga(_quando)} ${_quando.year}'),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _quando, firstDate: DateTime(2020), lastDate: DateTime(2100));
                      if (d != null) setState(() => _quando = DateTime(d.year, d.month, d.day, _quando.hour, _quando.minute));
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Ora'),
                    subtitle: Text(oraMinuti(_quando)),
                    onTap: () async {
                      final o = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_quando));
                      if (o != null) setState(() => _quando = DateTime(_quando.year, _quando.month, _quando.day, o.hour, o.minute));
                    },
                  ),
                ),
              ],
            ),
            SegmentedButton<TipoAppello>(
              segments: const [
                ButtonSegment(value: TipoAppello.scritto, label: Text('Scritto')),
                ButtonSegment(value: TipoAppello.orale, label: Text('Orale')),
                ButtonSegment(value: TipoAppello.altro, label: Text('Altro')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aula,
              decoration: const InputDecoration(labelText: 'Aula (facoltativa)'),
            ),
            const SizedBox(height: 12),
            Text('Avvisami', style: testo(15, peso: FontWeight.w700)),
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < _opzioni.length; i++)
                  FilterChip(
                    label: Text(_etichetteOpzioni[i]),
                    selected: _preavvisi.contains(_opzioni[i]),
                    onSelected: (s) => setState(() => s ? _preavvisi.add(_opzioni[i]) : _preavvisi.remove(_opzioni[i])),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note (facoltative)'),
              maxLines: 2,
            ),
            if (_errore != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_errore!, style: testo(14, colore: AuriColori.arancio)),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.appello != null)
                  TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Eliminare l\'appello?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
                            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Elimina')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref.read(repositoryProvider).eliminaAppello(widget.appello!.id);
                        if (context.mounted) Navigator.of(context).maybePop();
                      }
                    },
                    child: const Text('Elimina'),
                  ),
                const Spacer(),
                TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Annulla')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _salvando ? null : _salva, child: const Text('Salva')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
