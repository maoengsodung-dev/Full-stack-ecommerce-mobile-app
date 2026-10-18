import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/modules/auth/controllers/auth_controller.dart';
import 'package:architecture_getx/app/modules/auth/views/widgets/auth_header.dart';
import 'package:architecture_getx/app/modules/auth/views/widgets/auth_tab_switch.dart';
import 'package:architecture_getx/app/modules/auth/views/widgets/auth_text_field.dart';
import 'package:architecture_getx/app/modules/auth/views/widgets/social_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authPurple,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.authGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Dynamic Header
              Obx(
                () => AuthHeader(
                  title: controller.isLoginTab.value
                      ? 'Go ahead and complete\nyour account and setup'
                      : 'Sign up now to access\nyour personal account',
                  subtitle: controller.isLoginTab.value
                      ? 'Create your account and simplify your workflow instantly.'
                      : 'Sign up to access your account and exclusive features.',
                ),
              ),
              // White bottom card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab switcher: Login | Sign Up (in-place switcher)
                        Obx(
                          () => AuthTabSwitch(
                            activeTab: controller.isLoginTab.value
                                ? AuthTabType.login
                                : AuthTabType.register,
                            onTabChanged: (tab) {
                              FocusScope.of(context).unfocus();
                              controller.setAuthTab(tab == AuthTabType.login);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // In-place dynamic form
                        Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child: controller.isLoginTab.value
                                ? KeyedSubtree(
                                    key: const ValueKey('login_form'),
                                    child: _buildLoginForm(),
                                  )
                                : KeyedSubtree(
                                    key: const ValueKey('register_form'),
                                    child: _buildRegisterForm(),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Options Row (Remember Me & Forgot Password)
                        _buildOptionsRow(context),
                        const SizedBox(height: 24),

                        // Submit Button (Login or Register)
                        _buildSubmitButton(),
                        const SizedBox(height: 24),

                        // Social Login Section
                        Obx(
                          () => SocialLoginButtons(
                            dividerText: controller.isLoginTab.value
                                ? 'Or login with'
                                : 'Or register with',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Login Form ─────────────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return FocusScope(
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          children: [
            AuthTextField(
              label: 'Email',
              hintText: 'mdbearren@gmail.com',
              controller: controller.loginEmailCtrl,
              focusNode: controller.loginEmailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                controller.loginPasswordFocusNode.requestFocus();
              },
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Obx(
              () => AuthTextField(
                label: 'Password',
                hintText: '••••••••',
                controller: controller.loginPasswordCtrl,
                focusNode: controller.loginPasswordFocusNode,
                obscureText: !controller.isPasswordVisible.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => controller.login(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => controller.isPasswordVisible.toggle(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Register Form ──────────────────────────────────────────────────────────

  Widget _buildRegisterForm() {
    return FocusScope(
      child: Form(
        key: controller.regFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    label: 'First Name',
                    hintText: 'Wade',
                    controller: controller.regFirstNameCtrl,
                    focusNode: controller.regFirstNameFocusNode,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) {
                      controller.regLastNameFocusNode.requestFocus();
                    },
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AuthTextField(
                    label: 'Last Name',
                    hintText: 'Warren',
                    controller: controller.regLastNameCtrl,
                    focusNode: controller.regLastNameFocusNode,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) {
                      controller.regEmailFocusNode.requestFocus();
                    },
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Email',
              hintText: 'mdbearren@gmail.com',
              controller: controller.regEmailCtrl,
              focusNode: controller.regEmailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                controller.regPasswordFocusNode.requestFocus();
              },
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Obx(
              () => AuthTextField(
                label: 'Password',
                hintText: '••••••••',
                controller: controller.regPasswordCtrl,
                focusNode: controller.regPasswordFocusNode,
                obscureText: !controller.isRegPasswordVisible.value,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  controller.regConfirmFocusNode.requestFocus();
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isRegPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => controller.isRegPasswordVisible.toggle(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => AuthTextField(
                label: 'Confirm Password',
                hintText: '••••••••',
                controller: controller.regConfirmCtrl,
                focusNode: controller.regConfirmFocusNode,
                obscureText: !controller.isRegConfirmPasswordVisible.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => controller.register(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isRegConfirmPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      controller.isRegConfirmPasswordVisible.toggle(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != controller.regPasswordCtrl.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Options Row ────────────────────────────────────────────────────────────

  Widget _buildOptionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Checkbox
        Obx(
          () => InkWell(
            onTap: () => controller.rememberMe.toggle(),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (val) =>
                        controller.rememberMe.value = val ?? false,
                    activeColor: AppColors.authPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.authFieldBorder,
                      width: 1.5,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember Me',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Forgot Password? Link
        GestureDetector(
          onTap: () => _showForgotPasswordSheet(context),
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Obx(() {
      final isLogin = controller.isLoginTab.value;
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : (isLogin ? controller.login : controller.register),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.authPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: AppColors.authPurple.withValues(
              alpha: 0.6,
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isLogin ? 'Login' : 'Register',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    });
  }

  void _showForgotPasswordSheet(BuildContext context) {
    final emailCtrl = TextEditingController(text: controller.loginEmailCtrl.text);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Forgot Password',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Email',
                hintText: 'Enter your registered email',
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSendingReset.value
                        ? null
                        : () async {
                            final ok = await controller.forgotPassword(emailCtrl.text);
                            if (ok && Get.isBottomSheetOpen == true) {
                              Get.back();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.authPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSendingReset.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Send Reset Link',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
