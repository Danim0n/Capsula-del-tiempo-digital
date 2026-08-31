import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class TimeCapsuleApp extends ConsumerStatefulWidget {
  const TimeCapsuleApp({super.key});
  @override
  ConsumerState<TimeCapsuleApp> createState() => _TimeCapsuleAppState();
}

class _TimeCapsuleAppState extends ConsumerState<TimeCapsuleApp> {
  late final router = buildRouter(ref);

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider).value;
    return MaterialApp.router(
      title: 'Cápsula del Tiempo Digital',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: preferences.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
