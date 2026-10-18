import 'package:flutter/material.dart';
import '../../data/models/user_role.dart';
import '../router/app_router.dart';
import '../services/storage_service.dart';
import '../utils/l10n_extensions.dart';


class RoleSwitchBottomSheet extends StatelessWidget {
  final UserRole currentRole;
  final ValueChanged<UserRole>? onRoleSelected;

  const RoleSwitchBottomSheet({
    super.key,
    required this.currentRole,
    this.onRoleSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required UserRole currentRole,
    StorageService? storageService,
    ValueChanged<UserRole>? onRoleSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoleSwitchBottomSheet(
        currentRole: currentRole,
        onRoleSelected: (role) async {
          if (storageService != null) {
            await storageService.saveActiveRole(role.name);
            if (role == UserRole.admin) {
              await storageService.saveIsAdmin(true);
              final token = storageService.getToken();
              if (token != null &&
                  (storageService.getAdminToken() == null ||
                      storageService.getAdminToken()!.isEmpty)) {
                await storageService.saveAdminToken(token);
              }
            }
          }
          if (context.mounted) {
            Navigator.pop(ctx);
          }
          onRoleSelected?.call(role);
          if (role != currentRole) {
            AppRouter.pushNamedAndRemoveUntil(role.route);
          }
        },
      ),
    );
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
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          context.l10n.switchAccountRoleSubtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...UserRole.values.map((role) {
                final isActive = role == currentRole;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRoleItem(
                    context: context,
                    role: role,
                    isActive: isActive,
                    onTap: () {
                      if (onRoleSelected != null) {
                        onRoleSelected!(role);
                      } else {
                        Navigator.pop(context);
                        if (role != currentRole) {
                          AppRouter.pushNamedAndRemoveUntil(role.route);
                        }
                      }
                    },
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
    required BuildContext context,
    required UserRole role,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final suffix = role == UserRole.admin ? 'Dashboard' : 'Store';

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
                ? role.badgeColor.withOpacity(0.6)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? role.textColor.withOpacity(0.5)
                  : const Color(0xFFE2E8F0),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${role.displayName} $suffix',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
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
                              context.l10n.active.toUpperCase(),
                              style: const TextStyle(
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
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
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
