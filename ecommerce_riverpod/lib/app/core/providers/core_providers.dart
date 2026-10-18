import 'package:architecture_getx/app/core/providers/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_language.dart';
import '../../data/models/user_role.dart';


// App Language Notifier
class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final storage = ref.watch(storageServiceProvider);
    final savedCode = storage.getLanguage();
    return AppLanguage.fromCode(savedCode);
  }

  void setLanguage(AppLanguage language) {
    final storage = ref.read(storageServiceProvider);
    storage.saveLanguage(language.code);
    state = language;
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, AppLanguage>(
      AppLanguageNotifier.new,
    );

// Active User Role Notifier
class ActiveRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() {
    final storage = ref.watch(storageServiceProvider);
    return UserRole.fromString(storage.getActiveRole());
  }

  void setRole(UserRole role) {
    final storage = ref.read(storageServiceProvider);
    storage.saveActiveRole(role.name);
    if (role == UserRole.admin) {
      storage.saveIsAdmin(true);
    }
    state = role;
  }
}

final activeRoleProvider =
    NotifierProvider<ActiveRoleNotifier, UserRole>(
      ActiveRoleNotifier.new,
    );
