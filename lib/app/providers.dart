import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/authentication/authentication_service.dart';
import '../core/backup/backup_service.dart';
import '../core/database/app_database.dart';
import '../core/encryption/encryption_service.dart';
import '../core/encryption/key_service.dart';
import '../core/notifications/notification_service.dart';
import '../core/security/screen_security_service.dart';
import '../core/settings/app_preferences.dart';
import '../core/storage/private_storage_service.dart';
import '../features/capsules/data/capsule_repository.dart';
import '../features/capsules/domain/capsule_models.dart';

final appPreferencesProvider = ChangeNotifierProvider<AppPreferencesController>(
  (ref) {
    throw StateError('AppPreferencesController must be overridden at startup.');
  },
);
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
final capsuleRepositoryProvider = Provider(
  (ref) => CapsuleRepository(ref.watch(databaseProvider)),
);
final encryptionProvider = Provider((ref) => EncryptionService());
final keyServiceProvider = Provider((ref) => KeyService());
final storageProvider = Provider(
  (ref) => PrivateStorageService(ref.watch(encryptionProvider)),
);
final authenticationProvider = Provider((ref) => AuthenticationService());
final screenSecurityProvider = Provider((ref) => ScreenSecurityService());
final notificationProvider = Provider((ref) => NotificationService());
final backupProvider = Provider(
  (ref) => BackupService(
    repository: ref.watch(capsuleRepositoryProvider),
    storage: ref.watch(storageProvider),
    keys: ref.watch(keyServiceProvider),
    encryption: ref.watch(encryptionProvider),
  ),
);

final capsulesProvider = StreamProvider<List<Capsule>>(
  (ref) => ref.watch(capsuleRepositoryProvider).watchCapsules(),
);
final trashedCapsulesProvider = StreamProvider<List<Capsule>>(
  (ref) => ref.watch(capsuleRepositoryProvider).watchCapsules(trashed: true),
);
final categoriesProvider = StreamProvider<List<CapsuleCategory>>(
  (ref) => ref.watch(capsuleRepositoryProvider).watchCategories(),
);
final capsuleProvider = FutureProvider.family<Capsule, String>(
  (ref, id) => ref.watch(capsuleRepositoryProvider).getCapsule(id),
);
final capsuleItemsProvider = FutureProvider.family<List<CapsuleItem>, String>(
  (ref, id) => ref.watch(capsuleRepositoryProvider).getItems(id),
);
final accessGrantsProvider = StateProvider<Map<String, DateTime>>((ref) => {});
