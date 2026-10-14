import 'package:flutter/services.dart';

const kCanaleFirma = 'auri/firma';

/// Legge la data di scadenza della firma dell'app (profilo di SideStore).
/// Restituisce null se non disponibile: Windows, test, App Store, errori.
class ScadenzaFirmaService {
  const ScadenzaFirmaService([this._canale = const MethodChannel(kCanaleFirma)]);

  final MethodChannel _canale;

  Future<DateTime?> leggi() async {
    try {
      final s = await _canale.invokeMethod<String>('scadenza');
      return s == null ? null : DateTime.tryParse(s);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
