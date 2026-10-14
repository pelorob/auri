enum Valutazione { voto, idoneita }

enum TipoAppello { scritto, orale, altro }

extension EtichettaTipo on TipoAppello {
  String get etichetta => switch (this) {
    TipoAppello.scritto => 'scritto',
    TipoAppello.orale => 'orale',
    TipoAppello.altro => 'esame',
  };
}
