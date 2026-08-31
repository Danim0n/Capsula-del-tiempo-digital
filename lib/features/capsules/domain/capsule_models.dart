enum CapsuleStatus {
  draft,
  sealed,
  readyToOpen,
  opened,
  emergencyAccessed,
  trashed,
}

enum CapsuleItemType { image, video, audio, text }

class Capsule {
  const Capsule({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.coverId,
    required this.createdAt,
    required this.unlockAt,
    required this.unlockIncludesTime,
    required this.persistedStatus,
    this.description,
    this.sealedAt,
    this.openedAt,
    this.emergencyAccessedAt,
    this.deletedAt,
    this.itemCount = 0,
  });

  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final String coverId;
  final DateTime createdAt;
  final DateTime? sealedAt;
  final DateTime unlockAt;
  final bool unlockIncludesTime;
  final DateTime? openedAt;
  final DateTime? emergencyAccessedAt;
  final CapsuleStatus persistedStatus;
  final DateTime? deletedAt;
  final int itemCount;

  CapsuleStatus statusAt(DateTime now) {
    if (persistedStatus == CapsuleStatus.trashed) return CapsuleStatus.trashed;
    if (openedAt != null || persistedStatus == CapsuleStatus.opened) {
      return CapsuleStatus.opened;
    }
    if (persistedStatus == CapsuleStatus.draft) return CapsuleStatus.draft;
    if (!now.isBefore(unlockAt)) return CapsuleStatus.readyToOpen;
    if (emergencyAccessedAt != null) return CapsuleStatus.emergencyAccessed;
    return CapsuleStatus.sealed;
  }

  bool get isMutable => persistedStatus == CapsuleStatus.draft;

  Capsule copyWith({
    String? title,
    String? description,
    String? categoryId,
    String? coverId,
    DateTime? unlockAt,
    bool? unlockIncludesTime,
    DateTime? sealedAt,
    DateTime? openedAt,
    DateTime? emergencyAccessedAt,
    CapsuleStatus? persistedStatus,
    DateTime? deletedAt,
    int? itemCount,
  }) => Capsule(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    coverId: coverId ?? this.coverId,
    createdAt: createdAt,
    unlockAt: unlockAt ?? this.unlockAt,
    unlockIncludesTime: unlockIncludesTime ?? this.unlockIncludesTime,
    sealedAt: sealedAt ?? this.sealedAt,
    openedAt: openedAt ?? this.openedAt,
    emergencyAccessedAt: emergencyAccessedAt ?? this.emergencyAccessedAt,
    persistedStatus: persistedStatus ?? this.persistedStatus,
    deletedAt: deletedAt ?? this.deletedAt,
    itemCount: itemCount ?? this.itemCount,
  );
}

class CapsuleItem {
  const CapsuleItem({
    required this.id,
    required this.capsuleId,
    required this.type,
    required this.createdAt,
    required this.orderIndex,
    this.encryptedPath,
    this.encryptedText,
    this.textTitle,
    this.mimeType,
    this.byteSize = 0,
  });

  final String id;
  final String capsuleId;
  final CapsuleItemType type;
  final String? encryptedPath;
  final String? encryptedText;
  final String? textTitle;
  final String? mimeType;
  final int byteSize;
  final DateTime createdAt;
  final int orderIndex;
}

class CapsuleCategory {
  const CapsuleCategory({
    required this.id,
    required this.name,
    required this.isDefault,
  });
  final String id;
  final String name;
  final bool isDefault;
}

class CapsuleLockedException implements Exception {
  const CapsuleLockedException();
  @override
  String toString() => 'A sealed capsule is immutable.';
}
