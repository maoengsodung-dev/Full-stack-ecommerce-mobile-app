import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/cost_summary_section.dart';
import '../widgets/delivery_address_section.dart';
import '../widgets/delivery_method_section.dart';
import '../widgets/order_summary_section.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/promo_code_section.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F8),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
          style: AppFonts.font(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111111),
          ),
        ),
      ),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            DeliveryAddressSection(),
            SizedBox(height: 16),
            DeliveryMethodSection(),
            SizedBox(height: 16),
            PaymentMethodSection(),
            SizedBox(height: 16),
            OrderSummarySection(),
            SizedBox(height: 16),
            PromoCodeSection(),
            SizedBox(height: 16),
            CostSummarySection(),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CheckoutBottomBar(),
    );
  }
}
