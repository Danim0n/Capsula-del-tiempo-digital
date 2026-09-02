import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/notifications/notification_service.dart';
import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';
import '../categories/category_localization.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: Text(
        context.l10n.settings,
        style: emotionalTitle(context, size: 32),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        _section(context.l10n.general),
        _tile(
          Icons.language_rounded,
          context.l10n.language,
          onTap: () => _language(context, ref),
        ),
        _tile(
          Icons.notifications_none_rounded,
          context.l10n.notifications,
          onTap: () => context.push('/settings/notifications'),
        ),
        _tile(
          Icons.folder_outlined,
          context.l10n.manageCategories,
          onTap: () => context.push('/settings/categories'),
        ),
        _section(context.l10n.privacySecurity),
        _tile(
          Icons.delete_outline_rounded,
          context.l10n.trash,
          onTap: () => context.push('/settings/trash'),
        ),
        _section(context.l10n.data),
        _tile(
          Icons.wifi_tethering_rounded,
          context.l10n.nearbyTitle,
          onTap: () => context.push('/nearby'),
        ),
        _tile(
          Icons.archive_outlined,
          context.l10n.backups,
          onTap: () => context.push('/settings/backups'),
        ),
        _tile(
          Icons.pie_chart_outline_rounded,
          context.l10n.storageUsage,
          onTap: () => context.push('/settings/storage'),
        ),
        _section(context.l10n.application),
        _tile(
          Icons.school_outlined,
          context.l10n.repeatTutorial,
          onTap: () async {
            await ref.read(appPreferencesProvider).completeTutorial(false);
            if (context.mounted) context.go('/?tutorial=true');
          },
        ),
        _tile(
          Icons.info_outline_rounded,
          context.l10n.about,
          subtitle: context.l10n.version,
          onTap:
              () => showAboutDialog(
                context: context,
                applicationName: context.l10n.appName,
                applicationVersion: '0.1.0',
              ),
        ),
      ],
    ),
  );

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(5, 28, 5, 8),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.15,
        color: AppColors.secondaryInk,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _tile(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    leading: Icon(icon),
    title: Text(title),
    subtitle:
        subtitle == null
            ? null
            : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );

  Future<void> _language(BuildContext context, WidgetRef ref) async {
    final current = ref.read(appPreferencesProvider).value.locale.languageCode;
    final selected = await showDialog<String>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: Text(context.l10n.language),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'es'),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.spanish),
                  trailing:
                      current == 'es' ? const Icon(Icons.check_rounded) : null,
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'en'),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.english),
                  trailing:
                      current == 'en' ? const Icon(Icons.check_rounded) : null,
                ),
              ),
            ],
          ),
    );
    if (selected != null) {
      await ref.read(appPreferencesProvider).setLocale(Locale(selected));
    }
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appPreferencesProvider);
    final preferences = controller.value;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/settings'),
        title: Text(context.l10n.notifications),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text(context.l10n.notificationOpening),
            value: preferences.openingNotifications,
            onChanged: (value) => _change(ref, opening: value),
          ),
          SwitchListTile(
            title: Text(context.l10n.reminderDay),
            value: preferences.dayReminder,
            onChanged: (value) => _change(ref, day: value),
          ),
          SwitchListTile(
            title: Text(context.l10n.reminderWeek),
            value: preferences.weekReminder,
            onChanged: (value) => _change(ref, week: value),
          ),
        ],
      ),
    );
  }

  Future<void> _change(
    WidgetRef ref, {
    bool? opening,
    bool? day,
    bool? week,
  }) async {
    await ref
        .read(appPreferencesProvider)
        .setNotifications(opening: opening, day: day, week: week);
    final value = ref.read(appPreferencesProvider).value;
    final capsules =
        ref.read(capsulesProvider).valueOrNull ?? const <Capsule>[];
    for (final capsule in capsules.where(
      (c) => c.persistedStatus == CapsuleStatus.sealed,
    )) {
      await ref
          .read(notificationProvider)
          .scheduleCapsule(
            capsule,
            NotificationPreferences(
              opening: value.openingNotifications,
              dayBefore: value.dayReminder,
              weekBefore: value.weekReminder,
            ),
          );
    }
  }
}

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/settings'),
        title: Text(context.l10n.manageCategories),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newCategory),
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(child: Icon(Icons.error_outline_rounded)),
        data:
            (values) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              itemCount: values.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final category = values[index];
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(categoryLabel(context, category)),
                  trailing:
                      category.isDefault
                          ? null
                          : PopupMenuButton<String>(
                            onSelected:
                                (action) =>
                                    action == 'rename'
                                        ? _rename(context, ref, category)
                                        : _delete(context, ref, category),
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem(
                                    value: 'rename',
                                    child: Text(context.l10n.rename),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(context.l10n.delete),
                                  ),
                                ],
                          ),
                );
              },
            ),
      ),
    );
  }

  Future<String?> _nameDialog(
    BuildContext context, {
    String initial = '',
  }) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.newCategory),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: context.l10n.category),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: Text(context.l10n.save),
              ),
            ],
          ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await _nameDialog(context);
    if (name?.isNotEmpty == true) {
      await ref.read(capsuleRepositoryProvider).createCategory(name!);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    CapsuleCategory category,
  ) async {
    final name = await _nameDialog(context, initial: category.name);
    if (name?.isNotEmpty == true) {
      await ref
          .read(capsuleRepositoryProvider)
          .renameCategory(category.id, name!);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CapsuleCategory category,
  ) async {
    try {
      await ref.read(capsuleRepositoryProvider).deleteCategory(category.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.categoryInUse)));
      }
    }
  }
}

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsules = ref.watch(trashedCapsulesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/settings'),
        title: Text(context.l10n.trash),
      ),
      body: capsules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(child: Icon(Icons.error_outline_rounded)),
        data:
            (values) =>
                values.isEmpty
                    ? Center(child: Text(context.l10n.trashEmpty))
                    : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: values.length,
                      itemBuilder: (context, index) {
                        final capsule = values[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(capsule.title),
                            subtitle: Text(
                              capsule.deletedAt == null
                                  ? ''
                                  : DateFormat.yMMMd(
                                    Localizations.localeOf(context).toString(),
                                  ).format(capsule.deletedAt!),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected:
                                  (action) =>
                                      action == 'restore'
                                          ? _restore(ref, capsule)
                                          : _delete(context, ref, capsule),
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      value: 'restore',
                                      child: Text(context.l10n.restore),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(context.l10n.deleteForever),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }

  Future<void> _restore(WidgetRef ref, Capsule capsule) async {
    await ref.read(capsuleRepositoryProvider).restore(capsule.id);
    ref.invalidate(trashedCapsulesProvider);
    ref.invalidate(capsulesProvider);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Capsule capsule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.deleteForever),
            content: Text(context.l10n.deleteForeverQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.deleteForever),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    final paths = await ref
        .read(capsuleRepositoryProvider)
        .deleteForever(capsule.id);
    await ref.read(storageProvider).deleteEncryptedFiles(paths);
    ref.invalidate(trashedCapsulesProvider);
  }
}

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});
  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const AppBackButton(fallbackLocation: '/settings'),
      title: Text(context.l10n.backups),
    ),
    body: Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.paleRose,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.backupWarning,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: _busy ? null : _create,
              icon: const Icon(Icons.archive_outlined),
              label: Text(context.l10n.createBackup),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.unarchive_outlined),
              label: Text(context.l10n.restoreBackup),
            ),
          ],
        ),
        if (_busy)
          const ColoredBox(
            color: Color(0xAAFFFDFC),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    ),
  );

  Future<String?> _password({required bool confirm}) async {
    final first = TextEditingController();
    final second = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.backupPassword),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.backupPasswordHint),
                const SizedBox(height: 15),
                TextField(
                  controller: first,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.backupPassword,
                  ),
                ),
                if (confirm) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: second,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.backupPassword,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (first.text.length >= 8 &&
                      (!confirm || first.text == second.text)) {
                    Navigator.pop(context, first.text);
                  }
                },
                child: Text(context.l10n.continueLabel),
              ),
            ],
          ),
    );
  }

  Future<void> _create() async {
    final password = await _password(confirm: true);
    if (password == null || !mounted) return;
    final shareHint = context.l10n.backupPasswordHint;
    final successMessage = context.l10n.backupCreated;
    setState(() => _busy = true);
    try {
      final path = await ref.read(backupProvider).createBackup(password);
      if (mounted && path != null) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(path)], text: shareHint),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.backupError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final password = await _password(confirm: false);
    if (password == null) return;
    setState(() => _busy = true);
    try {
      final summary = await ref.read(backupProvider).inspectBackup(password);
      if (summary == null || !mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(context.l10n.restoreBackup),
              content: Text(
                '${context.l10n.replaceWarning}\n\n${summary.capsules} · ${context.l10n.itemsCount(summary.items)}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.l10n.restore),
                ),
              ],
            ),
      );
      if (confirmed == true) {
        await ref.read(backupProvider).restoreInspectedBackup(password);
        ref.invalidate(capsulesProvider);
        ref.invalidate(categoriesProvider);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.backupError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      leading: const AppBackButton(fallbackLocation: '/settings'),
      title: Text(context.l10n.storageUsage),
    ),
    body: FutureBuilder<_StorageData>(
      future: _load(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              context.l10n.storageTotal(_size(data.total)),
              style: emotionalTitle(context, size: 30),
            ),
            const SizedBox(height: 26),
            _storageRow(context.l10n.images, data.images),
            _storageRow(context.l10n.videos, data.videos),
            _storageRow(context.l10n.audios, data.audio),
            _storageRow(context.l10n.other, data.other),
          ],
        );
      },
    ),
  );

  Future<_StorageData> _load(WidgetRef ref) async {
    final capsules =
        await ref.read(capsuleRepositoryProvider).watchCapsules().first;
    var images = 0, videos = 0, audio = 0, other = 0;
    for (final capsule in capsules) {
      for (final item in await ref
          .read(capsuleRepositoryProvider)
          .getItems(capsule.id)) {
        switch (item.type) {
          case CapsuleItemType.image:
            images += item.byteSize;
          case CapsuleItemType.video:
            videos += item.byteSize;
          case CapsuleItemType.audio:
            audio += item.byteSize;
          case CapsuleItemType.text:
            other += item.byteSize;
        }
      }
    }
    return _StorageData(images, videos, audio, other);
  }

  Widget _storageRow(String label, int bytes) => ListTile(
    leading: const Icon(Icons.circle, size: 12, color: AppColors.dustyRose),
    title: Text(label),
    trailing: Text(_size(bytes)),
  );
  String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class _StorageData {
  const _StorageData(this.images, this.videos, this.audio, this.other);
  final int images, videos, audio, other;
  int get total => images + videos + audio + other;
}
