/// Celle del mese con il lunedì come primo giorno; null = cella vuota.
List<DateTime?> celleMese(int anno, int mese) {
  final primo = DateTime(anno, mese, 1);
  final giorni = DateTime(anno, mese + 1, 0).day;
  final celle = <DateTime?>[for (var i = 1; i < primo.weekday; i++) null, for (var d = 1; d <= giorni; d++) DateTime(anno, mese, d)];
  while (celle.length % 7 != 0) {
    celle.add(null);
  }
  return celle;
}
