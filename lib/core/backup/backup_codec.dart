import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class BackupCodec {
  BackupCodec({this.iterations = 210000});

  static final _magic = utf8.encode('CTDP1');
  final int iterations;
  final Random _random = Random.secure();
  final AesGcm _cipher = AesGcm.with256bits();

  Future<List<int>> encrypt(List<int> clear, String password) async {
    if (password.length < 8) {
      throw ArgumentError('Password must have at least 8 characters.');
    }
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final key = await _derive(password, salt, iterations);
    final box = await _cipher.encrypt(clear, secretKey: key, nonce: nonce);
    return [
      ..._magic,
      ..._u32(iterations),
      ...salt,
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ];
  }

  Future<List<int>> decrypt(List<int> encoded, String password) async {
    if (encoded.length < _magic.length + 4 + 16 + 12 + 16) {
      throw const FormatException('Invalid backup data.');
    }
    if (!_constantEquals(encoded.sublist(0, _magic.length), _magic)) {
      throw const FormatException('Invalid backup data.');
    }
    var offset = _magic.length;
    final rounds = ByteData.sublistView(
      Uint8List.fromList(encoded.sublist(offset, offset + 4)),
    ).getUint32(0, Endian.big);
    offset += 4;
    if (rounds < 100000 || rounds > 1000000) {
      throw const FormatException('Invalid KDF settings.');
    }
    final salt = encoded.sublist(offset, offset + 16);
    offset += 16;
    final nonce = encoded.sublist(offset, offset + 12);
    offset += 12;
    final cipher = encoded.sublist(offset, encoded.length - 16);
    final mac = Mac(encoded.sublist(encoded.length - 16));
    final key = await _derive(password, salt, rounds);
    return _cipher.decrypt(
      SecretBox(cipher, nonce: nonce, mac: mac),
      secretKey: key,
    );
  }

  Future<SecretKey> _derive(String password, List<int> salt, int rounds) =>
      Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: rounds,
        bits: 256,
      ).deriveKeyFromPassword(password: password, nonce: salt);

  List<int> _randomBytes(int length) =>
      List.generate(length, (_) => _random.nextInt(256));
}

List<int> _u32(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();
bool _constantEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
