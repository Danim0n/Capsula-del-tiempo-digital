import 'package:capsula_del_tiempo_digital/core/security/screen_security_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'missing native screen-security channel does not block content',
    () async {
      final service = ScreenSecurityService();

      await expectLater(service.protect(), completes);
      await expectLater(service.unprotect(), completes);
    },
  );
}
