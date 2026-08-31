import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum AuthenticationResult { success, cancelled, unavailable, failed }

class AuthenticationService {
  AuthenticationService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  Future<AuthenticationResult> authenticate(String reason) async {
    // local_auth has no web implementation. Browser builds cannot display the
    // operating system authentication prompt, so access continues without it.
    if (kIsWeb) return AuthenticationResult.success;

    try {
      if (!await _authentication.isDeviceSupported()) {
        return AuthenticationResult.unavailable;
      }
      final success = await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return success
          ? AuthenticationResult.success
          : AuthenticationResult.cancelled;
    } on MissingPluginException {
      return AuthenticationResult.unavailable;
    } on PlatformException {
      return AuthenticationResult.failed;
    }
  }
}
