import 'notifiche_piano.dart';

class Preferenze {
  const Preferenze({
    this.nomeCorsoDiLaurea = '',
    this.cfuTotali = 180,
    this.valoreLode = 30,
    this.bloccoAttivo = false,
    this.minutiRiblocco = 5,
    this.preavvisi = preavvisiPredefiniti,
    this.primoAvvioFatto = false,
    this.primoAvvioIl,
    this.ultimoBackup,
  });

  final String nomeCorsoDiLaurea;
  final int cfuTotali;
  final int valoreLode;
  final bool bloccoAttivo;
  final int minutiRiblocco;
  final String preavvisi;
  final bool primoAvvioFatto;
  final DateTime? primoAvvioIl;
  final DateTime? ultimoBackup;

  static const predefinite = Preferenze();

  static const kNome = 'nomeCorsoDiLaurea';
  static const kCfuTotali = 'cfuTotali';
  static const kLode = 'valoreLode';
  static const kBlocco = 'bloccoAttivo';
  static const kMinuti = 'minutiRiblocco';
  static const kPreavvisi = 'preavvisi';
  static const kPrimoAvvioFatto = 'primoAvvioFatto';
  static const kPrimoAvvioIl = 'primoAvvioIl';
  static const kUltimoBackup = 'ultimoBackup';

  factory Preferenze.daMappa(Map<String, String> m) {
    int intero(String k, int def, bool Function(int) ok) {
      final v = int.tryParse(m[k] ?? '');
      return v != null && ok(v) ? v : def;
    }

    return Preferenze(
      nomeCorsoDiLaurea: m[kNome] ?? '',
      cfuTotali: intero(kCfuTotali, 180, (v) => v > 0),
      valoreLode: intero(kLode, 30, (v) => v >= 30 && v <= 33),
      bloccoAttivo: m[kBlocco] == 'true',
      minutiRiblocco: intero(kMinuti, 5, (v) => v >= 0),
      preavvisi: m[kPreavvisi] ?? preavvisiPredefiniti,
      primoAvvioFatto: m[kPrimoAvvioFatto] == 'true',
      primoAvvioIl: DateTime.tryParse(m[kPrimoAvvioIl] ?? ''),
      ultimoBackup: DateTime.tryParse(m[kUltimoBackup] ?? ''),
    );
  }
}
