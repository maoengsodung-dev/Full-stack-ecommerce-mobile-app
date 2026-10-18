import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/core/utils/media_url_resolver.dart';
import '../../../app/data/models/user.model.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/core/providers/storage_providers.dart';

import '../../auth/presentation/providers/auth_provider.dart';

class ProfileState {
  final AsyncValue<UserModel?> user;
  final bool isUploadingImage;

  const ProfileState({
    this.user = const AsyncValue.data(null),
    this.isUploadingImage = false,
  });

  String get userName {
    final u = user.value;
    final name = u?.name ?? u?.data?.user?.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return 'Guest User';
  }

  String get userEmail {
    final u = user.value;
    final email = u?.email ?? u?.data?.user?.email;
    if (email != null && email.trim().isNotEmpty) return email.trim();
    return 'user@example.com';
  }

  String? get avatarUrl {
    final u = user.value;
    final raw = u?.avatarUrl ?? u?.data?.user?.avatarUrl;
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

  ProfileState copyWith({
    AsyncValue<UserModel?>? user,
    bool? isUploadingImage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  final ImagePicker _picker = ImagePicker();

  @override
  ProfileState build() {
    final storage = ref.watch(storageServiceProvider);
    final cached = storage.getUser();
    Future.microtask(() => fetchProfile());
    return ProfileState(user: AsyncValue.data(cached));
  }

  Future<void> fetchProfile() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final u = await repo.getProfile();
      final storage = ref.read(storageServiceProvider);
      await storage.saveUser(u);
      if (u.roles?.contains('admin') == true) {
        await storage.saveIsAdmin(true);
      }
      state = state.copyWith(user: AsyncValue.data(u));
    } catch (e, st) {
      // Keep cached user if fetch fails
      if (state.user.value == null) {
        state = state.copyWith(user: AsyncValue.error(e, st));
      }
    }
  }

  Future<bool> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return false;

      state = state.copyWith(isUploadingImage: true);
      final repo = ref.read(authRepositoryProvider);
      final updatedUser = await repo.uploadAvatar(file.path);

      final storage = ref.read(storageServiceProvider);
      final currentToken = state.user.value?.token ?? storage.getToken();
      if ((updatedUser.data?.token == null || updatedUser.data!.token!.isEmpty) &&
          currentToken != null) {
        updatedUser.data?.token = currentToken;
      }

      await storage.saveUser(updatedUser);
      state = state.copyWith(
        user: AsyncValue.data(updatedUser),
        isUploadingImage: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(isUploadingImage: false);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    state = const ProfileState();
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
