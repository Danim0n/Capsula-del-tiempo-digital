import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';

/// Only mounts the current memory so leaving a page disposes its media player.
class CapsuleSequenceViewer extends StatefulWidget {
  const CapsuleSequenceViewer({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onFinished,
    this.description,
  });
  final List<CapsuleItem> items;
  final Widget Function(CapsuleItem item, int index) itemBuilder;
  final VoidCallback onFinished;
  final String? description;

  @override
  State<CapsuleSequenceViewer> createState() => _CapsuleSequenceViewerState();
}

class _CapsuleSequenceViewerState extends State<CapsuleSequenceViewer> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant CapsuleSequenceViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.items.length) _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(child: Text(context.l10n.sequenceEmpty));
    }
    final item = widget.items[_index];
    final last = _index == widget.items.length - 1;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            children: [
              Text(
                context.l10n.sequencePosition(_index + 1, widget.items.length),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (_index + 1) / widget.items.length,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey('memory-scroll-${item.id}'),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_index == 0 && widget.description?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(widget.description!),
                  ),
                KeyedSubtree(
                  key: ValueKey(item.id),
                  child: widget.itemBuilder(item, _index),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              children: [
                IconButton.filledTonal(
                  key: const ValueKey('sequence-previous'),
                  tooltip: context.l10n.sequencePrevious,
                  onPressed: _index == 0
                      ? null
                      : () => setState(() => _index--),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('sequence-continue'),
                    onPressed: last
                        ? widget.onFinished
                        : () => setState(() => _index++),
                    icon: Icon(
                      last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      last
                          ? context.l10n.sequenceFinish
                          : context.l10n.continueLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
