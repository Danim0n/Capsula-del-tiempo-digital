import 'package:capsula_del_tiempo_digital/features/capsules/domain/unlock_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unlock policy', () {
    test('a future capsule remains closed', () {
      final unlock = DateTime(2030, 8, 15);
      expect(isReadyToOpen(unlock, DateTime(2030, 8, 14, 23, 59)), isFalse);
    });

    test('a capsule becomes ready at the exact instant', () {
      final unlock = DateTime(2030, 8, 15, 18, 45);
      expect(isReadyToOpen(unlock, unlock), isTrue);
      expect(
        isReadyToOpen(unlock, unlock.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('date-only opening is normalized to local midnight', () {
      final value = normalizeUnlockDate(
        DateTime(2030, 8, 15, 18, 45),
        includesTime: false,
      );
      expect(value, DateTime(2030, 8, 15));
    });

    test('exact date-time keeps its time', () {
      final input = DateTime(2030, 8, 15, 18, 45);
      expect(normalizeUnlockDate(input, includesTime: true), input);
    });
  });
}
