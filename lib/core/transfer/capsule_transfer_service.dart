import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/capsules/data/capsule_repository.dart';
import '../../features/capsules/domain/capsule_models.dart';
import '../encryption/encryption_service.dart';
import '../storage/custom_cover_id.dart';

const maxNearbyPackageBytes = 1024 * 1024 * 1024;
const _maxManifestBytes = 8 * 1024 * 1024;

class TransferCancelled implements Exception {}

class CapsuleTransferOffer {
  const CapsuleTransferOffer({
    required this.transferId,
    required this.title,
    required this.size,
    required this.digest,
    required this.key,
    required this.unlockAt,
  });
  final String transferId;
  final String title;
  final int size;
  final String digest;
  final String key;
  final DateTime unlockAt;

  Map<String, dynamic> toJson() => {
    'type': 'offer',
    'version': 1,
    'transferId': transferId,
    'title': title,
    'size': size,
    'digest': digest,
    'key': key,
    'unlockAt': unlockAt.toUtc().toIso8601String(),
  };

  factory CapsuleTransferOffer.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 || json['type'] != 'offer') {
      throw const FormatException('Unsupported transfer.');
    }
    final size = json['size'];
    final key = _string(json['key'], 100);
    final digest = _string(json['digest'], 64);
    if (size is! int ||
        size < 16 ||
        size > maxNearbyPackageBytes ||
        base64Decode(key).length != 32 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      throw const FormatException('Invalid transfer offer.');
    }
    return CapsuleTransferOffer(
      transferId: _string(json['transferId'], 100),
      title: _string(json['title'], 300),
      size: size,
      digest: digest,
      key: key,
      unlockAt: DateTime.parse(_string(json['unlockAt'], 40)),
    );
  }
}

class PreparedCapsuleTransfer {
  const PreparedCapsuleTransfer(this.directory, this.file, this.offer);
  final Directory directory;
  final File file;
  final CapsuleTransferOffer offer;

  Future<void> dispose() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

/// A single-capsule format, separate from full-library .ctdbackup restores.
/// Only a fresh transfer key is shared over the authenticated Nearby channel.
class CapsuleTransferService {
  CapsuleTransferService({required this.repository, required this.encryption});
  final CapsuleRepository repository;
  final EncryptionService encryption;
  static final _magic = utf8.encode('CTDS01');

  Future<PreparedCapsuleTransfer> prepare({
    required String capsuleId,
    required SecretKey localKey,
    required Directory temporaryRoot,
    void Function()? checkCancelled,
  }) async {
    final capsule = await repository.getCapsule(capsuleId);
    if (capsule.persistedStatus == CapsuleStatus.draft ||
        capsule.persistedStatus == CapsuleStatus.trashed ||
        capsule.sealedAt == null) {
      throw StateError('ONLY_SEALED_CAPSULES');
    }
    final items = await repository.getItems(capsuleId);
    if (items.isEmpty || items.length > 1000) {
      throw const FormatException('Invalid number of items.');
    }
    final directory = await temporaryRoot.createTemp('ctd_send_');
    try {
      final transferKey = await AesGcm.with256bits().newSecretKey();
      final files = <File>[];
      var total = 0;
      Future<int> addFile(String path) async {
        checkCancelled?.call();
        final source = File(path);
        total += await source.length();
        if (total > maxNearbyPackageBytes) {
          throw StateError('TRANSFER_TOO_LARGE');
        }
        final file = File(p.join(directory.path, '${files.length}.ctdv'));
        await encryption.reencryptFile(
          source,
          file,
          localKey,
          transferKey,
          checkCancelled: checkCancelled,
        );
        files.add(file);
        return files.length - 1;
      }

      final customPath = customCoverPath(capsule.coverId);
      final customFile = customPath == null ? null : await addFile(customPath);
      final itemData = <Map<String, dynamic>>[];
      for (final item in items) {
        checkCancelled?.call();
        itemData.add({
          'type': item.type.name,
          'file': item.encryptedPath == null
              ? null
              : await addFile(item.encryptedPath!),
          'text': item.encryptedText == null
              ? null
              : await encryption.encryptText(
                  await encryption.decryptText(item.encryptedText!, localKey),
                  transferKey,
                ),
          // Text titles in the local database are encrypted too.
          'textTitleTransfer': item.textTitle == null
              ? null
              : await encryption.encryptText(
                  await encryption.decryptText(item.textTitle!, localKey),
                  transferKey,
                ),
          'mimeType': item.mimeType,
          'byteSize': item.byteSize,
          'createdAt': item.createdAt.toUtc().toIso8601String(),
        });
      }
      final categories = await repository.getCategories();
      final category = categories.firstWhere((c) => c.id == capsule.categoryId);
      final manifest = {
        'version': 1,
        'id': capsule.id,
        'kind': capsule.kind.name,
        'title': capsule.title,
        'description': capsule.description,
        'category': category.name,
        'coverId': customPath == null ? capsule.coverId : 'cover_01',
        'customCoverFile': customFile,
        'createdAt': capsule.createdAt.toUtc().toIso8601String(),
        'sealedAt': capsule.sealedAt!.toUtc().toIso8601String(),
        'unlockAt': capsule.unlockAt.toUtc().toIso8601String(),
        'unlockIncludesTime': capsule.unlockIncludesTime,
        'items': itemData,
        'fileSizes': [for (final file in files) await file.length()],
      };
      final header = utf8.encode(
        await encryption.encryptText(jsonEncode(manifest), transferKey),
      );
      if (header.length > _maxManifestBytes) {
        throw StateError('TRANSFER_TOO_LARGE');
      }
      final package = File(p.join(directory.path, 'capsule.ctdshare'));
      final sink = await package.open(mode: FileMode.write);
      try {
        await sink.writeFrom(_magic);
        await sink.writeFrom(_u64(header.length));
        await sink.writeFrom(header);
        for (final file in files) {
          await _copy(file, sink, checkCancelled);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      checkCancelled?.call();
      final size = await package.length();
      if (size > maxNearbyPackageBytes) throw StateError('TRANSFER_TOO_LARGE');
      final offer = CapsuleTransferOffer(
        transferId: const Uuid().v4(),
        title: capsule.title,
        size: size,
        digest: await _digest(package, checkCancelled),
        key: base64Encode(await transferKey.extractBytes()),
        unlockAt: capsule.unlockAt,
      );
      // Validate our own offer before sending anything to the other device.
      CapsuleTransferOffer.fromJson(offer.toJson());
      return PreparedCapsuleTransfer(directory, package, offer);
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  }

  Future<Capsule> receive({
    required File package,
    required CapsuleTransferOffer offer,
    required SecretKey localKey,
    required Directory vault,
    required Directory temporaryRoot,
    void Function()? checkCancelled,
  }) async {
    CapsuleTransferOffer.fromJson(offer.toJson());
    checkCancelled?.call();
    if (await package.length() != offer.size ||
        await _digest(package, checkCancelled) != offer.digest) {
      throw const FormatException('Incomplete or damaged transfer.');
    }
    checkCancelled?.call();
    final transferKey = SecretKey(base64Decode(offer.key));
    final staging = await temporaryRoot.createTemp('ctd_receive_');
    final outputs = <File>[];
    var committed = false;
    try {
      final source = await package.open();
      late Map<String, dynamic> data;
      final received = <File>[];
      try {
        if (utf8.decode(await _read(source, _magic.length)) != 'CTDS01') {
          throw const FormatException('Invalid capsule package.');
        }
        final length = ByteData.sublistView(
          await _read(source, 8),
        ).getUint64(0);
        if (length < 28 || length > _maxManifestBytes) {
          throw const FormatException('Invalid manifest size.');
        }
        data =
            jsonDecode(
                  await encryption.decryptText(
                    utf8.decode(await _read(source, length)),
                    transferKey,
                  ),
                )
                as Map<String, dynamic>;
        if (data['version'] != 1) {
          throw const FormatException('Invalid version.');
        }
        final sizes = data['fileSizes'];
        if (sizes is! List || sizes.length > 1001) {
          throw const FormatException('Invalid file list.');
        }
        var expected = _magic.length + 8 + length;
        for (final size in sizes) {
          if (size is! int || size < 13 || size > maxNearbyPackageBytes) {
            throw const FormatException('Invalid file size.');
          }
          expected += size;
        }
        if (expected != offer.size) {
          throw const FormatException('Invalid package size.');
        }
        for (final size in sizes.cast<int>()) {
          final file = File(p.join(staging.path, '${received.length}.ctdv'));
          final sink = await file.open(mode: FileMode.write);
          try {
            var remaining = size;
            while (remaining > 0) {
              checkCancelled?.call();
              final bytes = await _read(
                source,
                remaining.clamp(1, 1024 * 1024),
              );
              await sink.writeFrom(bytes);
              remaining -= bytes.length;
            }
          } finally {
            await sink.close();
          }
          received.add(file);
        }
        if (await source.position() != await source.length()) {
          throw const FormatException('Unexpected trailing data.');
        }
      } finally {
        await source.close();
      }

      final id = _string(data['id'], 100);
      final title = _string(data['title'], 300);
      final unlockAt = DateTime.parse(_string(data['unlockAt'], 40)).toUtc();
      if (title != offer.title || !unlockAt.isAtSameMomentAs(offer.unlockAt)) {
        throw const FormatException('Offer does not match the capsule.');
      }
      if (await repository.containsCapsule(id)) {
        throw StateError('CAPSULE_ALREADY_EXISTS');
      }
      final usedFiles = <int>{};
      Future<String> saveFile(dynamic index) async {
        if (index is! int ||
            index < 0 ||
            index >= received.length ||
            !usedFiles.add(index)) {
          throw const FormatException('Invalid file reference.');
        }
        final output = File(p.join(vault.path, '${const Uuid().v4()}.ctdv'));
        outputs.add(output);
        await encryption.reencryptFile(
          received[index],
          output,
          transferKey,
          localKey,
          checkCancelled: checkCancelled,
        );
        return output.path;
      }

      final builtInCover = _string(data['coverId'], 40);
      if (!RegExp(r'^cover_\d{2}$').hasMatch(builtInCover)) {
        throw const FormatException('Invalid cover.');
      }
      final coverId = data['customCoverFile'] == null
          ? builtInCover
          : customCoverId(await saveFile(data['customCoverFile']));
      final rawItems = data['items'];
      if (rawItems is! List || rawItems.isEmpty || rawItems.length > 1000) {
        throw const FormatException('Invalid item list.');
      }
      final items = <CapsuleItem>[];
      for (final raw in rawItems) {
        checkCancelled?.call();
        final item = raw as Map<String, dynamic>;
        final type = CapsuleItemType.values.byName(_string(item['type'], 12));
        final isText = type == CapsuleItemType.text;
        if ((isText && (item['text'] is! String || item['file'] != null)) ||
            (!isText && (item['file'] == null || item['text'] != null))) {
          throw const FormatException('Invalid content type.');
        }
        final byteSize = item['byteSize'];
        if (byteSize is! int ||
            byteSize < 0 ||
            byteSize > maxNearbyPackageBytes) {
          throw const FormatException('Invalid content size.');
        }
        items.add(
          CapsuleItem(
            id: const Uuid().v4(),
            capsuleId: id,
            type: type,
            createdAt: DateTime.parse(_string(item['createdAt'], 40)).toLocal(),
            orderIndex: items.length,
            byteSize: byteSize,
            textTitle: item['textTitleTransfer'] == null
                ? null
                : await encryption.encryptText(
                    await encryption.decryptText(
                      _string(item['textTitleTransfer'], _maxManifestBytes),
                      transferKey,
                    ),
                    localKey,
                  ),
            mimeType: _optionalString(item['mimeType'], 150),
            encryptedPath: isText ? null : await saveFile(item['file']),
            encryptedText: isText
                ? await encryption.encryptText(
                    await encryption.decryptText(
                      item['text'] as String,
                      transferKey,
                    ),
                    localKey,
                  )
                : null,
          ),
        );
      }
      if (usedFiles.length != received.length ||
          data['unlockIncludesTime'] is! bool) {
        throw const FormatException('Invalid capsule contents.');
      }
      final capsule = Capsule(
        id: id,
        kind: CapsuleKind.values.byName(data['kind'] as String? ?? 'standard'),
        title: title,
        description: _optionalString(data['description'], 10000),
        categoryId: '',
        coverId: coverId,
        createdAt: DateTime.parse(_string(data['createdAt'], 40)).toLocal(),
        sealedAt: DateTime.parse(_string(data['sealedAt'], 40)).toLocal(),
        unlockAt: unlockAt.toLocal(),
        unlockIncludesTime: data['unlockIncludesTime'] as bool,
        persistedStatus: CapsuleStatus.sealed,
        itemCount: items.length,
      );
      checkCancelled?.call();
      await repository.importSharedCapsule(
        capsule,
        _string(data['category'], 100),
        items,
        checkCancelled: checkCancelled,
      );
      committed = true;
      return await repository.getCapsule(id);
    } finally {
      if (!committed) {
        for (final file in outputs) {
          if (await file.exists()) await file.delete();
        }
      }
      await staging.delete(recursive: true);
    }
  }
}

String _string(dynamic value, int max) {
  if (value is! String || value.isEmpty || value.length > max) {
    throw const FormatException('Invalid string field.');
  }
  return value;
}

String? _optionalString(dynamic value, int max) =>
    value == null || value == '' ? null : _string(value, max);
List<int> _u64(int value) =>
    (ByteData(8)..setUint64(0, value)).buffer.asUint8List();
Future<Uint8List> _read(RandomAccessFile source, int size) async {
  final data = await source.read(size);
  if (data.length != size) throw const FormatException('Truncated package.');
  return data;
}

Future<void> _copy(
  File source,
  RandomAccessFile sink,
  void Function()? check,
) async {
  await for (final bytes in source.openRead()) {
    check?.call();
    await sink.writeFrom(bytes);
  }
}

Future<String> _digest(File file, void Function()? checkCancelled) async {
  // The synchronous implementation has a bounded-memory incremental sink.
  final sink = Sha256().toSync().newHashSink();
  try {
    await for (final bytes in file.openRead()) {
      checkCancelled?.call();
      sink.add(bytes);
    }
  } finally {
    sink.close();
  }
  return (await sink.hash()).bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}
