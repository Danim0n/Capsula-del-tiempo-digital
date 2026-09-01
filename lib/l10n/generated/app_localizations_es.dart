// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Cápsula del Tiempo Digital';

  @override
  String get home => 'Inicio';

  @override
  String get myCapsules => 'Mis cápsulas';

  @override
  String get settings => 'Ajustes';

  @override
  String get heroTitle => 'Cápsula\ndel Tiempo';

  @override
  String get heroSubtitle => 'Guarda hoy lo que el futuro\nte hará sonreír.';

  @override
  String get photo => 'Foto';

  @override
  String get video => 'Vídeo';

  @override
  String get audio => 'Audio';

  @override
  String get text => 'Texto';

  @override
  String get createCapsule => 'Crear cápsula';

  @override
  String get createCapsuleSubtitle =>
      'Elige contenido y una fecha futura\npara abrir tu cápsula.';

  @override
  String get nextOpenings => 'Próximas aperturas';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get chooseDuration => 'Elegir duración';

  @override
  String get oneYear => '1 año';

  @override
  String get fiveYears => '5 años';

  @override
  String get chooseDate => 'Elegir fecha';

  @override
  String get emptyCapsules => 'Tu primera cápsula empieza aquí';

  @override
  String get emptyCapsulesBody =>
      'Guarda un recuerdo y elige cuándo volver a encontrarlo.';

  @override
  String get search => 'Buscar por título o categoría';

  @override
  String get all => 'Todas';

  @override
  String get closed => 'Cerradas';

  @override
  String get ready => 'Listas';

  @override
  String get opened => 'Abiertas';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recuerdos',
      one: '1 recuerdo',
    );
    return '$_temp0';
  }

  @override
  String unlockOn(Object date) {
    return 'Apertura: $date';
  }

  @override
  String get general => 'GENERAL';

  @override
  String get privacySecurity => 'PRIVACIDAD Y SEGURIDAD';

  @override
  String get data => 'DATOS';

  @override
  String get application => 'APLICACIÓN';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get manageCategories => 'Gestionar categorías';

  @override
  String get trash => 'Papelera';

  @override
  String get backups => 'Copias de seguridad';

  @override
  String get storageUsage => 'Uso de almacenamiento';

  @override
  String get repeatTutorial => 'Repetir tutorial';

  @override
  String get about => 'Información';

  @override
  String get version => 'Versión 0.1.0';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get saveMoment => 'Guarda un momento';

  @override
  String get saveMomentBody =>
      'Fotos, vídeos, audios y palabras que quieras conservar.';

  @override
  String get chooseWhen => 'Elige cuándo volver a verlo';

  @override
  String get chooseWhenBody => 'Tú decides cuándo se abrirá cada cápsula.';

  @override
  String get onlyDevice => 'Solo en tu dispositivo';

  @override
  String get onlyDeviceBody =>
      'Tus recuerdos permanecen almacenados localmente y protegidos.';

  @override
  String get futureSelf => 'Para tu yo del futuro';

  @override
  String get futureSelfBody =>
      'Si cambias de móvil, crea una copia antes de desinstalar la aplicación.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get skip => 'Saltar';

  @override
  String get start => 'Crear mi primera cápsula';

  @override
  String get whatToSave => '¿Qué quieres guardar?';

  @override
  String get addContent => 'Añade uno o varios recuerdos';

  @override
  String get nameStep => 'Ponle un nombre';

  @override
  String get whenStep => '¿Cuándo quieres abrirla?';

  @override
  String get reviewStep => 'Revisa tu cápsula';

  @override
  String get title => 'Título';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get category => 'Categoría';

  @override
  String get customCategoryName => 'Nombre de la categoría';

  @override
  String get cover => 'Portada';

  @override
  String get customCover => 'Tu foto';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Volver';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get addVideo => 'Añadir vídeo';

  @override
  String get addAudio => 'Añadir audio';

  @override
  String get addText => 'Añadir texto';

  @override
  String get camera => 'Cámara';

  @override
  String get importLabel => 'Importar';

  @override
  String get record => 'Grabar';

  @override
  String get write => 'Escribir';

  @override
  String get textTitleOptional => 'Título del texto (opcional)';

  @override
  String get textBody => 'Escribe tu recuerdo';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get quickOneMonth => '1 mes';

  @override
  String get quickSixMonths => '6 meses';

  @override
  String get quickOneYear => '1 año';

  @override
  String get quickFiveYears => '5 años';

  @override
  String get includeExactTime => 'Elegir hora exacta';

  @override
  String get sealCapsule => 'Sellar cápsula';

  @override
  String get sealQuestion => '¿Quieres sellarla?';

  @override
  String get sealWarning =>
      'Después de este momento no podrás modificar el contenido ni cambiar la fecha de apertura.';

  @override
  String get sealForFuture => 'Sellar para el futuro';

  @override
  String get sealedSuccess => 'La cápsula ha quedado sellada.';

  @override
  String get sealedMessage => 'Esta cápsula permanece sellada.';

  @override
  String get readyMessage => 'Ha llegado el momento.';

  @override
  String get openCapsule => 'Abrir cápsula';

  @override
  String get opening => 'Abriendo tu cápsula…';

  @override
  String get skipAnimation => 'Saltar animación';

  @override
  String get share => 'Compartir';

  @override
  String get saveToDevice => 'Guardar en el dispositivo';

  @override
  String get copy => 'Copiar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteQuestion => '¿Mover esta cápsula a la papelera?';

  @override
  String get restore => 'Restaurar';

  @override
  String get deleteForever => 'Eliminar definitivamente';

  @override
  String get deleteForeverQuestion =>
      'Esta acción no se puede deshacer. ¿Quieres eliminar definitivamente esta cápsula?';

  @override
  String get trashEmpty => 'La papelera está vacía';

  @override
  String get notificationOpening => 'Aviso al llegar la apertura';

  @override
  String get reminderDay => 'Recordatorio 1 día antes';

  @override
  String get reminderWeek => 'Recordatorio 1 semana antes';

  @override
  String get createBackup => 'Crear copia de seguridad';

  @override
  String get restoreBackup => 'Restaurar copia de seguridad';

  @override
  String get backupPassword => 'Contraseña para la copia';

  @override
  String get backupPasswordHint =>
      'La necesitarás para restaurar la copia en otro dispositivo.';

  @override
  String get backupWarning =>
      'Si desinstalas la aplicación sin una copia, tus cápsulas podrían perderse.';

  @override
  String get backupCreated => 'Copia de seguridad creada.';

  @override
  String get backupError =>
      'La copia está dañada o la contraseña no es correcta.';

  @override
  String get replaceWarning =>
      'La restauración reemplazará todos los datos actuales.';

  @override
  String storageTotal(Object size) {
    return 'Contenido almacenado: $size';
  }

  @override
  String get images => 'Fotos';

  @override
  String get videos => 'Vídeos';

  @override
  String get audios => 'Audio';

  @override
  String get other => 'Otros';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get rename => 'Renombrar';

  @override
  String get categoryInUse => 'No se puede eliminar una categoría en uso.';

  @override
  String get noContentError => 'Añade al menos un recuerdo.';

  @override
  String get titleError => 'Escribe un título.';

  @override
  String get customCategoryError =>
      'Escribe el nombre de la categoría personalizada.';

  @override
  String get dateError => 'Elige una fecha futura.';

  @override
  String get importError => 'No se pudo importar el archivo.';

  @override
  String get working => 'Protegiendo el contenido…';

  @override
  String get sort => 'Ordenar';

  @override
  String get sortNext => 'Próxima apertura';

  @override
  String get sortRecent => 'Más recientes';

  @override
  String get sortOldest => 'Más antiguas';

  @override
  String get sortName => 'Nombre A-Z';

  @override
  String get personal => 'Personal';

  @override
  String get family => 'Familia';

  @override
  String get couple => 'Pareja';

  @override
  String get friends => 'Amigos';

  @override
  String get travel => 'Viajes';

  @override
  String get goals => 'Metas';

  @override
  String get celebrations => 'Celebraciones';

  @override
  String get others => 'Personalizada';

  @override
  String get tutorialSampleText => 'Prueba de cápsula';

  @override
  String get tutorialHomeTitle => 'Crea tu primera cápsula';

  @override
  String get tutorialHomeBody =>
      'Empezaremos con una cápsula de texto. La aplicación añadirá un texto de prueba para que puedas conocer todo el proceso. Toca para continuar.';

  @override
  String get tutorialTextTitle => 'Un recuerdo en palabras';

  @override
  String get tutorialTextBody =>
      'El tutorial ha añadido «Prueba de cápsula» como título y contenido. Fuera del tutorial puedes escribir tantos recuerdos como quieras.';

  @override
  String get tutorialCategoryTitle => 'Organiza tus recuerdos';

  @override
  String get tutorialCategoryBody =>
      'Elige una categoría existente o selecciona Personalizada para escribir una nueva categoría propia.';

  @override
  String get tutorialCoversTitle => 'Elige una portada';

  @override
  String get tutorialCoversBody =>
      'Elige una portada o toca «Tu foto» para usar una imagen de la cámara o la galería.';

  @override
  String get tutorialQuickDatesTitle => 'Fechas rápidas';

  @override
  String get tutorialQuickDatesBody =>
      'Usa estas opciones para programar la apertura dentro de un mes, seis meses, un año o cinco años.';

  @override
  String get tutorialDateTitle => 'Una fecha concreta';

  @override
  String get tutorialDateBody =>
      'También puedes abrir el calendario y elegir exactamente el día en que podrá abrirse la cápsula.';

  @override
  String get tutorialTimeTitle => 'Elige también la hora';

  @override
  String get tutorialTimeBody =>
      'Activa esta opción si quieres fijar una hora exacta además del día de apertura.';

  @override
  String get tutorialSealTitle => 'Sella la cápsula';

  @override
  String get tutorialSealBody =>
      'Al sellarla, su contenido y fecha quedarán protegidos y ya no podrán modificarse. Toca para ver la confirmación.';

  @override
  String get tutorialCapsulesTitle => 'Todas tus cápsulas';

  @override
  String get tutorialCapsulesBody =>
      'En Mis cápsulas puedes encontrar, buscar y filtrar las cápsulas que hayas creado.';

  @override
  String get tutorialComplete =>
      'Tutorial completado. Puedes repetirlo cuando quieras desde Ajustes.';
}
