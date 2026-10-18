import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/core/theme/app_fonts.dart';


import '../../../../app/core/providers/core_providers.dart';
import '../../../../app/core/providers/storage_providers.dart';
import '../../../../app/core/router/route_names.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/data/models/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_tab_switch.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/social_login_buttons.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _loginFormKey = GlobalKey<FormState>();

  final _regFirstNameCtrl = TextEditingController();
  final _regLastNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  final _regFirstNameFocus = FocusNode();
  final _regLastNameFocus = FocusNode();
  final _regEmailFocus = FocusNode();
  final _regPasswordFocus = FocusNode();
  final _regConfirmFocus = FocusNode();
  final _regFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _regFirstNameCtrl.dispose();
    _regLastNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    _regFirstNameFocus.dispose();
    _regLastNameFocus.dispose();
    _regEmailFocus.dispose();
    _regPasswordFocus.dispose();
    _regConfirmFocus.dispose();
    super.dispose();
  }

  void _unfocusAll() {
    _loginEmailFocus.unfocus();
    _loginPasswordFocus.unfocus();
    _regFirstNameFocus.unfocus();
    _regLastNameFocus.unfocus();
    _regEmailFocus.unfocus();
    _regPasswordFocus.unfocus();
    _regConfirmFocus.unfocus();
  }

  Future<void> _handleLogin() async {
    _unfocusAll();
    if (!_loginFormKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
      _loginEmailCtrl.text.trim(),
      _loginPasswordCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      final activeRole = ref.read(activeRoleProvider);
      final storage = ref.read(storageServiceProvider);
      final isAdmin = activeRole == UserRole.admin || storage.isAdmin;

      if (isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.adminDashboard,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.shell,
          (route) => false,
        );
      }
    } else {
      final authState = ref.read(authNotifierProvider);
      final errorMsg = authState.actionState.hasError
          ? authState.actionState.error.toString()
          : 'Login failed. Please check your credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    _unfocusAll();
    if (!_regFormKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
      firstName: _regFirstNameCtrl.text.trim(),
      lastName: _regLastNameCtrl.text.trim(),
      email: _regEmailCtrl.text.trim(),
      password: _regPasswordCtrl.text,
      passwordConfirmation: _regConfirmCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.shell,
        (route) => false,
      );
    } else {
      final authState = ref.read(authNotifierProvider);
      final errorMsg = authState.actionState.hasError
          ? authState.actionState.error.toString()
          : 'Registration failed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.authPurple,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.authGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              AuthHeader(
                title: authState.isLoginTab
                    ? 'Go ahead and complete\nyour account and setup'
                    : 'Sign up now to access\nyour personal account',
                subtitle: authState.isLoginTab
                    ? 'Create your account and simplify your workflow instantly.'
                    : 'Sign up to access your account and exclusive features.',
              ),
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
                        AuthTabSwitch(
                          activeTab: authState.isLoginTab
                              ? AuthTabType.login
                              : AuthTabType.register,
                          onTabChanged: (tab) {
                            _unfocusAll();
                            ref
                                .read(authNotifierProvider.notifier)
                                .setAuthTab(tab == AuthTabType.login);
                          },
                        ),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          child: authState.isLoginTab
                              ? KeyedSubtree(
                                  key: const ValueKey('login_form'),
                                  child: LoginForm(
                                    formKey: _loginFormKey,
                                    emailController: _loginEmailCtrl,
                                    passwordController: _loginPasswordCtrl,
                                    emailFocusNode: _loginEmailFocus,
                                    passwordFocusNode: _loginPasswordFocus,
                                    onSubmitted: _handleLogin,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey('register_form'),
                                  child: RegisterForm(
                                    formKey: _regFormKey,
                                    firstNameController: _regFirstNameCtrl,
                                    lastNameController: _regLastNameCtrl,
                                    emailController: _regEmailCtrl,
                                    passwordController: _regPasswordCtrl,
                                    confirmPasswordController: _regConfirmCtrl,
                                    firstNameFocusNode: _regFirstNameFocus,
                                    lastNameFocusNode: _regLastNameFocus,
                                    emailFocusNode: _regEmailFocus,
                                    passwordFocusNode: _regPasswordFocus,
                                    confirmPasswordFocusNode: _regConfirmFocus,
                                    onSubmitted: _handleRegister,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        _buildOptionsRow(context, authState),
                        const SizedBox(height: 24),
                        _buildSubmitButton(authState),
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

  Widget _buildOptionsRow(BuildContext context, AuthState authState) {
    if (!authState.isLoginTab) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () =>
              ref.read(authNotifierProvider.notifier).toggleRememberMe(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: authState.rememberMe,
                  onChanged: (_) => ref
                      .read(authNotifierProvider.notifier)
                      .toggleRememberMe(),
                  activeColor: AppColors.authPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(
                    color: AppColors.authFieldBorder,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: AppFonts.font(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(RouteNames.forgotPassword);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: AppFonts.font(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.authPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: authState.isLoading
            ? null
            : () {
                if (authState.isLoginTab) {
                  _handleLogin();
                } else {
                  _handleRegister();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.authPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.authPurple.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: AppColors.authPurple.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: authState.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                authState.isLoginTab ? 'Login' : 'Register',
                style: AppFonts.font(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
