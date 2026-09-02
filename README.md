# Cápsula del Tiempo Digital

Aplicación Flutter local para guardar fotografías, vídeos, audios y textos hasta una fecha futura. No utiliza cuentas, backend ni almacenamiento remoto obligatorio.

## Desarrollo

Requisitos: Flutter 3.47.2 o compatible, Android SDK y JDK 17.

```sh
flutter pub get
flutter gen-l10n
flutter pub run build_runner build
flutter run
```

Verificación:

```sh
flutter analyze
flutter test
flutter build apk --debug
```

El APK de depuración se genera en `build/app/outputs/flutter-apk/app-debug.apk`.

## Cápsulas normales y personalizadas

El botón **Crear cápsula** permite elegir entre **Cápsula del tiempo** (la vista
habitual de recuerdos) y **Cápsula del tiempo personalizada** (una historia por pasos).
Los accesos rápidos de foto, vídeo, audio y texto, y el tutorial inicial, siguen
abriendo el editor normal.

En una personalizada, pulsar **+ Añadir recuerdo** permite elegir foto, audio,
texto o vídeo. Tras cada incorporación aparece el siguiente botón al final. Se
pueden eliminar elementos antes del sellado sin alterar el orden de los restantes.
Después se configuran título, descripción opcional, categoría, portada y fecha/hora.
Al abrirla, se muestra un recuerdo cada vez, con **Continuar**, **Anterior** y
**Finalizar**. Cambiar de recuerdo detiene y libera su reproductor.

Antes de sellar, toca un recuerdo en el editor o en **Comprueba tus recuerdos**
de la revisión final para abrir su **Vista previa**. Permite leer el texto completo,
ampliar las fotos y reproducir audios y vídeos. Volver conserva el paso del editor
y el borrador sin modificaciones. Esta vista no permite acceder a cápsulas ya
selladas; al cerrarla se liberan los reproductores y se eliminan las copias
temporales descifradas, conservando los originales cifrados.

El vídeo incluye reproducción/pausa, barra de avance, tiempo y reintento si falla.
La compatibilidad de códecs depende del dispositivo; se recomienda MP4/H.264.
La biblioteca multimedia privada actual usa archivos locales en Android/iOS;
la compilación web no implica compatibilidad con importar esos archivos en el navegador.

El esquema SQLite v2 añade el tipo de cápsula sin borrar datos: las anteriores se
mantienen como normales. El tipo y el orden se conservan en copias y transferencias
entre versiones actualizadas. Las copias antiguas siguen restaurándose como normales.

## Privacidad

- El contenido se copia al directorio privado de la aplicación.
- Archivos y textos se cifran con AES-256-GCM y nonces independientes.
- La clave maestra aleatoria se conserva mediante `flutter_secure_storage` / Android Keystore.
- Las copias `.ctdbackup` protegen la clave maestra y el manifiesto con una clave derivada de la contraseña mediante PBKDF2-HMAC-SHA256.
- Las pantallas con contenido real activan `FLAG_SECURE` en Android.

La desinstalación elimina los datos locales. Debe crearse una copia de seguridad antes de cambiar de teléfono o desinstalar.

## Transferencia cercana (Android)

Se puede enviar **una cápsula sellada** directamente a otro móvil Android cercano,
sin cuentas, servidor propio ni almacenamiento en la nube. La exportación habitual
de copias `.ctdbackup` y su envío mediante WhatsApp, correo o el menú de compartir
se mantienen sin cambios; no son el mismo formato ni el mismo flujo de importación.

1. Instalar esta versión en ambos teléfonos; activar Wi-Fi y Bluetooth.
2. Receptor: **Mis cápsulas → icono de transferencia → Recibir cápsula**.
3. Emisor: abrir la ficha de la cápsula → **Enviar a alguien cercano**, confirmar
   la selección y elegir el teléfono que aparece. También está en **Ajustes → Transferir cerca**.
4. Comparar el código mostrado en **ambos** teléfonos y confirmar solo si coincide.
5. El receptor revisa título, tamaño y fecha, y acepta la cápsula.
6. Mantener ambas pantallas abiertas hasta que el emisor vea que el receptor la ha guardado.

Requisitos y límites:

- Android con Google Play services disponible. Se usa Nearby Connections nativo
  (`play-services-nearby:19.4.0`), con conexión cifrada y confirmación explícita.
- No hace falta conexión a Internet ni estar conectados al mismo router. En Android
  antiguos, el descubrimiento también puede requerir permisos y servicio de ubicación.
- Hasta 1 GB por cápsula, 1.000 elementos y una transferencia por sesión. Hace falta
  espacio temporal adicional en ambos móviles; el receptor comprueba aproximadamente
  tres veces el tamaño del paquete más 32 MB antes de aceptarlo.
- No se ofrece un servicio de transferencia en segundo plano, edición conjunta, sincronización posterior
  ni envío remoto a personas que estén lejos. Para varias personas, repetir el envío.
- Web, iOS y escritorio muestran la limitación y conservan el acceso al flujo de copias existente.
- La cápsula conserva el instante de apertura (UTC, mostrado en hora local). Su
  apertura depende del reloj local, como el resto de la app: no es un bloqueo temporal
  criptográfico contra un propietario que manipule el dispositivo.

Protección de datos:

- Nunca se comparte la clave maestra, la base de datos completa ni otras cápsulas.
- Cada envío usa una clave aleatoria nueva; solo viaja por el canal confirmado.
- Archivos y portada personalizada se recifran por bloques, sin archivos temporales
  en claro. Texto y manifiesto también se cifran. SHA-256 verifica el paquete completo.
- El receptor recifra con su propia clave y añade la cápsula en una transacción.
  No reemplaza su biblioteca ni sus ajustes; rechaza duplicados, incluso en la papelera.
- El emisor solo indica «guardada» tras recibir confirmación posterior al guardado.
  Si se pierde esa confirmación, comprobar la biblioteca receptora antes de reintentar.
- Los temporales cifrados se eliminan al finalizar/cancelar normalmente. Si el proceso
  es terminado por el sistema pueden quedar restos cifrados en la caché privada.
- Nearby es un SDK de Google Play services: revisar sus requisitos de privacidad y
  declaraciones de datos antes de publicar; no implica que el SDK no use telemetría.

### Verificación de transferencia

Pruebas automatizadas: `flutter test` cubre el formato, claves diferentes entre
teléfonos, todos los tipos de contenido, portada personalizada, integridad, cancelación,
duplicados y conservación de cápsulas existentes.

Para validar la radio se necesitan **dos Android físicos**. Comprobar: texto y vídeo
grande sin Internet; código correcto e incorrecto; permisos denegados; rechazo del
receptor; salir durante el envío/importación; desactivar Bluetooth; espacio insuficiente;
reintento de duplicado; apertura a la hora prevista y persistencia al reiniciar. Probar
al menos un Android 12 o anterior y otro Android 13 o posterior.
