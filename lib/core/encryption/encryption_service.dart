import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class EncryptionService {
  EncryptionService({AesGcm? algorithm})
    : _algorithm = algorithm ?? AesGcm.with256bits();

  static const chunkSize = 1024 * 1024;
  static final _magic = utf8.encode('CTDE1');
  final AesGcm _algorithm;
  final Random _random = Random.secure();

  Future<String> encryptText(String clearText, SecretKey key) async {
    final nonce = _randomBytes(12);
    final box = await _algorithm.encrypt(
      utf8.encode(clearText),
      secretKey: key,
      nonce: nonce,
    );
    return base64Encode([...nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  Future<String> decryptText(String encrypted, SecretKey key) async {
    final bytes = base64Decode(encrypted);
    if (bytes.length < 28) {
      throw const FormatException('Invalid encrypted text.');
    }
    final nonce = bytes.sublist(0, 12);
    final cipher = bytes.sublist(12, bytes.length - 16);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final clear = await _algorithm.decrypt(
      SecretBox(cipher, nonce: nonce, mac: mac),
      secretKey: key,
    );
    return utf8.decode(clear);
  }

  Future<void> encryptFile(
    File input,
    File output,
    SecretKey key, {
    void Function(double progress)? onProgress,
  }) async {
    await output.parent.create(recursive: true);
    final source = await input.open();
    final sink = await output.open(mode: FileMode.write);
    final total = await input.length();
    var processed = 0;
    var index = 0;
    final noncePrefix = _randomBytes(8);
    try {
      await sink.writeFrom(_magic);
      await sink.writeFrom(noncePrefix);
      while (true) {
        final clear = await source.read(chunkSize);
        if (clear.isEmpty) break;
        final nonce = [...noncePrefix, ..._uint32(index++)];
        final box = await _algorithm.encrypt(
          clear,
          secretKey: key,
          nonce: nonce,
        );
        await sink.writeFrom(_uint32(box.cipherText.length));
        await sink.writeFrom(box.cipherText);
        await sink.writeFrom(box.mac.bytes);
        processed += clear.length;
        onProgress?.call(total == 0 ? 1 : processed / total);
      }
      await sink.flush();
    } catch (_) {
      if (await output.exists()) await output.delete();
      rethrow;
    } finally {
      await source.close();
      await sink.close();
    }
  }

  Future<void> decryptFile(File input, File output, SecretKey key) async {
    await output.parent.create(recursive: true);
    final sink = await output.open(mode: FileMode.write);
    try {
      await _decryptChunks(input, key, (bytes) => sink.writeFrom(bytes));
      await sink.flush();
    } catch (_) {
      await sink.close();
      if (await output.exists()) await output.delete();
      rethrow;
    } finally {
      await sink.close();
    }
  }

  Future<void> verifyFile(File input, SecretKey key) =>
      _decryptChunks(input, key, (_) async {});

  Future<void> _decryptChunks(
    File input,
    SecretKey key,
    Future<void> Function(List<int>) consume,
  ) async {
    final source = await input.open();
    try {
      final magic = await source.read(_magic.length);
      if (!_same(magic, _magic)) {
        throw const FormatException('Invalid encrypted file.');
      }
      final prefix = await source.read(8);
      if (prefix.length != 8) {
        throw const FormatException('Truncated encrypted file.');
      }
      var index = 0;
      while (true) {
        final sizeBytes = await source.read(4);
        if (sizeBytes.isEmpty) break;
        if (sizeBytes.length != 4) {
          throw const FormatException('Truncated encrypted file.');
        }
        final size = _readUint32(sizeBytes);
        if (size > chunkSize) {
          throw const FormatException('Invalid encrypted chunk.');
        }
        final cipher = await source.read(size);
        final mac = await source.read(16);
        if (cipher.length != size || mac.length != 16) {
          throw const FormatException('Truncated encrypted file.');
        }
        final nonce = [...prefix, ..._uint32(index++)];
        final clear = await _algorithm.decrypt(
          SecretBox(cipher, nonce: nonce, mac: Mac(mac)),
          secretKey: key,
        );
        await consume(clear);
      }
    } finally {
      await source.close();
    }
  }

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));
}

List<int> _uint32(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();
int _readUint32(List<int> bytes) =>
    ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0, Endian.big);
bool _same(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a[i] ^ b[i];
  }
  return difference == 0;
}
