import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';
import '../capsules/presentation/capsule_memory_view.dart';

/// An editor-only preview, separate from the time-locked capsule opening route.
class DraftMemoryPreviewScreen extends ConsumerStatefulWidget {
  const DraftMemoryPreviewScreen({
    super.key,
    required this.capsuleId,
    required this.itemId,
  });

  final String capsuleId;
  final String itemId;

  @override
  ConsumerState<DraftMemoryPreviewScreen> createState() =>
      _DraftMemoryPreviewScreenState();
}

class _DraftMemoryPreviewScreenState
    extends ConsumerState<DraftMemoryPreviewScreen> {
  late Future<({CapsuleItem item, int index})> _memory;
  late final _security = ref.read(screenSecurityProvider);

  @override
  void initState() {
    super.initState();
    _memory = _load();
    unawaited(_security.protect());
  }

  Future<({CapsuleItem item, int index})> _load() async {
    // Do not use cached capsule providers here: sealing/deleting a draft must
    // immediately revoke preview access. Read the stored item, not a UI copy.
    final repository = ref.read(capsuleRepositoryProvider);
    final capsule = await repository.getCapsule(widget.capsuleId);
    if (!capsule.isMutable) throw const CapsuleLockedException();
    final items = await repository.getItems(capsule.id);
    final index = items.indexWhere((item) => item.id == widget.itemId);
    if (index < 0) throw StateError('Memory is no longer in this draft.');
    return (item: items[index], index: index);
  }

  @override
  void dispose() {
    unawaited(_security.unprotect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: Text(context.l10n.previewMemory),
    ),
    body: SafeArea(
      child: FutureBuilder<({CapsuleItem item, int index})>(
        future: _memory,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility_off_outlined, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error is CapsuleLockedException
                          ? context.l10n.previewDraftOnly
                          : context.l10n.memoryLoadError,
                      textAlign: TextAlign.center,
                    ),
                    if (snapshot.error is! CapsuleLockedException) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          final memory = _load();
                          setState(() {
                            _memory = memory;
                          });
                        },
                        child: Text(context.l10n.memoryRetry),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          final memory = snapshot.data;
          if (memory == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.previewDraftHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                CapsuleMemoryView(
                  key: ValueKey(memory.item.id),
                  item: memory.item,
                  index: memory.index,
                  preview: true,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
