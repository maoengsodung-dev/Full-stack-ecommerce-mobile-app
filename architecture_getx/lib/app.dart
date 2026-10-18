import 'package:architecture_getx/app/bindings/init_bindings.dart';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:architecture_getx/flavor.dart';
import 'package:architecture_getx/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final storage =
        Get.isRegistered<StorageService>() ? Get.find<StorageService>() : null;
    final savedCode = storage?.getLanguage();
    final initialLocale =
        savedCode != null ? Locale(savedCode) : const Locale('en');

    return GetMaterialApp(
      title: F.title,
      theme: AppTheme.getTheme(savedCode),
      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,
      initialBinding: InitBindings(),
      locale: initialLocale,
      fallbackLocale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
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
