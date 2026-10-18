import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {
  late final PageController pageController;
  final currentPage = 0.obs;
  Timer? _autoTransitionTimer;

  StorageService get _storageService => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);

    // After splash delay, check auth state and navigate accordingly
    _startInitialNavigationFlow();
  }

  void _startInitialNavigationFlow() {
    _autoTransitionTimer = Timer(const Duration(milliseconds: 2500), () {
      // If user is already logged in, navigate straight to Shell
      if (_storageService.hasToken) {
        Get.offAllNamed(Routes.SHELL);
      } else {
        // Transition smoothly to the Onboarding / Welcome screen
        if (pageController.hasClients && currentPage.value == 0) {
          pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void goToSignIn() {
    Get.toNamed(Routes.AUTH);
  }

  void goToWelcome() {
    if (pageController.hasClients) {
      pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void goToSplash() {
    if (pageController.hasClients) {
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void onClose() {
    _autoTransitionTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
