import 'package:auri/app/providers.dart';
import 'package:auri/data/repository.dart';
import 'package:auri/features/studio/pomodoro.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepoFinto extends Fake implements Repository {
  final sessioni = <int>[];
  @override
  Future<int> salvaSessione({required int? corsoId, required DateTime inizio, required int minuti}) async {
    sessioni.add(minuti);
    return sessioni.length;
  }
}

void main() {
  late _RepoFinto repo;
  late ProviderContainer c;

  setUp(() {
    repo = _RepoFinto();
    c = ProviderContainer(overrides: [repositoryProvider.overrideWithValue(repo)]);
  });
  tearDown(() => c.dispose());

  test('iPad bloccato durante lo studio: al ritorno la sessione è salvata e si è in pausa', () {
    fakeAsync((async) {
      c.read(pomodoroProvider.notifier).inizia();
      async.elapse(const Duration(minutes: 1));
      expect(c.read(pomodoroProvider).secondi, 24 * 60);
      // App sospesa: il tempo passa ma il timer non scatta.
      async.elapseBlocking(const Duration(minutes: 26));
      async.elapse(const Duration(seconds: 1));
      final s = c.read(pomodoroProvider);
      expect(repo.sessioni, [25]);
      expect(s.pausa, isTrue);
      expect(s.inCorso, isTrue);
      expect(s.secondi, 2 * 60 + 59); // 27 min e 1 s dopo l'inizio: la pausa finisce a 30 min
    });
  });

  test('iPad bloccato oltre la fine della pausa: una sola sessione e Pomodoro fermo', () {
    fakeAsync((async) {
      c.read(pomodoroProvider.notifier).inizia();
      async.elapseBlocking(const Duration(hours: 2));
      async.elapse(const Duration(seconds: 1));
      async.elapse(const Duration(seconds: 5));
      final s = c.read(pomodoroProvider);
      expect(repo.sessioni, [25]);
      expect(s.inCorso, isFalse);
      expect(s.secondi, 25 * 60);
    });
  });

  test('con l\'app aperta: studio, pausa e di nuovo studio', () {
    fakeAsync((async) {
      c.read(pomodoroProvider.notifier).inizia();
      async.elapse(const Duration(minutes: 25, seconds: 1));
      expect(c.read(pomodoroProvider).pausa, isTrue);
      async.elapse(const Duration(minutes: 5, seconds: 1));
      final s = c.read(pomodoroProvider);
      expect(s.pausa, isFalse);
      expect(s.inCorso, isTrue);
      expect(repo.sessioni, [25]);
      c.read(pomodoroProvider.notifier).ferma();
    });
  });
}
