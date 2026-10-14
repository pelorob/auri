import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

class StatoPomodoro {
  const StatoPomodoro({
    this.inCorso = false,
    this.pausa = false,
    this.secondi = 25 * 60,
    this.minutiStudio = 25,
    this.minutiPausa = 5,
    this.corsoId,
    this.completati = 0,
  });
  final bool inCorso;
  final bool pausa;
  final int secondi;
  final int minutiStudio;
  final int minutiPausa;
  final int? corsoId;
  final int completati;

  StatoPomodoro copia({bool? inCorso, bool? pausa, int? secondi, int? minutiStudio, int? minutiPausa, int? Function()? corsoId, int? completati}) =>
      StatoPomodoro(
        inCorso: inCorso ?? this.inCorso,
        pausa: pausa ?? this.pausa,
        secondi: secondi ?? this.secondi,
        minutiStudio: minutiStudio ?? this.minutiStudio,
        minutiPausa: minutiPausa ?? this.minutiPausa,
        corsoId: corsoId == null ? this.corsoId : corsoId(),
        completati: completati ?? this.completati,
      );
}

/// Pomodoro: studio, poi pausa; ogni fase di studio completata diventa una sessione salvata.
///
/// Il tempo si misura dall'orario di fine fase (non contando i secondi): con l'iPad bloccato iOS
/// sospende l'app, ma al ritorno il conto è giusto, e a fine fase arriva una notifica locale.
class PomodoroController extends Notifier<StatoPomodoro> {
  Timer? _timer;
  DateTime? _inizio;
  DateTime? _fine;
  bool _occupato = false;

  /// Se la pausa è finita da più di così, lei non c'era: il Pomodoro si ferma invece di ripartire da solo.
  static const _ritardoMassimo = Duration(minutes: 1);

  @override
  StatoPomodoro build() {
    ref.onDispose(() => _timer?.cancel());
    return const StatoPomodoro();
  }

  void scegliCorso(int? corsoId) => state = state.copia(corsoId: () => corsoId);

  void scegliDurata(int minutiStudio, int minutiPausa) {
    if (state.inCorso) return;
    state = state.copia(minutiStudio: minutiStudio, minutiPausa: minutiPausa, secondi: minutiStudio * 60, pausa: false);
  }

  void inizia() {
    _inizio = ref.read(orologioProvider)();
    _fine = clock.now().add(Duration(seconds: state.secondi));
    // La prima volta iOS chiede il permesso; poi la notifica di fine fase viene programmata.
    ref.read(richiestaPermessoNotificheProvider)().then((_) => _avvisa());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _avanza());
    state = state.copia(inCorso: true);
  }

  void ferma() {
    _timer?.cancel();
    _fine = null;
    ref.read(notificheProvider).annullaPomodoro();
    state = state.copia(inCorso: false, pausa: false, secondi: state.minutiStudio * 60);
  }

  void _avvisa() {
    final fine = _fine;
    if (fine == null) return;
    final (titolo, testo) = state.pausa
        ? ('Pausa finita', 'Si ricomincia: altri ${state.minutiStudio} minuti di studio.')
        : ('Pomodoro completato', 'Brava! Ora ${state.minutiPausa} minuti di pausa.');
    ref.read(notificheProvider).programmaPomodoro(fine, titolo, testo);
  }

  Future<void> _avanza() async {
    final fine = _fine;
    if (_occupato || fine == null) return;
    final ora = clock.now();
    final resto = fine.difference(ora);
    if (resto > Duration.zero) {
      state = state.copia(secondi: (resto.inMilliseconds / 1000).ceil());
      return;
    }
    if (!state.pausa) {
      _occupato = true;
      try {
        await ref.read(repositoryProvider).salvaSessione(corsoId: state.corsoId, inizio: _inizio ?? DateTime.now(), minuti: state.minutiStudio);
      } finally {
        _occupato = false;
      }
      if (_fine != fine) return; // fermato durante il salvataggio
      _fine = fine.add(Duration(minutes: state.minutiPausa));
      state = state.copia(pausa: true, secondi: state.minutiPausa * 60, completati: state.completati + 1);
      if (_fine!.isAfter(ora)) {
        _avvisa();
        state = state.copia(secondi: (_fine!.difference(ora).inMilliseconds / 1000).ceil());
      } else {
        ferma(); // anche la pausa è passata mentre l'iPad era bloccato
      }
    } else if (ora.difference(fine) > _ritardoMassimo) {
      ferma();
    } else {
      _inizio = ref.read(orologioProvider)();
      _fine = ora.add(Duration(minutes: state.minutiStudio));
      state = state.copia(pausa: false, secondi: state.minutiStudio * 60);
      _avvisa();
    }
  }
}

final pomodoroProvider = NotifierProvider<PomodoroController, StatoPomodoro>(PomodoroController.new);
