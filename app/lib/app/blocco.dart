import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/avvisi.dart';
import '../domain/preferenze.dart';

class BloccoController extends Notifier<bool> {
  DateTime? _inBackgroundDa;

  @override
  bool build() => false;

  void blocca() => state = true;
  void sblocca() => state = false;
  void inBackground(DateTime ora) => _inBackgroundDa = ora;

  void alRitorno(DateTime ora, Preferenze p) {
    if (deveBloccare(attivo: p.bloccoAttivo, inBackgroundDa: _inBackgroundDa, ora: ora, minuti: p.minutiRiblocco)) state = true;
    _inBackgroundDa = null;
  }
}

final bloccoProvider = NotifierProvider<BloccoController, bool>(BloccoController.new);

class CoperturaController extends Notifier<bool> {
  @override
  bool build() => false;
  void copri() => state = true;
  void scopri() => state = false;
}

final coperturaProvider = NotifierProvider<CoperturaController, bool>(CoperturaController.new);
