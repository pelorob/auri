const mesi = ['gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'];
const _giorni = ['lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica'];

String formatta(double? v, int decimali) => v == null ? '—' : v.toStringAsFixed(decimali).replaceAll('.', ',');

String dataLunga(DateTime d) => '${d.day} ${mesi[d.month - 1]}';

String oraMinuti(DateTime d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}';

String meseBreve(DateTime d) => mesi[d.month - 1].substring(0, 3).toUpperCase();

String giornoSettimana(DateTime d) => _giorni[d.weekday - 1];

/// Giorni mancanti in forma breve: "oggi" oppure "14 g".
/// "1 pagina", "3 pagine".
String quanti(int n, String uno, String tanti) => '$n ${n == 1 ? uno : tanti}';

/// "oggi", "ieri", "3 giorni fa" (si contano i giorni di calendario).
String giorniFa(DateTime quando, DateTime ora) {
  final g = DateTime(ora.year, ora.month, ora.day).difference(DateTime(quando.year, quando.month, quando.day)).inDays;
  return switch (g) {
    <= 0 => 'oggi',
    1 => 'ieri',
    _ => '$g giorni fa',
  };
}

String mancanoBreve(int giorni) => giorni == 0 ? 'oggi' : '$giorni g';
