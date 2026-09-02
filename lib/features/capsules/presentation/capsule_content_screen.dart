import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';
import 'capsule_sequence_viewer.dart';
import 'capsule_memory_view.dart';

class CapsuleContentScreen extends ConsumerStatefulWidget {
  const CapsuleContentScreen({super.key, required this.capsuleId});
  final String capsuleId;

  @override
  ConsumerState<CapsuleContentScreen> createState() =>
      _CapsuleContentScreenState();
}

class _CapsuleContentScreenState extends ConsumerState<CapsuleContentScreen> {
  late final _security = ref.read(screenSecurityProvider);
  @override
  void initState() {
    super.initState();
    unawaited(_security.protect());
  }

  @override
  void dispose() {
    unawaited(_security.unprotect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capsule = ref.watch(capsuleProvider(widget.capsuleId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/capsules'),
        title: Text(capsule.valueOrNull?.title ?? context.l10n.appName),
      ),
      body: capsule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Icon(Icons.error_outline_rounded)),
        data: (capsule) {
          final status = capsule.statusAt(DateTime.now());
          if (status != CapsuleStatus.opened &&
              status != CapsuleStatus.readyToOpen) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.sealedMessage,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ref
              .watch(capsuleItemsProvider(widget.capsuleId))
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Icon(Icons.error_outline_rounded)),
                data: (values) => capsule.kind == CapsuleKind.personalized
                    ? CapsuleSequenceViewer(
                        items: values,
                        description: capsule.description,
                        itemBuilder: (item, index) => CapsuleMemoryView(
                          key: ValueKey(item.id),
                          item: item,
                          index: index,
                        ),
                        onFinished: () => context.go('/capsules'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: values.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) => CapsuleMemoryView(
                          key: ValueKey(values[index].id),
                          item: values[index],
                          index: index,
                        ),
                      ),
              );
        },
      ),
    );
  }
}
