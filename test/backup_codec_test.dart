import 'package:capsula_del_tiempo_digital/core/backup/backup_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final codec = BackupCodec(iterations: 100000);
  const password = 'correct horse battery staple';
  final payload = List<int>.generate(4096, (index) => index % 256);

  test('creates and restores an encrypted backup payload', () async {
    final backup = await codec.encrypt(payload, password);
    expect(backup, isNot(payload));
    expect(await codec.decrypt(backup, password), payload);
  });

  test('wrong backup password fails authentication', () async {
    final backup = await codec.encrypt(payload, password);
    await expectLater(
      codec.decrypt(backup, 'wrong password'),
      throwsA(anything),
    );
  });

  test('corrupted backup fails authentication', () async {
    final backup = await codec.encrypt(payload, password);
    backup[backup.length ~/ 2] ^= 0xff;
    await expectLater(codec.decrypt(backup, password), throwsA(anything));
  });
}
