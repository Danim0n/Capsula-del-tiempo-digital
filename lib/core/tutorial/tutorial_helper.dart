import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../app/theme/app_theme.dart';

TargetFocus tutorialTarget({
  required String id,
  required GlobalKey key,
  required String title,
  required String body,
  ContentAlign align = ContentAlign.bottom,
  ShapeLightFocus shape = ShapeLightFocus.RRect,
}) => TargetFocus(
  identify: id,
  keyTarget: key,
  shape: shape,
  radius: 18,
  paddingFocus: 8,
  enableOverlayTab: true,
  enableTargetTab: true,
  contents: [
    TargetContent(
      align: align,
      child: _TutorialMessage(title: title, body: body),
    ),
  ],
);

void showTutorial({
  required BuildContext context,
  required List<TargetFocus> targets,
  required String skipLabel,
  required VoidCallback onFinish,
  required Future<void> Function() onSkip,
}) {
  TutorialCoachMark(
    targets: targets,
    colorShadow: AppColors.ink,
    opacityShadow: .88,
    textSkip: skipLabel,
    textStyleSkip: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    paddingFocus: 8,
    useSafeArea: true,
    showSkipInLastTarget: true,
    onFinish: onFinish,
    onSkip: () {
      unawaited(onSkip());
      return true;
    },
  ).show(context: context, rootOverlay: true);
}

class _TutorialMessage extends StatelessWidget {
  const _TutorialMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 420),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'CormorantGaramond',
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}
