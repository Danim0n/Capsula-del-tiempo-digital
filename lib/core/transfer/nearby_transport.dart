import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-only foreground transport. Unsupported platforms never invoke it.
class NearbyTransport {
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static const _methods = MethodChannel('ctd/nearby');
  static const _events = EventChannel('ctd/nearby/events');

  Stream<Map<String, dynamic>> get events => supported
      ? _events.receiveBroadcastStream().map(
          (value) => Map<String, dynamic>.from(value as Map),
        )
      : const Stream.empty();

  Future<void> _call(String method, [Map<String, dynamic>? arguments]) async {
    if (!supported) throw UnsupportedError('Nearby requires Android.');
    await _methods.invokeMethod<void>(method, arguments);
  }

  Future<void> start({required bool receive, required String name}) =>
      _call('start', {'mode': receive ? 'receive' : 'send', 'name': name});
  Future<void> request(String id) => _call('request', {'id': id});
  Future<void> accept() => _call('accept');
  Future<void> reject() => _call('reject');
  Future<void> message(Map<String, dynamic> value) =>
      _call('message', {'message': jsonEncode(value)});
  Future<void> receiveStream(int size) =>
      _call('receiveStream', {'size': size});
  Future<void> sendStream(String path) => _call('sendStream', {'path': path});
  Future<void> release(String path) => _call('release', {'path': path});
  Future<void> stop() async {
    if (supported) await _call('stop');
  }
}
