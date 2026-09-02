import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/capsules/domain/capsule_models.dart';
import '../features/capsules/presentation/capsule_content_screen.dart';
import '../features/capsules/presentation/capsule_detail_screen.dart';
import '../features/capsules/presentation/capsules_screen.dart';
import '../features/capsules/presentation/opening_screen.dart';
import '../features/creation/creation_screen.dart';
import '../features/creation/creation_mode_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screens.dart';
import '../features/transfer/nearby_transfer_screen.dart';
import '../core/navigation/app_navigation.dart';
import 'app_shell.dart';

GoRouter buildRouter(WidgetRef ref) => GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder:
          (_, __, navigationShell) =>
              AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder:
                  (_, state) => HomeScreen(
                    tutorial: state.uri.queryParameters['tutorial'] == 'true',
                  ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/capsules',
              builder:
                  (_, state) => CapsulesScreen(
                    tutorial: state.uri.queryParameters['tutorial'] == 'true',
                  ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/nearby',
      builder: (_, state) => BackFallbackScope(
        fallbackLocation: '/capsules',
        child: NearbyTransferScreen(
          capsuleId: state.uri.queryParameters['capsule'],
        ),
      ),
    ),
    GoRoute(
      path: '/create',
      builder: (_, state) {
        final typeName = state.uri.queryParameters['type'];
        CapsuleItemType? type;
        for (final candidate in CapsuleItemType.values) {
          if (candidate.name == typeName) type = candidate;
        }
        final mode = state.uri.queryParameters['mode'];
        final tutorial = state.uri.queryParameters['tutorial'] == 'true';
        if (mode != 'standard' && mode != 'personalized' && type == null &&
            !tutorial && !state.uri.queryParameters.containsKey('days') &&
            state.uri.queryParameters['pickDate'] != 'true') {
          return const CreationModeScreen();
        }
        return CreationScreen(
          key: state.pageKey,
          kind: !tutorial && mode == 'personalized' ? CapsuleKind.personalized : CapsuleKind.standard,
          quickType: type,
          quickDays: int.tryParse(state.uri.queryParameters['days'] ?? ''),
          pickDateOnStart: state.uri.queryParameters['pickDate'] == 'true',
          tutorial: tutorial,
        );
      },
    ),
    GoRoute(
      path: '/capsule/:id',
      builder:
          (_, state) => BackFallbackScope(
            fallbackLocation: '/capsules',
            child: CapsuleDetailScreen(capsuleId: state.pathParameters['id']!),
          ),
    ),
    GoRoute(
      path: '/capsule/:id/opening',
      builder:
          (_, state) => BackFallbackScope(
            fallbackLocation: '/capsules',
            child: OpeningScreen(capsuleId: state.pathParameters['id']!),
          ),
    ),
    GoRoute(
      path: '/capsule/:id/content',
      builder:
          (_, state) => BackFallbackScope(
            fallbackLocation: '/capsules',
            child: CapsuleContentScreen(capsuleId: state.pathParameters['id']!),
          ),
    ),
    GoRoute(
      path: '/settings/notifications',
      builder:
          (_, __) => const BackFallbackScope(
            fallbackLocation: '/settings',
            child: NotificationSettingsScreen(),
          ),
    ),
    GoRoute(
      path: '/settings/categories',
      builder:
          (_, __) => const BackFallbackScope(
            fallbackLocation: '/settings',
            child: CategoriesScreen(),
          ),
    ),
    GoRoute(
      path: '/settings/trash',
      builder:
          (_, __) => const BackFallbackScope(
            fallbackLocation: '/settings',
            child: TrashScreen(),
          ),
    ),
    GoRoute(
      path: '/settings/backups',
      builder:
          (_, __) => const BackFallbackScope(
            fallbackLocation: '/settings',
            child: BackupScreen(),
          ),
    ),
    GoRoute(
      path: '/settings/storage',
      builder:
          (_, __) => const BackFallbackScope(
            fallbackLocation: '/settings',
            child: StorageScreen(),
          ),
    ),
  ],
);
