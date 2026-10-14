import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../data/repository.dart';
import '../../domain/avvisi.dart';
import '../../domain/calendario.dart';
import '../../domain/studio.dart';
import '../../domain/formati.dart';
import '../../domain/modelli.dart';
import '../../domain/notifiche_piano.dart';
import 'appello_form.dart';

class CalendarioPage extends ConsumerStatefulWidget {
  const CalendarioPage({super.key});
  @override
  ConsumerState<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends ConsumerState<CalendarioPage> {
  DateTime? _mese;

  @override
  Widget build(BuildContext context) {
    final ora = ref.watch(orologioProvider)();
    final mese = _mese ?? DateTime(ora.year, ora.month);
    final appelli = ref.watch(appelliProvider).value ?? const <AppelloConCorso>[];
    final futuri = appelli.where((a) => a.appello.dataOra.isAfter(ora)).toList();
    final permesso = ref.watch(permessoNotificheProvider).value;
    final celle = celleMese(mese.year, mese.month);
    final ripasso = {for (final x in ref.watch(pianiProvider).values) ...giorniDiRipasso(ora, x.esame)};
    final nomeMese = mesi[mese.month - 1];
    final titoloMese = '${nomeMese[0].toUpperCase()}${nomeMese.substring(1)} ${mese.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitoloPagina(
                sopra: 'Sessione d\'esami',
                testoTitolo: 'Calendario esami',
                azione: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Mese precedente',
                      onPressed: () => setState(() => _mese = DateTime(mese.year, mese.month - 1)),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        titoloMese,
                        textAlign: TextAlign.center,
                        style: titolo(18, peso: FontWeight.w700),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Mese successivo',
                      onPressed: () => setState(() => _mese = DateTime(mese.year, mese.month + 1)),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (permesso == false) ...[
                Scheda(
                  colore: AuriColori.lime,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Le notifiche sono disattivate: non riceverai i promemoria degli esami.')),
                      TextButton(onPressed: () => launchUrl(Uri.parse('app-settings:')), child: const Text('Apri impostazioni')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: Scheda(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (final g in const ['LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM']) Expanded(child: Center(child: Etichetta(g))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, v) {
                            final righe = celle.length ~/ 7;
                            final altezza = (v.maxHeight - (righe - 1) * 6) / righe;
                            final larghezza = (v.maxWidth - 6 * 6) / 7;
                            return GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 7,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: larghezza / altezza,
                              children: [for (final g in celle) _Cella(g, ora, appelli, ripasso)],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
                child: Row(
                  children: [
                    Expanded(child: Text('Appelli', style: titolo(24))),
                    FilledButton.icon(onPressed: () => mostraFormAppello(context), icon: const Icon(Icons.add_rounded), label: const Text('Nuovo')),
                  ],
                ),
              ),
              Expanded(
                child: futuri.isEmpty
                    ? Center(
                        child: Text('Nessun appello in programma', style: testo(15, colore: AuriColori.grigio)),
                      )
                    : ListView.separated(
                        itemCount: futuri.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _SchedaAppello(futuri[i], ora),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cella extends StatelessWidget {
  const _Cella(this.giorno, this.ora, this.appelli, this.ripasso);
  final DateTime? giorno;
  final DateTime ora;
  final List<AppelloConCorso> appelli;

  /// Giorni del piano di studio prima degli esami.
  final Set<DateTime> ripasso;

  /// Con più appelli nello stesso giorno lascia scegliere quale aprire.
  Future<void> _apri(BuildContext context, List<AppelloConCorso> delGiorno) async {
    if (delGiorno.length == 1) return mostraFormAppello(context, appello: delGiorno.single.appello);
    final scelto = await showModalBottomSheet<Appello>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text('Quale appello?', style: titolo(22)),
            ),
            for (final a in delGiorno)
              ListTile(
                leading: CircleAvatar(radius: 8, backgroundColor: coloreDaHex(a.corso.colore)),
                title: Text(a.corso.nome),
                subtitle: Text('${a.appello.tipo.etichetta} · ${oraMinuti(a.appello.dataOra)}${a.appello.aula == null ? '' : ' · ${a.appello.aula}'}'),
                onTap: () => Navigator.pop(c, a.appello),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (scelto != null && context.mounted) await mostraFormAppello(context, appello: scelto);
  }

  @override
  Widget build(BuildContext context) {
    final g = giorno;
    if (g == null) return const SizedBox();
    final delGiorno = appelli.where((a) => giorniTra(a.appello.dataOra, g) == 0).toList();
    final oggi = giorniTra(ora, g) == 0;
    final passato = giorniTra(ora, g) < 0;
    final diRipasso = delGiorno.isEmpty && ripasso.contains(DateTime(g.year, g.month, g.day));
    return Material(
      key: diRipasso ? ValueKey('ripasso-${g.year}-${g.month.toString().padLeft(2, '0')}-${g.day.toString().padLeft(2, '0')}') : null,
      color: delGiorno.isNotEmpty ? AuriColori.violaTenue : (diRipasso ? AuriColori.limeTenue : AuriColori.cella),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: oggi ? const BorderSide(color: AuriColori.inchiostro, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: delGiorno.isEmpty ? null : () => _apri(context, delGiorno),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${g.day}',
                style: titolo(16, peso: FontWeight.w700, colore: passato ? AuriColori.grigioChiaro : AuriColori.inchiostro),
              ),
              for (final a in delGiorno.take(2))
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: coloreDaHex(a.corso.colore), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${a.corso.nome} · ${a.appello.tipo.etichetta}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: testo(11, peso: FontWeight.w800, colore: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchedaAppello extends ConsumerWidget {
  const _SchedaAppello(this.a, this.ora);
  final AppelloConCorso a;
  final DateTime ora;

  static const _etichetteP = {7: '7 g', 1: '1 g', 0: 'mattina'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ap = a.appello;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => mostraFormAppello(context, appello: ap),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TesseraData(ap.dataOra, sfondo: tinta(a.corso.colore)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.corso.nome,
                          style: testo(15, peso: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${ap.tipo.etichetta} · ${oraMinuti(ap.dataOra)}${ap.aula == null ? '' : ' · ${ap.aula}'}',
                          style: testo(12, colore: AuriColori.grigio),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Pillola(mancanoBreve(giorniTra(ora, ap.dataOra)), sfondo: AuriColori.lime),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 16, color: AuriColori.grigio),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [for (final p in leggiPreavvisi(ap.preavvisi)) Pillola(_etichetteP[p.giorniPrima] ?? '${p.giorniPrima} g')],
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(44, 36),
                      backgroundColor: ap.iscritta ? AuriColori.viola : AuriColori.sfondo,
                      foregroundColor: ap.iscritta ? Colors.white : AuriColori.inchiostro,
                    ),
                    onPressed: () => ref.read(repositoryProvider).impostaIscritta(ap.id, !ap.iscritta),
                    child: Text(ap.iscritta ? 'Iscritta' : 'Non iscritta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
