import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/repository.dart';
import '../../domain/slide.dart';
import '../../services/importazione_slide.dart';
import 'documento_page.dart';

class SlidePage extends ConsumerStatefulWidget {
  const SlidePage({super.key});
  @override
  ConsumerState<SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends ConsumerState<SlidePage> {
  final _cerca = TextEditingController();
  Timer? _attesa;
  List<RisultatoRicerca>? _risultati;
  int _ricerca = 0;

  void _aggiornaRicerca(String testo) {
    _attesa?.cancel();
    final questa = ++_ricerca;
    _attesa = Timer(const Duration(milliseconds: 250), () async {
      final r = testo.trim().isEmpty ? null : await ref.read(repositoryProvider).cerca(testo);
      // Se nel frattempo ha scritto altro, vale solo l'ultima ricerca.
      if (mounted && questa == _ricerca) setState(() => _risultati = r);
    });
  }

  @override
  void dispose() {
    _attesa?.cancel();
    _cerca.dispose();
    super.dispose();
  }

  void _apri(int documentoId, {int pagina = 1}) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DocumentoPage(documentoId: documentoId, paginaIniziale: pagina),
    ),
  );

  Future<void> _importa() async {
    final avvisi = ScaffoldMessenger.of(context);
    final scelta = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (scelta.isEmpty || scelta.single.path == null || !mounted) return;
    final corsi = ref.read(corsiProvider).value ?? const [];
    if (corsi.isEmpty) {
      avvisi.showSnackBar(const SnackBar(content: Text('Prima crea un corso a cui collegare le slide.')));
      return;
    }
    final corsoId = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Di quale corso sono queste slide?'),
        children: [for (final x in corsi) SimpleDialogOption(onPressed: () => Navigator.pop(c, x.corso.id), child: Text(x.corso.nome))],
      ),
    );
    if (corsoId == null || !mounted) return;
    final avanzamento = ValueNotifier<double?>(null);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Sto leggendo il PDF…'),
          content: ValueListenableBuilder<double?>(
            valueListenable: avanzamento,
            builder: (_, v, _) => LinearProgressIndicator(value: v),
          ),
        ),
      ),
    );
    try {
      final id = await ref.read(importazioneProvider).importa(File(scelta.single.path!), corsoId: corsoId, avanzamento: (f, t) => avanzamento.value = f / t);
      if (mounted) Navigator.of(context).pop();
      _apri(id);
    } on PdfNonLeggibile {
      if (mounted) Navigator.of(context).pop();
      avvisi.showSnackBar(const SnackBar(content: Text('Non riesco a leggere questo PDF (protetto o danneggiato?).')));
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      avvisi.showSnackBar(const SnackBar(content: Text('Importazione non riuscita: riprova.')));
    }
  }

  Future<void> _elimina(DocumentoConCorso d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Eliminare "${d.documento.titolo}"?'),
        content: const Text('Il PDF e la sua ricerca verranno tolti dall\'app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Elimina')),
        ],
      ),
    );
    if (ok == true) await ref.read(importazioneProvider).elimina(d.documento.id);
  }

  @override
  Widget build(BuildContext context) {
    final documenti = ref.watch(documentiProvider).value ?? const <DocumentoConCorso>[];
    final perCorso = <String, List<DocumentoConCorso>>{};
    for (final d in documenti) {
      (perCorso[d.corso.nome] ??= []).add(d);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitoloPagina(
          sopra: '${documenti.length} PDF',
          testoTitolo: 'Slide',
          azione: FilledButton.icon(onPressed: _importa, icon: const Icon(Icons.upload_file_rounded), label: const Text('Importa PDF')),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cerca,
          onChanged: _aggiornaRicerca,
          decoration: const InputDecoration(hintText: 'Cerca nelle slide', prefixIcon: Icon(Icons.search_rounded)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Scheda(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: _risultati != null
                ? (_risultati!.isEmpty
                      ? Center(
                          child: Text('Nessun risultato', style: testo(15, colore: AuriColori.grigio)),
                        )
                      : ListView(
                          children: [
                            for (final r in _risultati!)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('${r.documento.titolo} · pag. ${r.pagina}', style: testo(15, peso: FontWeight.w700)),
                                subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      for (final (parte, evidenziata) in segmentiEstratto(r.estratto))
                                        TextSpan(
                                          text: parte,
                                          style: evidenziata
                                              ? testo(14, peso: FontWeight.w800).copyWith(backgroundColor: AuriColori.lime)
                                              : testo(14, colore: AuriColori.grigio),
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: Text(r.corso.nome, style: testo(12, colore: AuriColori.grigio)),
                                onTap: () => _apri(r.documento.id, pagina: r.pagina),
                              ),
                          ],
                        ))
                : (documenti.isEmpty
                      ? Center(
                          child: Text('Importa le slide dei tuoi corsi', style: titolo(24, colore: AuriColori.grigio)),
                        )
                      : ListView(
                          children: [
                            for (final MapEntry(key: corso, value: docs) in perCorso.entries) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: Etichetta(corso, colore: AuriColori.viola),
                              ),
                              for (final d in docs)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.picture_as_pdf_outlined, color: AuriColori.viola),
                                  title: Text(d.documento.titolo, style: testo(15, peso: FontWeight.w700)),
                                  subtitle: Text('${d.documento.numeroPagine} pagine', style: testo(13, colore: AuriColori.grigio)),
                                  trailing: IconButton(tooltip: 'Elimina', onPressed: () => _elimina(d), icon: const Icon(Icons.delete_outline_rounded)),
                                  onTap: () => _apri(d.documento.id),
                                ),
                            ],
                          ],
                        )),
          ),
        ),
      ],
    );
  }
}
