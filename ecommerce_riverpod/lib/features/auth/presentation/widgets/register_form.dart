import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/utils/validators.dart';

import '../providers/auth_provider.dart';
import 'auth_text_field.dart';

class RegisterForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode firstNameFocusNode;
  final FocusNode lastNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final VoidCallback onSubmitted;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
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
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'First Name',
                  hintText: 'First name',
                  controller: firstNameController,
                  focusNode: firstNameFocusNode,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (_) => lastNameFocusNode.requestFocus(),
                  validator: (v) => Validators.validateRequired(v, 'First name'),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.iconSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthTextField(
                  label: 'Last Name',
                  hintText: 'Last name',
                  controller: lastNameController,
                  focusNode: lastNameFocusNode,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (_) => emailFocusNode.requestFocus(),
                  validator: (v) => Validators.validateRequired(v, 'Last name'),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.iconSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            hintText: 'At least 8 characters',
            controller: passwordController,
            focusNode: passwordFocusNode,
            obscureText: !authState.isRegPasswordVisible,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => confirmPasswordFocusNode.requestFocus(),
            validator: Validators.validatePassword,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.iconSecondary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                authState.isRegPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.iconSecondary,
                size: 20,
              ),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).toggleRegPasswordVisibility();
              },
            ),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Confirm Password',
            hintText: 'Re-enter your password',
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            obscureText: !authState.isRegConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmitted(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != passwordController.text) return 'Passwords do not match';
              return null;
            },
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.iconSecondary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                authState.isRegConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.iconSecondary,
                size: 20,
              ),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).toggleRegConfirmPasswordVisibility();
              },
            ),
          ),
        ],
      ),
    );
  }
}
