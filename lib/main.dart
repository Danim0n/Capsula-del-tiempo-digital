import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/database/app_database.dart';
import 'core/encryption/encryption_service.dart';
import 'core/encryption/key_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/settings/app_preferences.dart';
import 'core/storage/private_storage_service.dart';
import 'features/capsules/data/capsule_repository.dart';
import 'features/capsules/domain/capsule_models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final preferences = await AppPreferencesController.load();
  final database = AppDatabase();
  final keys = KeyService();
  final notifications = NotificationService();
  final storage = PrivateStorageService(EncryptionService());
  await keys.getOrCreateMasterKey();
  try {
    await notifications.initialize();
  } catch (_) {
    // Notification availability must never prevent access to local capsules.
  }
  try {
    final repository = CapsuleRepository(database);
    final expiredPaths = await repository.purgeExpiredTrash(DateTime.now());
    await storage.deleteEncryptedFiles(expiredPaths);
    await storage.clearTemporaryPreviews();
    final notificationPreferences = NotificationPreferences(
      opening: preferences.value.openingNotifications,
      dayBefore: preferences.value.dayReminder,
      weekBefore: preferences.value.weekReminder,
    );
    for (final capsule in await repository.watchCapsules().first) {
      if (capsule.persistedStatus == CapsuleStatus.sealed) {
        await notifications.scheduleCapsule(capsule, notificationPreferences);
      }
    }
  } catch (_) {
    // Maintenance is retried at the next launch.
  }

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWith((ref) => preferences),
        databaseProvider.overrideWithValue(database),
        keyServiceProvider.overrideWithValue(keys),
        notificationProvider.overrideWithValue(notifications),
      ],
      child: const TimeCapsuleApp(),
    ),
  );
}
