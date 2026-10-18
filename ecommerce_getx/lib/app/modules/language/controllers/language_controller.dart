import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/data/models/app_language.dart';
import 'package:architecture_getx/app/modules/profile/controllers/profile_controller.dart';

class LanguageController extends GetxController {
  final StorageService _storage;

  LanguageController(this._storage);

  final selectedLanguage = AppLanguage.english.obs;

  List<AppLanguage> get languages => AppLanguage.values;

  @override
  void onInit() {
    super.onInit();
    final savedCode = _storage.getLanguage();
    selectedLanguage.value =
        AppLanguage.fromCode(savedCode ?? Get.locale?.languageCode);
  }

  void changeLanguage(AppLanguage language) {
    if (selectedLanguage.value == language) return;

    selectedLanguage.value = language;
    _storage.saveLanguage(language.code);
    Get.updateLocale(language.locale);
    Get.changeTheme(AppTheme.getTheme(language.code));

    // Sync with ProfileController if open
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().currentLanguage.value = language;
    }

    Get.snackbar(
      'Language Updated',
      'App language changed to ${language.displayName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
