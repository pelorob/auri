import 'package:flutter/material.dart';

import '../app/tema.dart';
import 'calendario/appello_form.dart';
import 'corsi/corso_form.dart';
import 'libretto/voto_form.dart';

// Un vero pulsante attivo che apre il menu (prima era un pulsante disattivato ridipinto).
Widget pulsanteAggiungi(BuildContext context) => MenuAnchor(
  menuChildren: [
    MenuItemButton(onPressed: () => mostraFormCorso(context), child: const Text('Corso')),
    MenuItemButton(onPressed: () => mostraFormAppello(context), child: const Text('Appello')),
    MenuItemButton(onPressed: () => mostraFormVoto(context), child: const Text('Voto')),
  ],
  builder: (_, menu, _) => FilledButton.icon(
    style: FilledButton.styleFrom(backgroundColor: AuriColori.inchiostro, foregroundColor: Colors.white),
    onPressed: () => menu.isOpen ? menu.close() : menu.open(),
    icon: const Icon(Icons.add_rounded),
    label: const Text('Aggiungi'),
  ),
);
