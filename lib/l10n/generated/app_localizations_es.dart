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
  String get previewMemory => 'Vista previa';

  @override
  String get previewContent => 'Comprueba tus recuerdos';

  @override
  String get previewMemoryHint => 'Toca un recuerdo para verlo o reproducirlo.';

  @override
  String get previewDraftHint =>
      'Estás viendo un borrador. Puedes volver para seguir preparando tu cápsula sin cambiar su contenido.';

  @override
  String get previewDraftOnly =>
      'La vista previa solo está disponible antes de sellar la cápsula.';

  @override
  String get previewImageHint =>
      'Separa dos dedos sobre la foto para ampliarla.';

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
  String get recordingTitle => 'Grabar audio';

  @override
  String get recordingReady => 'Listo para empezar';

  @override
  String get recordingActive => 'Grabando…';

  @override
  String get recordingPaused => 'Grabación en pausa';

  @override
  String get recordingInterrupted => 'Grabación interrumpida';

  @override
  String get recordingStart => 'Comenzar grabación';

  @override
  String get recordingPause => 'Pausar grabación';

  @override
  String get recordingResume => 'Continuar grabación';

  @override
  String get recordingStop => 'Detener y guardar';

  @override
  String get recordingHint =>
      'Pulsa el micrófono para empezar. Puedes pausar y continuar; al detener se añade el audio a tu cápsula.';

  @override
  String get recordingPermission =>
      'Permite el acceso al micrófono para grabar. Si lo has bloqueado, actívalo en los ajustes de tu dispositivo.';

  @override
  String get recordingError =>
      'No se ha podido completar la grabación. Comprueba el micrófono y el espacio disponible. Puedes volver a intentarlo o cancelar.';

  @override
  String get recordingMeterError =>
      'No se puede mostrar el nivel de sonido. La grabación puede continuar.';

  @override
  String get recordingDiscardQuestion => '¿Descartar esta grabación?';

  @override
  String get recordingDiscardHint =>
      'El audio no se añadirá a la cápsula. Si quieres conservarlo, vuelve y pulsa detener.';

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

  @override
  String get nearbyTitle => 'Transferir cerca';

  @override
  String get nearbySend => 'Enviar a alguien cercano';

  @override
  String get nearbyReceive => 'Recibir cápsula';

  @override
  String get nearbyIntro =>
      'Comparte una cápsula con otro Android cercano, sin Internet ni nube. Ambos debéis tener esta versión de la app abierta, Wi-Fi y Bluetooth activados. En Android antiguos puede hacer falta activar la ubicación.';

  @override
  String get nearbyPrivacy =>
      'Se enviará solo la cápsula elegida, con su contenido y portada. La copia conserva la fecha de apertura y ocupa espacio en ambos móviles. No se sincronizan cambios posteriores.';

  @override
  String get nearbyUnsupported =>
      'La transferencia cercana está disponible entre móviles Android con servicios de Google Play. Puedes seguir usando la exportación habitual en las plataformas compatibles.';

  @override
  String get nearbyExport => 'Exportación y copias actuales';

  @override
  String get nearbyName => 'Tu nombre para esta conexión';

  @override
  String get nearbyChoose => 'Elige una cápsula sellada';

  @override
  String get nearbyEmpty =>
      'Todavía no hay cápsulas selladas para enviar. Sí puedes recibir una.';

  @override
  String get nearbyDiscovering =>
      'Buscando móviles… En el otro móvil pulsa «Recibir cápsula».';

  @override
  String get nearbyWaiting =>
      'Listo para recibir. En el otro móvil elige una cápsula y pulsa «Enviar a alguien cercano».';

  @override
  String get nearbyConnecting => 'Conectando con el otro móvil…';

  @override
  String get nearbyPairing => 'Comprobad el código';

  @override
  String get nearbyCodeHint =>
      'Confirma solo si este mismo código aparece en el otro móvil y reconoces a la persona.';

  @override
  String get nearbyConfirm => 'El código coincide';

  @override
  String get nearbyPreparing => 'Preparando una copia cifrada…';

  @override
  String get nearbyAwaitingOffer => 'Conectados. Esperando la cápsula…';

  @override
  String get nearbyAwaitingAccept =>
      'Esperando que la otra persona acepte la cápsula…';

  @override
  String get nearbyAcceptTitle => '¿Guardar esta cápsula?';

  @override
  String get nearbyAcceptHint =>
      'Se añadirá a tus cápsulas sin reemplazar las existentes. Acepta solo contenido de alguien de confianza.';

  @override
  String get nearbySending => 'Enviando cápsula…';

  @override
  String get nearbyReceiving => 'Recibiendo cápsula…';

  @override
  String get nearbyImporting => 'Comprobando y guardando la cápsula…';

  @override
  String get nearbyAwaitingSave =>
      'Envío completado. Esperando confirmación de guardado…';

  @override
  String get nearbySent => 'La otra persona ha guardado la cápsula.';

  @override
  String get nearbySaved => 'Cápsula recibida y añadida a «Mis cápsulas».';

  @override
  String get nearbyNotificationWarning =>
      'Se ha guardado la cápsula, pero no se ha podido programar su aviso. Revisa los permisos de notificaciones.';

  @override
  String get nearbyKeepOpen =>
      'Mantened ambos móviles cerca y esta pantalla abierta hasta terminar. Máximo: 1 GB por cápsula.';

  @override
  String get nearbyError =>
      'No se ha completado la transferencia. Comprueba permisos, Wi-Fi, Bluetooth y espacio libre en ambos móviles. Vuelve a abrir esta pantalla para intentarlo de nuevo.';

  @override
  String get nearbyPermission =>
      'Se necesitan los permisos de dispositivos cercanos (y ubicación en Android antiguos). Puedes concederlos en los ajustes del móvil.';

  @override
  String get nearbyPlayServices =>
      'Este móvil necesita servicios de Google Play disponibles y actualizados para transferir cerca.';

  @override
  String get nearbySpace =>
      'No hay espacio libre suficiente. La recepción necesita espacio temporal adicional para comprobar y cifrar los archivos.';

  @override
  String get nearbyTooLarge =>
      'La cápsula supera el límite de 1 GB para transferencias cercanas.';

  @override
  String get nearbyDuplicate =>
      'Este móvil ya tiene esta cápsula. No se ha sobrescrito ni duplicado.';

  @override
  String get nearbyDeclined =>
      'La conexión o la cápsula se ha rechazado. No se ha enviado la cápsula.';

  @override
  String get nearbyDisconnected =>
      'La conexión se ha interrumpido. Si el envío ya había terminado, comprueba «Mis cápsulas» en el móvil receptor antes de repetirlo.';

  @override
  String get nearbyTimeout =>
      'Se ha agotado el tiempo de espera. Comprueba los dos móviles e inténtalo de nuevo.';

  @override
  String get nearbyBack => 'Volver a mis cápsulas';

  @override
  String get chooseCapsuleKind => '¿Qué cápsula quieres crear?';

  @override
  String get standardCapsule => 'Cápsula del tiempo';

  @override
  String get standardCapsuleHint =>
      'La cápsula de siempre: guarda tus recuerdos y descubre todo su contenido al abrirla.';

  @override
  String get personalizedCapsule => 'Cápsula del tiempo personalizada';

  @override
  String get personalizedCapsuleHint =>
      'Crea una historia con fotos, audios, textos y vídeos. Se descubrirá recuerdo a recuerdo, en el orden que elijas.';

  @override
  String get sequenceHeading => 'Construye tu historia';

  @override
  String get sequenceHint =>
      'Pulsa + para añadir el primer recuerdo. Después podrás seguir añadiendo debajo. Al abrirla, se mostrarán en este mismo orden.';

  @override
  String get sequenceAdd => 'Añadir recuerdo';

  @override
  String get sequenceDetails => 'Continuar con los detalles';

  @override
  String get sequencePrevious => 'Anterior';

  @override
  String get sequenceFinish => 'Finalizar';

  @override
  String get sequenceEmpty => 'Esta cápsula no tiene recuerdos.';

  @override
  String sequencePosition(int current, int total) {
    return '$current de $total';
  }

  @override
  String get memoryLoadError =>
      'No se ha podido abrir este recuerdo. Puedes continuar con el siguiente.';

  @override
  String get videoPlaybackError =>
      'No se puede reproducir este vídeo. Comprueba que el archivo está completo y que su formato es compatible con tu dispositivo (por ejemplo, MP4 con H.264).';

  @override
  String get memoryRetry => 'Reintentar';

  @override
  String get mediaPlay => 'Reproducir';

  @override
  String get mediaPause => 'Pausar';
}
