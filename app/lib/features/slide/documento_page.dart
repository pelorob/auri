import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/riassunto.dart';
import '../../domain/slide.dart';
import '../../services/ocr.dart';
import '../../services/scheda_pdf.dart';
import 'annotazioni.dart';

class _Dati {
  const _Dati(this.documento, this.pagine, this.percorso, this.analisi);
  final Documento documento;
  final List<Pagina> pagine;
  final String percorso;
  final _Analisi analisi;
}

_Analisi _analizza((List<String>, Map<int, String>) dati) => _Analisi(indiceDaPagine(dati.$1), glossario(dati.$2), definizioni(dati.$2), riassunto(dati.$2));

/// Indice, glossario, definizioni e riassunto: calcolati una volta, fuori dal thread dell'interfaccia.
class _Analisi {
  const _Analisi(this.indice, this.termini, this.definizioni, this.riassunto);
  final List<VoceIndice> indice;
  final List<TermineGlossario> termini;
  final List<Definizione> definizioni;
  final List<Frase> riassunto;
}

/// Un PDF con indice, glossario e definizioni a fianco.
class DocumentoPage extends ConsumerStatefulWidget {
  const DocumentoPage({super.key, required this.documentoId, this.paginaIniziale = 1});
  final int documentoId;
  final int paginaIniziale;

  @override
  ConsumerState<DocumentoPage> createState() => _DocumentoPageState();
}

class _DocumentoPageState extends ConsumerState<DocumentoPage> {
  late int _pagina = widget.paginaIniziale;
  late Future<_Dati> _dati = _carica();

  Future<_Dati> _carica() async {
    final repo = ref.read(repositoryProvider);
    final doc = (await repo.documento(widget.documentoId))!;
    final pagine = await repo.pagineDi(widget.documentoId);
    final cartella = await ref.read(cartellaSlideProvider)();
    final dati = ([for (final x in pagine) x.titolo], {for (final x in pagine) x.numero: x.testo});
    final analisi = await Isolate.run(() => _analizza(dati));
    return _Dati(doc, pagine, p.join(cartella.path, doc.nomeFile), analisi);
  }

  Future<void> _leggiImmagini(String percorso) async {
    final avvisi = ScaffoldMessenger.of(context);
    final avanzamento = ValueNotifier<double?>(null);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Sto leggendo le slide…'),
        content: ValueListenableBuilder<double?>(
          valueListenable: avanzamento,
          builder: (_, v, _) => LinearProgressIndicator(value: v),
        ),
      ),
    );
    try {
      final n = await ref.read(letturaScansioniProvider).leggiDocumento(widget.documentoId, percorso, avanzamento: (f, t) => avanzamento.value = f / t);
      avvisi.showSnackBar(SnackBar(content: Text(n == 0 ? 'Non ho trovato testo in queste immagini.' : 'Testo letto in $n pagine: ora puoi cercarlo.')));
    } on OcrNonDisponibile catch (e) {
      avvisi.showSnackBar(SnackBar(content: Text(e.toString())));
    } catch (_) {
      avvisi.showSnackBar(const SnackBar(content: Text('Lettura non riuscita: riprova.')));
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _dati = _carica();
        });
      }
    }
  }

  Widget _voce(String testoVoce, int pagina, {String? sotto}) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    selected: pagina == _pagina,
    title: Text(testoVoce, style: testo(14, peso: FontWeight.w600)),
    subtitle: sotto == null ? null : Text(sotto, style: testo(12, colore: AuriColori.grigio)),
    trailing: Text('$pagina', style: testo(12, colore: AuriColori.grigio)),
    onTap: () => setState(() => _pagina = pagina),
  );

  @override
  Widget build(BuildContext context) {
    final visualizzatore = ref.watch(visualizzatorePdfProvider);
    return Scaffold(
      backgroundColor: AuriColori.sfondo,
      appBar: AppBar(backgroundColor: AuriColori.sfondo),
      body: FutureBuilder<_Dati>(
        future: _dati,
        builder: (context, s) {
          if (s.hasError) {
            return Center(
              child: Text('Non riesco ad aprire questo PDF.', style: testo(16, colore: AuriColori.grigio)),
            );
          }
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final d = s.data!;
          final soloImmagini = d.pagine.where((x) => x.testo.trim().isEmpty).length;
          final indice = d.analisi.indice;
          final termini = d.analisi.termini;
          final defs = d.analisi.definizioni;
          final sintesi = d.analisi.riassunto;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 320,
                  child: Scheda(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(d.documento.titolo, style: titolo(22), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('${d.documento.numeroPagine} pagine', style: testo(13, colore: AuriColori.grigio)),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final avvisi = ScaffoldMessenger.of(context);
                                final n = await ref.read(repositoryProvider).generaCarte(widget.documentoId);
                                avvisi.showSnackBar(
                                  SnackBar(content: Text(n == 0 ? 'Nessuna nuova flashcard: le hai già tutte' : '$n flashcard create: le trovi in Ripasso')),
                                );
                              },
                              icon: const Icon(Icons.style_outlined),
                              label: const Text('Crea flashcard'),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Builder(
                              builder: (ctx) => TextButton.icon(
                                onPressed: () async {
                                  final box = ctx.findRenderObject()! as RenderBox;
                                  final origine = box.localToGlobal(Offset.zero) & box.size;
                                  final corso = (ref.read(corsiProvider).value ?? const []).where((c) => c.corso.id == d.documento.corsoId).firstOrNull;
                                  final byte = await creaSchedaPdf(
                                    titolo: d.documento.titolo,
                                    corso: corso?.corso.nome ?? '',
                                    indice: indice,
                                    riassunto: sintesi,
                                    glossario: termini,
                                    definizioni: defs,
                                  );
                                  final file = File(p.join((await getTemporaryDirectory()).path, 'Scheda ${d.documento.titolo}.pdf'))..writeAsBytesSync(byte);
                                  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], sharePositionOrigin: origine));
                                },
                                icon: const Icon(Icons.print_outlined),
                                label: const Text('Scheda PDF'),
                              ),
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final fatta = (ref.watch(pagineStudiateProvider).value ?? const []).any(
                                (p) => p.documentoId == widget.documentoId && p.pagina == _pagina,
                              );
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                value: fatta,
                                title: const Text('Ho studiato questa pagina'),
                                subtitle: Text('pagina $_pagina'),
                                onChanged: (v) =>
                                    ref.read(repositoryProvider).segnaStudiata(widget.documentoId, _pagina, v ?? false, ref.read(orologioProvider)()),
                              );
                            },
                          ),
                          if (soloImmagini > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Scheda(
                                colore: AuriColori.lime,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      soloImmagini == d.pagine.length
                                          ? 'Questo PDF contiene solo immagini: la ricerca non trova nulla.'
                                          : '${soloImmagini == 1 ? '1 pagina è' : '$soloImmagini pagine sono'} solo immagini: la ricerca non le trova.',
                                      style: testo(13, peso: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    FilledButton.icon(
                                      onPressed: () => _leggiImmagini(d.percorso),
                                      icon: const Icon(Icons.document_scanner_outlined),
                                      label: const Text('Leggi il testo dalle immagini'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelPadding: EdgeInsets.symmetric(horizontal: 10),
                            tabs: [
                              Tab(text: 'Indice'),
                              Tab(text: 'Glossario'),
                              Tab(text: 'Definizioni'),
                              Tab(text: 'Riassunto'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                ListView(children: [for (final v in indice) _voce(v.titolo, v.pagina)]),
                                ListView(children: [for (final t in termini) _voce(t.termine, t.pagine.first, sotto: 'pagine ${t.pagine.join(', ')}')]),
                                ListView(children: [for (final x in defs) _voce(x.testo, x.pagina)]),
                                ListView(children: [for (final f in sintesi) _voce(f.testo, f.pagina)]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BarraStrumenti(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: ColoredBox(color: Colors.white, child: visualizzatore(d.percorso, _pagina, widget.documentoId, (n) => setState(() => _pagina = n))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
