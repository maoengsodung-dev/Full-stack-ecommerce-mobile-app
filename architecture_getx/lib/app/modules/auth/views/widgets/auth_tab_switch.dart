import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthTabType { login, register }

class AuthTabSwitch extends StatelessWidget {
  final AuthTabType activeTab;
  final ValueChanged<AuthTabType>? onTabChanged;

  const AuthTabSwitch({
    super.key,
    required this.activeTab,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.authTabBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'Login',
              isActive: activeTab == AuthTabType.login,
              onTap: () {
                if (activeTab != AuthTabType.login) {
                  onTabChanged?.call(AuthTabType.login);
                }
              },
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: 'Sign Up',
              isActive: activeTab == AuthTabType.register,
              onTap: () {
                if (activeTab != AuthTabType.register) {
                  onTabChanged?.call(AuthTabType.register);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
