import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/providers/storage_providers.dart';

class SplashState {
  final int currentPage;
  final bool hasToken;
  final bool isAdmin;

  const SplashState({
    this.currentPage = 0,
    this.hasToken = false,
    this.isAdmin = false,
  });

  SplashState copyWith({
    int? currentPage,
    bool? hasToken,
    bool? isAdmin,
  }) {
    return SplashState(
      currentPage: currentPage ?? this.currentPage,
      hasToken: hasToken ?? this.hasToken,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    final storageService = ref.watch(storageServiceProvider);
    final user = storageService.getUser();
    final roles = user?.roles ?? user?.data?.user?.roles ?? [];
    final isAdmin = storageService.isAdmin ||
        roles.any((r) => r.toLowerCase().contains('admin')) ||
        user?.isAdmin == true ||
        (storageService.getAdminToken() != null &&
            storageService.getAdminToken()!.isNotEmpty) ||
        storageService.getActiveRole().toLowerCase() == 'admin';

    return SplashState(
      currentPage: 0,
      hasToken: storageService.hasToken,
      isAdmin: isAdmin,
    );
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(() {
  return SplashNotifier();
});
