import 'package:flutter/material.dart';
import 'package:learn_buddy/l10n/app_localizations.dart';

extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
