import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../core/authentication/authentication_service.dart';
import '../../core/tutorial/tutorial_helper.dart';
import '../../core/widgets/capsule_cover.dart';
import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key, this.tutorial = false});

  final bool tutorial;
  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  final _explanationTutorialKey = GlobalKey();
  final _warningTutorialKey = GlobalKey();
  bool _authenticated = false;
  Capsule? _selected;
  bool _tutorialScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.emergencyMode)),
    body:
        !_authenticated
            ? _explanation()
            : _selected == null
            ? _capsuleList()
            : _confirmation(_selected!),
  );

  Widget _explanation() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 22),
      const CircleAvatar(
        radius: 43,
        backgroundColor: AppColors.paleRose,
        child: Icon(Icons.shield_outlined, size: 44),
      ),
      const SizedBox(height: 28),
      Text(
        context.l10n.emergencyExplanation,
        key: widget.tutorial ? _explanationTutorialKey : null,
        textAlign: TextAlign.center,
        style: emotionalTitle(context, size: 31),
      ),
      const SizedBox(height: 24),
      Container(
        key: widget.tutorial ? _warningTutorialKey : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEADDD2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.emergencyWarning,
                style: const TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      FilledButton(
        onPressed: _authenticate,
        child: Text(context.l10n.continueLabel),
      ),
    ],
  );

  Widget _capsuleList() {
    final capsules =
        ref.watch(capsulesProvider).valueOrNull ?? const <Capsule>[];
    final locked =
        capsules
            .where(
              (c) =>
                  c.statusAt(DateTime.now()) == CapsuleStatus.sealed ||
                  c.statusAt(DateTime.now()) == CapsuleStatus.emergencyAccessed,
            )
            .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.selectCapsule,
          style: emotionalTitle(context, size: 30),
        ),
        const SizedBox(height: 20),
        for (final capsule in locked)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: SizedBox(
                width: 74,
                child: CapsuleCover(
                  coverId: capsule.coverId,
                  height: 62,
                  showLock: true,
                ),
              ),
              title: Text(capsule.title),
              subtitle: Text(
                context.l10n.unlockOn(
                  DateFormat.yMMMd(
                    Localizations.localeOf(context).toString(),
                  ).format(capsule.unlockAt),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => setState(() => _selected = capsule),
            ),
          ),
        if (locked.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(context.l10n.emptyCapsules),
            ),
          ),
      ],
    );
  }

  Widget _confirmation(Capsule capsule) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      CapsuleCover(coverId: capsule.coverId, height: 190, showLock: true),
      const SizedBox(height: 25),
      Text(capsule.title, style: emotionalTitle(context, size: 34)),
      const SizedBox(height: 12),
      Text(
        context.l10n.unlockOn(
          DateFormat.yMMMMd(
            Localizations.localeOf(context).toString(),
          ).add_Hm().format(capsule.unlockAt),
        ),
      ),
      const SizedBox(height: 24),
      Text(context.l10n.emergencyWarning, style: const TextStyle(height: 1.5)),
      const SizedBox(height: 30),
      _HoldToOpen(onCompleted: () => _complete(capsule)),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => setState(() => _selected = null),
        child: Text(context.l10n.back),
      ),
    ],
  );

  Future<void> _authenticate() async {
    final result = await ref
        .read(authenticationProvider)
        .authenticate(context.l10n.authenticatePrompt);
    if (!mounted) return;
    if (result == AuthenticationResult.success) {
      setState(() => _authenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == AuthenticationResult.unavailable
                ? context.l10n.deviceSecurityMissing
                : context.l10n.authenticationFailed,
          ),
        ),
      );
    }
  }

  void _maybeShowTutorial() {
    if (!mounted || !widget.tutorial || _tutorialScheduled) return;
    if (_explanationTutorialKey.currentContext == null ||
        _warningTutorialKey.currentContext == null) {
      return;
    }
    _tutorialScheduled = true;
    showTutorial(
      context: context,
      skipLabel: context.l10n.skip,
      targets: [
        tutorialTarget(
          id: 'emergency-explanation',
          key: _explanationTutorialKey,
          title: context.l10n.tutorialEmergencyTitle,
          body: context.l10n.tutorialEmergencyBody,
        ),
        tutorialTarget(
          id: 'emergency-warning',
          key: _warningTutorialKey,
          title: context.l10n.tutorialEmergencyWarningTitle,
          body: context.l10n.tutorialEmergencyWarningBody,
        ),
      ],
      onFinish: _completeTutorial,
      onSkip: _completeTutorial,
    );
  }

  Future<void> _completeTutorial() async {
    await ref.read(appPreferencesProvider).completeTutorial();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.tutorialComplete)));
  }

  Future<void> _complete(Capsule capsule) async {
    await ref
        .read(capsuleRepositoryProvider)
        .markEmergencyAccessed(capsule.id, DateTime.now());
    ref.read(accessGrantsProvider.notifier).state = {
      ...ref.read(accessGrantsProvider),
      capsule.id: DateTime.now().add(const Duration(minutes: 2)),
    };
    ref.invalidate(capsuleProvider(capsule.id));
    ref.invalidate(capsulesProvider);
    if (mounted) context.go('/capsule/${capsule.id}/content');
  }
}

class _HoldToOpen extends StatefulWidget {
  const _HoldToOpen({required this.onCompleted});
  final VoidCallback onCompleted;
  @override
  State<_HoldToOpen> createState() => _HoldToOpenState();
}

class _HoldToOpenState extends State<_HoldToOpen> {
  Timer? _timer;
  final _stopwatch = Stopwatch();
  double _progress = 0;

  void _start(LongPressStartDetails _) {
    _stopwatch
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final progress = _stopwatch.elapsedMilliseconds / 3000;
      if (progress >= 1) {
        _cancel(reset: false);
        widget.onCompleted();
      } else if (mounted) {
        setState(() => _progress = progress);
      }
    });
  }

  void _cancel({bool reset = true}) {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    if (reset && mounted) setState(() => _progress = 0);
  }

  @override
  void dispose() {
    _cancel(reset: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPressStart: _start,
    onLongPressEnd: (_) => _cancel(),
    child: Container(
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dustyRose,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.emergencyAccess,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  context.l10n.holdEmergency,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
