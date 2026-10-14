String? validaNome(String? s) => (s == null || s.trim().isEmpty) ? 'Scrivi il nome del corso' : null;

String? validaCfu(String? s) {
  final n = int.tryParse((s ?? '').trim());
  return (n == null || n <= 0) ? 'I CFU devono essere un numero maggiore di 0' : null;
}

String? validaVoto(int? voto) => (voto == null || voto < 18 || voto > 30) ? 'Il voto va da 18 a 30' : null;

bool lodeAmmessa(int? voto) => voto == 30;
