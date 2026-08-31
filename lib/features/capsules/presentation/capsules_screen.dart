import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/tutorial/tutorial_helper.dart';
import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';
import 'capsule_card.dart';
import '../../categories/category_localization.dart';

enum CapsuleFilter { all, closed, ready, opened, emergency }

enum CapsuleSort { next, recent, oldest, name }

class CapsulesScreen extends ConsumerStatefulWidget {
  const CapsulesScreen({super.key, this.tutorial = false});

  final bool tutorial;
  @override
  ConsumerState<CapsulesScreen> createState() => _CapsulesScreenState();
}

class _CapsulesScreenState extends ConsumerState<CapsulesScreen> {
  final _search = TextEditingController();
  final _tutorialKey = GlobalKey();
  CapsuleFilter _filter = CapsuleFilter.all;
  CapsuleSort _sort = CapsuleSort.next;
  bool _tutorialScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(capsulesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.myCapsules,
          key: widget.tutorial ? _tutorialKey : null,
          style: emotionalTitle(context, size: 32),
        ),
        actions: [
          PopupMenuButton<CapsuleSort>(
            initialValue: _sort,
            tooltip: context.l10n.sort,
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: CapsuleSort.next,
                    child: Text(context.l10n.sortNext),
                  ),
                  PopupMenuItem(
                    value: CapsuleSort.recent,
                    child: Text(context.l10n.sortRecent),
                  ),
                  PopupMenuItem(
                    value: CapsuleSort.oldest,
                    child: Text(context.l10n.sortOldest),
                  ),
                  PopupMenuItem(
                    value: CapsuleSort.name,
                    child: Text(context.l10n.sortName),
                  ),
                ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.createCapsule),
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(child: Icon(Icons.error_outline_rounded)),
        data: (capsules) {
          final categories =
              ref.watch(categoriesProvider).valueOrNull ??
              const <CapsuleCategory>[];
          final visible = _filterAndSort(capsules, categories);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                sliver: SliverList.list(
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: context.l10n.search,
                      ),
                    ),
                    const SizedBox(height: 13),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip(CapsuleFilter.all, context.l10n.all),
                          _filterChip(
                            CapsuleFilter.closed,
                            context.l10n.closed,
                          ),
                          _filterChip(CapsuleFilter.ready, context.l10n.ready),
                          _filterChip(
                            CapsuleFilter.opened,
                            context.l10n.opened,
                          ),
                          _filterChip(
                            CapsuleFilter.emergency,
                            context.l10n.emergency,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 58,
                            color: AppColors.sage,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            context.l10n.emptyCapsules,
                            textAlign: TextAlign.center,
                            style: emotionalTitle(context, size: 27),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverGrid.builder(
                    itemCount: visible.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 250,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                    itemBuilder:
                        (context, index) => CapsuleCard(
                          capsule: visible[index],
                          onTap:
                              () =>
                                  context.push('/capsule/${visible[index].id}'),
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _maybeShowTutorial() {
    if (!mounted || !widget.tutorial || _tutorialScheduled) return;
    if (_tutorialKey.currentContext == null) return;
    _tutorialScheduled = true;
    showTutorial(
      context: context,
      skipLabel: context.l10n.skip,
      targets: [
        tutorialTarget(
          id: 'my-capsules',
          key: _tutorialKey,
          title: context.l10n.tutorialCapsulesTitle,
          body: context.l10n.tutorialCapsulesBody,
        ),
      ],
      onFinish: () {
        if (mounted) context.push('/emergency?tutorial=true');
      },
      onSkip: () async {
        await ref.read(appPreferencesProvider).completeTutorial();
      },
    );
  }

  Widget _filterChip(CapsuleFilter value, String label) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      selected: _filter == value,
      label: Text(label),
      onSelected: (_) => setState(() => _filter = value),
    ),
  );

  List<Capsule> _filterAndSort(
    List<Capsule> source,
    List<CapsuleCategory> categories,
  ) {
    final query = _search.text.trim().toLowerCase();
    final now = DateTime.now();
    final categoryNames = {
      for (final category in categories)
        category.id: categoryLabel(context, category).toLowerCase(),
    };
    final result =
        source.where((capsule) {
          if (capsule.persistedStatus == CapsuleStatus.draft) return false;
          if (query.isNotEmpty &&
              !capsule.title.toLowerCase().contains(query) &&
              !(categoryNames[capsule.categoryId] ?? capsule.categoryId)
                  .contains(query)) {
            return false;
          }
          final status = capsule.statusAt(now);
          return switch (_filter) {
            CapsuleFilter.all => true,
            CapsuleFilter.closed => status == CapsuleStatus.sealed,
            CapsuleFilter.ready => status == CapsuleStatus.readyToOpen,
            CapsuleFilter.opened => status == CapsuleStatus.opened,
            CapsuleFilter.emergency => capsule.emergencyAccessedAt != null,
          };
        }).toList();
    result.sort(switch (_sort) {
      CapsuleSort.next => (a, b) => a.unlockAt.compareTo(b.unlockAt),
      CapsuleSort.recent => (a, b) => b.createdAt.compareTo(a.createdAt),
      CapsuleSort.oldest => (a, b) => a.createdAt.compareTo(b.createdAt),
      CapsuleSort.name =>
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    });
    return result;
  }
}
