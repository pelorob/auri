import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../domain/avvisi.dart';
import '../../domain/formati.dart';
import '../../domain/modelli.dart';
import '../../domain/preferenze.dart';
import '../../domain/studio.dart';
import '../aggiungi.dart';

class OggiPage extends ConsumerWidget {
  const OggiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ora = ref.watch(orologioProvider)();
    final corsi = ref.watch(corsiProvider).value ?? const [];
    final appelli = ref.watch(appelliProvider).value ?? const [];
    final pref = ref.watch(preferenzeProvider).value ?? Preferenze.predefinite;
    final r = ref.watch(riepilogoProvider);
    final scadenza = ref.watch(scadenzaFirmaProvider).value;

    final futuri = appelli.where((a) => a.appello.dataOra.isAfter(ora)).toList();
    final prossimo = futuri.isEmpty ? null : futuri.first;
    final ultimiVoti = corsi.where((c) => c.esito != null).toList()..sort((a, b) => b.esito!.data.compareTo(a.esito!.data));
    final giorniFirma = giorniAllaScadenza(scadenza, ora);

    final avvisi = <String>[
      if (mostraAvvisoFirma(giorniFirma)) testoAvvisoFirma(giorniFirma!),
      if (pref.primoAvvioIl != null && mostraPromemoriaBackup(ultimoBackup: pref.ultimoBackup, primoAvvio: pref.primoAvvioIl!, ora: ora))
        'Fai un backup: Impostazioni → Esporta backup',
    ];

    final giorno = giornoSettimana(ora);
    final giornoCap = '${giorno[0].toUpperCase()}${giorno.substring(1)}';
    // Riempie lo schermo; se gli avvisi tolgono spazio, la pagina scorre invece di traboccare.
    return LayoutBuilder(
      builder: (context, vincoli) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: vincoli.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TitoloPagina(sopra: '$giornoCap ${dataLunga(ora)}', testoTitolo: 'Ciao! Pronta a spaccare?', azione: pulsanteAggiungi(context)),
                const SizedBox(height: 20),
                for (final a in avvisi) ...[
                  Scheda(
                    colore: AuriColori.lime,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(a, style: testo(15, peso: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: 270,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ProssimoEsame(
                          prossimo == null ? null : (prossimo.corso.nome, prossimo.appello.tipo, prossimo.appello.dataOra, prossimo.appello.aula),
                          ora,
                          piano: prossimo == null ? null : ref.watch(pianiProvider)[prossimo.corso.id]?.piano,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _Media(r.mediaPonderata, r.baseLaurea, r.cfuConVoto, onTap: () => ref.read(sezioneProvider.notifier).vai(Sezione.libretto)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _Cfu(r.cfuOttenuti, pref.cfuTotali)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _Elenco(
                          titoloElenco: 'Prossimi appelli',
                          link: 'Tutti',
                          onLink: () => ref.read(sezioneProvider.notifier).vai(Sezione.calendario),
                          vuoto: 'Nessun appello',
                          righe: [
                            for (final a in futuri.take(3))
                              Row(
                                children: [
                                  TesseraData(a.appello.dataOra, sfondo: tinta(a.corso.colore)),
                                  const SizedBox(width: 14),
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
                                          '${a.appello.tipo.etichetta} · ${oraMinuti(a.appello.dataOra)}${a.appello.aula == null ? '' : ' · ${a.appello.aula}'}',
                                          style: testo(13, colore: AuriColori.grigio),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Pillola(mancanoBreve(giorniTra(ora, a.appello.dataOra))),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _Elenco(
                          titoloElenco: 'Ultimi voti',
                          link: 'Libretto',
                          onLink: () => ref.read(sezioneProvider.notifier).vai(Sezione.libretto),
                          vuoto: 'Ancora nessun voto',
                          righe: [
                            for (final c in ultimiVoti.take(3))
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.corso.nome,
                                          style: testo(15, peso: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text('${c.corso.cfu} CFU · ${dataLunga(c.esito!.data)}', style: testo(13, colore: AuriColori.grigio)),
                                      ],
                                    ),
                                  ),
                                  _Voto(c.esito!.voto, c.esito!.lode),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProssimoEsame extends StatelessWidget {
  const _ProssimoEsame(this.dati, this.ora, {this.piano});
  final (String, TipoAppello, DateTime, String?)? dati;
  final DateTime ora;
  final PianoStudio? piano;

  @override
  Widget build(BuildContext context) {
    final d = dati;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AuriColori.viola, borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(color: AuriColori.viola2, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: d == null
                ? Center(
                    child: Text(
                      'Nessun esame in vista: aggiungi un appello',
                      style: titolo(26, colore: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Pillola('PROSSIMO ESAME', sfondo: AuriColori.lime),
                            const SizedBox(height: 16),
                            Text(
                              d.$1,
                              style: titolo(34, colore: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${d.$2.etichetta[0].toUpperCase()}${d.$2.etichetta.substring(1)} · ${giornoSettimana(d.$3).substring(0, 3)} ${dataLunga(d.$3)} · ${oraMinuti(d.$3)}${d.$4 == null ? '' : ' · ${d.$4}'}',
                              style: testo(15, colore: AuriColori.violaChip),
                            ),
                            if (piano != null && piano!.totalePagine > 0) ...[
                              const Spacer(),
                              Text(
                                'Piano di ripasso ${(piano!.percentuale * 100).round()}% · oggi ${quanti(piano!.paginePerOggi, 'pagina', 'pagine')}',
                                style: testo(13, peso: FontWeight.w600, colore: AuriColori.violaChip),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: piano!.percentuale,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                                color: AuriColori.lime,
                                backgroundColor: AuriColori.viola3,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: giorniTra(ora, d.$3) == 0
                            ? [
                                Text('Oggi', style: titolo(72, colore: AuriColori.lime)),
                                Text(
                                  'in bocca al lupo!',
                                  style: testo(16, peso: FontWeight.w700, colore: Colors.white),
                                ),
                              ]
                            : [
                                Text('${giorniTra(ora, d.$3)}', style: titolo(112, colore: AuriColori.lime)),
                                Text(
                                  giorniTra(ora, d.$3) == 1 ? 'giorno' : 'giorni',
                                  style: testo(16, peso: FontWeight.w700, colore: Colors.white),
                                ),
                              ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Media extends StatelessWidget {
  const _Media(this.media, this.base, this.cfuConVoto, {required this.onTap});
  final double? media;
  final double? base;
  final int cfuConVoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AuriColori.lime,
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Etichetta('Media ponderata', colore: AuriColori.inchiostro),
            const SizedBox(height: 14),
            FittedBox(child: Text(formatta(media, 2), style: titolo(76))),
            Text('su $cfuConVoto CFU con voto', style: testo(14, peso: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AuriColori.inchiostro, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Base di laurea',
                      style: testo(13, peso: FontWeight.w600, colore: Colors.white),
                    ),
                  ),
                  Text(formatta(base, 1), style: titolo(22, colore: Colors.white)),
                  Text('/110', style: testo(14, colore: const Color(0xFFB9B4D0))),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Cfu extends StatelessWidget {
  const _Cfu(this.ottenuti, this.totali);
  final int ottenuti;
  final int totali;

  @override
  Widget build(BuildContext context) {
    final quota = totali == 0 ? 0.0 : (ottenuti / totali).clamp(0.0, 1.0);
    return Scheda(
      child: Column(
        children: [
          const Align(alignment: Alignment.centerLeft, child: Etichetta('Avanzamento')),
          const Spacer(),
          SizedBox(
            width: 168,
            height: 168,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: quota,
                    strokeWidth: 18,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AuriColori.violaTenue,
                    color: AuriColori.viola,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$ottenuti', style: titolo(44)),
                    Text(
                      'di $totali CFU',
                      style: testo(13, peso: FontWeight.w600, colore: AuriColori.grigio),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Hai fatto il ${(quota * 100).round()}% del percorso',
            style: testo(14, peso: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Elenco extends StatelessWidget {
  const _Elenco({required this.titoloElenco, required this.link, required this.onLink, required this.righe, required this.vuoto});
  final String titoloElenco;
  final String link;
  final VoidCallback onLink;
  final List<Widget> righe;
  final String vuoto;

  @override
  Widget build(BuildContext context) => Scheda(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(titoloElenco, style: titolo(20, peso: FontWeight.w700)),
            ),
            TextButton(
              onPressed: onLink,
              child: Text(
                link,
                style: testo(14, peso: FontWeight.w700, colore: AuriColori.viola),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (righe.isEmpty) Text(vuoto, style: testo(14, colore: AuriColori.grigio)),
        for (final r in righe) Padding(padding: const EdgeInsets.only(bottom: 14), child: r),
      ],
    ),
  );
}

class _Voto extends StatelessWidget {
  const _Voto(this.voto, this.lode);
  final int? voto;
  final bool lode;

  @override
  Widget build(BuildContext context) {
    final forte = voto == 30;
    return Container(
      constraints: const BoxConstraints(minWidth: 52),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: forte ? AuriColori.viola : AuriColori.violaTenue, borderRadius: BorderRadius.circular(14)),
      child: Text(
        voto == null ? 'Idoneo' : '$voto${lode ? 'L' : ''}',
        style: titolo(voto == null ? 13 : 20, colore: forte ? Colors.white : AuriColori.inchiostro),
      ),
    );
  }
}
