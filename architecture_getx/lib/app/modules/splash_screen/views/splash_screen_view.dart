import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:architecture_getx/app/core/constants/icons.dart';

import '../controllers/splash_screen_controller.dart';
import '../widgets/iot_dashboard_illustration.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  static const Color primaryPurple = Color(0xFF5352EC);
  static const Color darkText = Color(0xFF1E1B4B);
  static const Color subtitleText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isSplash = controller.currentPage.value == 0;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isSplash
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                ),
          child: PageView(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            physics: const ClampingScrollPhysics(),
            children: [
              _buildSplashScreen(context),
              _buildWelcomeScreen(context),
            ],
          ),
        );
      }),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Page 1: Brand Splash Screen (Vibrant Purple with Brain Logo)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSplashScreen(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5A58F2),
            Color(0xFF4F4DE8),
            Color(0xFF4542DE),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Background ambient soft circles
          Positioned(
            top: -60,
            left: -40,
            child: _buildAmbientBubble(180, 0.08),
          ),
          Positioned(
            bottom: 120,
            left: -50,
            child: _buildAmbientBubble(140, 0.12),
          ),
          Positioned(
            top: 200,
            right: -60,
            child: _buildAmbientBubble(160, 0.06),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: _buildAmbientBubble(120, 0.09),
          ),

          // Center Animated Brain Logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      kAppLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Optional subtle tap-to-continue hint or progress
                GestureDetector(
                  onTap: controller.goToWelcome,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.transparent,
                    child: Text(
                      'IOTON',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Page 2: Welcome / Cloud Dashboard Onboarding Screen
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustrationSize = (size.width * 0.72).clamp(240.0, 320.0);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Back Arrow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: darkText,
                      size: 24,
                    ),
                    onPressed: controller.goToSplash,
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // IoT Dashboard Graphic / Illustration
            Center(
              child: IotDashboardIllustration(
                size: illustrationSize,
              ),
            ),

            const Spacer(flex: 1),

            // Headings & Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Your Real Time Cloud\nDashboard On The Go',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Before You Start, Create One At\nCreate.ioton./iot',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: subtitleText,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Sign In Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.goToSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: primaryPurple.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'SIGN IN',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
