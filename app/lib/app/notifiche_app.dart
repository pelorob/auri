import '../data/repository.dart';
import '../domain/avvisi.dart';
import '../domain/notifiche_piano.dart';

List<NotificaPianificata> tutteLeNotifiche({required List<AppelloConCorso> appelli, required DateTime? scadenza, required DateTime ora}) {
  final n = pianificaNotifiche(
    [
      for (final a in appelli)
        AppelloPerNotifica(
          id: a.appello.id,
          corso: a.corso.nome,
          dataOra: a.appello.dataOra,
          tipo: a.appello.tipo,
          aula: a.appello.aula,
          preavvisi: leggiPreavvisi(a.appello.preavvisi),
        ),
    ],
    ora,
    massimo: 59,
  );
  final quando = quandoNotificaFirma(scadenza, ora);
  if (quando != null) {
    final giorni = giorniAllaScadenza(scadenza, quando)!;
    n.add(NotificaPianificata(id: 0, quando: quando, titolo: 'auri', testo: testoAvvisoFirma(giorni)));
  }
  return n;
}
