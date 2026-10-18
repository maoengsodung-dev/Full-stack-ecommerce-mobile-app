import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:architecture_getx/app/core/utils/media_url_resolver.dart';
import 'package:architecture_getx/app/data/models/app_language.dart';
import 'package:architecture_getx/app/data/models/user.model.dart';
import 'package:architecture_getx/app/data/models/user_role.dart';
import 'package:architecture_getx/app/core/widgets/role_switch_bottom_sheet.dart';
import 'package:architecture_getx/app/data/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final AuthRepository _repo;
  final StorageService _storage;

  ProfileController(this._repo, this._storage);

  final isLoading = false.obs;
  final isUploadingImage = false.obs;
  final user = Rxn<UserModel>();
  final currentRole = UserRole.customer.obs;
  final currentLanguage = AppLanguage.english.obs;

  final ImagePicker _picker = ImagePicker();

  // ── Convenience Getters ───────────────────────────────────────────────────

  String get userName {
    final name = user.value?.name ??
        user.value?.data?.user?.name ??
        _storage.getUser()?.name ??
        _storage.getUser()?.data?.user?.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return 'Guest User';
  }

  String get userEmail {
    final email = user.value?.email ?? user.value?.data?.user?.email;
    if (email != null && email.trim().isNotEmpty) return email.trim();
    return 'user@example.com';
  }

  String? get avatarUrl {
    final raw = user.value?.avatarUrl ?? user.value?.data?.user?.avatarUrl;
    if (raw == null || raw.trim().isEmpty) return null;
    return MediaUrlResolver.resolve(raw);
  }

  String get userInitials {
    final name = userName;
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  void onInit() {
    super.onInit();
    user.value = _storage.getUser();
    currentRole.value = UserRole.fromString(_storage.getActiveRole());
    final savedLang = _storage.getLanguage();
    currentLanguage.value =
        AppLanguage.fromCode(savedLang ?? Get.locale?.languageCode);
    fetchProfile();
  }

  void openRoleSwitcher(BuildContext context) {
    RoleSwitchBottomSheet.show(
      context,
      currentRole: currentRole.value,
    );
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final u = await _repo.getProfile();
      user.value = u;
      await _storage.saveUser(u);
      if (u.roles?.contains('admin') == true) {
        await _storage.saveIsAdmin(true);
      }
    } on DioException catch (_) {
      // Use cached user if API fails
    } finally {
      isLoading.value = false;
    }
  }

  // ── Image Upload ──────────────────────────────────────────────────────────

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      isUploadingImage.value = true;
      final updatedUser = await _repo.uploadAvatar(pickedFile.path);

      // Preserve existing token if absent in response
      final currentToken = user.value?.token ?? _storage.getToken();
      if ((updatedUser.data?.token == null || updatedUser.data!.token!.isEmpty) && currentToken != null) {
        updatedUser.data?.token = currentToken;
      }

      user.value = updatedUser;
      await _storage.saveUser(updatedUser);

      Get.snackbar(
        'Success',
        'Profile photo updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      Get.snackbar(
        'Upload Failed',
        'Could not upload profile photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              appL10n.changeProfilePhoto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              title: Text(appL10n.takeAPhoto),
              onTap: () {
                Get.back();
                pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
              title: Text(appL10n.chooseFromGallery),
              onTap: () {
                Get.back();
                pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    await _storage.clearAll();
    user.value = null;
    Get.offAllNamed('/login');
  }
}
