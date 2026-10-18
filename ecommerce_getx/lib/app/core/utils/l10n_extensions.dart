import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:architecture_getx/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// Convenient accessor for localized messages in build methods
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ??
      lookupAppLocalizations(Get.locale ?? const Locale('en'));
}

/// Global accessor for localized messages anywhere in controllers, snackbars, or services
AppLocalizations get appL10n {
  final ctx = Get.context;
  if (ctx != null) {
    final localizations = AppLocalizations.of(ctx);
    if (localizations != null) return localizations;
  }
  return lookupAppLocalizations(Get.locale ?? const Locale('en'));
}
