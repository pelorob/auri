import 'package:auri/domain/modelli.dart';
import 'package:auri/domain/notifiche_piano.dart';
import 'package:flutter_test/flutter_test.dart';

AppelloPerNotifica analisi({int id = 1, DateTime? quando, String? aula = 'Aula B2'}) => AppelloPerNotifica(
  id: id,
  corso: 'Analisi Matematica I',
  dataOra: quando ?? DateTime(2026, 10, 27, 9, 0),
  tipo: TipoAppello.scritto,
  aula: aula,
  preavvisi: leggiPreavvisi(preavvisiPredefiniti),
);

void main() {
  final ora = DateTime(2026, 10, 13, 10, 0);

  test('leggi e scrivi i preavvisi', () {
    expect(leggiPreavvisi('7@9:00,1@9:00,0@7:30'), const [Preavviso(7, 9, 0), Preavviso(1, 9, 0), Preavviso(0, 7, 30)]);
    expect(scriviPreavvisi(const [Preavviso(7, 9, 0), Preavviso(0, 7, 30)]), '7@9:00,0@7:30');
    expect(leggiPreavvisi(''), isEmpty);
    expect(leggiPreavvisi('7@9:00,boh,1@25:00'), const [Preavviso(7, 9, 0)]);
  });

  test('tre notifiche per un appello lontano, con id e orari giusti', () {
    final n = pianificaNotifiche([analisi()], ora);
    expect(n.map((x) => x.quando), [DateTime(2026, 10, 20, 9), DateTime(2026, 10, 26, 9), DateTime(2026, 10, 27, 7, 30)]);
    expect(n.map((x) => x.id), [10, 11, 12]);
    expect(n.first.titolo, 'auri');
    expect(n.first.testo, 'Analisi Matematica I: scritto tra 7 giorni (27 ottobre, 9:00, Aula B2)');
    expect(n[1].testo, 'Analisi Matematica I: scritto domani (27 ottobre, 9:00, Aula B2)');
    expect(n[2].testo, 'Analisi Matematica I: scritto oggi (27 ottobre, 9:00, Aula B2)');
  });

  test('senza aula il testo non ha la virgola finale', () {
    expect(testoNotifica(analisi(aula: null), 7), 'Analisi Matematica I: scritto tra 7 giorni (27 ottobre, 9:00)');
  });

  test('i preavvisi già passati vengono saltati', () {
    final n = pianificaNotifiche([analisi(quando: DateTime(2026, 10, 14, 9))], ora);
    expect(n.map((x) => x.quando), [DateTime(2026, 10, 14, 7, 30)]);
  });

  test('appello passato: nessuna notifica', () {
    expect(pianificaNotifiche([analisi(quando: DateTime(2026, 10, 1, 9))], ora), isEmpty);
  });

  test('al massimo 60, le più vicine, in ordine', () {
    final tanti = [
      for (var i = 1; i <= 30; i++)
        analisi(
          id: i,
          quando: DateTime(2026, 11, 1).add(Duration(days: i)),
        ),
    ];
    final n = pianificaNotifiche(tanti, ora);
    expect(n.length, 60);
    for (var i = 1; i < n.length; i++) {
      expect(n[i].quando.isBefore(n[i - 1].quando), isFalse);
    }
    expect(n.first.id, 10);
  });
}
