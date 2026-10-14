import 'dart:io';

import 'package:local_auth/local_auth.dart';

class TouchIdService {
  final _auth = LocalAuthentication();

  Future<bool> disponibile() async {
    if (!Platform.isIOS) return false;
    try {
      return await _auth.isDeviceSupported() && (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Consente il ripiego con il codice dell'iPad (non solo biometria).
  Future<bool> autentica() async {
    try {
      return await _auth.authenticate(localizedReason: 'Sblocca auri');
    } catch (_) {
      return false;
    }
  }
}
