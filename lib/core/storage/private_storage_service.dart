import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../encryption/encryption_service.dart';

class PrivateStorageService {
  PrivateStorageService(this.encryption, {Uuid uuid = const Uuid()})
    : _uuid = uuid;

  final EncryptionService encryption;
  final Uuid _uuid;

  Future<Directory> get vaultDirectory async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'vault'));
    await directory.create(recursive: true);
    return directory;
  }

  Future<String> importAndEncrypt(
    String sourcePath,
    SecretKey key, {
    void Function(double)? onProgress,
    bool deleteSource = false,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Source file does not exist.', sourcePath);
    }
    final vault = await vaultDirectory;
    final destination = File(p.join(vault.path, '${_uuid.v4()}.ctdv'));
    await encryption.encryptFile(
      source,
      destination,
      key,
      onProgress: onProgress,
    );
    if (deleteSource) {
      try {
        await source.delete();
      } catch (_) {
        // A picker may own its temporary file; failure to delete it is non-fatal.
      }
    }
    return destination.path;
  }

  Future<File> decryptToTemporary(
    String encryptedPath,
    SecretKey key, {
    String extension = '',
  }) async {
    final temp = await getTemporaryDirectory();
    final directory = Directory(p.join(temp.path, 'private_preview'));
    await directory.create(recursive: true);
    final output = File(p.join(directory.path, '${_uuid.v4()}$extension'));
    await encryption.decryptFile(File(encryptedPath), output, key);
    return output;
  }

  Future<void> clearTemporaryPreviews() async {
    final temp = await getTemporaryDirectory();
    final directory = Directory(p.join(temp.path, 'private_preview'));
    if (await directory.exists()) await directory.delete(recursive: true);
  }

  Future<void> deleteEncryptedFiles(Iterable<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  Future<int> totalBytes() async {
    final vault = await vaultDirectory;
    var total = 0;
    await for (final entity in vault.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}
