import 'package:flutter/material.dart';

class AuriColori {
  static const viola = Color(0xFF5B3DE6);
  static const viola2 = Color(0xFF6B50F2);
  static const viola3 = Color(0xFF4730C4);
  static const violaTenue = Color(0xFFECE8FF);
  static const violaChip = Color(0xFFE4DEFF);
  static const lime = Color(0xFFD6F35B);
  static const limeTenue = Color(0xFFEEF9C8);
  static const inchiostro = Color(0xFF19142E);
  static const grigio = Color(0xFF6B6785);
  static const grigioChiaro = Color(0xFF8A87A0);
  static const sfondo = Color(0xFFF2F1FA);
  static const cella = Color(0xFFF7F6FC);
  static const linea = Color(0xFFF0EEF7);
  static const verde = Color(0xFF15803D);
  static const arancio = Color(0xFFC2410C);
}

const paletteCorsi = ['#5B3DE6', '#FF7A2F', '#14B8A6', '#E0457B', '#2F80ED', '#8A87A0'];

Color coloreDaHex(String hex) => Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));

/// Tinta chiara (per le tessere data) di un colore di corso.
Color tinta(String hex) => Color.alphaBlend(coloreDaHex(hex).withValues(alpha: 0.18), Colors.white);

TextStyle titolo(double size, {FontWeight peso = FontWeight.w800, Color? colore}) => TextStyle(
  fontFamily: 'Bricolage',
  fontSize: size,
  fontWeight: peso,
  fontVariations: [FontVariation('wght', peso.value.toDouble())],
  letterSpacing: -size * 0.025,
  height: 1.05,
  color: colore ?? AuriColori.inchiostro,
);

TextStyle testo(double size, {FontWeight peso = FontWeight.w500, Color? colore}) => TextStyle(
  fontFamily: 'DMSans',
  fontSize: size,
  fontWeight: peso,
  fontVariations: [FontVariation('wght', peso.value.toDouble())],
  color: colore ?? AuriColori.inchiostro,
);

ThemeData temaAuri() {
  final schema = ColorScheme.fromSeed(seedColor: AuriColori.viola, primary: AuriColori.viola, surface: Colors.white);
  return ThemeData(
    useMaterial3: true,
    colorScheme: schema,
    fontFamily: 'DMSans',
    scaffoldBackgroundColor: AuriColori.sfondo,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AuriColori.inchiostro,
        minimumSize: const Size(48, 48),
        shape: const StadiumBorder(),
        textStyle: testo(15, peso: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AuriColori.sfondo,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}
