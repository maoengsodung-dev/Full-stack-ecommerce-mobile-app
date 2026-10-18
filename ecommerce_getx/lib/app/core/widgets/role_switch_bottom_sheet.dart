import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_fonts.dart';
import '../utils/l10n_extensions.dart';

import '../../data/models/user_role.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';

class RoleSwitchBottomSheet extends StatelessWidget {
  final UserRole currentRole;

  const RoleSwitchBottomSheet({super.key, required this.currentRole});

  static Future<void> show(
    BuildContext context, {
    UserRole? currentRole,
  }) async {
    final storage = Get.find<StorageService>();
    final resolvedRole =
        currentRole ?? UserRole.fromString(storage.getActiveRole());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoleSwitchBottomSheet(currentRole: resolvedRole),
    );
  }

  static void _onRoleSelected(UserRole role, UserRole current) async {
    final storage = Get.find<StorageService>();
    await storage.saveActiveRole(role.name);
    if (role == UserRole.admin) {
      await storage.saveIsAdmin(true);
      if (Get.isRegistered<ApiClient>()) {
        Get.find<ApiClient>().ensureAdminToken();
      }
    }

    Get.back(); // Dismiss bottom sheet

    if (role == current) {
      if (role == UserRole.admin) {
        Get.toNamed(role.route);
        return;
      }
      Get.snackbar(
        'Already Active',
        'You are currently in ${role.displayName} mode.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF334155),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.snackbar(
      'Role Switched',
      'Navigated to ${role.displayName} portal',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      icon: Icon(role.icon, color: Colors.white, size: 20),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    // Navigate to role's entry route
    Get.offAllNamed(role.route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),

              // Sheet Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.switch_account_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.switchAccountRole,
                          style: AppFonts.font(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          context.l10n.switchAccountRoleSubtitle,
                          style: AppFonts.font(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Role Cards List
              ...UserRole.values.map((role) {
                final isActive = role == currentRole;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRoleItem(
                    role: role,
                    isActive: isActive,
                    onTap: () => _onRoleSelected(role, currentRole),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleItem({
    required UserRole role,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    String suffix;
    switch (role) {
      case UserRole.customer:
        suffix = 'Store';
        break;
      case UserRole.admin:
        suffix = 'Dashboard';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? role.badgeColor.withValues(alpha: 0.6)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? role.textColor.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Role Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: role.badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(role.icon, color: role.textColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${role.displayName} $suffix',
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: role.textColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              appL10n.active.toUpperCase(),
                              style: AppFonts.font(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.description,
                      style: AppFonts.font(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing action
              Icon(
                isActive
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: isActive ? 22 : 15,
                color: isActive ? role.textColor : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
