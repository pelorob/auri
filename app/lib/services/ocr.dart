import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../data/repository.dart';

class OcrNonDisponibile implements Exception {
  const OcrNonDisponibile();
  @override
  String toString() => 'La lettura del testo dalle immagini non è disponibile su questo dispositivo.';
}

/// Riconoscimento del testo in un'immagine PNG (sostituibile nei test).
abstract class Ocr {
  Future<String> leggi(Uint8List png);
}

/// Usa Apple Vision tramite il canale nativo "auri/ocr" (vedi AppDelegate.swift).
class OcrVision implements Ocr {
  const OcrVision();
  static const _canale = MethodChannel('auri/ocr');

  @override
  Future<String> leggi(Uint8List png) async {
    try {
      return await _canale.invokeMethod<String>('leggi', png) ?? '';
    } on MissingPluginException {
      throw const OcrNonDisponibile();
    }
  }
}

typedef RenderPagina = Future<Uint8List> Function(String percorsoPdf, int numero);

/// Trasforma una pagina del PDF in immagine PNG (doppia risoluzione, per leggere meglio).
Future<Uint8List> renderPaginaPdf(String percorsoPdf, int numero) async {
  final doc = await PdfDocument.openFile(percorsoPdf);
  try {
    final pagina = doc.pages[numero - 1];
    final immagine = await pagina.render(fullWidth: pagina.width * 2, fullHeight: pagina.height * 2);
    if (immagine == null) return Uint8List(0);
    try {
      final ui.Image img = await immagine.createImage();
      try {
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        return png!.buffer.asUint8List();
      } finally {
        img.dispose();
      }
    } finally {
      immagine.dispose();
    }
  } finally {
    await doc.dispose();
  }
}

/// Legge con l'OCR le pagine senza testo di un PDF (slide scansionate).
class LetturaScansioni {
  LetturaScansioni(this._repo, this._ocr, [this._render = renderPaginaPdf]);
  final Repository _repo;
  final Ocr _ocr;
  final RenderPagina _render;

  /// Restituisce quante pagine hanno ora del testo.
  Future<int> leggiDocumento(int documentoId, String percorsoPdf, {void Function(int fatte, int totali)? avanzamento}) async {
    final vuote = (await _repo.pagineDi(documentoId)).where((p) => p.testo.trim().isEmpty).toList();
    var trovate = 0;
    for (var i = 0; i < vuote.length; i++) {
      final png = await _render(percorsoPdf, vuote[i].numero);
      final testo = png.isEmpty ? '' : (await _ocr.leggi(png)).trim();
      if (testo.isNotEmpty) {
        await _repo.aggiornaTestoPagina(documentoId, vuote[i].numero, testo);
        trovate++;
      }
      avanzamento?.call(i + 1, vuote.length);
    }
    return trovate;
  }
}
