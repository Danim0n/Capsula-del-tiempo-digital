// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Digital Time Capsule';

  @override
  String get home => 'Home';

  @override
  String get myCapsules => 'My capsules';

  @override
  String get settings => 'Settings';

  @override
  String get heroTitle => 'Time\nCapsule';

  @override
  String get heroSubtitle =>
      'Save today what the future\nwill make you smile about.';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get text => 'Text';

  @override
  String get createCapsule => 'Create capsule';

  @override
  String get createCapsuleSubtitle =>
      'Choose content and a future date\nto open your capsule.';

  @override
  String get nextOpenings => 'Upcoming openings';

  @override
  String get viewAll => 'View all';

  @override
  String get chooseDuration => 'Choose duration';

  @override
  String get oneYear => '1 year';

  @override
  String get fiveYears => '5 years';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get emptyCapsules => 'Your first capsule starts here';

  @override
  String get emptyCapsulesBody =>
      'Save a memory and choose when to find it again.';

  @override
  String get search => 'Search by title or category';

  @override
  String get all => 'All';

  @override
  String get closed => 'Closed';

  @override
  String get ready => 'Ready';

  @override
  String get opened => 'Opened';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memories',
      one: '1 memory',
    );
    return '$_temp0';
  }

  @override
  String unlockOn(Object date) {
    return 'Opens: $date';
  }

  @override
  String get general => 'GENERAL';

  @override
  String get privacySecurity => 'PRIVACY & SECURITY';

  @override
  String get data => 'DATA';

  @override
  String get application => 'APPLICATION';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get trash => 'Trash';

  @override
  String get backups => 'Backups';

  @override
  String get storageUsage => 'Storage usage';

  @override
  String get repeatTutorial => 'Repeat tutorial';

  @override
  String get about => 'About';

  @override
  String get version => 'Version 0.1.0';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get saveMoment => 'Save a moment';

  @override
  String get saveMomentBody =>
      'Photos, videos, audio and words you want to preserve.';

  @override
  String get chooseWhen => 'Choose when to see it again';

  @override
  String get chooseWhenBody => 'You decide when each capsule will open.';

  @override
  String get onlyDevice => 'Only on your device';

  @override
  String get onlyDeviceBody =>
      'Your memories stay locally stored and protected.';

  @override
  String get futureSelf => 'For your future self';

  @override
  String get futureSelfBody =>
      'If you change phones, make a backup before uninstalling the app.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get start => 'Create my first capsule';

  @override
  String get whatToSave => 'What do you want to save?';

  @override
  String get addContent => 'Add one or more memories';

  @override
  String get nameStep => 'Give it a name';

  @override
  String get whenStep => 'When do you want to open it?';

  @override
  String get reviewStep => 'Review your capsule';

  @override
  String get title => 'Title';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get category => 'Category';

  @override
  String get customCategoryName => 'Category name';

  @override
  String get cover => 'Cover';

  @override
  String get customCover => 'Your photo';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addVideo => 'Add video';

  @override
  String get addAudio => 'Add audio';

  @override
  String get addText => 'Add text';

  @override
  String get camera => 'Camera';

  @override
  String get importLabel => 'Import';

  @override
  String get record => 'Record';

  @override
  String get write => 'Write';

  @override
  String get textTitleOptional => 'Text title (optional)';

  @override
  String get textBody => 'Write your memory';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get quickOneMonth => '1 month';

  @override
  String get quickSixMonths => '6 months';

  @override
  String get quickOneYear => '1 year';

  @override
  String get quickFiveYears => '5 years';

  @override
  String get includeExactTime => 'Choose an exact time';

  @override
  String get sealCapsule => 'Seal capsule';

  @override
  String get sealQuestion => 'Seal this capsule?';

  @override
  String get sealWarning =>
      'After this moment you cannot change its contents or opening date.';

  @override
  String get sealForFuture => 'Seal for the future';

  @override
  String get sealedSuccess => 'The capsule is now sealed.';

  @override
  String get sealedMessage => 'This capsule remains sealed.';

  @override
  String get readyMessage => 'The moment has arrived.';

  @override
  String get openCapsule => 'Open capsule';

  @override
  String get opening => 'Opening your capsule…';

  @override
  String get skipAnimation => 'Skip animation';

  @override
  String get share => 'Share';

  @override
  String get saveToDevice => 'Save to device';

  @override
  String get copy => 'Copy';

  @override
  String get delete => 'Delete';

  @override
  String get deleteQuestion => 'Move this capsule to trash?';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get deleteForeverQuestion =>
      'This action cannot be undone. Do you want to permanently delete this capsule?';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get notificationOpening => 'Opening notification';

  @override
  String get reminderDay => 'Reminder 1 day before';

  @override
  String get reminderWeek => 'Reminder 1 week before';

  @override
  String get createBackup => 'Create backup';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupPasswordHint =>
      'You will need it to restore the backup on another device.';

  @override
  String get backupWarning =>
      'If you uninstall without a backup, your capsules may be lost.';

  @override
  String get backupCreated => 'Backup created.';

  @override
  String get backupError =>
      'The backup is damaged or the password is incorrect.';

  @override
  String get replaceWarning => 'Restoring will replace all current data.';

  @override
  String storageTotal(Object size) {
    return 'Stored content: $size';
  }

  @override
  String get images => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get audios => 'Audio';

  @override
  String get other => 'Other';

  @override
  String get newCategory => 'New category';

  @override
  String get rename => 'Rename';

  @override
  String get categoryInUse => 'A category in use cannot be deleted.';

  @override
  String get noContentError => 'Add at least one memory.';

  @override
  String get titleError => 'Enter a title.';

  @override
  String get customCategoryError => 'Enter a name for the custom category.';

  @override
  String get dateError => 'Choose a future date.';

  @override
  String get importError => 'The file could not be imported.';

  @override
  String get working => 'Protecting content…';

  @override
  String get sort => 'Sort';

  @override
  String get sortNext => 'Next opening';

  @override
  String get sortRecent => 'Most recent';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortName => 'Name A-Z';

  @override
  String get personal => 'Personal';

  @override
  String get family => 'Family';

  @override
  String get couple => 'Partner';

  @override
  String get friends => 'Friends';

  @override
  String get travel => 'Travel';

  @override
  String get goals => 'Goals';

  @override
  String get celebrations => 'Celebrations';

  @override
  String get others => 'Custom';

  @override
  String get tutorialSampleText => 'Test capsule';

  @override
  String get tutorialHomeTitle => 'Create your first capsule';

  @override
  String get tutorialHomeBody =>
      'We will start with a text capsule. The app will add sample text so you can learn the complete process. Tap to continue.';

  @override
  String get tutorialTextTitle => 'A memory in words';

  @override
  String get tutorialTextBody =>
      'The tutorial added “Test capsule” as its title and content. Outside the tutorial you can write as many memories as you like.';

  @override
  String get tutorialCategoryTitle => 'Organize your memories';

  @override
  String get tutorialCategoryBody =>
      'Choose an existing category or select Custom to enter a new category of your own.';

  @override
  String get tutorialCoversTitle => 'Choose a cover';

  @override
  String get tutorialCoversBody =>
      'Choose a cover or tap “Your photo” to use an image from the camera or gallery.';

  @override
  String get tutorialQuickDatesTitle => 'Quick dates';

  @override
  String get tutorialQuickDatesBody =>
      'Use these options to schedule opening in one month, six months, one year or five years.';

  @override
  String get tutorialDateTitle => 'A specific date';

  @override
  String get tutorialDateBody =>
      'You can also open the calendar and choose the exact day when the capsule can be opened.';

  @override
  String get tutorialTimeTitle => 'Choose the time too';

  @override
  String get tutorialTimeBody =>
      'Enable this option if you want to set an exact time as well as the opening day.';

  @override
  String get tutorialSealTitle => 'Seal the capsule';

  @override
  String get tutorialSealBody =>
      'Once sealed, its content and date are protected and cannot be changed. Tap to see the confirmation.';

  @override
  String get tutorialCapsulesTitle => 'All your capsules';

  @override
  String get tutorialCapsulesBody =>
      'My capsules is where you can find, search and filter every capsule you create.';

  @override
  String get tutorialComplete =>
      'Tutorial complete. You can repeat it at any time from Settings.';
}
