import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/preferenze.dart';
import '../features/impostazioni/primo_avvio_page.dart';
import 'blocco.dart';
import 'blocco_page.dart';
import 'notifiche_app.dart';
import 'providers.dart';
import 'serializzatore.dart';
import 'shell.dart';
import 'tema.dart';

class AuriApp extends ConsumerStatefulWidget {
  const AuriApp({super.key});
  @override
  ConsumerState<AuriApp> createState() => _AuriAppState();
}

class _AuriAppState extends ConsumerState<AuriApp> {
  late final AppLifecycleListener _ciclo;
  bool _bloccoIniziale = false;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(
      onHide: () {
        ref.read(bloccoProvider.notifier).inBackground(DateTime.now());
        if (ref.read(preferenzeProvider).value?.bloccoAttivo ?? false) ref.read(coperturaProvider.notifier).copri();
      },
      onShow: () {
        ref.read(bloccoProvider.notifier).alRitorno(DateTime.now(), ref.read(preferenzeProvider).value ?? Preferenze.predefinite);
        ref.read(coperturaProvider.notifier).scopri();
        ref.invalidate(scadenzaFirmaProvider);
        _riprogramma();
      },
    );
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  final _coda = Serializzatore();

  /// Una riprogrammazione alla volta, calcolata sui dati più recenti al momento dell'esecuzione.
  void _riprogramma() {
    _coda.esegui(() async {
      if (!mounted || !ref.read(dbProvider).hasValue) return;
      final appelli = ref.read(appelliProvider).value;
      if (appelli == null) return;
      final n = tutteLeNotifiche(appelli: appelli, scadenza: ref.read(scadenzaFirmaProvider).value, ora: DateTime.now());
      await ref.read(notificheProvider).riprogramma(n);
    });
  }

  Widget _corpo() {
    final pref = ref.watch(preferenzeProvider);
    ref.listen(appelliProvider, (_, _) => _riprogramma());
    ref.listen(scadenzaFirmaProvider, (_, _) => _riprogramma());
    ref.listen(preferenzeProvider, (_, p) {
      if (!_bloccoIniziale && p.value != null) {
        _bloccoIniziale = true;
        if (p.value!.bloccoAttivo) ref.read(bloccoProvider.notifier).blocca();
      }
    });
    if (!pref.hasValue) return const Center(child: CircularProgressIndicator());
    if (!pref.value!.primoAvvioFatto) return const PrimoAvvioPage();
    return const AuriShell();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(dbProvider);
    return MaterialApp(
      title: 'auri',
      debugShowCheckedModeBanner: false,
      theme: temaAuri(),
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => StratoBlocco(child: child!),
      home: Scaffold(
        body: db.isLoading
            ? const Center(child: CircularProgressIndicator())
            : db.when(
                data: (_) => _corpo(),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Impossibile aprire i dati: $e')),
              ),
      ),
    );
  }
}
