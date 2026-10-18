import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/constants/icons.dart';
import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../providers/splash_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const Color primaryPurple = Color(0xFF6D28E1);
  static const Color darkText = Color(0xFF1E1B4B);
  static const Color subtitleText = Color(0xFF6B7280);

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final PageController _pageController;
  Timer? _autoTransitionTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(splashProvider);
      _autoTransitionTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        if (state.hasToken) {
          if (state.isAdmin) {
            Navigator.of(context)
                .pushReplacementNamed(RouteNames.adminDashboard);
          } else {
            Navigator.of(context).pushReplacementNamed(RouteNames.shell);
          }
        } else {
          if (_pageController.hasClients && _pageController.page == 0) {
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _autoTransitionTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    Navigator.of(context).pushNamed(RouteNames.auth);
  }

  void _goToHome() {
    Navigator.of(context).pushReplacementNamed(RouteNames.shell);
  }

  void _goToWelcome() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToSplash() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashProvider);
    final isSplash = splashState.currentPage == 0;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isSplash
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: const Color(0xFFE3DBE5),
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            ref.read(splashProvider.notifier).setPage(index);
          },
          physics: const ClampingScrollPhysics(),
          children: [_buildSplashScreen(context), _buildWelcomeScreen(context)],
        ),
      ),
    );
  }

  Widget _buildSplashScreen(BuildContext context) {
    return GestureDetector(
      onTap: _goToWelcome,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6D28E1),
              Color(0xFF8B5CF6),
              Color(0xFFC4B5FD),
              Color(0xFFE3DBE5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Image.asset(
          kSplash,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustrationSize = (size.width * 0.65).clamp(200.0, 280.0);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: SplashPage.darkText,
                      size: 24,
                    ),
                    onPressed: _goToSplash,
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _goToHome,
                    child: Text(
                      'Skip',
                      style: AppFonts.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SplashPage.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            Center(
              child: Container(
                width: illustrationSize,
                height: illustrationSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: SplashPage.primaryPurple.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(kSplash, fit: BoxFit.cover),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Cat TomNinh\nShop Everything You Love',
                    textAlign: TextAlign.center,
                    style: AppFonts.font(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: SplashPage.darkText,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover trending items, premium deals, and fast doorstep delivery.',
                    textAlign: TextAlign.center,
                    style: AppFonts.font(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: SplashPage.subtitleText,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _goToSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SplashPage.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: SplashPage.primaryPurple.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'SIGN IN / REGISTER',
                        style: AppFonts.font(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _goToHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SplashPage.darkText,
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'CONTINUE AS GUEST',
                        style: AppFonts.font(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
