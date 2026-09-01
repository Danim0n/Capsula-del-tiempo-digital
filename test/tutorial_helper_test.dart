import 'package:capsula_del_tiempo_digital/core/tutorial/tutorial_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() {
  testWidgets('reveals an off-screen tutorial target before highlighting it', (
    tester,
  ) async {
    final targetKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 900),
                  SizedBox(
                    key: targetKey,
                    height: 60,
                    child: const Text('Objetivo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(targetKey)).dy, greaterThan(300));

    final reveal = revealTutorialTarget(
      TargetFocus(identify: 'target', keyTarget: targetKey),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await reveal;

    final targetTop = tester.getTopLeft(find.byKey(targetKey)).dy;
    expect(targetTop, inInclusiveRange(0, 300));
  });
}
