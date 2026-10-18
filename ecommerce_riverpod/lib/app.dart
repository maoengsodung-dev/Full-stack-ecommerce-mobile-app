import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'app/core/config/flavor_config.dart';
import 'app/core/providers/core_providers.dart';
import 'app/core/router/app_router.dart';
import 'app/core/router/route_names.dart';
import 'app/core/theme/app_theme.dart';
import 'flavor.dart';
import 'l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final locale = language.locale;
    final currentCode = language.code;

    return MaterialApp(
      title: F.title,
      theme: AppTheme.getTheme(currentCode),
      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: RouteNames.splash,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return _flavorBanner(child: child!, show: true);
      },
    );
  }

  Widget _flavorBanner({required Widget child, bool show = true}) {
    if (!show) return child;

    return Banner(
      message: F.name,
      location: BannerLocation.topStart,
      color: _bannerColor(),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 1,
      ),
      child: child,
    );
  }

  Color _bannerColor() {
    switch (F.appFlavor) {
      case Flavor.dev:
        return Colors.green;
      case Flavor.staging:
        return Colors.orange;
      case Flavor.prod:
        return Colors.red;
    }
  }
}
