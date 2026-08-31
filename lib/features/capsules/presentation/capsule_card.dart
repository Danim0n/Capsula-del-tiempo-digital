import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/capsule_cover.dart';
import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';

class CapsuleCard extends StatelessWidget {
  const CapsuleCard({
    super.key,
    required this.capsule,
    required this.onTap,
    this.width,
  });
  final Capsule capsule;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final status = capsule.statusAt(DateTime.now());
    final ready = status == CapsuleStatus.readyToOpen;
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    CapsuleCover(
                      coverId: capsule.coverId,
                      height: 112,
                      showLock: !ready && status != CapsuleStatus.opened,
                    ),
                    if (ready)
                      const Positioned(
                        right: 10,
                        top: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.lock_open_rounded, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  capsule.title.isEmpty ? '—' : capsule.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: emotionalTitle(context, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  ready
                      ? context.l10n.readyMessage
                      : context.l10n.unlockOn(
                        DateFormat.yMMMd(
                          Localizations.localeOf(context).toString(),
                        ).format(capsule.unlockAt),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ready ? AppColors.dustyRose : AppColors.secondaryInk,
                    fontWeight: ready ? FontWeight.w700 : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.itemsCount(capsule.itemCount),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
