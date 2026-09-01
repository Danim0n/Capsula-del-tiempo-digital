import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gift box dotLottie asset can be loaded and decoded', () async {
    final data = await rootBundle.load('assets/animations/giftbox_open.lottie');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final composition = await LottieComposition.decodeZip(
      bytes,
      filePicker:
          (files) => files.firstWhere(
            (file) =>
                file.name.startsWith('animations/') &&
                file.name.endsWith('.json'),
          ),
    );

    expect(composition, isNotNull);
    expect(composition!.duration, greaterThan(Duration.zero));
  });
}
