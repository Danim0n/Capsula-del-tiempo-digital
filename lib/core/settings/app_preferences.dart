import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  const AppPreferences({
    this.locale = const Locale('es'),
    this.tutorialComplete = false,
    this.openingNotifications = true,
    this.dayReminder = false,
    this.weekReminder = false,
  });

  final Locale locale;
  final bool tutorialComplete;
  final bool openingNotifications;
  final bool dayReminder;
  final bool weekReminder;

  AppPreferences copyWith({
    Locale? locale,
    bool? tutorialComplete,
    bool? openingNotifications,
    bool? dayReminder,
    bool? weekReminder,
  }) => AppPreferences(
    locale: locale ?? this.locale,
    tutorialComplete: tutorialComplete ?? this.tutorialComplete,
    openingNotifications: openingNotifications ?? this.openingNotifications,
    dayReminder: dayReminder ?? this.dayReminder,
    weekReminder: weekReminder ?? this.weekReminder,
  );
}

class AppPreferencesController extends ChangeNotifier {
  AppPreferencesController(this._storage, this.value);

  final SharedPreferences _storage;
  AppPreferences value;

  static Future<AppPreferencesController> load() async {
    final storage = await SharedPreferences.getInstance();
    return AppPreferencesController(
      storage,
      AppPreferences(
        locale: Locale(storage.getString('locale') ?? 'es'),
        tutorialComplete: storage.getBool('tutorialComplete') ?? false,
        openingNotifications: storage.getBool('openingNotifications') ?? true,
        dayReminder: storage.getBool('dayReminder') ?? false,
        weekReminder: storage.getBool('weekReminder') ?? false,
      ),
    );
  }

  Future<void> setLocale(Locale locale) async {
    value = value.copyWith(locale: locale);
    await _storage.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> completeTutorial([bool complete = true]) async {
    value = value.copyWith(tutorialComplete: complete);
    await _storage.setBool('tutorialComplete', complete);
    notifyListeners();
  }

  Future<void> setNotifications({bool? opening, bool? day, bool? week}) async {
    value = value.copyWith(
      openingNotifications: opening,
      dayReminder: day,
      weekReminder: week,
    );
    await _storage.setBool('openingNotifications', value.openingNotifications);
    await _storage.setBool('dayReminder', value.dayReminder);
    await _storage.setBool('weekReminder', value.weekReminder);
    notifyListeners();
  }
}
