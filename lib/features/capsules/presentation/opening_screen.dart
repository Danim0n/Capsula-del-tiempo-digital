import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/navigation/app_navigation.dart';
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
  bool _loaded = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)..addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
  }

  void _finish() {
    if (!mounted || _finished) return;
    _finished = true;
    context.pushReplacement('/capsule/${widget.capsuleId}/content');
  }

  void _startAnimation(LottieComposition composition) {
    if (_loaded) return;
    setState(() => _loaded = true);
    _controller
      ..duration = composition.duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
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
                      width: 430,
                      height: 430,
                      child: Lottie.asset(
                        'assets/animations/giftbox_open.lottie',
                        controller: _controller,
                        decoder: _decodeDotLottie,
                        fit: BoxFit.cover,
                        repeat: false,
                        frameRate: FrameRate.max,
                        onLoaded: _startAnimation,
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
                left: 6,
                top: 4,
                child: const AppBackButton(fallbackLocation: '/capsules'),
              ),
              Positioned(
                right: 14,
                top: 8,
                child: TextButton(
                  onPressed: _loaded && value > .12 ? _finish : null,
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

Future<LottieComposition?> _decodeDotLottie(List<int> bytes) =>
    LottieComposition.decodeZip(
      bytes,
      filePicker:
          (files) => files.firstWhere(
            (file) =>
                file.name.startsWith('animations/') &&
                file.name.endsWith('.json'),
          ),
    );
