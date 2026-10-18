import 'package:flutter/material.dart';
import '../../../../app/core/theme/app_fonts.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final bool showBackButton;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.font(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppFonts.font(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
