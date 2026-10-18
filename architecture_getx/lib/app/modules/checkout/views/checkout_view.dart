import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/cost_summary_section.dart';
import '../widgets/delivery_address_section.dart';
import '../widgets/delivery_method_section.dart';
import '../widgets/order_summary_section.dart';
import '../widgets/payment_method_section.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    CartController? cartController;
    if (Get.isRegistered<CartController>()) {
      cartController = Get.find<CartController>();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F8),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Get.back(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F1F3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          context.l10n.shoppingBag,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111111),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: Color(0xFF4A4A4A),
              ),
              onPressed: () {
                Get.snackbar(
                  'Shopping Bag',
                  'Checkout is ready to proceed.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF111111),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0267F6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF111111),
              strokeWidth: 2.5,
            ),
          );
        }

        final cart = cartController?.cart.value;
        final items = cart?.items ?? [];

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Delivery Destination Card
                  DeliveryAddressSection(controller: controller),
                  const SizedBox(height: 14),

                  // 2. Courier Service Card
                  DeliveryMethodSection(controller: controller),
                  const SizedBox(height: 14),

                  // 3. Order Manifest Card
                  OrderSummarySection(
                    controller: controller,
                    items: items,
                    formatter: fmt,
                  ),
                  const SizedBox(height: 14),

                  // 4. Payment Method Card
                  PaymentMethodSection(controller: controller),
                  const SizedBox(height: 14),

                  // 5. Cost Summary Card
                  CostSummarySection(
                    controller: controller,
                    itemsCount: items.length,
                    formatter: fmt,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Sticky Bottom Action Bar with Electric Lime "Place Order" button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CheckoutBottomBar(
                controller: controller,
              ),
            ),
          ],
        );
      }),
    );
  }
}
