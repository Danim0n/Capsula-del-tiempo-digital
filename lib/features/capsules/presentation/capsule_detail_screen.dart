import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/widgets/capsule_cover.dart';
import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';
import '../../categories/category_localization.dart';

class CapsuleDetailScreen extends ConsumerWidget {
  const CapsuleDetailScreen({super.key, required this.capsuleId});
  final String capsuleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsuleAsync = ref.watch(capsuleProvider(capsuleId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/capsules'),
      ),
      body: capsuleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(child: Icon(Icons.error_outline_rounded)),
        data: (capsule) {
          final status = capsule.statusAt(DateTime.now());
          final locale = Localizations.localeOf(context).toString();
          final categories =
              ref.watch(categoriesProvider).valueOrNull ??
              const <CapsuleCategory>[];
          var categoryName = capsule.categoryId;
          for (final category in categories) {
            if (category.id == capsule.categoryId) {
              categoryName = categoryLabel(context, category);
            }
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              CapsuleCover(
                coverId: capsule.coverId,
                height: 230,
                showLock:
                    status == CapsuleStatus.sealed ||
                    status == CapsuleStatus.emergencyAccessed,
              ),
              const SizedBox(height: 26),
              Text(capsule.title, style: emotionalTitle(context, size: 38)),
              const SizedBox(height: 10),
              Text(
                categoryName,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.secondaryInk),
              ),
              const SizedBox(height: 25),
              _InfoRow(
                icon: Icons.event_outlined,
                label: context.l10n.unlockOn(
                  DateFormat.yMMMMd(locale).add_Hm().format(capsule.unlockAt),
                ),
              ),
              _InfoRow(
                icon: Icons.collections_bookmark_outlined,
                label: context.l10n.itemsCount(capsule.itemCount),
              ),
              const SizedBox(height: 24),
              if (status == CapsuleStatus.sealed ||
                  status == CapsuleStatus.emergencyAccessed)
                _StatusPanel(
                  icon: Icons.lock_outline_rounded,
                  title: context.l10n.sealedMessage,
                  color: AppColors.paleSage,
                )
              else if (status == CapsuleStatus.readyToOpen) ...[
                _StatusPanel(
                  icon: Icons.lock_open_rounded,
                  title: context.l10n.readyMessage,
                  color: AppColors.paleRose,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed:
                      () => _open(context, ref, capsule, firstOpening: true),
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(context.l10n.openCapsule),
                ),
              ] else if (status == CapsuleStatus.opened) ...[
                FilledButton.icon(
                  onPressed:
                      () => _open(context, ref, capsule, firstOpening: false),
                  icon: const Icon(Icons.auto_stories_outlined),
                  label: Text(context.l10n.openCapsule),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _delete(context, ref, capsule),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(context.l10n.delete),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Capsule capsule, {
    required bool firstOpening,
  }) async {
    if (firstOpening) {
      await ref
          .read(capsuleRepositoryProvider)
          .markOpened(capsule.id, DateTime.now());
      ref.invalidate(capsuleProvider(capsule.id));
      ref.invalidate(capsulesProvider);
      if (context.mounted) {
        context.push('/capsule/${capsule.id}/opening');
      }
    } else {
      context.push('/capsule/${capsule.id}/content');
    }
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
            title: Text(context.l10n.delete),
            content: Text(context.l10n.deleteQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref
        .read(capsuleRepositoryProvider)
        .moveToTrash(capsule.id, DateTime.now());
    ref.invalidate(capsulesProvider);
    if (context.mounted) context.go('/capsules');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: AppColors.secondaryInk),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: emotionalTitle(context, size: 25),
        ),
      ],
    ),
  );
}
