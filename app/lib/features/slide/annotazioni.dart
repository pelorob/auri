import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/tema.dart';
import '../../data/database.dart';
import '../../domain/tratti.dart';

enum Strumento { nessuno, penna, evidenziatore, gomma }

class StatoStrumento {
  const StatoStrumento({this.strumento = Strumento.nessuno, this.colore = 0xFF5B3DE6, this.conDito = false});
  final Strumento strumento;
  final int colore;

  /// Se vero si disegna anche col dito (altrimenti il dito serve a scorrere).
  final bool conDito;

  StatoStrumento copia({Strumento? strumento, int? colore, bool? conDito}) =>
      StatoStrumento(strumento: strumento ?? this.strumento, colore: colore ?? this.colore, conDito: conDito ?? this.conDito);
}

class StrumentoController extends Notifier<StatoStrumento> {
  StrumentoController([this._iniziale = const StatoStrumento()]);
  final StatoStrumento _iniziale;

  @override
  StatoStrumento build() => _iniziale;
  void scegli(Strumento s) => state = state.copia(strumento: s);
  void colore(int c) => state = state.copia(colore: c);
  void conDito(bool v) => state = state.copia(conDito: v);
}

final strumentoProvider = NotifierProvider<StrumentoController, StatoStrumento>(StrumentoController.new);

/// Tratti di un documento (aggiornati in tempo reale).
final trattiProvider = StreamProvider.family<List<Tratto>, int>((ref, documentoId) => ref.watch(repositoryProvider).guardaTratti(documentoId));

const coloriPenna = [0xFF5B3DE6, 0xFF19142E, 0xFFE0457B, 0xFF14B8A6];
const coloriEvidenziatore = [0xFFD6F35B, 0xFFFFD166, 0xFF7DD3FC];
const nomiColori = {
  0xFF5B3DE6: 'viola',
  0xFF19142E: 'nero',
  0xFFE0457B: 'rosa',
  0xFF14B8A6: 'verde acqua',
  0xFFD6F35B: 'lime',
  0xFFFFD166: 'giallo',
  0xFF7DD3FC: 'azzurro',
};

/// Livello di disegno sopra una pagina del PDF.
class StratoAnnotazioni extends ConsumerStatefulWidget {
  const StratoAnnotazioni({super.key, required this.documentoId, required this.pagina});
  final int documentoId;
  final int pagina;

  @override
  ConsumerState<StratoAnnotazioni> createState() => _StratoAnnotazioniState();
}

class _StratoAnnotazioniState extends ConsumerState<StratoAnnotazioni> {
  List<Offset>? _incorso;

  Offset _rel(Offset locale, Size dimensione) => Offset(locale.dx / dimensione.width, locale.dy / dimensione.height);

  void _cancellaVicino(Offset punto, List<Tratto> tratti) {
    for (final t in tratti) {
      if (toccato(leggiPunti(t.punti), punto)) ref.read(repositoryProvider).eliminaTratto(t.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stato = ref.watch(strumentoProvider);
    final tratti = (ref.watch(trattiProvider(widget.documentoId)).value ?? const <Tratto>[]).where((t) => t.pagina == widget.pagina).toList();
    final disegno = CustomPaint(painter: _Pittore(tratti, _incorso, stato), size: Size.infinite);
    if (stato.strumento == Strumento.nessuno) return IgnorePointer(child: disegno);

    final dispositivi = {
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      if (stato.conDito) ...{PointerDeviceKind.touch, PointerDeviceKind.mouse},
    };
    return LayoutBuilder(
      builder: (context, v) => GestureDetector(
        supportedDevices: dispositivi,
        behavior: HitTestBehavior.translucent,
        onPanStart: (d) {
          final p = _rel(d.localPosition, v.biggest);
          if (stato.strumento == Strumento.gomma) {
            _cancellaVicino(p, tratti);
          } else {
            setState(() => _incorso = [p]);
          }
        },
        onPanUpdate: (d) {
          final p = _rel(d.localPosition, v.biggest);
          if (stato.strumento == Strumento.gomma) {
            _cancellaVicino(p, tratti);
          } else if (_incorso != null) {
            setState(() => _incorso!.add(p));
          }
        },
        onPanEnd: (_) {
          final punti = _incorso;
          setState(() => _incorso = null);
          if (punti == null || punti.length < 2) return;
          final evid = stato.strumento == Strumento.evidenziatore;
          ref
              .read(repositoryProvider)
              .salvaTratto(
                documentoId: widget.documentoId,
                pagina: widget.pagina,
                colore: stato.colore,
                spessore: evid ? 14 : 2.5,
                evidenziatore: evid,
                punti: scriviPunti(semplifica(punti)),
              );
        },
        child: disegno,
      ),
    );
  }
}

class _Pittore extends CustomPainter {
  _Pittore(this.tratti, this.incorso, this.stato);
  final List<Tratto> tratti;
  final List<Offset>? incorso;
  final StatoStrumento stato;

  void _disegna(Canvas canvas, Size size, List<Offset> punti, int colore, double spessore, bool evidenziatore) {
    if (punti.isEmpty) return;
    final scala = size.width / 400; // spessore pensato per una pagina larga ~400 punti
    final paint = Paint()
      ..color = Color(colore).withValues(alpha: evidenziatore ? 0.45 : 1)
      ..strokeWidth = spessore * scala
      ..strokeCap = evidenziatore ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = evidenziatore ? BlendMode.multiply : BlendMode.srcOver;
    final path = Path()..moveTo(punti.first.dx * size.width, punti.first.dy * size.height);
    for (final p in punti.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in tratti) {
      _disegna(canvas, size, leggiPunti(t.punti), t.colore, t.spessore, t.evidenziatore);
    }
    final c = incorso;
    if (c != null) {
      final evid = stato.strumento == Strumento.evidenziatore;
      _disegna(canvas, size, c, stato.colore, evid ? 14 : 2.5, evid);
    }
  }

  @override
  bool shouldRepaint(_Pittore vecchio) => true;
}

/// Barra degli strumenti di annotazione.
class BarraStrumenti extends ConsumerWidget {
  const BarraStrumenti({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(strumentoProvider);
    final c = ref.read(strumentoProvider.notifier);
    Widget pulsante(Strumento st, IconData icona, String nome) => IconButton(
      tooltip: nome,
      isSelected: s.strumento == st,
      style: IconButton.styleFrom(backgroundColor: s.strumento == st ? AuriColori.violaTenue : null),
      onPressed: () {
        c.scegli(s.strumento == st ? Strumento.nessuno : st);
        if (st == Strumento.evidenziatore && !coloriEvidenziatore.contains(s.colore)) c.colore(coloriEvidenziatore.first);
        if (st == Strumento.penna && !coloriPenna.contains(s.colore)) c.colore(coloriPenna.first);
      },
      icon: Icon(icona),
    );
    final colori = s.strumento == Strumento.evidenziatore ? coloriEvidenziatore : coloriPenna;
    return Row(
      children: [
        pulsante(Strumento.penna, Icons.edit_outlined, 'Penna'),
        pulsante(Strumento.evidenziatore, Icons.highlight_outlined, 'Evidenziatore'),
        pulsante(Strumento.gomma, Icons.auto_fix_normal_outlined, 'Gomma'),
        if (s.strumento == Strumento.penna || s.strumento == Strumento.evidenziatore)
          for (final col in colori)
            // Pallino da 26 dentro un'area da 44: abbastanza grande per il dito, con nome per VoiceOver.
            Tooltip(
              message: 'Colore ${nomiColori[col] ?? ''}'.trim(),
              excludeFromSemantics: true,
              child: Semantics(
                label: 'Colore ${nomiColori[col] ?? ''}'.trim(),
                button: true,
                selected: s.colore == col,
                child: InkResponse(
                  onTap: () => c.colore(col),
                  radius: 22,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Color(col),
                          shape: BoxShape.circle,
                          border: Border.all(color: s.colore == col ? AuriColori.inchiostro : Colors.transparent, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        const Spacer(),
        if (s.strumento != Strumento.nessuno)
          Row(
            children: [
              Text('Disegna col dito', style: testo(13)),
              Switch(value: s.conDito, onChanged: c.conDito),
            ],
          ),
      ],
    );
  }
}
