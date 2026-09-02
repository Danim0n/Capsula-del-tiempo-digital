import 'dart:convert';
import 'dart:io';

import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/core/encryption/encryption_service.dart';
import 'package:capsula_del_tiempo_digital/core/storage/custom_cover_id.dart';
import 'package:capsula_del_tiempo_digital/core/transfer/capsule_transfer_service.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Each executor is a distinct in-memory device, intentionally alive together.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);
  final encryption = EncryptionService();
  late Directory root;
  late Directory vault;
  late AppDatabase senderDb, receiverDb;
  late CapsuleRepository sender, receiver;
  late SecretKey senderKey, receiverKey;
  late CapsuleTransferService sendService, receiveService;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ctd_transfer_test_');
    vault = await Directory('${root.path}/recipient_vault').create();
    senderDb = AppDatabase(NativeDatabase.memory());
    receiverDb = AppDatabase(NativeDatabase.memory());
    sender = CapsuleRepository(senderDb);
    receiver = CapsuleRepository(receiverDb);
    senderKey = await AesGcm.with256bits().newSecretKey();
    receiverKey = await AesGcm.with256bits().newSecretKey();
    sendService = CapsuleTransferService(
      repository: sender,
      encryption: encryption,
    );
    receiveService = CapsuleTransferService(
      repository: receiver,
      encryption: encryption,
    );
  });

  tearDown(() async {
    await senderDb.close();
    await receiverDb.close();
    await root.delete(recursive: true);
  });

  Future<Capsule> makeCapsule({
    bool media = false,
    bool customCover = false,
    CapsuleKind kind = CapsuleKind.standard,
  }) async {
    final category = await sender.findOrCreateCategory('Nuestro viaje');
    final draft = await sender.createDraft(
      kind: kind,
      title: 'Nuestra cápsula privada',
      categoryId: category.id,
      unlockAt: DateTime.utc(2035, 7, 9, 18, 35),
    );
    await sender.updateDraft(draft.copyWith(unlockIncludesTime: true));
    await sender.addItem(
      CapsuleItem(
        id: 'text',
        capsuleId: draft.id,
        type: CapsuleItemType.text,
        encryptedText: await encryption.encryptText(
          'Un mensaje secreto 🌻',
          senderKey,
        ),
        textTitle: await encryption.encryptText('Carta', senderKey),
        createdAt: DateTime.now(),
        orderIndex: 0,
      ),
    );
    if (media) {
      for (final type in [
        CapsuleItemType.image,
        CapsuleItemType.video,
        CapsuleItemType.audio,
      ]) {
        final clear = File('${root.path}/${type.name}.bin');
        await clear.writeAsBytes(List.generate(1301, (index) => index % 251));
        final cipher = File('${root.path}/${type.name}.ctdv');
        await encryption.encryptFile(clear, cipher, senderKey);
        await sender.addItem(
          CapsuleItem(
            id: type.name,
            capsuleId: draft.id,
            type: type,
            encryptedPath: cipher.path,
            byteSize: 1301,
            createdAt: DateTime.now(),
            orderIndex: type.index + 1,
          ),
        );
      }
    }
    if (customCover) {
      final clear = File('${root.path}/cover.jpg');
      await clear.writeAsString('test cover bytes');
      final encrypted = File('${root.path}/cover.ctdv');
      await encryption.encryptFile(clear, encrypted, senderKey);
      await sender.updateDraft(
        (await sender.getCapsule(
          draft.id,
        )).copyWith(coverId: customCoverId(encrypted.path)),
      );
    }
    await sender.seal(draft.id, DateTime.now());
    return sender.getCapsule(draft.id);
  }

  Future<PreparedCapsuleTransfer> prepare(Capsule capsule) => sendService
      .prepare(capsuleId: capsule.id, localKey: senderKey, temporaryRoot: root);
  Future<Capsule> receive(
    PreparedCapsuleTransfer prepared, {
    void Function()? check,
  }) => receiveService.receive(
    package: prepared.file,
    offer: prepared.offer,
    localKey: receiverKey,
    vault: vault,
    temporaryRoot: root,
    checkCancelled: check,
  );

  test(
    'single capsule roundtrip rekeys every item and custom cover without replacing the library',
    () async {
      final existing = await receiver.createDraft(title: 'Keep this');
      final source = await makeCapsule(
        media: true,
        customCover: true,
        kind: CapsuleKind.personalized,
      );
      final prepared = await prepare(source);
      final result = await receive(prepared);
      expect(result.id, source.id);
      expect(result.kind, CapsuleKind.personalized);
      expect(result.unlockAt.isAtSameMomentAs(source.unlockAt), isTrue);
      expect(result.unlockIncludesTime, isTrue);
      expect(result.persistedStatus, CapsuleStatus.sealed);
      expect(result.statusAt(DateTime.now()), CapsuleStatus.sealed);
      expect(result.openedAt, isNull);
      expect((await receiver.getCapsule(existing.id)).title, 'Keep this');
      expect(
        (await receiver.getCategories())
            .firstWhere((c) => c.id == result.categoryId)
            .name,
        'Nuestro viaje',
      );
      final items = await receiver.getItems(result.id);
      expect(items, hasLength(4));
      final text = items.firstWhere((i) => i.type == CapsuleItemType.text);
      expect(
        await encryption.decryptText(text.textTitle!, receiverKey),
        'Carta',
      );
      expect(items.map((item) => item.type), [
        CapsuleItemType.text,
        CapsuleItemType.image,
        CapsuleItemType.video,
        CapsuleItemType.audio,
      ]);
      expect(
        await encryption.decryptText(text.encryptedText!, receiverKey),
        'Un mensaje secreto 🌻',
      );
      await expectLater(
        encryption.decryptText(text.encryptedText!, senderKey),
        throwsA(anything),
      );
      for (final item in items.where((i) => i.type != CapsuleItemType.text)) {
        expect(item.encryptedPath, startsWith(vault.path));
        await encryption.verifyFile(File(item.encryptedPath!), receiverKey);
        await expectLater(
          encryption.verifyFile(File(item.encryptedPath!), senderKey),
          throwsA(anything),
        );
        final clear = File('${root.path}/received_${item.type.name}');
        await encryption.decryptFile(
          File(item.encryptedPath!),
          clear,
          receiverKey,
        );
        expect(
          await clear.readAsBytes(),
          List.generate(1301, (index) => index % 251),
        );
      }
      final cover = File(customCoverPath(result.coverId)!);
      expect(cover.path, startsWith(vault.path));
      final restoredCover = File('${root.path}/restored_cover');
      await encryption.decryptFile(cover, restoredCover, receiverKey);
      expect(await restoredCover.readAsString(), 'test cover bytes');
      final raw = latin1.decode(await prepared.file.readAsBytes());
      expect(raw, isNot(contains(source.title)));
      expect(
        raw,
        isNot(contains(base64Encode(await senderKey.extractBytes()))),
      );
      expect(
        prepared.offer.key,
        isNot(base64Encode(await senderKey.extractBytes())),
      );
      await prepared.dispose();
      expect(await prepared.directory.exists(), isFalse);
    },
  );

  test(
    'duplicate capsule does not overwrite existing content or leave new files',
    () async {
      final prepared = await prepare(await makeCapsule(media: true));
      final original = await receive(prepared);
      final before = await vault.list().map((f) => f.path).toList();
      await expectLater(
        receive(prepared),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'code',
            'CAPSULE_ALREADY_EXISTS',
          ),
        ),
      );
      expect((await receiver.getCapsule(original.id)).itemCount, 4);
      expect(
        await vault.list().map((f) => f.path).toList(),
        unorderedEquals(before),
      );
      await prepared.dispose();
    },
  );

  test(
    'tampered and truncated packages are rejected before database writes',
    () async {
      final source = await makeCapsule();
      final prepared = await prepare(source);
      final bytes = await prepared.file.readAsBytes();
      bytes.last ^= 1;
      await prepared.file.writeAsBytes(bytes);
      await expectLater(receive(prepared), throwsA(isA<FormatException>()));
      await prepared.file.writeAsBytes(bytes.sublist(0, bytes.length - 1));
      await expectLater(receive(prepared), throwsA(isA<FormatException>()));
      expect(await receiver.containsCapsule(source.id), isFalse);
      expect(await vault.list().toList(), isEmpty);
      await prepared.dispose();
    },
  );

  test(
    'cancellation during import removes rekeyed files and leaves no capsule',
    () async {
      final source = await makeCapsule(media: true, customCover: true);
      final prepared = await prepare(source);
      await expectLater(
        receive(
          prepared,
          check: () {
            if (vault.listSync().isNotEmpty) throw TransferCancelled();
          },
        ),
        throwsA(isA<TransferCancelled>()),
      );
      expect(await receiver.containsCapsule(source.id), isFalse);
      expect(await vault.list().toList(), isEmpty);
      expect(
        root.listSync().whereType<Directory>().where(
          (d) => d.path.contains('ctd_receive_'),
        ),
        isEmpty,
      );
      await prepared.dispose();
    },
  );

  test('cancellation while preparing removes temporary ciphertext', () async {
    final source = await makeCapsule(media: true);
    await expectLater(
      sendService.prepare(
        capsuleId: source.id,
        localKey: senderKey,
        temporaryRoot: root,
        checkCancelled: () => throw TransferCancelled(),
      ),
      throwsA(isA<TransferCancelled>()),
    );
    expect(
      root.listSync().whereType<Directory>().where(
        (d) => d.path.contains('ctd_send_'),
      ),
      isEmpty,
    );
  });

  test(
    'opened capsule arrives ready to open, not marked as already opened',
    () async {
      final source = await makeCapsule();
      await sender.markOpened(source.id, DateTime.utc(2040));
      final prepared = await prepare(await sender.getCapsule(source.id));
      final result = await receive(prepared);
      expect(result.openedAt, isNull);
      expect(result.statusAt(DateTime.utc(2040)), CapsuleStatus.readyToOpen);
      await prepared.dispose();
    },
  );

  test('drafts cannot be transferred', () async {
    final draft = await sender.createDraft(title: 'Not sealed');
    await expectLater(prepare(draft), throwsA(isA<StateError>()));
  });

  test('offer rejects invalid keys and excessive sizes', () {
    final data = CapsuleTransferOffer(
      transferId: 'id',
      title: 'title',
      size: 100,
      digest: 'a' * 64,
      key: base64Encode(List.filled(32, 1)),
      unlockAt: DateTime.utc(2030),
    ).toJson();
    expect(CapsuleTransferOffer.fromJson(data).size, 100);
    expect(
      () => CapsuleTransferOffer.fromJson({...data, 'key': 'bad'}),
      throwsFormatException,
    );
    expect(
      () => CapsuleTransferOffer.fromJson({
        ...data,
        'size': maxNearbyPackageBytes + 1,
      }),
      throwsFormatException,
    );
    expect(
      () => CapsuleTransferOffer.fromJson({...data, 'version': 2}),
      throwsFormatException,
    );
  });
}
