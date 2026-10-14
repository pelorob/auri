import 'package:auri/services/scadenza_firma.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canale = MethodChannel(kCanaleFirma);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(canale, null));

  test('restituisce la data quando il nativo risponde ISO-8601', () async {
    messenger.setMockMethodCallHandler(canale, (call) async {
      expect(call.method, 'scadenza');
      return '2026-10-25T08:30:00Z';
    });
    final d = await const ScadenzaFirmaService().leggi();
    expect(d, DateTime.utc(2026, 10, 25, 8, 30));
  });

  test('null quando il nativo risponde null (nessun profilo)', () async {
    messenger.setMockMethodCallHandler(canale, (call) async => null);
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });

  test('null quando la stringa non è una data', () async {
    messenger.setMockMethodCallHandler(canale, (call) async => 'boh');
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });

  test('null quando il canale non esiste (Windows, test)', () async {
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });

  test('null quando il nativo lancia un errore', () async {
    messenger.setMockMethodCallHandler(canale, (call) async => throw PlatformException(code: 'x'));
    expect(await const ScadenzaFirmaService().leggi(), isNull);
  });
}
