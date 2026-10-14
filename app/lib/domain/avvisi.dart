/// Giorni di calendario tra due date, ignorando le ore (immune all'ora legale).
int giorniTra(DateTime da, DateTime a) => DateTime.utc(a.year, a.month, a.day).difference(DateTime.utc(da.year, da.month, da.day)).inDays;

int? giorniAllaScadenza(DateTime? scadenza, DateTime ora) => scadenza == null ? null : giorniTra(ora, scadenza.toLocal());

bool mostraAvvisoFirma(int? giorni) => giorni != null && giorni <= 3;

String testoAvvisoFirma(int giorni) {
  final quando = switch (giorni) {
    <= 0 => 'oggi',
    1 => 'domani',
    _ => 'tra $giorni giorni',
  };
  return 'auri scade $quando: apri SideStore e tocca Aggiorna';
}

DateTime? quandoNotificaFirma(DateTime? scadenza, DateTime ora) {
  if (scadenza == null) return null;
  final s = scadenza.toLocal();
  final q = DateTime(s.year, s.month, s.day - 1, 9);
  return q.isAfter(ora) ? q : null;
}

bool mostraPromemoriaBackup({DateTime? ultimoBackup, required DateTime primoAvvio, required DateTime ora}) => giorniTra(ultimoBackup ?? primoAvvio, ora) >= 7;

bool deveBloccare({required bool attivo, required DateTime? inBackgroundDa, required DateTime ora, required int minuti}) =>
    attivo && inBackgroundDa != null && ora.difference(inBackgroundDa).inMinutes >= minuti;

String nomeFileBackup(DateTime ora) => 'auri-backup-${ora.year}-${ora.month.toString().padLeft(2, '0')}-${ora.day.toString().padLeft(2, '0')}.auri';
