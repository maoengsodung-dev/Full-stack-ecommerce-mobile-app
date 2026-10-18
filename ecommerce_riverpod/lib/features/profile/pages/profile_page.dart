import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/constants/icons.dart';
import '../../../app/core/providers/core_providers.dart';
import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/core/widgets/role_switch_bottom_sheet.dart';
import '../../notification/providers/notification_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final profileNotifier = ref.read(profileNotifierProvider.notifier);
    final currentLang = ref.watch(appLanguageProvider);
    final notifState = ref.watch(notificationNotifierProvider);
    final unreadCount = notifState.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.accountAndSettings,
                      style: AppFonts.font(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar & Image Upload
              Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFE8F4F8),
                    backgroundImage: profileState.avatarUrl != null &&
                            profileState.avatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(profileState.avatarUrl!)
                        : null,
                    child: profileState.avatarUrl == null ||
                            profileState.avatarUrl!.isEmpty
                        ? Text(
                            profileState.userInitials,
                            style: AppFonts.font(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  if (profileState.isUploadingImage)
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
                      onTap: () => _showImagePickerOptions(context, profileNotifier),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // User Name & Email
              Text(
                profileState.userName,
                style: AppFonts.font(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profileState.userEmail,
                style: AppFonts.font(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Settings Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Language
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: SvgPicture.asset(
                        AssetConstants.languages,
                        width: 22,
                        height: 22,
                      ),
                      title: Text(
                        context.l10n.languages,
                        style: AppFonts.font(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: currentLang.badgeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${currentLang.flag} ${currentLang.displayName}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: currentLang.textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.navigate_next, color: AppColors.textHint),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteNames.language);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),

                    // My Orders
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: SvgPicture.asset(kHistory, width: 22, height: 22),
                      title: Text(
                        context.l10n.myOrders,
                        style: AppFonts.font(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.navigate_next, color: AppColors.textHint),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteNames.orders);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),

                    // Notifications
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: SvgPicture.asset(kNotification, width: 22, height: 22),
                      title: Text(
                        context.l10n.notifications,
                        style: AppFonts.font(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unreadCount > 0)
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
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          const Icon(Icons.navigate_next, color: AppColors.textHint),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteNames.notification);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),

                    // Address
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: SvgPicture.asset(kLocation, width: 22, height: 22),
                      title: Text(
                        context.l10n.address,
                        style: AppFonts.font(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.navigate_next, color: AppColors.textHint),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteNames.addressList);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),

                    // Support
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: SvgPicture.asset(kSupport, width: 22, height: 22),
                      title: Text(
                        context.l10n.helpSupport,
                        style: AppFonts.font(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.navigate_next, color: AppColors.textHint),
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),

                    // Help Center
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: SvgPicture.asset(kHelp, width: 22, height: 22),
                      title: Text(
                        context.l10n.helpCenter,
                        style: AppFonts.font(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.navigate_next, color: AppColors.textHint),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: SvgPicture.asset(bLogout, width: 22, height: 22),
                  title: Text(
                    context.l10n.logout,
                    style: AppFonts.font(
                      fontSize: 14,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next, color: AppColors.textHint),
                  onTap: () => _showLogoutDialog(context, profileNotifier),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(
    BuildContext context,
    ProfileNotifier profileNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                context.l10n.changeProfilePhoto,
                style: AppFonts.font(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text(context.l10n.takeAPhoto),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok = await profileNotifier.pickAndUploadImage(ImageSource.camera);
                  if (context.mounted && ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile photo updated successfully!')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok = await profileNotifier.pickAndUploadImage(ImageSource.gallery);
                  if (context.mounted && ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile photo updated successfully!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    ProfileNotifier profileNotifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.logout),
        content: Text(context.l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await profileNotifier.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.login,
                  (route) => false,
                );
              }
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
