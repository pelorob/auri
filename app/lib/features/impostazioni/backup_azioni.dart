import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../domain/preferenze.dart';
import '../../services/backup.dart';

Future<void> esportaBackup(BuildContext context, WidgetRef ref, Rect origine) async {
  final avvisi = ScaffoldMessenger.of(context);
  try {
    final db = ref.read(dbProvider).requireValue;
    final file = await creaCopiaBackup(db, await getTemporaryDirectory(), DateTime.now());
    final esito = await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], sharePositionOrigin: origine));
    if (esportazioneRiuscita(esito.status)) {
      await ref.read(repositoryProvider).salvaPreferenza(Preferenze.kUltimoBackup, DateTime.now().toIso8601String());
    }
  } catch (_) {
    avvisi.showSnackBar(const SnackBar(content: Text('Esportazione non riuscita: riprova.')));
  }
}

Future<void> ripristinaBackup(BuildContext context, WidgetRef ref) async {
  final scelta = await FilePicker.pickFiles();
  final percorso = scelta.isEmpty ? null : scelta.single.path;
  if (percorso == null || !context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Ripristinare il backup?'),
      content: const Text('Sostituirà tutti i dati attuali.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Ripristina')),
      ],
    ),
  );
  if (ok != true) return;
  if (!context.mounted) return;
  final avvisi = ScaffoldMessenger.of(context);
  try {
    await ref.read(dbProvider.notifier).ripristina(File(percorso));
    avvisi.showSnackBar(const SnackBar(content: Text('Backup ripristinato')));
  } on BackupNonValido catch (e) {
    avvisi.showSnackBar(SnackBar(content: Text(e.motivo)));
  } catch (_) {
    avvisi.showSnackBar(const SnackBar(content: Text("Ripristino non riuscito: i tuoi dati sono rimasti com'erano.")));
  }
}

bool esportazioneRiuscita(ShareResultStatus s) => s == ShareResultStatus.success;
