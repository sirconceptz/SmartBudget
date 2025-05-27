import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum RepeatInterval {
  daily,
  weekly,
  monthly,
}

extension RepeatIntervalExtension on RepeatInterval {
  String localizedName(BuildContext context) {
    switch (this) {
      case RepeatInterval.daily:
        return AppLocalizations.of(context)!.daily;
      case RepeatInterval.weekly:
        return AppLocalizations.of(context)!.weekly;
      case RepeatInterval.monthly:
        return AppLocalizations.of(context)!.monthly;
    }
  }
}
