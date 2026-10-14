import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/repository.dart';
import '../../domain/formati.dart';
import '../../domain/libretto.dart';
import '../../domain/modelli.dart';
import '../../domain/preferenze.dart';
import 'voto_form.dart';

class LibrettoPage extends ConsumerStatefulWidget {
  const LibrettoPage({super.key});
  @override
  ConsumerState<LibrettoPage> createState() => _LibrettoPageState();
}

class _LibrettoPageState extends ConsumerState<LibrettoPage> {
  int? _corsoSimulato;
  int _votoSimulato = 27;
  int _obiettivo = 105;

  @override
  Widget build(BuildContext context) {
    final corsi = ref.watch(corsiProvider).value ?? const <CorsoConEsito>[];
    final pref = ref.watch(preferenzeProvider).value ?? Preferenze.predefinite;
    final r = ref.watch(riepilogoProvider);
    final superati = corsi.where((c) => c.superato).toList()..sort((a, b) => (b.esito!.voto ?? 0).compareTo(a.esito!.voto ?? 0));
    final daFare = corsi.where((c) => !c.superato).toList();
    final simulabili = daFare.where((c) => c.corso.valutazione == Valutazione.voto).toList();
    final sim = simulabili.where((c) => c.corso.id == _corsoSimulato).firstOrNull ?? simulabili.firstOrNull;
    final nuovaMedia = sim == null ? null : simulaMedia(r, cfu: sim.corso.cfu, voto: _votoSimulato, valoreLode: pref.valoreLode);
    final diff = (nuovaMedia != null && r.mediaPonderata != null) ? nuovaMedia - r.mediaPonderata! : null;
    final necessaria = mediaNecessaria(r, obiettivo: _obiettivo, cfuTotali: pref.cfuTotali);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitoloPagina(
                sopra: pref.nomeCorsoDiLaurea.isEmpty ? 'Il tuo percorso' : pref.nomeCorsoDiLaurea,
                testoTitolo: 'Libretto',
                azione: FilledButton.icon(onPressed: () => mostraFormVoto(context), icon: const Icon(Icons.add_rounded), label: const Text('Registra voto')),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Scheda(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: ListView(
                    children: [
                      Etichetta('Superati · ${superati.length}', colore: AuriColori.viola),
                      for (final c in superati) _Riga(c),
                      const SizedBox(height: 14),
                      Etichetta('Da sostenere · ${daFare.length}'),
                      for (final c in daFare) _Riga(c),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 360,
          child: ListView(
            children: [
              Scheda(
                colore: AuriColori.viola,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Etichetta('Media ponderata', colore: AuriColori.violaChip),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatta(r.mediaPonderata, 2), style: titolo(64, colore: AuriColori.lime)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'aritmetica ${formatta(r.mediaAritmetica, 2)}',
                            style: testo(14, peso: FontWeight.w600, colore: AuriColori.violaChip),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _Mini('Base di laurea', formatta(r.baseLaurea, 1), '/110')),
                        const SizedBox(width: 10),
                        Expanded(child: _Mini('CFU ottenuti', '${r.cfuOttenuti}', '/${pref.cfuTotali}')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (sim != null)
                Scheda(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Pillola('E SE…', sfondo: AuriColori.lime),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: sim.corso.id,
                              items: [
                                for (final c in simulabili)
                                  DropdownMenuItem(
                                    value: c.corso.id,
                                    child: Text('${c.corso.nome} · ${c.corso.cfu} CFU', overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                              onChanged: (v) => setState(() => _corsoSimulato = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            label: 'Abbassa il voto',
                            button: true,
                            excludeSemantics: true,
                            child: IconButton.filledTonal(
                              iconSize: 26,
                              onPressed: () => setState(() => _votoSimulato = (_votoSimulato - 1).clamp(18, 30)),
                              icon: const Icon(Icons.remove_rounded),
                            ),
                          ),
                          Column(
                            children: [
                              Text('$_votoSimulato', style: titolo(48)),
                              Text(
                                'voto ipotetico',
                                style: testo(12, peso: FontWeight.w600, colore: AuriColori.grigio),
                              ),
                            ],
                          ),
                          Semantics(
                            label: 'Alza il voto',
                            button: true,
                            excludeSemantics: true,
                            child: IconButton.filled(
                              iconSize: 26,
                              onPressed: () => setState(() => _votoSimulato = (_votoSimulato + 1).clamp(18, 30)),
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Chiaro(
                              'Nuova media',
                              formatta(nuovaMedia, 2),
                              diff == null ? null : '${diff >= 0 ? '+' : ''}${formatta(diff, 2)}',
                              diff != null && diff >= 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _Chiaro('Nuova base', nuovaMedia == null ? '—' : formatta(baseDaMedia(nuovaMedia), 1), '/110', true)),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (necessaria != null)
                Scheda(
                  colore: AuriColori.lime,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Etichetta('Obiettivo di laurea', colore: AuriColori.inchiostro),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final o in [100, 105, 110]) ...[
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: o == _obiettivo ? AuriColori.inchiostro : Colors.white,
                                  foregroundColor: o == _obiettivo ? Colors.white : AuriColori.inchiostro,
                                ),
                                onPressed: () => setState(() => _obiettivo = o),
                                child: Text('$o', style: titolo(17, colore: o == _obiettivo ? Colors.white : AuriColori.inchiostro)),
                              ),
                            ),
                            if (o != 110) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Media da tenere negli esami che mancano', style: testo(14, peso: FontWeight.w600)),
                      Text(switch (necessaria) {
                        Raggiungibile(:final valore) => formatta(valore, 2),
                        BastaPassare() => '18',
                        FuoriPortata() => 'oltre 30',
                      }, style: titolo(40)),
                      Text(switch (necessaria) {
                        FuoriPortata() => 'Fuori portata: prova un obiettivo più basso',
                        BastaPassare() => 'Basta passare gli esami che mancano',
                        Raggiungibile() => 'sui ${pref.cfuTotali - r.cfuOttenuti} CFU che ti mancano',
                      }, style: testo(13, peso: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga(this.c);
  final CorsoConEsito c;
  @override
  Widget build(BuildContext context) {
    final e = c.esito;
    final etichetta = e == null ? '—' : (e.voto == null ? 'Idoneo' : '${e.voto}${e.lode ? 'L' : ''}');
    final forte = e != null && e.voto == 30 && e.lode;
    return InkWell(
      onTap: () => mostraFormVoto(context, corso: c.corso),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuriColori.linea)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: e == null ? null : coloreDaHex(c.corso.colore),
                border: Border.all(color: coloreDaHex(c.corso.colore), width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.corso.nome,
                    style: testo(15, peso: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(e == null ? 'Da sostenere' : dataLunga(e.data), style: testo(12, colore: AuriColori.grigio)),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                '${c.corso.cfu}',
                textAlign: TextAlign.center,
                style: testo(15, peso: FontWeight.w600),
              ),
            ),
            Container(
              width: 70,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: e == null ? Colors.transparent : (forte ? AuriColori.viola : (e.voto == null ? AuriColori.sfondo : AuriColori.violaTenue)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(etichetta, style: titolo(e?.voto == null ? 13 : 18, colore: forte ? Colors.white : AuriColori.inchiostro)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.etichetta, this.valore, this.suffisso);
  final String etichetta, valore, suffisso;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: AuriColori.viola3, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etichetta,
          style: testo(12, peso: FontWeight.w600, colore: AuriColori.violaChip),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: valore,
                style: titolo(22, colore: Colors.white),
              ),
              TextSpan(
                text: suffisso,
                style: testo(13, colore: const Color(0xFFC9C0FF)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Chiaro extends StatelessWidget {
  const _Chiaro(this.etichetta, this.valore, this.extra, this.positivo);
  final String etichetta, valore;
  final String? extra;
  final bool positivo;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: AuriColori.sfondo, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etichetta,
          style: testo(12, peso: FontWeight.w600, colore: AuriColori.grigio),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: valore, style: titolo(20)),
              if (extra != null)
                TextSpan(
                  text: ' $extra',
                  style: testo(
                    13,
                    peso: FontWeight.w700,
                    colore: extra!.startsWith('/') ? AuriColori.grigio : (positivo ? AuriColori.verde : AuriColori.arancio),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
