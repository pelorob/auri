import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auri/app/app.dart';
import 'package:auri/app/providers.dart';
import 'package:auri/app/shell.dart';
import 'package:auri/data/apertura.dart';
import 'package:auri/domain/notifiche_piano.dart';
import 'package:auri/features/slide/annotazioni.dart';
import 'package:auri/features/slide/documento_page.dart';
import 'package:auri/services/backup.dart';
import 'package:auri/services/notifiche.dart';
import 'package:auri/services/ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

/// Il PDF di prova di test/fixtures/ohm.pdf (3 pagine sulla legge di Ohm).
const _ohmPdf =
    'JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvRm9udCAvU3VidHlwZSAvVHlwZTEgL0Jhc2VGb250IC9IZWx2ZXRpY2EgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL0xlbmd0aCAyMDQgPj4Kc3RyZWFtCkJUIC9GMSAyOCBUZiA3MiA3MjAgVGQgKExlZ2dlIGRpIE9obSkgVGogRVQKQlQgL0YxIDE0IFRmIDcyIDY2MCBUZCAoTGEgcmVzaXN0ZW56YSBlbGV0dHJpY2EgZScgaWwgcmFwcG9ydG8gdHJhIHRlbnNpb25lIGUgY29ycmVudGUuKSBUaiBFVApCVCAvRjEgMTQgVGYgNzIgNjMwIFRkIChTaSBkZWZpbmlzY2UgcmVzaXN0ZW56YSBSID0gViAvIEkuKSBUaiBFVAplbmRzdHJlYW0KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCA4IDAgUiAvTWVkaWFCb3ggWzAgMCA2MTIgNzkyXSAvUmVzb3VyY2VzIDw8IC9Gb250IDw8IC9GMSAxIDAgUiA+PiA+PiAvQ29udGVudHMgMiAwIFIgPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCAxODQgPj4Kc3RyZWFtCkJUIC9GMSAyOCBUZiA3MiA3MjAgVGQgKExlZ2dlIGRpIE9obSkgVGogRVQKQlQgL0YxIDE0IFRmIDcyIDY2MCBUZCAoRXNlbXBpIGRpIGNpcmN1aXRpIGluIHNlcmllIGUgaW4gcGFyYWxsZWxvLikgVGogRVQKQlQgL0YxIDE0IFRmIDcyIDYzMCBUZCAoTGUgcmVzaXN0ZW56ZSBpbiBzZXJpZSBzaSBzb21tYW5vLikgVGogRVQKZW5kc3RyZWFtCmVuZG9iago1IDAgb2JqCjw8IC9UeXBlIC9QYWdlIC9QYXJlbnQgOCAwIFIgL01lZGlhQm94IFswIDAgNjEyIDc5Ml0gL1Jlc291cmNlcyA8PCAvRm9udCA8PCAvRjEgMSAwIFIgPj4gPj4gL0NvbnRlbnRzIDQgMCBSID4+CmVuZG9iago2IDAgb2JqCjw8IC9MZW5ndGggMTg0ID4+CnN0cmVhbQpCVCAvRjEgMjggVGYgNzIgNzIwIFRkIChQb3RlbnphIGVsZXR0cmljYSkgVGogRVQKQlQgL0YxIDE0IFRmIDcyIDY2MCBUZCAoTGEgcG90ZW56YSBlJyBpbCBwcm9kb3R0byBkaSB0ZW5zaW9uZSBlIGNvcnJlbnRlLikgVGogRVQKQlQgL0YxIDE0IFRmIDcyIDYzMCBUZCAoRGVmaW5pemlvbmU6IFAgPSBWICogSS4pIFRqIEVUCmVuZHN0cmVhbQplbmRvYmoKNyAwIG9iago8PCAvVHlwZSAvUGFnZSAvUGFyZW50IDggMCBSIC9NZWRpYUJveCBbMCAwIDYxMiA3OTJdIC9SZXNvdXJjZXMgPDwgL0ZvbnQgPDwgL0YxIDEgMCBSID4+ID4+IC9Db250ZW50cyA2IDAgUiA+PgplbmRvYmoKOCAwIG9iago8PCAvVHlwZSAvUGFnZXMgL0tpZHMgWzMgMCBSIDUgMCBSIDcgMCBSXSAvQ291bnQgMyA+PgplbmRvYmoKOSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgOCAwIFIgPj4KZW5kb2JqCnhyZWYKMCAxMAowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAwMDkgMDAwMDAgbiAKMDAwMDAwMDA3OSAwMDAwMCBuIAowMDAwMDAwMzM0IDAwMDAwIG4gCjAwMDAwMDA0NjAgMDAwMDAgbiAKMDAwMDAwMDY5NSAwMDAwMCBuIAowMDAwMDAwODIxIDAwMDAwIG4gCjAwMDAwMDEwNTYgMDAwMDAgbiAKMDAwMDAwMTE4MiAwMDAwMCBuIAowMDAwMDAxMjUxIDAwMDAwIG4gCnRyYWlsZXIKPDwgL1NpemUgMTAgL1Jvb3QgOSAwIFIgPj4Kc3RhcnR4cmVmCjEzMDAKJSVFT0YK';

/// Il simulatore non può rispondere al dialogo di sistema dei permessi: le notifiche
/// vengono solo registrate qui (la pianificazione è già coperta dai test di unità).
class NotificheFinte extends NotificheService {
  final programmate = <NotificaPianificata>[];
  @override
  Future<void> inizializza() async {}
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool?> permessoConcesso() async => true;
  @override
  Future<void> riprogramma(List<NotificaPianificata> notifiche) async => programmate
    ..clear()
    ..addAll(notifiche);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Attesa con limite: se l'interfaccia non si ferma entro 30 s il test fallisce invece di restare appeso.
  Future<void> attendi(WidgetTester t) => t.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 30));

  void passo(String testo) => debugPrint('PASSO: $testo');

  /// Salva una foto dello schermo in FOTO_DIR (cartella del Mac che ospita il simulatore).
  Future<void> foto(WidgetTester t, String nome) async {
    await attendi(t);
    passo('foto $nome');
    const cartella = String.fromEnvironment('FOTO_DIR');
    if (cartella.isEmpty) return;
    final vista = t.binding.renderViews.first;
    final strato = vista.debugLayer! as OffsetLayer;
    // Lo strato è in pixel fisici: si cattura tutto lo schermo e lo si riporta a dimensione logica.
    final dpr = vista.flutterView.devicePixelRatio;
    final immagine = await strato.toImage(Offset.zero & (vista.size * dpr), pixelRatio: 1 / dpr);
    final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
    File('$cartella/$nome.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  }

  Future<void> vai(WidgetTester t, String sezione) async {
    passo('vai a $sezione');
    await t.tap(find.text(sezione).last);
    await attendi(t);
  }

  testWidgets('giro completo di auri su iPad', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    passo('avvio');
    pdfrxFlutterInitialize();
    final db = await fileDatabase();
    if (db.existsSync()) db.deleteSync();
    final notifiche = NotificheFinte();
    await t.pumpWidget(ProviderScope(overrides: [notificheProvider.overrideWithValue(notifiche)], child: const AuriApp()));
    await attendi(t);

    // Il codice nativo per la scadenza della firma è registrato (senza SideStore risponde null).
    expect(await const MethodChannel('auri/firma').invokeMethod<String>('scadenza'), isNull);

    passo('primo avvio');
    // Primo avvio
    expect(find.text('Benvenuta in auri'), findsOneWidget);
    await foto(t, '01-primo-avvio');
    await t.enterText(find.byType(TextField).first, 'Ingegneria Informatica');
    await t.tap(find.text('Avanti'));
    await attendi(t);
    await t.tap(find.text('Avanti'));
    await attendi(t);
    await t.tap(find.text('Inizia'));
    await attendi(t);
    expect(find.text('Ciao! Pronta a spaccare?'), findsOneWidget);
    await foto(t, '02-home-vuota-verticale');

    passo('corsi');
    // Corsi
    await vai(t, 'Corsi');
    for (final (nome, cfu) in [('Analisi Matematica I', '12'), ('Programmazione', '9')]) {
      await t.tap(find.text('Nuovo corso'));
      await attendi(t);
      await t.enterText(find.byKey(const Key('nome')), nome);
      await t.enterText(find.byKey(const Key('cfu')), cfu);
      await t.tap(find.text('Salva'));
      await attendi(t);
    }
    expect(find.text('Analisi Matematica I'), findsOneWidget);
    await foto(t, '03-corsi');

    passo('voto');
    // Voto: Programmazione 29
    await vai(t, 'Libretto');
    await t.tap(find.text('Registra voto'));
    await attendi(t);
    await t.tap(find.byType(DropdownButtonFormField<int>));
    await attendi(t);
    await t.tap(find.text('Programmazione').last);
    await attendi(t);
    await t.tap(find.byTooltip('Alza'));
    await t.tap(find.byTooltip('Alza'));
    await attendi(t);
    await foto(t, '04-registra-voto');
    await t.tap(find.text('Salva'));
    await attendi(t);
    expect(find.text('29,00'), findsWidgets);
    await foto(t, '05-libretto-verticale');

    passo('appello');
    // Appello di Analisi tra 14 giorni
    await vai(t, 'Calendario');
    await t.tap(find.text('Nuovo'));
    await attendi(t);
    await t.tap(find.byType(DropdownButtonFormField<int>));
    await attendi(t);
    await t.tap(find.text('Analisi Matematica I').last);
    await attendi(t);
    await t.tap(find.text('Salva'));
    await attendi(t);
    expect(find.text('14 g'), findsOneWidget);
    expect(notifiche.programmate, isNotEmpty);
    await foto(t, '06-calendario-verticale');

    passo('orizzontale');
    // In orizzontale, come la userà di solito
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    await Future<void>.delayed(const Duration(seconds: 2));
    await attendi(t);
    expect(find.byType(NavigationBar), findsNothing, reason: 'in orizzontale deve esserci la barra laterale');
    for (final (sezione, nome) in [
      ('Oggi', '07-oggi'),
      ('Corsi', '08-corsi'),
      ('Libretto', '09-libretto'),
      ('Calendario', '10-calendario'),
      ('Impostazioni', '11-impostazioni'),
    ]) {
      await vai(t, sezione);
      await foto(t, nome);
    }

    passo('backup');
    // Backup e ripristino con il database vero di iOS
    final c = ProviderScope.containerOf(t.element(find.byType(AuriShell)));
    final copia = await creaCopiaBackup(c.read(dbProvider).requireValue, await getTemporaryDirectory(), DateTime.now());
    final programmazione = (c.read(corsiProvider).value!).firstWhere((x) => x.corso.nome == 'Programmazione');
    await c.read(repositoryProvider).eliminaCorso(programmazione.corso.id);
    await attendi(t);
    await vai(t, 'Libretto');
    expect(find.text('Programmazione'), findsNothing);
    await c.read(dbProvider.notifier).ripristina(copia);
    await attendi(t);
    await vai(t, 'Libretto');
    expect(find.text('Programmazione'), findsOneWidget);
    expect(find.text('29,00'), findsWidgets);
    await foto(t, '12-dopo-ripristino');

    passo('slide');
    final pdf = File('${(await getTemporaryDirectory()).path}/Elettricita.pdf')..writeAsBytesSync(base64Decode(_ohmPdf));
    final analisi = (c.read(corsiProvider).value!).firstWhere((x) => x.corso.nome == 'Analisi Matematica I');
    final idPdf = await c.read(importazioneProvider).importa(pdf, corsoId: analisi.corso.id);
    expect((await c.read(repositoryProvider).pagineDi(idPdf)).length, 3);
    await vai(t, 'Slide');
    expect(find.text('Elettricita'), findsOneWidget);
    await foto(t, '13-slide');
    await t.enterText(find.byType(TextField), 'resistenze');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await attendi(t);
    expect(find.textContaining('Elettricita · pag. 1'), findsOneWidget);
    await foto(t, '14-ricerca');
    await t.tap(find.textContaining('Elettricita · pag. 1'));
    await Future<void>.delayed(const Duration(seconds: 2));
    await attendi(t);
    expect(find.text('Legge di Ohm'), findsOneWidget);
    await foto(t, '15-documento');

    passo('riassunto');
    await t.tap(find.text('Riassunto'));
    await attendi(t);
    expect(find.textContaining('tensione e corrente'), findsWidgets);
    await foto(t, '15b-riassunto');

    passo('annotazioni');
    await t.tap(find.byTooltip('Penna'));
    await attendi(t);
    await t.tap(find.byType(Switch).last);
    await attendi(t);
    await t.timedDrag(find.byType(StratoAnnotazioni).first, const Offset(160, 40), const Duration(milliseconds: 600));
    await attendi(t);
    expect((await c.read(repositoryProvider).guardaTratti(idPdf).first).where((x) => x.pagina == 1), isNotEmpty);
    await foto(t, '15c-annotazione');
    await t.tap(find.byTooltip('Penna'));
    await attendi(t);

    passo('ocr');
    // Apple Vision legge il titolo della pagina 1 dall'immagine della pagina.
    final letto = await const OcrVision().leggi(await renderPaginaPdf(pdf.path, 1));
    debugPrint('OCR pagina 1: $letto');
    expect(letto, contains('Legge di Ohm'));

    passo('ripasso');
    await t.tap(find.text('Crea flashcard'));
    await attendi(t);
    await foto(t, '15d-flashcard-create');
    passo('indietro: back button trovati = ${find.byType(BackButton).evaluate().length}');
    await t.tap(find.byType(BackButton));
    await attendi(t);
    await foto(t, '15e-dopo-indietro');
    final ancoraAperto = find.byType(DocumentoPage).evaluate().isNotEmpty;
    passo('dopo indietro: documento ancora aperto = $ancoraAperto');
    expect(ancoraAperto, isFalse, reason: 'il tasto indietro deve chiudere il documento');
    await vai(t, 'Ripasso');
    expect(find.text('Ripassa'), findsWidgets);
    await foto(t, '16-ripasso');
    await t.tap(find.text('Ripassa').first);
    await attendi(t);
    await t.tap(find.text('Mostra risposta'));
    await attendi(t);
    await foto(t, '17-carta');

    passo('studio');
    await t.tap(find.byType(BackButton));
    await attendi(t);
    await vai(t, 'Studio');
    expect(find.text('Inizia'), findsOneWidget);
    await foto(t, '18-studio');
  });
}
