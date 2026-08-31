import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyService {
  KeyService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _masterKeyName = 'ctd_master_key_v1';
  final FlutterSecureStorage _storage;

  Future<SecretKey> getOrCreateMasterKey() async {
    final existing = await _storage.read(key: _masterKeyName);
    if (existing != null) return SecretKey(base64Decode(existing));
    final key = await AesGcm.with256bits().newSecretKey();
    await setMasterKey(key);
    return key;
  }

  Future<void> setMasterKey(SecretKey key) async {
    final bytes = await key.extractBytes();
    await _storage.write(key: _masterKeyName, value: base64Encode(bytes));
  }

  Future<List<int>> exportMasterKey() async =>
      (await getOrCreateMasterKey()).extractBytes();
}
