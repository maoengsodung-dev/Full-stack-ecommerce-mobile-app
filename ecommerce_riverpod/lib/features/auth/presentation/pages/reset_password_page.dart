import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/core/theme/app_text_styles.dart';
import '../../../../app/core/utils/validators.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String? token;
  final String? email;

  const ResetPasswordPage({super.key, this.token, this.email});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  late final TextEditingController _emailCtrl;
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.email ?? '');
    _tokenCtrl.text = widget.token ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authNotifierProvider.notifier).resetPassword(
          token: _tokenCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirmation: _confirmCtrl.text,
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please log in.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final authState = ref.read(authNotifierProvider);
      final errorMsg = authState.actionState.hasError
          ? authState.actionState.error.toString()
          : 'Failed to reset password.';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reset Password',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set New Password',
                  style: AppFonts.font(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new strong password for your account.',
                  style: AppFonts.font(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Reset Token',
                  hintText: 'Enter reset token from email',
                  controller: _tokenCtrl,
                  validator: (v) =>
                      Validators.validateRequired(v, 'Reset token'),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'New Password',
                  hintText: 'At least 8 characters',
                  controller: _passwordCtrl,
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Confirm New Password',
                  hintText: 'Re-enter new password',
                  controller: _confirmCtrl,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (v != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.authPurple,
                      foregroundColor: Colors.white,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Reset Password',
                            style: AppFonts.font(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
