import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

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
];

class CapsuleCover extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final index = capsuleCoverIds
        .indexOf(coverId)
        .clamp(0, capsuleCoverIds.length - 1);
    final assetName =
        'assets/images/covers/cover_${(index + 1).toString().padLeft(2, '0')}.png';
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetName,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              cacheWidth: 768,
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
}
