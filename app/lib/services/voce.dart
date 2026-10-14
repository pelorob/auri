import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Sintesi vocale (sostituibile nei test).
abstract class Voce {
  Future<void> parla(String testo);
  Future<void> ferma();
}

/// Riconoscimento vocale (sostituibile nei test).
abstract class Ascolto {
  /// false se il permesso è negato o il riconoscimento non è disponibile.
  Future<bool> prepara();
  Future<void> inizia(void Function(String testo) aggiornamento);
  Future<String> fine();

  /// Smette di ascoltare senza aspettare il risultato (es. uscendo dalla pagina).
  Future<void> annulla();
}

class VoceTts implements Voce {
  final _tts = FlutterTts();
  bool _pronta = false;

  Future<void> _prepara() async {
    if (_pronta) return;
    await _tts.setLanguage('it-IT');
    await _tts.setSpeechRate(0.48);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSharedInstance(true);
    _pronta = true;
  }

  /// Il riconoscimento vocale lascia la sessione audio in registrazione (voce bassa, nell'auricolare):
  /// prima di ogni frase la si riporta su altoparlante o cuffie.
  Future<void> _sessioneAudio() => _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
    IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
    IosTextToSpeechAudioCategoryOptions.allowBluetooth,
    IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
  ], IosTextToSpeechAudioMode.spokenAudio);

  @override
  Future<void> parla(String testo) async {
    try {
      await _prepara();
      await _sessioneAudio();
      await _tts.speak(testo);
    } catch (_) {
      // Su piattaforme senza sintesi vocale (es. test sul PC) si prosegue in silenzio.
    }
  }

  @override
  Future<void> ferma() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

class AscoltoStt implements Ascolto {
  final _stt = SpeechToText();
  String _testo = '';

  @override
  Future<bool> prepara() async {
    try {
      return await _stt.initialize();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> inizia(void Function(String testo) aggiornamento) async {
    _testo = '';
    await _stt.listen(
      onResult: (SpeechRecognitionResult r) {
        _testo = r.recognizedWords;
        aggiornamento(_testo);
      },
      listenOptions: SpeechListenOptions(
        localeId: 'it_IT',
        onDevice: true,
        partialResults: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Future<String> fine() async {
    await _stt.stop();
    await Future<void>.delayed(const Duration(milliseconds: 400)); // ultimo risultato
    return _testo;
  }

  @override
  Future<void> annulla() async {
    try {
      await _stt.cancel();
    } catch (_) {}
  }
}
