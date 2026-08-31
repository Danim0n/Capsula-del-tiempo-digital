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

## Privacidad

- El contenido se copia al directorio privado de la aplicación.
- Archivos y textos se cifran con AES-256-GCM y nonces independientes.
- La clave maestra aleatoria se conserva mediante `flutter_secure_storage` / Android Keystore.
- Las copias `.ctdbackup` protegen la clave maestra y el manifiesto con una clave derivada de la contraseña mediante PBKDF2-HMAC-SHA256.
- Las pantallas con contenido real activan `FLAG_SECURE` en Android.

La desinstalación elimina los datos locales. Debe crearse una copia de seguridad antes de cambiar de teléfono o desinstalar.
