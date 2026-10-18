import 'dart:ui';

import 'package:architecture_getx/app/core/constants/icons.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';


class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Active Screen
          Obx(() => controller.screens[controller.selectIndex.value]),

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

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
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
                    navItem(kHome, context.l10n.home, 0),
                    _cartNavItem(context),
                    navItem(kOrder, context.l10n.myOrder, 2),
                    _wishlistNavItem(context),
                    navItem(kUser, context.l10n.account, 4),
                  ],
                ),
              ),
            ),
            // const SizedBox(width: 6),
            //
            // // Search Product
            // GestureDetector(
            //   onTap: () {
            //     Get.toNamed(Routes.SEARCH_PRODUCT);
            //   },
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.white.withValues(alpha: 0.3),
            //       borderRadius: BorderRadius.circular(50),
            //       border: Border.all(color: Colors.white, width: 2),
            //       boxShadow: const [
            //         BoxShadow(
            //           color: Color.fromRGBO(100, 100, 111, 0.2),
            //           blurRadius: 29,
            //           spreadRadius: 0,
            //           offset: Offset(0, 7),
            //         ),
            //       ],
            //     ),
            //     height: 60,
            //     width: 60,
            //     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            //     child: Center(
            //       child: Image.asset('$kSearch',height: 24,width: 24, color: Colors.black),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget navItem(String icon, String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeScreen(index),
        child: Obx(() {
          bool active = controller.selectIndex.value == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: active ? Colors.white : null,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    icon,
                    color: active ? const Color(0xff6A5FF5) : const Color(0xff6D6D6D),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? const Color(0xff6A5FF5) : const Color(0xff6D6D6D),
                      fontSize: active ? 12 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _cartNavItem(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeScreen(1),
        child: Obx(() {
          final bool active = controller.selectIndex.value == 1;
          final int count = Get.isRegistered<CartController>()
              ? Get.find<CartController>().itemCount
              : 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: active ? Colors.white : null,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        iCart,
                        color: active
                            ? const Color(0xff6A5FF5)
                            : const Color(0xff6D6D6D),
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
                      color: active
                          ? const Color(0xff6A5FF5)
                          : const Color(0xff6D6D6D),
                      fontSize: active ? 12 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _wishlistNavItem(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeScreen(3),
        child: Obx(() {
          final bool active = controller.selectIndex.value == 3;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: active ? Colors.white : null,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    kLove,
                    colorFilter: ColorFilter.mode(
                      active ? const Color(0xff6A5FF5) : const Color(0xff6D6D6D),
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.wishlist,
                    style: TextStyle(
                      color: active ? const Color(0xff6A5FF5) : const Color(0xff6D6D6D),
                      fontSize: active ? 12 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
