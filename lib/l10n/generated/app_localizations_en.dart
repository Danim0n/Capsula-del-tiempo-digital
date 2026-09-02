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
  String get previewMemory => 'Preview';

  @override
  String get previewContent => 'Check your memories';

  @override
  String get previewMemoryHint => 'Tap a memory to view or play it.';

  @override
  String get previewDraftHint =>
      'You are previewing a draft. Go back to continue preparing your capsule without changing its contents.';

  @override
  String get previewDraftOnly =>
      'Preview is only available before the capsule is sealed.';

  @override
  String get previewImageHint => 'Spread two fingers on the photo to zoom in.';

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
  String get recordingTitle => 'Record audio';

  @override
  String get recordingReady => 'Ready to start';

  @override
  String get recordingActive => 'Recording…';

  @override
  String get recordingPaused => 'Recording paused';

  @override
  String get recordingInterrupted => 'Recording interrupted';

  @override
  String get recordingStart => 'Start recording';

  @override
  String get recordingPause => 'Pause recording';

  @override
  String get recordingResume => 'Resume recording';

  @override
  String get recordingStop => 'Stop and save';

  @override
  String get recordingHint =>
      'Tap the microphone to start. You can pause and resume; stopping adds the audio to your capsule.';

  @override
  String get recordingPermission =>
      'Allow microphone access to record. If you blocked it, enable it in your device settings.';

  @override
  String get recordingError =>
      'The recording could not be completed. Check the microphone and available storage. You can try again or cancel.';

  @override
  String get recordingMeterError =>
      'The sound level cannot be displayed. Recording can continue.';

  @override
  String get recordingDiscardQuestion => 'Discard this recording?';

  @override
  String get recordingDiscardHint =>
      'The audio will not be added to the capsule. To keep it, go back and tap stop.';

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

  @override
  String get nearbyTitle => 'Nearby transfer';

  @override
  String get nearbySend => 'Send to someone nearby';

  @override
  String get nearbyReceive => 'Receive capsule';

  @override
  String get nearbyIntro =>
      'Share a capsule with a nearby Android, without Internet or cloud storage. Both phones need this version of the app open, with Wi-Fi and Bluetooth enabled. Older Android versions may also need location enabled.';

  @override
  String get nearbyPrivacy =>
      'Only the selected capsule, its contents and cover are sent. The copy keeps the opening date and takes up space on both phones. Later changes are not synced.';

  @override
  String get nearbyUnsupported =>
      'Nearby transfer is available between Android phones with Google Play services. You can still use the existing export on supported platforms.';

  @override
  String get nearbyExport => 'Existing export and backups';

  @override
  String get nearbyName => 'Your name for this connection';

  @override
  String get nearbyChoose => 'Choose a sealed capsule';

  @override
  String get nearbyEmpty =>
      'There are no sealed capsules to send yet. You can still receive one.';

  @override
  String get nearbyDiscovering =>
      'Looking for phones… Tap “Receive capsule” on the other phone.';

  @override
  String get nearbyWaiting =>
      'Ready to receive. On the other phone choose a capsule and tap “Send to someone nearby”.';

  @override
  String get nearbyConnecting => 'Connecting to the other phone…';

  @override
  String get nearbyPairing => 'Compare the code';

  @override
  String get nearbyCodeHint =>
      'Confirm only if the same code appears on the other phone and you recognize the person.';

  @override
  String get nearbyConfirm => 'The code matches';

  @override
  String get nearbyPreparing => 'Preparing an encrypted copy…';

  @override
  String get nearbyAwaitingOffer => 'Connected. Waiting for the capsule…';

  @override
  String get nearbyAwaitingAccept =>
      'Waiting for the other person to accept the capsule…';

  @override
  String get nearbyAcceptTitle => 'Save this capsule?';

  @override
  String get nearbyAcceptHint =>
      'It will be added to your capsules without replacing existing ones. Only accept content from someone you trust.';

  @override
  String get nearbySending => 'Sending capsule…';

  @override
  String get nearbyReceiving => 'Receiving capsule…';

  @override
  String get nearbyImporting => 'Verifying and saving the capsule…';

  @override
  String get nearbyAwaitingSave =>
      'Transfer complete. Waiting for save confirmation…';

  @override
  String get nearbySent => 'The other person has saved the capsule.';

  @override
  String get nearbySaved => 'Capsule received and added to “My capsules”.';

  @override
  String get nearbyNotificationWarning =>
      'The capsule was saved, but its reminder could not be scheduled. Check notification permissions.';

  @override
  String get nearbyKeepOpen =>
      'Keep both phones nearby and this screen open until finished. Maximum: 1 GB per capsule.';

  @override
  String get nearbyError =>
      'The transfer did not complete. Check permissions, Wi-Fi, Bluetooth and free space on both phones. Reopen this screen to try again.';

  @override
  String get nearbyPermission =>
      'Nearby devices permissions are required (and location on older Android). You can grant them in your phone settings.';

  @override
  String get nearbyPlayServices =>
      'This phone needs available, up-to-date Google Play services for nearby transfer.';

  @override
  String get nearbySpace =>
      'There is not enough free storage. Receiving needs extra temporary space to verify and encrypt the files.';

  @override
  String get nearbyTooLarge =>
      'The capsule exceeds the 1 GB limit for nearby transfers.';

  @override
  String get nearbyDuplicate =>
      'This phone already has this capsule. It was not overwritten or duplicated.';

  @override
  String get nearbyDeclined =>
      'The connection or capsule was declined. The capsule was not sent.';

  @override
  String get nearbyDisconnected =>
      'The connection was interrupted. If the transfer had finished, check “My capsules” on the receiving phone before retrying.';

  @override
  String get nearbyTimeout =>
      'The session timed out. Check both phones and try again.';

  @override
  String get nearbyBack => 'Back to my capsules';

  @override
  String get chooseCapsuleKind =>
      'What kind of capsule would you like to create?';

  @override
  String get standardCapsule => 'Time capsule';

  @override
  String get standardCapsuleHint =>
      'The original capsule: save your memories and browse all its contents when it opens.';

  @override
  String get personalizedCapsule => 'Personalized time capsule';

  @override
  String get personalizedCapsuleHint =>
      'Build a story with photos, audio, text and videos. Discover it one memory at a time, in the order you choose.';

  @override
  String get sequenceHeading => 'Build your story';

  @override
  String get sequenceHint =>
      'Tap + to add the first memory. Then keep adding below it. They will appear in this same order when the capsule opens.';

  @override
  String get sequenceAdd => 'Add a memory';

  @override
  String get sequenceDetails => 'Continue to details';

  @override
  String get sequencePrevious => 'Previous';

  @override
  String get sequenceFinish => 'Finish';

  @override
  String get sequenceEmpty => 'This capsule has no memories.';

  @override
  String sequencePosition(int current, int total) {
    return '$current of $total';
  }

  @override
  String get memoryLoadError =>
      'This memory could not be opened. You can continue to the next one.';

  @override
  String get videoPlaybackError =>
      'This video cannot be played. Check that the file is complete and its format is supported on your device (for example, MP4 with H.264).';

  @override
  String get memoryRetry => 'Retry';

  @override
  String get mediaPlay => 'Play';

  @override
  String get mediaPause => 'Pause';
}
