import 'package:capsula_del_tiempo_digital/core/settings/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('tutorial is shown once and can be enabled again', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await AppPreferencesController.load();

    expect(preferences.value.tutorialComplete, isFalse);

    await preferences.completeTutorial();
    expect(preferences.value.tutorialComplete, isTrue);

    await preferences.completeTutorial(false);
    expect(preferences.value.tutorialComplete, isFalse);
  });
}
