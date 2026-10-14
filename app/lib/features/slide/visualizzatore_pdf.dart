import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'annotazioni.dart';

/// PDF con salto alla pagina richiesta; segnala la pagina visibile quando si scorre.
class VisualizzatorePdf extends StatefulWidget {
  const VisualizzatorePdf({super.key, required this.percorso, required this.pagina, required this.documentoId, this.paginaCambiata});
  final String percorso;
  final int pagina;
  final int documentoId;
  final ValueChanged<int>? paginaCambiata;

  @override
  State<VisualizzatorePdf> createState() => _VisualizzatorePdfState();
}

class _VisualizzatorePdfState extends State<VisualizzatorePdf> {
  final _controller = PdfViewerController();
  late int _visibile = widget.pagina;

  @override
  void didUpdateWidget(VisualizzatorePdf vecchio) {
    super.didUpdateWidget(vecchio);
    // Si salta solo se la pagina richiesta non è già quella sullo schermo (es. arriva dallo scorrimento).
    if (widget.pagina != _visibile && _controller.isReady) {
      _visibile = widget.pagina;
      _controller.goToPage(pageNumber: widget.pagina);
    }
  }

  @override
  Widget build(BuildContext context) => PdfViewer.file(
    widget.percorso,
    controller: _controller,
    initialPageNumber: widget.pagina,
    params: PdfViewerParams(
      onPageChanged: (numero) {
        if (numero == null || numero == _visibile) return;
        _visibile = numero;
        widget.paginaCambiata?.call(numero);
      },
      // Su ogni pagina, il livello con le annotazioni della Pencil.
      pageOverlaysBuilder: (context, pageRect, page) => [
        Positioned.fromRect(
          rect: pageRect,
          child: StratoAnnotazioni(documentoId: widget.documentoId, pagina: page.pageNumber),
        ),
      ],
    ),
  );
}
