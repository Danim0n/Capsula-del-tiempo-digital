import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenSecurityService {
  static const _channel = MethodChannel('ctd/screen_security');

  Future<void> protect() => _invokeIfSupported('protect');
  Future<void> unprotect() => _invokeIfSupported('unprotect');

  Future<void> _invokeIfSupported(String method) async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Screenshot protection is only available on platforms that implement
      // this optional native channel.
    } on PlatformException {
      // A protection failure must not leave the private-content screen stuck.
    }
  }
}
