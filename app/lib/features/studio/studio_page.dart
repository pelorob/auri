import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/componenti.dart';
import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../domain/avvisi.dart';
import '../../domain/formati.dart';
import '../../domain/studio.dart';
import 'pomodoro.dart';

/// Pomodoro, piano di studio per esame e statistiche.
class StudioPage extends ConsumerWidget {
  const StudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                TitoloPagina(sopra: 'Concentrazione', testoTitolo: 'Studio'),
                SizedBox(height: 20),
                _Pomodoro(),
                SizedBox(height: 16),
                _Piani(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(child: _Statistiche()),
      ],
    );
  }
}

class _Pomodoro extends ConsumerWidget {
  const _Pomodoro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(pomodoroProvider);
    final p = ref.read(pomodoroProvider.notifier);
    final corsi = ref.watch(corsiProvider).value ?? const [];
    return Scheda(
      colore: s.pausa ? AuriColori.lime : AuriColori.viola,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Etichetta(s.pausa ? 'Pausa' : 'Pomodoro', colore: s.pausa ? AuriColori.inchiostro : AuriColori.violaChip),
          const SizedBox(height: 8),
          Center(
            child: Text(formattaTimer(s.secondi), style: titolo(84, colore: s.pausa ? AuriColori.inchiostro : Colors.white)),
          ),
          if (s.completati > 0)
            Center(
              child: Text('${s.completati} completati oggi', style: testo(13, colore: s.pausa ? AuriColori.inchiostro : AuriColori.violaChip)),
            ),
          const SizedBox(height: 12),
          if (!s.inCorso) ...[
            DropdownButtonFormField<int?>(
              initialValue: corsi.any((c) => c.corso.id == s.corsoId) ? s.corsoId : null,
              dropdownColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Corso', fillColor: Colors.white),
              items: [
                const DropdownMenuItem(value: null, child: Text('Nessun corso')),
                for (final c in corsi)
                  DropdownMenuItem(
                    value: c.corso.id,
                    child: Text(c.corso.nome, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: p.scegliCorso,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final (studio, pausa) in const [(25, 5), (50, 10), (15, 5)])
                  ChoiceChip(label: Text('$studio / $pausa'), selected: s.minutiStudio == studio, onSelected: (_) => p.scegliDurata(studio, pausa)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: s.pausa ? AuriColori.inchiostro : AuriColori.lime,
              foregroundColor: s.pausa ? Colors.white : AuriColori.inchiostro,
            ),
            onPressed: s.inCorso ? p.ferma : p.inizia,
            child: Text(s.inCorso ? 'Ferma' : 'Inizia'),
          ),
        ],
      ),
    );
  }
}

class _Piani extends ConsumerWidget {
  const _Piani();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piani = ref.watch(pianiProvider);
    final corsi = {for (final c in ref.watch(corsiProvider).value ?? const []) c.corso.id: c.corso.nome};
    final ora = ref.watch(orologioProvider)();
    return Scheda(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Piano di studio', style: titolo(20, peso: FontWeight.w700)),
          const SizedBox(height: 8),
          if (piani.isEmpty) Text('Importa le slide di un corso e aggiungi il suo appello per avere il piano.', style: testo(14, colore: AuriColori.grigio)),
          for (final MapEntry(key: corsoId, value: x) in piani.entries) ...[
            const SizedBox(height: 10),
            Text(corsi[corsoId] ?? '', style: testo(15, peso: FontWeight.w700)),
            Text('Esame ${dataLunga(x.esame)} · tra ${giorniTra(ora, x.esame)} giorni', style: testo(13, colore: AuriColori.grigio)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: x.piano.percentuale,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              color: AuriColori.viola,
              backgroundColor: AuriColori.violaTenue,
            ),
            const SizedBox(height: 4),
            Text('Oggi: ${x.piano.paginePerOggi} pagine', style: testo(14, peso: FontWeight.w700)),
            Text('${x.piano.fatte} di ${x.piano.totalePagine} pagine studiate', style: testo(12, colore: AuriColori.grigio)),
          ],
        ],
      ),
    );
  }
}

class _Statistiche extends ConsumerWidget {
  const _Statistiche();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ora = ref.watch(orologioProvider)();
    final corsi = {for (final c in ref.watch(corsiProvider).value ?? const []) c.corso.id: c.corso.nome};
    final sessioni = ref.watch(sessioniProvider).value ?? const [];
    final revisioni = ref.watch(revisioniProvider).value ?? const [];
    final carte = {for (final c in ref.watch(carteProvider).value ?? const []) c.id: c.fronte};
    final simulazioni = ref.watch(simulazioniProvider).value ?? const [];
    final lista = [for (final s in sessioni) (corsoId: s.corsoId, inizio: s.inizio, minuti: s.minuti)];
    final settimana = minutiPerCorso(lista, oggi: ora, giorni: 7);
    final mese = minutiPerCorso(lista, oggi: ora, giorni: 30);
    final perGiorno = revisioniPerGiorno([for (final r in revisioni) r.data], oggi: ora);
    final deboli = argomentiDeboli([for (final r in revisioni) (cartaId: r.cartaId, risposta: r.risposta)]);
    final massimoMinuti = mese.values.fold(1, (a, b) => a > b ? a : b);
    final massimoGiorno = perGiorno.fold(1, (a, b) => a > b ? a : b);

    return ListView(
      children: [
        const SizedBox(height: 6),
        Text('Statistiche', style: titolo(30)),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Minuti di studio', style: titolo(20, peso: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('ultimi 7 giorni (in viola) e 30 giorni', style: testo(13, colore: AuriColori.grigio)),
              const SizedBox(height: 12),
              if (mese.isEmpty) Text('Usa il Pomodoro: qui vedrai quanto studi per ogni corso.', style: testo(14, colore: AuriColori.grigio)),
              for (final MapEntry(key: id, value: minuti) in mese.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${corsi[id] ?? ''} · ${settimana[id] ?? 0} min / $minuti min', style: testo(14, peso: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: minuti / massimoMinuti,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(color: AuriColori.violaTenue, borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (settimana[id] ?? 0) / massimoMinuti,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(color: AuriColori.viola, borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Carte ripassate', style: titolo(20, peso: FontWeight.w700)),
              Text('ultimi 14 giorni', style: testo(13, colore: AuriColori.grigio)),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final n in perGiorno)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Tooltip(
                            message: '$n carte',
                            child: Container(
                              height: 6 + 80 * n / massimoGiorno,
                              decoration: BoxDecoration(color: n == 0 ? AuriColori.violaTenue : AuriColori.viola, borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Simulazioni d\'esame', style: titolo(20, peso: FontWeight.w700)),
              const SizedBox(height: 8),
              if (simulazioni.isEmpty) Text('Nessuna simulazione ancora.', style: testo(14, colore: AuriColori.grigio)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in simulazioni.reversed.take(12))
                    Pillola('${dataLunga(s.data)} · ${corsi[s.corsoId] ?? ''}: ${s.voto}', sfondo: s.voto >= 18 ? AuriColori.violaTenue : AuriColori.limeTenue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Scheda(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Da ripassare di più', style: titolo(20, peso: FontWeight.w700)),
              const SizedBox(height: 8),
              if (deboli.isEmpty) Text('Nessun punto debole per ora.', style: testo(14, colore: AuriColori.grigio)),
              for (final id in deboli)
                if (carte[id] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• ${carte[id]}', style: testo(14)),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
