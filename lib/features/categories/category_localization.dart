import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import '../capsules/domain/capsule_models.dart';

String categoryLabel(BuildContext context, CapsuleCategory category) {
  if (!category.isDefault) return category.name;
  return switch (category.id) {
    'personal' => context.l10n.personal,
    'family' => context.l10n.family,
    'couple' => context.l10n.couple,
    'friends' => context.l10n.friends,
    'travel' => context.l10n.travel,
    'goals' => context.l10n.goals,
    'celebrations' => context.l10n.celebrations,
    _ => context.l10n.others,
  };
}
