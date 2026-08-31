import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:flutter_test/flutter_test.dart';

Capsule capsule({
  CapsuleStatus status = CapsuleStatus.sealed,
  DateTime? unlock,
  DateTime? opened,
  DateTime? emergency,
}) => Capsule(
  id: 'capsule',
  title: 'Future',
  categoryId: 'personal',
  coverId: 'cover_01',
  createdAt: DateTime(2026),
  unlockAt: unlock ?? DateTime(2030),
  unlockIncludesTime: false,
  persistedStatus: status,
  openedAt: opened,
  emergencyAccessedAt: emergency,
);

void main() {
  test('sealed state is retained before opening date', () {
    expect(capsule().statusAt(DateTime(2029)), CapsuleStatus.sealed);
  });

  test('sealed capsule computes ready state from source-of-truth date', () {
    expect(capsule().statusAt(DateTime(2030)), CapsuleStatus.readyToOpen);
  });

  test('opened state never becomes closed again', () {
    expect(
      capsule(
        status: CapsuleStatus.opened,
        opened: DateTime(2030),
      ).statusAt(DateTime(2029)),
      CapsuleStatus.opened,
    );
  });

  test('early access is distinct before the real date', () {
    expect(
      capsule(emergency: DateTime(2028)).statusAt(DateTime(2029)),
      CapsuleStatus.emergencyAccessed,
    );
  });

  test('emergency capsule becomes normally ready on its real date', () {
    expect(
      capsule(emergency: DateTime(2028)).statusAt(DateTime(2030)),
      CapsuleStatus.readyToOpen,
    );
  });
}
