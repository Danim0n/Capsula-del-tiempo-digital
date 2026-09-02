import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/navigation/app_navigation.dart';
import '../../l10n/l10n.dart';

class CreationModeScreen extends StatelessWidget {
  const CreationModeScreen({super.key});

  @override
  Widget build(BuildContext context) => BackFallbackScope(
    fallbackLocation: '/',
    child: Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/'),
        title: Text(context.l10n.createCapsule),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              context.l10n.chooseCapsuleKind,
              style: emotionalTitle(context, size: 34),
            ),
            const SizedBox(height: 24),
            _choice(
              context,
              mode: 'standard',
              icon: Icons.inventory_2_outlined,
              title: context.l10n.standardCapsule,
              body: context.l10n.standardCapsuleHint,
              color: AppColors.paleRose,
            ),
            const SizedBox(height: 20),
            _choice(
              context,
              mode: 'personalized',
              icon: Icons.auto_stories_outlined,
              title: context.l10n.personalizedCapsule,
              body: context.l10n.personalizedCapsuleHint,
              color: AppColors.paleSage,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _choice(
    BuildContext context, {
    required String mode,
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) => Card(
    clipBehavior: Clip.antiAlias,
    color: color,
    child: InkWell(
      key: ValueKey('create-$mode'),
      onTap: () => context.push('/create?mode=$mode'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 38),
            const SizedBox(height: 16),
            Text(title, style: emotionalTitle(context, size: 28)),
            const SizedBox(height: 10),
            Text(body),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    ),
  );
}
