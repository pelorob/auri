import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/riassunto.dart';
import '../domain/slide.dart';

const _sostituzioni = {
  '’': "'", '‘': "'", '“': '"', '”': '"', '…': '...', '–': '-', '—': '-', '•': '-', ' ': ' ', //
};

/// Testo limitato ai caratteri del font standard del PDF (Latin-1): il resto diventa "?".
String perPdf(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    final sost = _sostituzioni[c];
    if (sost != null) {
      b.write(sost);
    } else if (r < 256) {
      b.write(c);
    } else {
      b.write('?');
    }
  }
  return b.toString();
}

final _viola = PdfColor.fromInt(0xFF5B3DE6);
final _grigio = PdfColor.fromInt(0xFF6B6785);
final _lime = PdfColor.fromInt(0xFFD6F35B);

/// Scheda di ripasso stampabile di un PDF di slide.
Future<Uint8List> creaSchedaPdf({
  required String titolo,
  required String corso,
  required List<VoceIndice> indice,
  required List<Frase> riassunto,
  required List<TermineGlossario> glossario,
  required List<Definizione> definizioni,
}) {
  final doc = pw.Document(title: perPdf(titolo), author: 'auri');
  pw.Widget sezione(String nome) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
    child: pw.Text(
      nome,
      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _viola),
    ),
  );
  pw.Widget riga(String testo, {String? destra}) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: pw.Text(perPdf(testo), style: const pw.TextStyle(fontSize: 11))),
        if (destra != null) pw.Text(destra, style: pw.TextStyle(fontSize: 9, color: _grigio)),
      ],
    ),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (c) => c.pageNumber == 1 ? pw.SizedBox() : pw.Text(perPdf('$titolo · $corso'), style: pw.TextStyle(fontSize: 9, color: _grigio)),
      footer: (c) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('auri · ${c.pageNumber}/${c.pagesCount}', style: pw.TextStyle(fontSize: 9, color: _grigio)),
      ),
      build: (c) => [
        pw.Container(height: 4, width: 60, color: _lime),
        pw.SizedBox(height: 10),
        pw.Text(perPdf(titolo), style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
        pw.Text(perPdf(corso), style: pw.TextStyle(fontSize: 12, color: _grigio)),
        if (indice.isNotEmpty) ...[sezione('Indice'), for (final v in indice) riga(v.titolo, destra: 'pag. ${v.pagina}')],
        if (riassunto.isNotEmpty) ...[sezione('Riassunto'), for (final f in riassunto) riga('- ${f.testo}', destra: 'pag. ${f.pagina}')],
        if (glossario.isNotEmpty) ...[sezione('Glossario'), for (final t in glossario) riga(t.termine, destra: 'pag. ${t.pagine.join(', ')}')],
        if (definizioni.isNotEmpty) ...[sezione('Definizioni'), for (final d in definizioni) riga(d.testo, destra: 'pag. ${d.pagina}')],
      ],
    ),
  );
  return doc.save();
}
