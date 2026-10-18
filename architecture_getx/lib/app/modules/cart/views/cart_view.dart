import 'package:architecture_getx/app/core/constants/asset_constants.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:architecture_getx/app/core/theme/app_fonts.dart';
import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:architecture_getx/app/core/widgets/empty_state_widget.dart';
import 'package:architecture_getx/app/core/widgets/loading_widget.dart';

import '../../../routes/app_pages.dart';
import '../../main_page/controllers/main_controller.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final fmt = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: _buildAppBar(controller, context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ShimmerList(count: 3);
        }

        if (controller.errorMessage.value.isNotEmpty &&
            (controller.cart.value?.items.isEmpty ?? true)) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: controller.fetchCart,
          );
        }

        final items = controller.cart.value?.items ?? [];

        // EMPTY CART
        if (items.isEmpty) {
          return EmptyStateWidget(
            assetName: AssetConstants.product,
            title: context.l10n.yourShoppingBagIsEmpty,
            subtitle: context.l10n.emptyCartSubtitle,
            actionLabel: context.l10n.shopNow,
            onAction: () {
              if (Get.isRegistered<MainController>()) {
                Get.find<MainController>().changeScreen(0);
              } else {
                Get.offAllNamed(Routes.SHELL);
              }
            },
          );
        }

        // CART HAS ITEMS
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF0F172A),
                onRefresh: controller.fetchCart,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    20,
                  ),
                  child: Column(
                    children: [
                      ...items.map(
                            (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CartItemCard(
                            item: item,
                            controller: controller,
                            formatter: fmt,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      CartSummary(
                        controller: controller,
                        formatter: fmt,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _buildCheckoutBottomBar(controller),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(
      CartController controller,
      BuildContext context,
      ) {
    return AppBar(
      backgroundColor: const Color(0xFFFAF9F6),
      elevation: 0,
      centerTitle: true,
      title: Text(
        context.l10n.cart,
        style: AppFonts.font(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: [
        Obx(() {
          final hasItems =
              controller.cart.value?.items.isNotEmpty ?? false;

          if (!hasItems) {
            return const SizedBox(width: 48);
          }

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _showClearDialog(controller),
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 23,
                color: Color(0xFF475569),
              ),
              tooltip: context.l10n.clearShoppingBag,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCheckoutBottomBar(
      CartController controller,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final total = controller.grandTotal;

          return GestureDetector(
            onTap: () => Get.toNamed(Routes.CHECKOUT),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFC7F000),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Text(
                    appL10n.proceedToCheckout,
                    style: AppFonts.font(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppFonts.font(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Color(0xFF0F172A),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showClearDialog(CartController ctrl) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          appL10n.clearShoppingBag,
          style: AppFonts.font(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          appL10n.clearCartConfirm,
          style: AppFonts.font(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              appL10n.cancel,
              style: AppFonts.font(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.clearCart();
            },
            child: Text(
              appL10n.clear,
              style: AppFonts.font(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}