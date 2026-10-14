import 'package:flutter/material.dart';

import '../app/tema.dart';
import 'calendario/appello_form.dart';
import 'corsi/corso_form.dart';
import 'libretto/voto_form.dart';

Widget pulsanteAggiungi(BuildContext context) => PopupMenuButton<String>(
  tooltip: 'Aggiungi',
  onSelected: (v) => switch (v) {
    'corso' => mostraFormCorso(context),
    'appello' => mostraFormAppello(context),
    _ => mostraFormVoto(context),
  },
  itemBuilder: (_) => const [
    PopupMenuItem(value: 'corso', child: Text('Corso')),
    PopupMenuItem(value: 'appello', child: Text('Appello')),
    PopupMenuItem(value: 'voto', child: Text('Voto')),
  ],
  child: IgnorePointer(
    child: FilledButton.icon(
      style: FilledButton.styleFrom(disabledBackgroundColor: AuriColori.inchiostro, disabledForegroundColor: Colors.white),
      onPressed: null,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Aggiungi'),
    ),
  ),
);
