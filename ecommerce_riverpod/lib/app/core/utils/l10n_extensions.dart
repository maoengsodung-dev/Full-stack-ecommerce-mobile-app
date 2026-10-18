import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../router/app_router.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
}

AppLocalizations get appL10n {
  final ctx = AppRouter.navigatorKey.currentContext;
  if (ctx != null) {
    final localizations = AppLocalizations.of(ctx);
    if (localizations != null) return localizations;
  }
  return lookupAppLocalizations(const Locale('en'));
}
