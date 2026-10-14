import 'dart:io';

import 'package:auri/domain/riassunto.dart';
import 'package:auri/domain/slide.dart';
import 'package:auri/services/scheda_pdf.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('testo compatibile con i caratteri del PDF', () {
    expect(perPdf('l’energia… “ciao” – è'), "l'energia... \"ciao\" - è");
    expect(perPdf('α → β'), '? ? ?');
  });

  test('crea un PDF leggibile con titolo, riassunto, glossario e definizioni', () async {
    final byte = await creaSchedaPdf(
      titolo: 'Elettricità',
      corso: 'Fisica II',
      indice: const [VoceIndice('Legge di Ohm', 1), VoceIndice('Potenza elettrica', 3)],
      riassunto: const [Frase('La resistenza elettrica è il rapporto tra tensione e corrente.', 1)],
      glossario: const [
        TermineGlossario('tensione', [1, 3]),
      ],
      definizioni: const [Definizione('Si definisce resistenza R = V / I.', 1)],
    );
    expect(String.fromCharCodes(byte.take(4)), '%PDF');
    final f = File('${Directory.systemTemp.path}/scheda_test.pdf')..writeAsBytesSync(byte);
    final doc = await PdfDocument.openFile(f.path);
    final testo = StringBuffer();
    for (final p in doc.pages) {
      testo.write((await p.loadText())?.fullText ?? '');
    }
    await doc.dispose();
    final t = testo.toString();
    expect(t, contains('Elettricità'));
    expect(t, contains('Riassunto'));
    expect(t, contains('La resistenza elettrica'));
    expect(t, contains('tensione'));
    expect(t, contains('Si definisce resistenza'));
  }, tags: ['pdfium']);
}
