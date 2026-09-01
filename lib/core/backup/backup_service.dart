import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/capsules/data/capsule_repository.dart';
import '../encryption/encryption_service.dart';
import '../encryption/key_service.dart';
import '../storage/private_storage_service.dart';
import '../storage/custom_cover_id.dart';
import 'backup_codec.dart';

class BackupSummary {
  const BackupSummary({
    required this.capsules,
    required this.items,
    required this.createdAt,
  });
  final int capsules;
  final int items;
  final DateTime createdAt;
}

class BackupService {
  BackupService({
    required this.repository,
    required this.storage,
    required this.keys,
    required this.encryption,
    BackupCodec? codec,
  }) : codec = codec ?? BackupCodec();

  static final _magic = utf8.encode('CTDB01');
  final CapsuleRepository repository;
  final PrivateStorageService storage;
  final KeyService keys;
  final EncryptionService encryption;
  final BackupCodec codec;

  Future<String?> createBackup(String password) async {
    final fileName =
        'capsula_${DateTime.now().toIso8601String().substring(0, 10)}.ctdbackup';
    final destination =
        Platform.isAndroid || Platform.isIOS
            ? p.join((await getTemporaryDirectory()).path, fileName)
            : await FilePicker.saveFile(
              dialogTitle: 'Guardar copia de seguridad',
              fileName: fileName,
              type: FileType.custom,
              allowedExtensions: const ['ctdbackup'],
            );
    if (destination == null) return null;

    final export = await repository.exportData();
    final vault = await storage.vaultDirectory;
    final files = <File>[];
    await for (final entity in vault.list()) {
      if (entity is File && p.extension(entity.path) == '.ctdv') {
        files.add(entity);
      }
    }
    final manifest = <String, dynamic>{
      'format': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'database': export,
      'files': [
        for (final file in files)
          {'name': p.basename(file.path), 'size': await file.length()},
      ],
    };
    final encryptedManifest = await codec.encrypt(
      utf8.encode(jsonEncode(manifest)),
      password,
    );
    final encryptedMasterKey = await codec.encrypt(
      await keys.exportMasterKey(),
      password,
    );
    final output = File(destination);
    final sink = await output.open(mode: FileMode.write);
    try {
      await sink.writeFrom(_magic);
      await _writeBlock(sink, encryptedManifest);
      await _writeBlock(sink, encryptedMasterKey);
      await sink.writeFrom(_u32(files.length));
      for (final file in files) {
        final name = utf8.encode(p.basename(file.path));
        await sink.writeFrom(_u32(name.length));
        await sink.writeFrom(name);
        await sink.writeFrom(_u64(await file.length()));
        final source = await file.open();
        try {
          while (true) {
            final chunk = await source.read(1024 * 1024);
            if (chunk.isEmpty) break;
            await sink.writeFrom(chunk);
          }
        } finally {
          await source.close();
        }
      }
      await sink.flush();
      return destination;
    } catch (_) {
      if (await output.exists()) await output.delete();
      rethrow;
    } finally {
      await sink.close();
    }
  }

  Future<BackupSummary?> inspectBackup(String password) async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Seleccionar copia de seguridad',
      type: FileType.custom,
      allowedExtensions: const ['ctdbackup'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    final parsed = await _readHeader(File(path), password);
    _pendingRestore = _PendingRestore(
      File(path),
      parsed.manifest,
      parsed.masterKey,
    );
    final database = parsed.manifest['database'] as Map<String, dynamic>;
    return BackupSummary(
      capsules: (database['capsules'] as List).length,
      items: (database['items'] as List).length,
      createdAt:
          DateTime.parse(parsed.manifest['createdAt'] as String).toLocal(),
    );
  }

  _PendingRestore? _pendingRestore;

  Future<void> restoreInspectedBackup(String password) async {
    final pending = _pendingRestore;
    if (pending == null) throw StateError('No backup selected.');
    final parsed = await _readHeader(pending.file, password);
    final support = await getApplicationSupportDirectory();
    final staging = Directory(
      p.join(support.path, 'restore_${const Uuid().v4()}'),
    );
    await staging.create(recursive: true);
    final source = await pending.file.open();
    try {
      await source.setPosition(parsed.payloadOffset);
      final count = _readU32(await source.read(4));
      final expected = {
        for (final raw in parsed.manifest['files'] as List)
          (raw as Map<String, dynamic>)['name'] as String: raw['size'] as int,
      };
      if (count != expected.length) {
        throw const FormatException('Backup file list mismatch.');
      }
      for (var i = 0; i < count; i++) {
        final nameLength = _readU32(await source.read(4));
        if (nameLength < 1 || nameLength > 255) {
          throw const FormatException('Invalid file name.');
        }
        final name = utf8.decode(await source.read(nameLength));
        if (p.basename(name) != name || !expected.containsKey(name)) {
          throw const FormatException('Invalid file entry.');
        }
        final size = _readU64(await source.read(8));
        if (size != expected[name]) {
          throw const FormatException('Invalid file size.');
        }
        final output = File(p.join(staging.path, name));
        final sink = await output.open(mode: FileMode.write);
        try {
          var remaining = size;
          while (remaining > 0) {
            final chunk = await source.read(
              remaining > 1024 * 1024 ? 1024 * 1024 : remaining,
            );
            if (chunk.isEmpty) throw const FormatException('Truncated backup.');
            await sink.writeFrom(chunk);
            remaining -= chunk.length;
          }
        } finally {
          await sink.close();
        }
        await encryption.verifyFile(output, SecretKey(parsed.masterKey));
      }
    } catch (_) {
      if (await staging.exists()) await staging.delete(recursive: true);
      rethrow;
    } finally {
      await source.close();
    }

    final currentVault = await storage.vaultDirectory;
    final oldVault = Directory(
      p.join(support.path, 'vault_previous_${const Uuid().v4()}'),
    );
    final oldKey = await keys.exportMasterKey();
    try {
      await currentVault.rename(oldVault.path);
      await staging.rename(currentVault.path);
      await keys.setMasterKey(SecretKey(parsed.masterKey));
      final database = parsed.manifest['database'] as Map<String, dynamic>;
      for (final raw in database['capsules'] as List) {
        final capsule = raw as Map<String, dynamic>;
        final oldCoverPath = customCoverPath(capsule['coverId'] as String);
        if (oldCoverPath != null) {
          capsule['coverId'] = customCoverId(
            p.join(currentVault.path, p.basename(oldCoverPath)),
          );
        }
      }
      for (final raw in database['items'] as List) {
        final item = raw as Map<String, dynamic>;
        final oldPath = item['encryptedPath'] as String?;
        if (oldPath != null) {
          item['encryptedPath'] = p.join(
            currentVault.path,
            p.basename(oldPath),
          );
        }
      }
      await repository.replaceFromJson(database);
      _pendingRestore = null;
    } catch (_) {
      await keys.setMasterKey(SecretKey(oldKey));
      if (await currentVault.exists()) {
        await currentVault.delete(recursive: true);
      }
      if (await oldVault.exists()) await oldVault.rename(currentVault.path);
      rethrow;
    }
    try {
      if (await oldVault.exists()) await oldVault.delete(recursive: true);
    } catch (_) {
      // The restored library is already committed; stale encrypted files can be
      // cleaned safely on a later maintenance pass.
    }
  }

  Future<_ParsedBackup> _readHeader(File file, String password) async {
    final source = await file.open();
    try {
      if (!_equal(await source.read(_magic.length), _magic)) {
        throw const FormatException('Invalid backup.');
      }
      final manifestBlock = await _readBlock(source);
      final keyBlock = await _readBlock(source);
      final manifest =
          jsonDecode(utf8.decode(await codec.decrypt(manifestBlock, password)))
              as Map<String, dynamic>;
      final masterKey = await codec.decrypt(keyBlock, password);
      if (masterKey.length != 32 || manifest['format'] != 1) {
        throw const FormatException('Invalid backup.');
      }
      return _ParsedBackup(manifest, masterKey, await source.position());
    } finally {
      await source.close();
    }
  }

  Future<void> _writeBlock(RandomAccessFile sink, List<int> value) async {
    await sink.writeFrom(_u32(value.length));
    await sink.writeFrom(value);
  }

  Future<List<int>> _readBlock(RandomAccessFile source) async {
    final size = _readU32(await source.read(4));
    if (size < 32 || size > 100 * 1024 * 1024) {
      throw const FormatException('Invalid backup block.');
    }
    final value = await source.read(size);
    if (value.length != size) throw const FormatException('Truncated backup.');
    return value;
  }
}

class _ParsedBackup {
  const _ParsedBackup(this.manifest, this.masterKey, this.payloadOffset);
  final Map<String, dynamic> manifest;
  final List<int> masterKey;
  final int payloadOffset;
}

class _PendingRestore {
  const _PendingRestore(this.file, this.manifest, this.masterKey);
  final File file;
  final Map<String, dynamic> manifest;
  final List<int> masterKey;
}

List<int> _u32(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.big)).buffer.asUint8List();
List<int> _u64(int value) =>
    (ByteData(8)..setUint64(0, value, Endian.big)).buffer.asUint8List();
int _readU32(List<int> value) {
  if (value.length != 4) throw const FormatException('Truncated backup.');
  return ByteData.sublistView(
    Uint8List.fromList(value),
  ).getUint32(0, Endian.big);
}

int _readU64(List<int> value) {
  if (value.length != 8) throw const FormatException('Truncated backup.');
  return ByteData.sublistView(
    Uint8List.fromList(value),
  ).getUint64(0, Endian.big);
}

bool _equal(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
