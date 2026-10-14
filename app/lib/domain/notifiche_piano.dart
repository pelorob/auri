import 'formati.dart';
import 'modelli.dart';

const preavvisiPredefiniti = '7@9:00,1@9:00,0@7:30';

/// Le scelte offerte all'utente, nell'ordine in cui vengono salvate.
const opzioniPreavviso = [Preavviso(7, 9, 0), Preavviso(1, 9, 0), Preavviso(0, 7, 30)];
const etichetteOpzioniPreavviso = ['7 giorni prima', '1 giorno prima', 'La mattina'];

class Preavviso {
  const Preavviso(this.giorniPrima, this.ora, this.minuto);
  final int giorniPrima;
  final int ora;
  final int minuto;

  @override
  bool operator ==(Object other) => other is Preavviso && other.giorniPrima == giorniPrima && other.ora == ora && other.minuto == minuto;
  @override
  int get hashCode => Object.hash(giorniPrima, ora, minuto);
  @override
  String toString() => '$giorniPrima@$ora:${minuto.toString().padLeft(2, '0')}';
}

List<Preavviso> leggiPreavvisi(String s) {
  final out = <Preavviso>[];
  final re = RegExp(r'^(\d{1,2})@(\d{1,2}):(\d{2})$');
  for (final parte in s.split(',')) {
    final m = re.firstMatch(parte.trim());
    if (m == null) continue;
    final g = int.parse(m[1]!), h = int.parse(m[2]!), mi = int.parse(m[3]!);
    if (h > 23 || mi > 59) continue;
    out.add(Preavviso(g, h, mi));
  }
  return out;
}

String scriviPreavvisi(List<Preavviso> p) => p.map((x) => x.toString()).join(',');

class AppelloPerNotifica {
  const AppelloPerNotifica({required this.id, required this.corso, required this.dataOra, required this.tipo, this.aula, required this.preavvisi});
  final int id;
  final String corso;
  final DateTime dataOra;
  final TipoAppello tipo;
  final String? aula;
  final List<Preavviso> preavvisi;
}

class NotificaPianificata {
  const NotificaPianificata({required this.id, required this.quando, required this.titolo, required this.testo});
  final int id;
  final DateTime quando;
  final String titolo;
  final String testo;
}

String testoNotifica(AppelloPerNotifica a, int giorniPrima) {
  final quando = switch (giorniPrima) {
    0 => 'oggi',
    1 => 'domani',
    _ => 'tra $giorniPrima giorni',
  };
  final dettagli = [dataLunga(a.dataOra), oraMinuti(a.dataOra), if (a.aula != null && a.aula!.trim().isNotEmpty) a.aula!.trim()].join(', ');
  return '${a.corso}: ${a.tipo.etichetta} $quando ($dettagli)';
}

List<NotificaPianificata> pianificaNotifiche(Iterable<AppelloPerNotifica> appelli, DateTime ora, {int massimo = 60}) {
  final tutte = <NotificaPianificata>[];
  for (final a in appelli) {
    for (var i = 0; i < a.preavvisi.length && i < 10; i++) {
      final p = a.preavvisi[i];
      final giorno = DateTime(a.dataOra.year, a.dataOra.month, a.dataOra.day - p.giorniPrima);
      final quando = DateTime(giorno.year, giorno.month, giorno.day, p.ora, p.minuto);
      if (!quando.isAfter(ora)) continue;
      tutte.add(NotificaPianificata(id: a.id * 10 + i, quando: quando, titolo: 'auri', testo: testoNotifica(a, p.giorniPrima)));
    }
  }
  tutte.sort((x, y) => x.quando.compareTo(y.quando));
  return tutte.take(massimo).toList();
}
