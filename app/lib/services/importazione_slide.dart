import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../domain/slide.dart';

class PdfNonLeggibile implements Exception {
  const PdfNonLeggibile();
  @override
  String toString() => 'Non riesco a leggere questo PDF.';
}

/// Importa un PDF: ne legge il testo pagina per pagina, lo copia tra i file dell'app e lo indicizza.
class ImportazioneSlide {
  ImportazioneSlide(this._repo, this._cartellaSlide);

  final Repository _repo;
  final Future<Directory> Function() _cartellaSlide;

  Future<int> importa(File pdf, {required int corsoId, String? titolo, void Function(int fatte, int totali)? avanzamento}) async {
    final pagine = await _leggi(pdf, avanzamento);
    final cartella = await _cartellaSlide();
    final nomeFile = '${DateTime.now().microsecondsSinceEpoch}.pdf';
    final copia = await pdf.copy(p.join(cartella.path, nomeFile));
    try {
      return await _repo.salvaDocumento(
        DocumentiCompanion.insert(
          corsoId: corsoId,
          titolo: (titolo?.trim().isNotEmpty ?? false) ? titolo!.trim() : p.basenameWithoutExtension(pdf.path),
          nomeFile: nomeFile,
          numeroPagine: pagine.length,
          importatoIl: DateTime.now(),
        ),
        pagine,
      );
    } catch (_) {
      if (copia.existsSync()) copia.deleteSync();
      rethrow;
    }
  }

  Future<void> elimina(int documentoId) async {
    final doc = await _repo.documento(documentoId);
    if (doc == null) return;
    await _repo.eliminaDocumento(documentoId);
    final file = File(p.join((await _cartellaSlide()).path, doc.nomeFile));
    if (file.existsSync()) file.deleteSync();
  }

  /// Elimina il corso e anche i file PDF dei suoi documenti (il database li toglie a cascata, i file no).
  Future<void> eliminaCorso(int corsoId) async {
    final nomi = [for (final d in await _repo.documentiDelCorso(corsoId)) d.nomeFile];
    await _repo.eliminaCorso(corsoId);
    final cartella = (await _cartellaSlide()).path;
    for (final nome in nomi) {
      final file = File(p.join(cartella, nome));
      if (file.existsSync()) file.deleteSync();
    }
  }

  Future<List<PaginaNuova>> _leggi(File pdf, void Function(int, int)? avanzamento) async {
    final PdfDocument doc;
    try {
      doc = await PdfDocument.openFile(pdf.path);
    } catch (_) {
      throw const PdfNonLeggibile();
    }
    try {
      final testi = <String>[];
      for (final pagina in doc.pages) {
        final t = await pagina.loadText();
        testi.add(t?.fullText ?? '');
        avanzamento?.call(testi.length, doc.pages.length);
      }
      final titoli = await _titoliDaStruttura(doc, testi.length) ?? [for (final t in testi) titoloPagina(t)];
      return [for (var i = 0; i < testi.length; i++) (numero: i + 1, titolo: titoli[i], testo: testi[i])];
    } catch (e) {
      if (e is PdfNonLeggibile) rethrow;
      throw const PdfNonLeggibile();
    } finally {
      await doc.dispose();
    }
  }

  /// Se il PDF ha una struttura (segnalibri), ogni pagina prende il titolo della voce che la precede.
  Future<List<String>?> _titoliDaStruttura(PdfDocument doc, int numeroPagine) async {
    final voci = <(int, String)>[];
    void visita(List<PdfOutlineNode> nodi) {
      for (final n in nodi) {
        final pagina = n.dest?.pageNumber;
        if (pagina != null && n.title.trim().isNotEmpty) voci.add((pagina, n.title.trim()));
        visita(n.children);
      }
    }

    visita(await doc.loadOutline());
    if (voci.isEmpty) return null;
    voci.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (var n = 1; n <= numeroPagine; n++) voci.lastWhere((v) => v.$1 <= n, orElse: () => (0, '')).$2];
  }
}
