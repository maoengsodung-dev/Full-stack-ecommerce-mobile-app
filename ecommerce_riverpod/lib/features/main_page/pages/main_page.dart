import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/core/constants/asset_constants.dart';
import '../../../app/core/constants/icons.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../cart/presentation/pages/cart_page.dart';
import '../../cart/presentation/providers/cart_provider.dart';
import '../../home/pages/home_page.dart';
import '../../orders/pages/orders_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../wishlist/pages/wishlist_page.dart';
import '../providers/main_page_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  static const List<Widget> _screens = [
    HomePage(),
    WishlistPage(),
    CartPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainPageNotifierProvider);
    final notifier = ref.read(mainPageNotifierProvider.notifier);
    final cartState = ref.watch(cartNotifierProvider);
    final cartCount = cartState.itemCount;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Active Screen
          IndexedStack(index: selectedIndex, children: _screens),

          // Frosted Glass Blur & Gradient overlay behind the floating navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 85,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xffF7F7F8).withValues(alpha: 0.0),
                          const Color(0xffF7F7F8).withValues(alpha: 0.6),
                          const Color(0xffF7F7F8).withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(100, 100, 111, 0.2),
              blurRadius: 29,
              spreadRadius: 0,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: AssetConstants.home,
              title: context.l10n.home,
              index: 0,
              selectedIndex: selectedIndex,
              onTap: () => notifier.setIndex(0),
            ),
            _buildWishlistNavItem(
              context: context,
              index: 1,
              selectedIndex: selectedIndex,
              onTap: () => notifier.setIndex(1),
            ),
            _buildCartNavItem(
              context: context,
              index: 2,
              selectedIndex: selectedIndex,
              count: cartCount,
              onTap: () => notifier.setIndex(2),
            ),
            _buildNavItem(
              icon: AssetConstants.order,
              title: context.l10n.myOrder,
              index: 3,
              selectedIndex: selectedIndex,
              onTap: () => notifier.setIndex(3),
            ),

            _buildNavItem(
              icon: AssetConstants.user,
              title: context.l10n.account,
              index: 4,
              selectedIndex: selectedIndex,
              onTap: () => notifier.setIndex(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String title,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final active = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                icon,
                color: active ? AppColors.primary : const Color(0xff6D6D6D),
                width: 20,
                height: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: active ? AppColors.primary : const Color(0xff6D6D6D),
                  fontSize: active ? 12 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required int count,
    required VoidCallback onTap,
  }) {
    final active = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    AssetConstants.cart,
                    color: active ? AppColors.primary : const Color(0xff6D6D6D),
                    width: 20,
                    height: 20,
                  ),
                  if (count > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.cart,
                style: TextStyle(
                  color: active ? AppColors.primary : const Color(0xff6D6D6D),
                  fontSize: active ? 12 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final active = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                kLove,
                colorFilter: ColorFilter.mode(
                  active ? AppColors.primary : const Color(0xff6D6D6D),
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.wishlist,
                style: TextStyle(
                  color: active ? AppColors.primary : const Color(0xff6D6D6D),
                  fontSize: active ? 12 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
