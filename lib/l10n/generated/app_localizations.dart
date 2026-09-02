import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Cápsula del Tiempo Digital'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @myCapsules.
  ///
  /// In es, this message translates to:
  /// **'Mis cápsulas'**
  String get myCapsules;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @heroTitle.
  ///
  /// In es, this message translates to:
  /// **'Cápsula\ndel Tiempo'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Guarda hoy lo que el futuro\nte hará sonreír.'**
  String get heroSubtitle;

  /// No description provided for @photo.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In es, this message translates to:
  /// **'Vídeo'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In es, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @text.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get text;

  /// No description provided for @createCapsule.
  ///
  /// In es, this message translates to:
  /// **'Crear cápsula'**
  String get createCapsule;

  /// No description provided for @createCapsuleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige contenido y una fecha futura\npara abrir tu cápsula.'**
  String get createCapsuleSubtitle;

  /// No description provided for @nextOpenings.
  ///
  /// In es, this message translates to:
  /// **'Próximas aperturas'**
  String get nextOpenings;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get viewAll;

  /// No description provided for @chooseDuration.
  ///
  /// In es, this message translates to:
  /// **'Elegir duración'**
  String get chooseDuration;

  /// No description provided for @oneYear.
  ///
  /// In es, this message translates to:
  /// **'1 año'**
  String get oneYear;

  /// No description provided for @fiveYears.
  ///
  /// In es, this message translates to:
  /// **'5 años'**
  String get fiveYears;

  /// No description provided for @chooseDate.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get chooseDate;

  /// No description provided for @emptyCapsules.
  ///
  /// In es, this message translates to:
  /// **'Tu primera cápsula empieza aquí'**
  String get emptyCapsules;

  /// No description provided for @emptyCapsulesBody.
  ///
  /// In es, this message translates to:
  /// **'Guarda un recuerdo y elige cuándo volver a encontrarlo.'**
  String get emptyCapsulesBody;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar por título o categoría'**
  String get search;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @closed.
  ///
  /// In es, this message translates to:
  /// **'Cerradas'**
  String get closed;

  /// No description provided for @ready.
  ///
  /// In es, this message translates to:
  /// **'Listas'**
  String get ready;

  /// No description provided for @opened.
  ///
  /// In es, this message translates to:
  /// **'Abiertas'**
  String get opened;

  /// No description provided for @itemsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 recuerdo} other{{count} recuerdos}}'**
  String itemsCount(num count);

  /// No description provided for @unlockOn.
  ///
  /// In es, this message translates to:
  /// **'Apertura: {date}'**
  String unlockOn(Object date);

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @privacySecurity.
  ///
  /// In es, this message translates to:
  /// **'PRIVACIDAD Y SEGURIDAD'**
  String get privacySecurity;

  /// No description provided for @data.
  ///
  /// In es, this message translates to:
  /// **'DATOS'**
  String get data;

  /// No description provided for @application.
  ///
  /// In es, this message translates to:
  /// **'APLICACIÓN'**
  String get application;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @manageCategories.
  ///
  /// In es, this message translates to:
  /// **'Gestionar categorías'**
  String get manageCategories;

  /// No description provided for @trash.
  ///
  /// In es, this message translates to:
  /// **'Papelera'**
  String get trash;

  /// No description provided for @backups.
  ///
  /// In es, this message translates to:
  /// **'Copias de seguridad'**
  String get backups;

  /// No description provided for @storageUsage.
  ///
  /// In es, this message translates to:
  /// **'Uso de almacenamiento'**
  String get storageUsage;

  /// No description provided for @repeatTutorial.
  ///
  /// In es, this message translates to:
  /// **'Repetir tutorial'**
  String get repeatTutorial;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión 0.1.0'**
  String get version;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @saveMoment.
  ///
  /// In es, this message translates to:
  /// **'Guarda un momento'**
  String get saveMoment;

  /// No description provided for @saveMomentBody.
  ///
  /// In es, this message translates to:
  /// **'Fotos, vídeos, audios y palabras que quieras conservar.'**
  String get saveMomentBody;

  /// No description provided for @chooseWhen.
  ///
  /// In es, this message translates to:
  /// **'Elige cuándo volver a verlo'**
  String get chooseWhen;

  /// No description provided for @chooseWhenBody.
  ///
  /// In es, this message translates to:
  /// **'Tú decides cuándo se abrirá cada cápsula.'**
  String get chooseWhenBody;

  /// No description provided for @onlyDevice.
  ///
  /// In es, this message translates to:
  /// **'Solo en tu dispositivo'**
  String get onlyDevice;

  /// No description provided for @onlyDeviceBody.
  ///
  /// In es, this message translates to:
  /// **'Tus recuerdos permanecen almacenados localmente y protegidos.'**
  String get onlyDeviceBody;

  /// No description provided for @futureSelf.
  ///
  /// In es, this message translates to:
  /// **'Para tu yo del futuro'**
  String get futureSelf;

  /// No description provided for @futureSelfBody.
  ///
  /// In es, this message translates to:
  /// **'Si cambias de móvil, crea una copia antes de desinstalar la aplicación.'**
  String get futureSelfBody;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get skip;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Crear mi primera cápsula'**
  String get start;

  /// No description provided for @whatToSave.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres guardar?'**
  String get whatToSave;

  /// No description provided for @addContent.
  ///
  /// In es, this message translates to:
  /// **'Añade uno o varios recuerdos'**
  String get addContent;

  /// No description provided for @nameStep.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre'**
  String get nameStep;

  /// No description provided for @whenStep.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo quieres abrirla?'**
  String get whenStep;

  /// No description provided for @reviewStep.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu cápsula'**
  String get reviewStep;

  /// No description provided for @previewMemory.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get previewMemory;

  /// No description provided for @previewContent.
  ///
  /// In es, this message translates to:
  /// **'Comprueba tus recuerdos'**
  String get previewContent;

  /// No description provided for @previewMemoryHint.
  ///
  /// In es, this message translates to:
  /// **'Toca un recuerdo para verlo o reproducirlo.'**
  String get previewMemoryHint;

  /// No description provided for @previewDraftHint.
  ///
  /// In es, this message translates to:
  /// **'Estás viendo un borrador. Puedes volver para seguir preparando tu cápsula sin cambiar su contenido.'**
  String get previewDraftHint;

  /// No description provided for @previewDraftOnly.
  ///
  /// In es, this message translates to:
  /// **'La vista previa solo está disponible antes de sellar la cápsula.'**
  String get previewDraftOnly;

  /// No description provided for @previewImageHint.
  ///
  /// In es, this message translates to:
  /// **'Separa dos dedos sobre la foto para ampliarla.'**
  String get previewImageHint;

  /// No description provided for @title.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @descriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descriptionOptional;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @customCategoryName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la categoría'**
  String get customCategoryName;

  /// No description provided for @cover.
  ///
  /// In es, this message translates to:
  /// **'Portada'**
  String get cover;

  /// No description provided for @customCover.
  ///
  /// In es, this message translates to:
  /// **'Tu foto'**
  String get customCover;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @addPhoto.
  ///
  /// In es, this message translates to:
  /// **'Añadir foto'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In es, this message translates to:
  /// **'Añadir vídeo'**
  String get addVideo;

  /// No description provided for @addAudio.
  ///
  /// In es, this message translates to:
  /// **'Añadir audio'**
  String get addAudio;

  /// No description provided for @addText.
  ///
  /// In es, this message translates to:
  /// **'Añadir texto'**
  String get addText;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @importLabel.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get importLabel;

  /// No description provided for @record.
  ///
  /// In es, this message translates to:
  /// **'Grabar'**
  String get record;

  /// No description provided for @recordingTitle.
  ///
  /// In es, this message translates to:
  /// **'Grabar audio'**
  String get recordingTitle;

  /// No description provided for @recordingReady.
  ///
  /// In es, this message translates to:
  /// **'Listo para empezar'**
  String get recordingReady;

  /// No description provided for @recordingActive.
  ///
  /// In es, this message translates to:
  /// **'Grabando…'**
  String get recordingActive;

  /// No description provided for @recordingPaused.
  ///
  /// In es, this message translates to:
  /// **'Grabación en pausa'**
  String get recordingPaused;

  /// No description provided for @recordingInterrupted.
  ///
  /// In es, this message translates to:
  /// **'Grabación interrumpida'**
  String get recordingInterrupted;

  /// No description provided for @recordingStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar grabación'**
  String get recordingStart;

  /// No description provided for @recordingPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar grabación'**
  String get recordingPause;

  /// No description provided for @recordingResume.
  ///
  /// In es, this message translates to:
  /// **'Continuar grabación'**
  String get recordingResume;

  /// No description provided for @recordingStop.
  ///
  /// In es, this message translates to:
  /// **'Detener y guardar'**
  String get recordingStop;

  /// No description provided for @recordingHint.
  ///
  /// In es, this message translates to:
  /// **'Pulsa el micrófono para empezar. Puedes pausar y continuar; al detener se añade el audio a tu cápsula.'**
  String get recordingHint;

  /// No description provided for @recordingPermission.
  ///
  /// In es, this message translates to:
  /// **'Permite el acceso al micrófono para grabar. Si lo has bloqueado, actívalo en los ajustes de tu dispositivo.'**
  String get recordingPermission;

  /// No description provided for @recordingError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido completar la grabación. Comprueba el micrófono y el espacio disponible. Puedes volver a intentarlo o cancelar.'**
  String get recordingError;

  /// No description provided for @recordingMeterError.
  ///
  /// In es, this message translates to:
  /// **'No se puede mostrar el nivel de sonido. La grabación puede continuar.'**
  String get recordingMeterError;

  /// No description provided for @recordingDiscardQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar esta grabación?'**
  String get recordingDiscardQuestion;

  /// No description provided for @recordingDiscardHint.
  ///
  /// In es, this message translates to:
  /// **'El audio no se añadirá a la cápsula. Si quieres conservarlo, vuelve y pulsa detener.'**
  String get recordingDiscardHint;

  /// No description provided for @write.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get write;

  /// No description provided for @textTitleOptional.
  ///
  /// In es, this message translates to:
  /// **'Título del texto (opcional)'**
  String get textTitleOptional;

  /// No description provided for @textBody.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu recuerdo'**
  String get textBody;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @quickOneMonth.
  ///
  /// In es, this message translates to:
  /// **'1 mes'**
  String get quickOneMonth;

  /// No description provided for @quickSixMonths.
  ///
  /// In es, this message translates to:
  /// **'6 meses'**
  String get quickSixMonths;

  /// No description provided for @quickOneYear.
  ///
  /// In es, this message translates to:
  /// **'1 año'**
  String get quickOneYear;

  /// No description provided for @quickFiveYears.
  ///
  /// In es, this message translates to:
  /// **'5 años'**
  String get quickFiveYears;

  /// No description provided for @includeExactTime.
  ///
  /// In es, this message translates to:
  /// **'Elegir hora exacta'**
  String get includeExactTime;

  /// No description provided for @sealCapsule.
  ///
  /// In es, this message translates to:
  /// **'Sellar cápsula'**
  String get sealCapsule;

  /// No description provided for @sealQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres sellarla?'**
  String get sealQuestion;

  /// No description provided for @sealWarning.
  ///
  /// In es, this message translates to:
  /// **'Después de este momento no podrás modificar el contenido ni cambiar la fecha de apertura.'**
  String get sealWarning;

  /// No description provided for @sealForFuture.
  ///
  /// In es, this message translates to:
  /// **'Sellar para el futuro'**
  String get sealForFuture;

  /// No description provided for @sealedSuccess.
  ///
  /// In es, this message translates to:
  /// **'La cápsula ha quedado sellada.'**
  String get sealedSuccess;

  /// No description provided for @sealedMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta cápsula permanece sellada.'**
  String get sealedMessage;

  /// No description provided for @readyMessage.
  ///
  /// In es, this message translates to:
  /// **'Ha llegado el momento.'**
  String get readyMessage;

  /// No description provided for @openCapsule.
  ///
  /// In es, this message translates to:
  /// **'Abrir cápsula'**
  String get openCapsule;

  /// No description provided for @opening.
  ///
  /// In es, this message translates to:
  /// **'Abriendo tu cápsula…'**
  String get opening;

  /// No description provided for @skipAnimation.
  ///
  /// In es, this message translates to:
  /// **'Saltar animación'**
  String get skipAnimation;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @saveToDevice.
  ///
  /// In es, this message translates to:
  /// **'Guardar en el dispositivo'**
  String get saveToDevice;

  /// No description provided for @copy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Mover esta cápsula a la papelera?'**
  String get deleteQuestion;

  /// No description provided for @restore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In es, this message translates to:
  /// **'Eliminar definitivamente'**
  String get deleteForever;

  /// No description provided for @deleteForeverQuestion.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer. ¿Quieres eliminar definitivamente esta cápsula?'**
  String get deleteForeverQuestion;

  /// No description provided for @trashEmpty.
  ///
  /// In es, this message translates to:
  /// **'La papelera está vacía'**
  String get trashEmpty;

  /// No description provided for @notificationOpening.
  ///
  /// In es, this message translates to:
  /// **'Aviso al llegar la apertura'**
  String get notificationOpening;

  /// No description provided for @reminderDay.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio 1 día antes'**
  String get reminderDay;

  /// No description provided for @reminderWeek.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio 1 semana antes'**
  String get reminderWeek;

  /// No description provided for @createBackup.
  ///
  /// In es, this message translates to:
  /// **'Crear copia de seguridad'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In es, this message translates to:
  /// **'Restaurar copia de seguridad'**
  String get restoreBackup;

  /// No description provided for @backupPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña para la copia'**
  String get backupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'La necesitarás para restaurar la copia en otro dispositivo.'**
  String get backupPasswordHint;

  /// No description provided for @backupWarning.
  ///
  /// In es, this message translates to:
  /// **'Si desinstalas la aplicación sin una copia, tus cápsulas podrían perderse.'**
  String get backupWarning;

  /// No description provided for @backupCreated.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad creada.'**
  String get backupCreated;

  /// No description provided for @backupError.
  ///
  /// In es, this message translates to:
  /// **'La copia está dañada o la contraseña no es correcta.'**
  String get backupError;

  /// No description provided for @replaceWarning.
  ///
  /// In es, this message translates to:
  /// **'La restauración reemplazará todos los datos actuales.'**
  String get replaceWarning;

  /// No description provided for @storageTotal.
  ///
  /// In es, this message translates to:
  /// **'Contenido almacenado: {size}'**
  String storageTotal(Object size);

  /// No description provided for @images.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In es, this message translates to:
  /// **'Vídeos'**
  String get videos;

  /// No description provided for @audios.
  ///
  /// In es, this message translates to:
  /// **'Audio'**
  String get audios;

  /// No description provided for @other.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get other;

  /// No description provided for @newCategory.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get newCategory;

  /// No description provided for @rename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get rename;

  /// No description provided for @categoryInUse.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar una categoría en uso.'**
  String get categoryInUse;

  /// No description provided for @noContentError.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos un recuerdo.'**
  String get noContentError;

  /// No description provided for @titleError.
  ///
  /// In es, this message translates to:
  /// **'Escribe un título.'**
  String get titleError;

  /// No description provided for @customCategoryError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre de la categoría personalizada.'**
  String get customCategoryError;

  /// No description provided for @dateError.
  ///
  /// In es, this message translates to:
  /// **'Elige una fecha futura.'**
  String get dateError;

  /// No description provided for @importError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo importar el archivo.'**
  String get importError;

  /// No description provided for @working.
  ///
  /// In es, this message translates to:
  /// **'Protegiendo el contenido…'**
  String get working;

  /// No description provided for @sort.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// No description provided for @sortNext.
  ///
  /// In es, this message translates to:
  /// **'Próxima apertura'**
  String get sortNext;

  /// No description provided for @sortRecent.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get sortRecent;

  /// No description provided for @sortOldest.
  ///
  /// In es, this message translates to:
  /// **'Más antiguas'**
  String get sortOldest;

  /// No description provided for @sortName.
  ///
  /// In es, this message translates to:
  /// **'Nombre A-Z'**
  String get sortName;

  /// No description provided for @personal.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @family.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get family;

  /// No description provided for @couple.
  ///
  /// In es, this message translates to:
  /// **'Pareja'**
  String get couple;

  /// No description provided for @friends.
  ///
  /// In es, this message translates to:
  /// **'Amigos'**
  String get friends;

  /// No description provided for @travel.
  ///
  /// In es, this message translates to:
  /// **'Viajes'**
  String get travel;

  /// No description provided for @goals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get goals;

  /// No description provided for @celebrations.
  ///
  /// In es, this message translates to:
  /// **'Celebraciones'**
  String get celebrations;

  /// No description provided for @others.
  ///
  /// In es, this message translates to:
  /// **'Personalizada'**
  String get others;

  /// No description provided for @tutorialSampleText.
  ///
  /// In es, this message translates to:
  /// **'Prueba de cápsula'**
  String get tutorialSampleText;

  /// No description provided for @tutorialHomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera cápsula'**
  String get tutorialHomeTitle;

  /// No description provided for @tutorialHomeBody.
  ///
  /// In es, this message translates to:
  /// **'Empezaremos con una cápsula de texto. La aplicación añadirá un texto de prueba para que puedas conocer todo el proceso. Toca para continuar.'**
  String get tutorialHomeBody;

  /// No description provided for @tutorialTextTitle.
  ///
  /// In es, this message translates to:
  /// **'Un recuerdo en palabras'**
  String get tutorialTextTitle;

  /// No description provided for @tutorialTextBody.
  ///
  /// In es, this message translates to:
  /// **'El tutorial ha añadido «Prueba de cápsula» como título y contenido. Fuera del tutorial puedes escribir tantos recuerdos como quieras.'**
  String get tutorialTextBody;

  /// No description provided for @tutorialCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza tus recuerdos'**
  String get tutorialCategoryTitle;

  /// No description provided for @tutorialCategoryBody.
  ///
  /// In es, this message translates to:
  /// **'Elige una categoría existente o selecciona Personalizada para escribir una nueva categoría propia.'**
  String get tutorialCategoryBody;

  /// No description provided for @tutorialCoversTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una portada'**
  String get tutorialCoversTitle;

  /// No description provided for @tutorialCoversBody.
  ///
  /// In es, this message translates to:
  /// **'Elige una portada o toca «Tu foto» para usar una imagen de la cámara o la galería.'**
  String get tutorialCoversBody;

  /// No description provided for @tutorialQuickDatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Fechas rápidas'**
  String get tutorialQuickDatesTitle;

  /// No description provided for @tutorialQuickDatesBody.
  ///
  /// In es, this message translates to:
  /// **'Usa estas opciones para programar la apertura dentro de un mes, seis meses, un año o cinco años.'**
  String get tutorialQuickDatesBody;

  /// No description provided for @tutorialDateTitle.
  ///
  /// In es, this message translates to:
  /// **'Una fecha concreta'**
  String get tutorialDateTitle;

  /// No description provided for @tutorialDateBody.
  ///
  /// In es, this message translates to:
  /// **'También puedes abrir el calendario y elegir exactamente el día en que podrá abrirse la cápsula.'**
  String get tutorialDateBody;

  /// No description provided for @tutorialTimeTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige también la hora'**
  String get tutorialTimeTitle;

  /// No description provided for @tutorialTimeBody.
  ///
  /// In es, this message translates to:
  /// **'Activa esta opción si quieres fijar una hora exacta además del día de apertura.'**
  String get tutorialTimeBody;

  /// No description provided for @tutorialSealTitle.
  ///
  /// In es, this message translates to:
  /// **'Sella la cápsula'**
  String get tutorialSealTitle;

  /// No description provided for @tutorialSealBody.
  ///
  /// In es, this message translates to:
  /// **'Al sellarla, su contenido y fecha quedarán protegidos y ya no podrán modificarse. Toca para ver la confirmación.'**
  String get tutorialSealBody;

  /// No description provided for @tutorialCapsulesTitle.
  ///
  /// In es, this message translates to:
  /// **'Todas tus cápsulas'**
  String get tutorialCapsulesTitle;

  /// No description provided for @tutorialCapsulesBody.
  ///
  /// In es, this message translates to:
  /// **'En Mis cápsulas puedes encontrar, buscar y filtrar las cápsulas que hayas creado.'**
  String get tutorialCapsulesBody;

  /// No description provided for @tutorialComplete.
  ///
  /// In es, this message translates to:
  /// **'Tutorial completado. Puedes repetirlo cuando quieras desde Ajustes.'**
  String get tutorialComplete;

  /// No description provided for @nearbyTitle.
  ///
  /// In es, this message translates to:
  /// **'Transferir cerca'**
  String get nearbyTitle;

  /// No description provided for @nearbySend.
  ///
  /// In es, this message translates to:
  /// **'Enviar a alguien cercano'**
  String get nearbySend;

  /// No description provided for @nearbyReceive.
  ///
  /// In es, this message translates to:
  /// **'Recibir cápsula'**
  String get nearbyReceive;

  /// No description provided for @nearbyIntro.
  ///
  /// In es, this message translates to:
  /// **'Comparte una cápsula con otro Android cercano, sin Internet ni nube. Ambos debéis tener esta versión de la app abierta, Wi-Fi y Bluetooth activados. En Android antiguos puede hacer falta activar la ubicación.'**
  String get nearbyIntro;

  /// No description provided for @nearbyPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Se enviará solo la cápsula elegida, con su contenido y portada. La copia conserva la fecha de apertura y ocupa espacio en ambos móviles. No se sincronizan cambios posteriores.'**
  String get nearbyPrivacy;

  /// No description provided for @nearbyUnsupported.
  ///
  /// In es, this message translates to:
  /// **'La transferencia cercana está disponible entre móviles Android con servicios de Google Play. Puedes seguir usando la exportación habitual en las plataformas compatibles.'**
  String get nearbyUnsupported;

  /// No description provided for @nearbyExport.
  ///
  /// In es, this message translates to:
  /// **'Exportación y copias actuales'**
  String get nearbyExport;

  /// No description provided for @nearbyName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre para esta conexión'**
  String get nearbyName;

  /// No description provided for @nearbyChoose.
  ///
  /// In es, this message translates to:
  /// **'Elige una cápsula sellada'**
  String get nearbyChoose;

  /// No description provided for @nearbyEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cápsulas selladas para enviar. Sí puedes recibir una.'**
  String get nearbyEmpty;

  /// No description provided for @nearbyDiscovering.
  ///
  /// In es, this message translates to:
  /// **'Buscando móviles… En el otro móvil pulsa «Recibir cápsula».'**
  String get nearbyDiscovering;

  /// No description provided for @nearbyWaiting.
  ///
  /// In es, this message translates to:
  /// **'Listo para recibir. En el otro móvil elige una cápsula y pulsa «Enviar a alguien cercano».'**
  String get nearbyWaiting;

  /// No description provided for @nearbyConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando con el otro móvil…'**
  String get nearbyConnecting;

  /// No description provided for @nearbyPairing.
  ///
  /// In es, this message translates to:
  /// **'Comprobad el código'**
  String get nearbyPairing;

  /// No description provided for @nearbyCodeHint.
  ///
  /// In es, this message translates to:
  /// **'Confirma solo si este mismo código aparece en el otro móvil y reconoces a la persona.'**
  String get nearbyCodeHint;

  /// No description provided for @nearbyConfirm.
  ///
  /// In es, this message translates to:
  /// **'El código coincide'**
  String get nearbyConfirm;

  /// No description provided for @nearbyPreparing.
  ///
  /// In es, this message translates to:
  /// **'Preparando una copia cifrada…'**
  String get nearbyPreparing;

  /// No description provided for @nearbyAwaitingOffer.
  ///
  /// In es, this message translates to:
  /// **'Conectados. Esperando la cápsula…'**
  String get nearbyAwaitingOffer;

  /// No description provided for @nearbyAwaitingAccept.
  ///
  /// In es, this message translates to:
  /// **'Esperando que la otra persona acepte la cápsula…'**
  String get nearbyAwaitingAccept;

  /// No description provided for @nearbyAcceptTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Guardar esta cápsula?'**
  String get nearbyAcceptTitle;

  /// No description provided for @nearbyAcceptHint.
  ///
  /// In es, this message translates to:
  /// **'Se añadirá a tus cápsulas sin reemplazar las existentes. Acepta solo contenido de alguien de confianza.'**
  String get nearbyAcceptHint;

  /// No description provided for @nearbySending.
  ///
  /// In es, this message translates to:
  /// **'Enviando cápsula…'**
  String get nearbySending;

  /// No description provided for @nearbyReceiving.
  ///
  /// In es, this message translates to:
  /// **'Recibiendo cápsula…'**
  String get nearbyReceiving;

  /// No description provided for @nearbyImporting.
  ///
  /// In es, this message translates to:
  /// **'Comprobando y guardando la cápsula…'**
  String get nearbyImporting;

  /// No description provided for @nearbyAwaitingSave.
  ///
  /// In es, this message translates to:
  /// **'Envío completado. Esperando confirmación de guardado…'**
  String get nearbyAwaitingSave;

  /// No description provided for @nearbySent.
  ///
  /// In es, this message translates to:
  /// **'La otra persona ha guardado la cápsula.'**
  String get nearbySent;

  /// No description provided for @nearbySaved.
  ///
  /// In es, this message translates to:
  /// **'Cápsula recibida y añadida a «Mis cápsulas».'**
  String get nearbySaved;

  /// No description provided for @nearbyNotificationWarning.
  ///
  /// In es, this message translates to:
  /// **'Se ha guardado la cápsula, pero no se ha podido programar su aviso. Revisa los permisos de notificaciones.'**
  String get nearbyNotificationWarning;

  /// No description provided for @nearbyKeepOpen.
  ///
  /// In es, this message translates to:
  /// **'Mantened ambos móviles cerca y esta pantalla abierta hasta terminar. Máximo: 1 GB por cápsula.'**
  String get nearbyKeepOpen;

  /// No description provided for @nearbyError.
  ///
  /// In es, this message translates to:
  /// **'No se ha completado la transferencia. Comprueba permisos, Wi-Fi, Bluetooth y espacio libre en ambos móviles. Vuelve a abrir esta pantalla para intentarlo de nuevo.'**
  String get nearbyError;

  /// No description provided for @nearbyPermission.
  ///
  /// In es, this message translates to:
  /// **'Se necesitan los permisos de dispositivos cercanos (y ubicación en Android antiguos). Puedes concederlos en los ajustes del móvil.'**
  String get nearbyPermission;

  /// No description provided for @nearbyPlayServices.
  ///
  /// In es, this message translates to:
  /// **'Este móvil necesita servicios de Google Play disponibles y actualizados para transferir cerca.'**
  String get nearbyPlayServices;

  /// No description provided for @nearbySpace.
  ///
  /// In es, this message translates to:
  /// **'No hay espacio libre suficiente. La recepción necesita espacio temporal adicional para comprobar y cifrar los archivos.'**
  String get nearbySpace;

  /// No description provided for @nearbyTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La cápsula supera el límite de 1 GB para transferencias cercanas.'**
  String get nearbyTooLarge;

  /// No description provided for @nearbyDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Este móvil ya tiene esta cápsula. No se ha sobrescrito ni duplicado.'**
  String get nearbyDuplicate;

  /// No description provided for @nearbyDeclined.
  ///
  /// In es, this message translates to:
  /// **'La conexión o la cápsula se ha rechazado. No se ha enviado la cápsula.'**
  String get nearbyDeclined;

  /// No description provided for @nearbyDisconnected.
  ///
  /// In es, this message translates to:
  /// **'La conexión se ha interrumpido. Si el envío ya había terminado, comprueba «Mis cápsulas» en el móvil receptor antes de repetirlo.'**
  String get nearbyDisconnected;

  /// No description provided for @nearbyTimeout.
  ///
  /// In es, this message translates to:
  /// **'Se ha agotado el tiempo de espera. Comprueba los dos móviles e inténtalo de nuevo.'**
  String get nearbyTimeout;

  /// No description provided for @nearbyBack.
  ///
  /// In es, this message translates to:
  /// **'Volver a mis cápsulas'**
  String get nearbyBack;

  /// No description provided for @chooseCapsuleKind.
  ///
  /// In es, this message translates to:
  /// **'¿Qué cápsula quieres crear?'**
  String get chooseCapsuleKind;

  /// No description provided for @standardCapsule.
  ///
  /// In es, this message translates to:
  /// **'Cápsula del tiempo'**
  String get standardCapsule;

  /// No description provided for @standardCapsuleHint.
  ///
  /// In es, this message translates to:
  /// **'La cápsula de siempre: guarda tus recuerdos y descubre todo su contenido al abrirla.'**
  String get standardCapsuleHint;

  /// No description provided for @personalizedCapsule.
  ///
  /// In es, this message translates to:
  /// **'Cápsula del tiempo personalizada'**
  String get personalizedCapsule;

  /// No description provided for @personalizedCapsuleHint.
  ///
  /// In es, this message translates to:
  /// **'Crea una historia con fotos, audios, textos y vídeos. Se descubrirá recuerdo a recuerdo, en el orden que elijas.'**
  String get personalizedCapsuleHint;

  /// No description provided for @sequenceHeading.
  ///
  /// In es, this message translates to:
  /// **'Construye tu historia'**
  String get sequenceHeading;

  /// No description provided for @sequenceHint.
  ///
  /// In es, this message translates to:
  /// **'Pulsa + para añadir el primer recuerdo. Después podrás seguir añadiendo debajo. Al abrirla, se mostrarán en este mismo orden.'**
  String get sequenceHint;

  /// No description provided for @sequenceAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir recuerdo'**
  String get sequenceAdd;

  /// No description provided for @sequenceDetails.
  ///
  /// In es, this message translates to:
  /// **'Continuar con los detalles'**
  String get sequenceDetails;

  /// No description provided for @sequencePrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get sequencePrevious;

  /// No description provided for @sequenceFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get sequenceFinish;

  /// No description provided for @sequenceEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta cápsula no tiene recuerdos.'**
  String get sequenceEmpty;

  /// No description provided for @sequencePosition.
  ///
  /// In es, this message translates to:
  /// **'{current} de {total}'**
  String sequencePosition(int current, int total);

  /// No description provided for @memoryLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido abrir este recuerdo. Puedes continuar con el siguiente.'**
  String get memoryLoadError;

  /// No description provided for @videoPlaybackError.
  ///
  /// In es, this message translates to:
  /// **'No se puede reproducir este vídeo. Comprueba que el archivo está completo y que su formato es compatible con tu dispositivo (por ejemplo, MP4 con H.264).'**
  String get videoPlaybackError;

  /// No description provided for @memoryRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get memoryRetry;

  /// No description provided for @mediaPlay.
  ///
  /// In es, this message translates to:
  /// **'Reproducir'**
  String get mediaPlay;

  /// No description provided for @mediaPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get mediaPause;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
