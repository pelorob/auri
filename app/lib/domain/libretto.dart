class VoceLibretto {
  const VoceLibretto({required this.cfu, required this.superato, required this.aVoto, this.voto, this.lode = false});
  final int cfu;
  final bool superato;
  final bool aVoto;
  final int? voto;
  final bool lode;
}

class Riepilogo {
  const Riepilogo({required this.sommaPesata, required this.cfuConVoto, required this.numeroVoti, required this.sommaVoti, required this.cfuOttenuti});
  final double sommaPesata;
  final int cfuConVoto;
  final int numeroVoti;
  final double sommaVoti;
  final int cfuOttenuti;

  double? get mediaPonderata => cfuConVoto == 0 ? null : sommaPesata / cfuConVoto;
  double? get mediaAritmetica => numeroVoti == 0 ? null : sommaVoti / numeroVoti;
  double? get baseLaurea => mediaPonderata == null ? null : baseDaMedia(mediaPonderata!);
}

double valoreVoto(int voto, bool lode, int valoreLode) => voto == 30 && lode ? valoreLode.toDouble() : voto.toDouble();

double baseDaMedia(double media) => media * 110 / 30;

Riepilogo calcolaRiepilogo(Iterable<VoceLibretto> voci, {required int valoreLode}) {
  var sommaPesata = 0.0, sommaVoti = 0.0;
  var cfuConVoto = 0, numeroVoti = 0, cfuOttenuti = 0;
  for (final v in voci) {
    if (!v.superato) continue;
    cfuOttenuti += v.cfu;
    if (v.aVoto && v.voto != null) {
      final x = valoreVoto(v.voto!, v.lode, valoreLode);
      sommaPesata += x * v.cfu;
      cfuConVoto += v.cfu;
      sommaVoti += x;
      numeroVoti++;
    }
  }
  return Riepilogo(sommaPesata: sommaPesata, cfuConVoto: cfuConVoto, numeroVoti: numeroVoti, sommaVoti: sommaVoti, cfuOttenuti: cfuOttenuti);
}

double simulaMedia(Riepilogo r, {required int cfu, required int voto, bool lode = false, required int valoreLode}) =>
    (r.sommaPesata + valoreVoto(voto, lode, valoreLode) * cfu) / (r.cfuConVoto + cfu);

sealed class MediaNecessaria {
  const MediaNecessaria();
}

class Raggiungibile extends MediaNecessaria {
  const Raggiungibile(this.valore);
  final double valore;
}

class BastaPassare extends MediaNecessaria {
  const BastaPassare();
}

class FuoriPortata extends MediaNecessaria {
  const FuoriPortata();
}

MediaNecessaria? mediaNecessaria(Riepilogo r, {required int obiettivo, required int cfuTotali}) {
  final mancanti = cfuTotali - r.cfuOttenuti;
  if (mancanti <= 0) return null;
  final req = (obiettivo * 30 / 110 * (r.cfuConVoto + mancanti) - r.sommaPesata) / mancanti;
  if (req > 30) return const FuoriPortata();
  if (req < 18) return const BastaPassare();
  return Raggiungibile(req);
}
