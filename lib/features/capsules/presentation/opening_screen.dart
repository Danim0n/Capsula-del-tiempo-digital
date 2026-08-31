import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/l10n.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key, required this.capsuleId});
  final String capsuleId;
  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 3100), _finish);
  }

  void _finish() {
    if (mounted) context.go('/capsule/${widget.capsuleId}/content');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = Curves.easeInOutCubic.transform(_controller.value);
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(0, -55 * value),
                            child: Transform.rotate(
                              angle: -.08 * value,
                              child: Container(
                                width: 195,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: AppColors.paleSage,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.ink.withValues(alpha: .15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            child: Container(
                              width: 220,
                              height: 125,
                              decoration: BoxDecoration(
                                color: AppColors.sage,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x18000000),
                                    blurRadius: 22,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 76,
                            child: Transform.scale(
                              scale: 1 - .18 * value,
                              child: Icon(
                                value > .52
                                    ? Icons.lock_open_rounded
                                    : Icons.lock_rounded,
                                size: 46,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: ((value - .55) / .45).clamp(0, 1),
                      child: Text(
                        context.l10n.opening,
                        style: emotionalTitle(context, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 14,
                top: 8,
                child: TextButton(
                  onPressed: _controller.value > .12 ? _finish : null,
                  child: Text(context.l10n.skipAnimation),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
