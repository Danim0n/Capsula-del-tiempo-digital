DateTime normalizeUnlockDate(DateTime selected, {required bool includesTime}) {
  if (includesTime) return selected;
  return DateTime(selected.year, selected.month, selected.day);
}

bool isReadyToOpen(DateTime unlockAt, DateTime now) => !now.isBefore(unlockAt);
