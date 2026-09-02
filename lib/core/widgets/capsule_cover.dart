import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../storage/custom_cover_id.dart';

const capsuleCoverIds = [
  'cover_01',
  'cover_02',
  'cover_03',
  'cover_04',
  'cover_05',
  'cover_06',
  'cover_07',
  'cover_08',
  'cover_09',
  'cover_10',
  'cover_11',
  'cover_12',
  'cover_13',
  'cover_14',
  'cover_15',
  'cover_16',
  'cover_17',
  'cover_18',
  'cover_19',
  'cover_20',
  'cover_21',
  'cover_22',
  'cover_23',
  'cover_24',
];

class CapsuleCover extends ConsumerWidget {
  const CapsuleCover({
    super.key,
    required this.coverId,
    this.height = 150,
    this.showLock = false,
  });
  final String coverId;
  final double height;
  final bool showLock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encryptedPath = customCoverPath(coverId);
    final index = capsuleCoverIds
        .indexOf(coverId)
        .clamp(0, capsuleCoverIds.length - 1);
    final coverNumber = index + 1;
    final extension = coverNumber <= 12 ? 'png' : 'webp';
    final assetName =
        'assets/images/covers/cover_${coverNumber.toString().padLeft(2, '0')}.$extension';
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (encryptedPath == null)
              Image.asset(
                assetName,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                cacheWidth: 768,
              )
            else
              ref
                  .watch(privateImageBytesProvider(encryptedPath))
                  .when(
                    loading: _coverPlaceholder,
                    error: (_, __) => _coverPlaceholder(),
                    data:
                        (bytes) =>
                            bytes == null
                                ? _coverPlaceholder()
                                : Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.medium,
                                  cacheWidth: 1200,
                                  gaplessPlayback: true,
                                  errorBuilder:
                                      (_, __, ___) => _coverPlaceholder(),
                                ),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x22000000)],
                  stops: [.65, 1],
                ),
              ),
            ),
            if (showLock)
              const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x26000000), blurRadius: 8),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(Icons.lock_outline_rounded, size: 18),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => const ColoredBox(
    color: AppColors.paleRose,
    child: Center(
      child: Icon(
        Icons.photo_outlined,
        size: 34,
        color: AppColors.secondaryInk,
      ),
    ),
  );
}
