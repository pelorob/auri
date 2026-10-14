import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/calendario/calendario_page.dart';
import '../features/corsi/corsi_page.dart';
import '../features/impostazioni/impostazioni_page.dart';
import '../features/libretto/libretto_page.dart';
import '../features/oggi/oggi_page.dart';
import '../features/ripasso/ripasso_page.dart';
import '../features/slide/slide_page.dart';
import '../features/studio/studio_page.dart';
import 'blocco.dart';
import 'providers.dart';
import 'tema.dart';

const _voci = [
  (Sezione.oggi, 'Oggi', Icons.home_rounded),
  (Sezione.corsi, 'Corsi', Icons.menu_book_rounded),
  (Sezione.calendario, 'Calendario', Icons.calendar_month_rounded),
  (Sezione.libretto, 'Libretto', Icons.school_rounded),
  (Sezione.slide, 'Slide', Icons.picture_as_pdf_outlined),
  (Sezione.ripasso, 'Ripasso', Icons.style_outlined),
  (Sezione.studio, 'Studio', Icons.timer_outlined),
];

class AuriShell extends ConsumerWidget {
  const AuriShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sezione = ref.watch(sezioneProvider);
    final pagina = switch (sezione) {
      Sezione.oggi => const OggiPage(),
      Sezione.corsi => const CorsiPage(),
      Sezione.calendario => const CalendarioPage(),
      Sezione.libretto => const LibrettoPage(),
      Sezione.slide => const SlidePage(),
      Sezione.ripasso => const RipassoPage(),
      Sezione.studio => const StudioPage(),
      Sezione.impostazioni => const ImpostazioniPage(),
    };
    return LayoutBuilder(
      builder: (context, vincoli) {
        if (vincoli.maxWidth >= 900) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BarraLaterale(),
                  const SizedBox(width: 20),
                  Expanded(child: pagina),
                ],
              ),
            ),
          );
        }
        final bloccoAttivo = ref.watch(preferenzeProvider).value?.bloccoAttivo ?? false;
        return Column(
          children: [
            if (bloccoAttivo)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                  child: Row(
                    children: [
                      Text('auri', style: titolo(24)),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Blocca app',
                        onPressed: () => ref.read(bloccoProvider.notifier).blocca(),
                        icon: const Icon(Icons.lock_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SafeArea(
                top: !bloccoAttivo,
                bottom: false,
                child: Padding(padding: const EdgeInsets.all(16), child: pagina),
              ),
            ),
            NavigationBar(
              selectedIndex: sezione.index,
              onDestinationSelected: (i) => ref.read(sezioneProvider.notifier).vai(Sezione.values[i]),
              destinations: [
                for (final v in _voci) NavigationDestination(icon: Icon(v.$3), label: v.$2),
                const NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Impostazioni'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BarraLaterale extends ConsumerWidget {
  const _BarraLaterale();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sezione = ref.watch(sezioneProvider);
    Widget voce(Sezione s, String etichetta, IconData icona) =>
        _Voce(etichetta: etichetta, icona: icona, attiva: s == sezione, onTap: () => ref.read(sezioneProvider.notifier).vai(s));

    final bloccoAttivo = ref.watch(preferenzeProvider).value?.bloccoAttivo ?? false;
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      // Riempie l'altezza; se non basta (es. tastiera aperta) scorre invece di traboccare.
      child: LayoutBuilder(
        builder: (context, vincoli) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: vincoli.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 22),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('auri', style: titolo(30)),
                        const SizedBox(width: 6),
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: const BoxDecoration(color: AuriColori.lime, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                  for (final v in _voci) voce(v.$1, v.$2, v.$3),
                  const Divider(height: 25, indent: 8, endIndent: 8, color: Color(0xFFECEAF5)),
                  const _Voce(etichetta: 'Lezioni', icona: Icons.mic_none_rounded, presto: true),
                  const Spacer(),
                  voce(Sezione.impostazioni, 'Impostazioni', Icons.settings_rounded),
                  if (bloccoAttivo) _Voce(etichetta: 'Blocca app', icona: Icons.lock_outline_rounded, onTap: () => ref.read(bloccoProvider.notifier).blocca()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Voce extends StatelessWidget {
  const _Voce({required this.etichetta, required this.icona, this.attiva = false, this.presto = false, this.onTap});
  final String etichetta;
  final IconData icona;
  final bool attiva;
  final bool presto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colore = attiva ? Colors.white : (presto ? AuriColori.grigioChiaro : AuriColori.inchiostro);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: attiva ? AuriColori.viola : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(icona, size: 20, color: colore),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      etichetta,
                      overflow: TextOverflow.ellipsis,
                      style: testo(15, peso: FontWeight.w600, colore: colore),
                    ),
                  ),
                  if (presto) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AuriColori.sfondo, borderRadius: BorderRadius.circular(99)),
                      child: Text(
                        'presto',
                        style: testo(11, peso: FontWeight.w700, colore: AuriColori.grigio),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
