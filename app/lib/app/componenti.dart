import 'package:flutter/material.dart';

import '../domain/formati.dart';
import 'tema.dart';

class Scheda extends StatelessWidget {
  const Scheda({super.key, required this.child, this.colore = Colors.white, this.padding = const EdgeInsets.all(24)});
  final Widget child;
  final Color colore;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(color: colore, borderRadius: BorderRadius.circular(28)),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class Etichetta extends StatelessWidget {
  const Etichetta(this.testoEtichetta, {super.key, this.colore});
  final String testoEtichetta;
  final Color? colore;
  @override
  Widget build(BuildContext context) => Text(
    testoEtichetta.toUpperCase(),
    style: testo(12, peso: FontWeight.w800, colore: colore ?? AuriColori.grigio).copyWith(letterSpacing: 1.2),
  );
}

class Pillola extends StatelessWidget {
  const Pillola(this.testoPillola, {super.key, this.sfondo = AuriColori.sfondo, this.colore = AuriColori.inchiostro});
  final String testoPillola;
  final Color sfondo;
  final Color colore;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: sfondo, borderRadius: BorderRadius.circular(99)),
    child: Text(
      testoPillola,
      style: testo(13, peso: FontWeight.w800, colore: colore),
    ),
  );
}

class TesseraData extends StatelessWidget {
  const TesseraData(this.data, {super.key, required this.sfondo});
  final DateTime data;
  final Color sfondo;
  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 56,
    decoration: BoxDecoration(color: sfondo, borderRadius: BorderRadius.circular(16)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${data.day}', style: titolo(20)),
        Text(meseBreve(data), style: testo(11, peso: FontWeight.w800)),
      ],
    ),
  );
}

class TitoloPagina extends StatelessWidget {
  const TitoloPagina({super.key, required this.sopra, required this.testoTitolo, this.azione});
  final String sopra;
  final String testoTitolo;
  final Widget? azione;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Etichetta(sopra),
              const SizedBox(height: 6),
              Text(testoTitolo, style: titolo(38)),
            ],
          ),
        ),
        ?azione,
      ],
    ),
  );
}
