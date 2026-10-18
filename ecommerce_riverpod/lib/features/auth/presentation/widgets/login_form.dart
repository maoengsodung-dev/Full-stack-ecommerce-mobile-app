import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/utils/validators.dart';

import '../providers/auth_provider.dart';
import 'auth_text_field.dart';

class LoginForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onSubmitted;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            label: 'Email',
            hintText: 'Enter your email',
            controller: emailController,
            focusNode: emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
            validator: Validators.validateEmail,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.iconSecondary,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Password',
            hintText: 'Enter your password',
            controller: passwordController,
            focusNode: passwordFocusNode,
            obscureText: !authState.isPasswordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmitted(),
            validator: (v) => Validators.validateRequired(v, 'Password'),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.iconSecondary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                authState.isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.iconSecondary,
                size: 20,
              ),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).togglePasswordVisibility();
              },
            ),
          ),
        ],
      ),
    );
  }
}
