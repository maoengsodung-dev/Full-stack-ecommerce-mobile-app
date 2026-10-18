import 'package:architecture_getx/app/core/constants/asset_constants.dart';
import 'package:architecture_getx/app/core/constants/icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import '../../../routes/app_pages.dart';
import '../../notification/controllers/notification_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Top Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.accountAndSettings,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () => controller.openRoleSwitcher(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz_rounded,
                                size: 16,
                                color: controller.currentRole.value.textColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.switchText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: controller.currentRole.value.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar & Image Upload Button
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFE8F4F8),
                      backgroundImage:
                          controller.avatarUrl != null &&
                              controller.avatarUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(controller.avatarUrl!)
                          : null,
                      child:
                          controller.avatarUrl == null ||
                              controller.avatarUrl!.isEmpty
                          ? Text(
                              controller.userInitials,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    if (controller.isUploadingImage.value)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller.showImagePickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── User Name & Email
                Text(
                  controller.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // ── Quick Role Switch Banner
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Change Language
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        leading: SvgPicture.asset(AssetConstants.languages),
                        title: Text(
                          context.l10n.languages,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Obx(() {
                          final lang = controller.currentLanguage.value;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: lang.badgeColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${lang.flag} ${lang.displayName}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: lang.textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.navigate_next),
                            ],
                          );
                        }),
                        onTap: () => Get.toNamed(Routes.LANGUAGE),
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      // History Order
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        leading: SvgPicture.asset(kHistory),
                        title: Text(
                          context.l10n.myOrders,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.navigate_next),
                        onTap: () {
                          Get.toNamed(Routes.ORDERS);
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),

                      // Notification
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        leading: SvgPicture.asset(kNotification),
                        title: Text(
                          context.l10n.notifications,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Obx(() {
                          final notifCtrl =
                              Get.isRegistered<NotificationController>()
                                  ? Get.find<NotificationController>()
                                  : null;
                          final count = notifCtrl?.unreadCount ?? 0;

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (count > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count > 99 ? '99+' : '$count',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 4),
                              const Icon(Icons.navigate_next),
                            ],
                          );
                        }),
                        onTap: () {
                          Get.toNamed(Routes.NOTIFICATION);
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),

                      // Address
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        leading: SvgPicture.asset(kLocation),
                        title: Text(
                          context.l10n.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.navigate_next),
                        onTap: () {
                          Get.toNamed(Routes.ADDRESS_LIST);
                        },
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      // Switch Role
                      // ListTile(
                      //   contentPadding: const EdgeInsets.symmetric(
                      //     horizontal: 15,
                      //   ),
                      //   leading: Container(
                      //     padding: const EdgeInsets.all(6),
                      //     decoration: BoxDecoration(
                      //       color: const Color(0xFFEFF6FF),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: const Icon(
                      //       Icons.switch_account_rounded,
                      //       color: Color(0xFF2563EB),
                      //       size: 20,
                      //     ),
                      //   ),
                      //   title: const Text(
                      //     'Switch Role',
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w600,
                      //       color: AppColors.textPrimary,
                      //     ),
                      //   ),
                      //   subtitle: const Text(
                      //     'Switch between Customer & Admin',
                      //     style: TextStyle(
                      //       fontSize: 11,
                      //       color: AppColors.textSecondary,
                      //     ),
                      //   ),
                      //   trailing: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Container(
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 8,
                      //           vertical: 3,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: controller.currentRole.value.badgeColor,
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //         child: Text(
                      //           controller.currentRole.value.displayName,
                      //           style: TextStyle(
                      //             fontSize: 11,
                      //             fontWeight: FontWeight.w700,
                      //             color: controller.currentRole.value.textColor,
                      //           ),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 4),
                      //       const Icon(Icons.navigate_next),
                      //     ],
                      //   ),
                      //   onTap: () => controller.openRoleSwitcher(context),
                      // ),
                      Divider(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      // Support
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        leading: SvgPicture.asset(kSupport),
                        title: Text(
                          context.l10n.helpSupport,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.navigate_next),
                        onTap: () {},
                      ),
                      Divider(
                        height: 1,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      // Help
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        leading: SvgPicture.asset(kHelp),
                        title: Text(
                          context.l10n.helpCenter,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.navigate_next),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    leading: SvgPicture.asset(bLogout),
                    title: Text(
                      context.l10n.logout,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      // showDialog
                      _showLogoutDialog(context);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(context.l10n.logout),
        content: Text(context.l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text(
              context.l10n.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
