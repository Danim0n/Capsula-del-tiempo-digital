import 'dart:io';

import 'package:capsula_del_tiempo_digital/core/encryption/encryption_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late SecretKey key;
  final service = EncryptionService();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ctd_crypto_test_');
    key = await AesGcm.with256bits().newSecretKey();
  });

  tearDown(() => directory.delete(recursive: true));

  test('text encrypt then decrypt returns the original', () async {
    const original = 'Un recuerdo privado con acentos: mañana.';
    final encrypted = await service.encryptText(original, key);
    expect(encrypted, isNot(contains(original)));
    expect(await service.decryptText(encrypted, key), original);
  });

  test('file encryption streams multiple chunks and restores bytes', () async {
    final original = File('${directory.path}/original.bin');
    final encrypted = File('${directory.path}/encrypted.ctdv');
    final restored = File('${directory.path}/restored.bin');
    final bytes = List<int>.generate(
      EncryptionService.chunkSize * 2 + 137,
      (index) => index % 251,
    );
    await original.writeAsBytes(bytes);
    await service.encryptFile(original, encrypted, key);
    await service.decryptFile(encrypted, restored, key);
    expect(await restored.readAsBytes(), bytes);
  });

  test('tampered encrypted file fails integrity verification', () async {
    final original = File('${directory.path}/original.bin')
      ..writeAsStringSync('private memory');
    final encrypted = File('${directory.path}/encrypted.ctdv');
    await service.encryptFile(original, encrypted, key);
    final bytes = await encrypted.readAsBytes();
    bytes[20] ^= 0xff;
    await encrypted.writeAsBytes(bytes);
    await expectLater(service.verifyFile(encrypted, key), throwsA(anything));
  });

  test(
    'rekey streams multiple chunks and only the new key can decrypt',
    () async {
      final otherKey = await AesGcm.with256bits().newSecretKey();
      final original = File('${directory.path}/original');
      final bytes = List.generate(
        EncryptionService.chunkSize + 97,
        (i) => i % 251,
      );
      await original.writeAsBytes(bytes);
      final encrypted = File('${directory.path}/encrypted');
      final rekeyed = File('${directory.path}/rekeyed');
      final restored = File('${directory.path}/restored');
      await service.encryptFile(original, encrypted, key);
      await service.reencryptFile(encrypted, rekeyed, key, otherKey);
      await service.decryptFile(rekeyed, restored, otherKey);
      expect(await restored.readAsBytes(), bytes);
      await expectLater(service.verifyFile(rekeyed, key), throwsA(anything));
      final failed = File('${directory.path}/failed');
      await expectLater(
        service.reencryptFile(encrypted, failed, otherKey, key),
        throwsA(anything),
      );
      expect(await failed.exists(), isFalse);
    },
  );
}
