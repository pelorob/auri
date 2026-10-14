import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../domain/preferenze.dart';

class PrimoAvvioPage extends ConsumerStatefulWidget {
  const PrimoAvvioPage({super.key});
  @override
  ConsumerState<PrimoAvvioPage> createState() => _PrimoAvvioPageState();
}

class _PrimoAvvioPageState extends ConsumerState<PrimoAvvioPage> {
  final _pagine = PageController();
  final _nome = TextEditingController();
  int _passo = 0;
  int _cfu = 180;
  int _lode = 30;
  bool _blocco = false;
  bool _finito = false;

  /// Salva quanto scelto finora: con "Salta" i passi non visti restano ai valori predefiniti.
  Future<void> _fine() async {
    if (_finito) return;
    _finito = true;
    final repo = ref.read(repositoryProvider);
    await repo.salvaPreferenza(Preferenze.kNome, _nome.text.trim());
    await repo.salvaPreferenza(Preferenze.kCfuTotali, '$_cfu');
    await repo.salvaPreferenza(Preferenze.kLode, '$_lode');
    await repo.salvaPreferenza(Preferenze.kBlocco, '$_blocco');
    await repo.salvaPreferenza(Preferenze.kPrimoAvvioIl, DateTime.now().toIso8601String());
    await repo.salvaPreferenza(Preferenze.kPrimoAvvioFatto, 'true');
  }

  void _avanti() {
    if (_passo == 2) {
      _fine();
      return;
    }
    setState(() => _passo++);
    _pagine.animateToPage(_passo, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final touchId = ref.watch(touchIdDisponibileProvider).value ?? false;
    Widget passo(String t, Widget contenuto) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t, style: titolo(40)),
        const SizedBox(height: 24),
        contenuto,
      ],
    );
    // Material (non ColoredBox): l'interruttore di Touch ID disegna l'effetto del tocco.
    return Material(
      color: AuriColori.sfondo,
      child: Center(
        child: SizedBox(
          width: 560,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pagine,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    passo(
                      'Benvenuta in auri',
                      Column(
                        children: [
                          TextField(
                            controller: _nome,
                            decoration: const InputDecoration(labelText: 'Il tuo corso di laurea (es. Ingegneria Informatica)'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('CFU totali'),
                              const Spacer(),
                              for (final v in [120, 180, 300, 360])
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ChoiceChip(label: Text('$v'), selected: _cfu == v, onSelected: (_) => setState(() => _cfu = v)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    passo(
                      'Quanto vale la lode?',
                      SegmentedButton<int>(
                        segments: [
                          for (final v in [30, 31, 32, 33]) ButtonSegment(value: v, label: Text('$v')),
                        ],
                        selected: {_lode},
                        onSelectionChanged: (s) => setState(() => _lode = s.first),
                      ),
                    ),
                    passo(
                      'Proteggere auri con Touch ID?',
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Blocca con Touch ID'),
                        subtitle: Text(touchId ? 'Potrai cambiarlo nelle impostazioni' : 'Touch ID non è configurato: puoi attivarlo più tardi'),
                        value: _blocco && touchId,
                        onChanged: touchId ? (v) => setState(() => _blocco = v) : null,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  children: [
                    TextButton(onPressed: _fine, child: const Text('Salta')),
                    const Spacer(),
                    FilledButton(onPressed: _avanti, child: Text(_passo == 2 ? 'Inizia' : 'Avanti')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
