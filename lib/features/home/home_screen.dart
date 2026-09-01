import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../core/tutorial/tutorial_helper.dart';
import '../../core/widgets/capsule_cover.dart';
import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.tutorial = false});

  final bool tutorial;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _textTutorialKey = GlobalKey();
  bool _tutorialScheduled = false;
  Timer? _tutorialRetry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tutorial && !oldWidget.tutorial) {
      _tutorialScheduled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
    }
  }

  @override
  void dispose() {
    _tutorialRetry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capsules =
        ref.watch(capsulesProvider).valueOrNull ?? const <Capsule>[];
    final upcoming =
        capsules
            .where((capsule) => capsule.persistedStatus != CapsuleStatus.draft)
            .take(3)
            .toList();

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroAndComposer(
                    textTutorialKey: _textTutorialKey,
                    onCreate: () => context.push('/create'),
                    onSelected:
                        (type) => context.push('/create?type=${type.name}'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                  sliver: SliverList.list(
                    children: [
                      _SectionHeader(onViewAll: () => context.go('/capsules')),
                      const SizedBox(height: 14),
                      _UpcomingCards(
                        capsules: upcoming,
                        onCreate: () => context.push('/create'),
                        onOpen: (id) => context.push('/capsule/$id'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _maybeShowTutorial() {
    if (!mounted || _tutorialScheduled) return;
    final preferences = ref.read(appPreferencesProvider).value;
    if (!widget.tutorial && preferences.tutorialComplete) return;
    if (_textTutorialKey.currentContext == null) {
      _scheduleTutorialRetry();
      return;
    }
    _tutorialScheduled = true;
    showTutorial(
      context: context,
      skipLabel: context.l10n.skip,
      targets: [
        tutorialTarget(
          id: 'home-text',
          key: _textTutorialKey,
          title: context.l10n.tutorialHomeTitle,
          body: context.l10n.tutorialHomeBody,
          align: ContentAlign.top,
        ),
      ],
      onFinish: () {
        if (mounted) context.push('/create?tutorial=true');
      },
      onSkip: _skipTutorial,
    );
  }

  void _scheduleTutorialRetry() {
    _tutorialRetry?.cancel();
    _tutorialRetry = Timer(const Duration(milliseconds: 250), () {
      if (mounted) _maybeShowTutorial();
    });
  }

  Future<void> _skipTutorial() async {
    await ref.read(appPreferencesProvider).completeTutorial();
    if (mounted) context.go('/');
  }
}

class _HeroAndComposer extends StatelessWidget {
  const _HeroAndComposer({
    required this.onCreate,
    required this.onSelected,
    required this.textTutorialKey,
  });

  final VoidCallback onCreate;
  final ValueChanged<CapsuleItemType> onSelected;
  final GlobalKey textTutorialKey;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 610,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(bottom: 145, child: const _FadedHeroImage()),
        Positioned(
          left: 76,
          right: 76,
          top: 67,
          child: Column(
            children: [
              Text(
                context.l10n.heroTitle,
                textAlign: TextAlign.center,
                style: emotionalTitle(context, size: 56).copyWith(
                  fontWeight: FontWeight.w500,
                  height: .96,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 18),
              const _TimeMark(),
              const SizedBox(height: 14),
              Text(
                context.l10n.heroSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 20,
                  height: 1.18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          top: 306,
          child: _ComposerPanel(
            onCreate: onCreate,
            onSelected: onSelected,
            textTutorialKey: textTutorialKey,
          ),
        ),
      ],
    ),
  );
}

class _FadedHeroImage extends StatelessWidget {
  const _FadedHeroImage();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.cream,
    child: Align(
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/memory_hero.png', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.cream,
                  ],
                  stops: [0, .62, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TimeMark extends StatelessWidget {
  const _TimeMark();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _DecorativeDot(),
      SizedBox(width: 10),
      Icon(Icons.hourglass_empty_rounded, size: 20, color: AppColors.dustyRose),
      SizedBox(width: 10),
      _DecorativeDot(),
    ],
  );
}

class _DecorativeDot extends StatelessWidget {
  const _DecorativeDot();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.dustyRose,
      shape: BoxShape.circle,
    ),
    child: SizedBox.square(dimension: 4),
  );
}

class _ComposerPanel extends StatelessWidget {
  const _ComposerPanel({
    required this.onCreate,
    required this.onSelected,
    required this.textTutorialKey,
  });

  final VoidCallback onCreate;
  final ValueChanged<CapsuleItemType> onSelected;
  final GlobalKey textTutorialKey;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 17),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: .97),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white, width: 1.3),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        _QuickActions(onSelected: onSelected, textTutorialKey: textTutorialKey),
        const SizedBox(height: 20),
        _CreateButton(onTap: onCreate),
      ],
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onSelected,
    required this.textTutorialKey,
  });

  final ValueChanged<CapsuleItemType> onSelected;
  final GlobalKey textTutorialKey;

  @override
  Widget build(BuildContext context) {
    final entries = [
      (
        CapsuleItemType.image,
        context.l10n.photo,
        Icons.photo_outlined,
        AppColors.paleRose,
        const Color(0xFFA76963),
      ),
      (
        CapsuleItemType.video,
        context.l10n.video,
        Icons.video_library_outlined,
        AppColors.paleSage,
        const Color(0xFF596052),
      ),
      (
        CapsuleItemType.audio,
        context.l10n.audio,
        Icons.mic_none_rounded,
        const Color(0xFFEADBC9),
        const Color(0xFF71563E),
      ),
      (
        CapsuleItemType.text,
        context.l10n.text,
        Icons.description_outlined,
        AppColors.lavender,
        const Color(0xFF625A67),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Expanded(
            child: InkWell(
              key: entry.$1 == CapsuleItemType.text ? textTutorialKey : null,
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSelected(entry.$1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: entry.$4,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: entry.$5.withValues(alpha: .22),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(entry.$3, color: entry.$5, size: 31),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      entry.$2,
                      style: const TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.dustyRose,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .4)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard_outlined,
                  color: Colors.white,
                  size: 31,
                ),
                const SizedBox(width: 13),
                Text(
                  context.l10n.createCapsule,
                  style: const TextStyle(
                    fontFamily: 'CormorantGaramond',
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.createCapsuleSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                height: 1.35,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.schedule_rounded, size: 28, color: AppColors.ink),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          context.l10n.nextOpenings,
          style: emotionalTitle(
            context,
            size: 27,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      TextButton(
        onPressed: onViewAll,
        style: TextButton.styleFrom(foregroundColor: AppColors.secondaryInk),
        child: Row(
          children: [
            Text(context.l10n.viewAll),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 22),
          ],
        ),
      ),
    ],
  );
}

class _UpcomingCards extends StatelessWidget {
  const _UpcomingCards({
    required this.capsules,
    required this.onCreate,
    required this.onOpen,
  });

  final List<Capsule> capsules;
  final VoidCallback onCreate;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (capsules.isEmpty) {
      const previews = [
        ('Para mi yo\ndel futuro', '12 de junio de 2026', 'En 1 año'),
        ('Nuestros\nrecuerdos', '3 de mayo de 2029', 'En 5 años'),
        ('Sueños por\ncumplir', '8 de abril de 2032', 'En 8 años'),
      ];
      return Row(
        children: [
          for (var index = 0; index < previews.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: _MemoryCard(
                title: previews[index].$1,
                date: previews[index].$2,
                relativeDate: previews[index].$3,
                coverId: capsuleCoverIds[index],
                onTap: onCreate,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var index = 0; index < capsules.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _MemoryCard(
              title: capsules[index].title,
              date: DateFormat.yMMMMd(
                Localizations.localeOf(context).toString(),
              ).format(capsules[index].unlockAt),
              relativeDate: _relativeDate(context, capsules[index].unlockAt),
              coverId: capsules[index].coverId,
              onTap: () => onOpen(capsules[index].id),
            ),
          ),
        ],
      ],
    );
  }

  String _relativeDate(BuildContext context, DateTime date) {
    final years = (date.difference(DateTime.now()).inDays / 365).ceil().clamp(
      1,
      99,
    );
    final spanish = Localizations.localeOf(context).languageCode == 'es';
    if (spanish) return 'En $years ${years == 1 ? 'año' : 'años'}';
    return 'In $years ${years == 1 ? 'year' : 'years'}';
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.title,
    required this.date,
    required this.relativeDate,
    required this.coverId,
    required this.onTap,
  });

  final String title;
  final String date;
  final String relativeDate;
  final String coverId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 235,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sand),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CapsuleCover(coverId: coverId, height: 178),
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xEFFFFCF8), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, -.77),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 17,
                            height: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x18000000), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.lock_outline_rounded, size: 26),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                color: AppColors.surface.withValues(alpha: .94),
                child: Column(
                  children: [
                    Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      relativeDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
