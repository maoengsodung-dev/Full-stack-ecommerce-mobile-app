import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../providers/cart_provider.dart';

class CartSummary extends ConsumerStatefulWidget {
  const CartSummary({
    super.key,
    required this.formatter,
  });

  final NumberFormat formatter;

  @override
  ConsumerState<CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends ConsumerState<CartSummary> {
  final TextEditingController _voucherInputController =
      TextEditingController();

  @override
  void dispose() {
    _voucherInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPrivilegeCard(context),
        const SizedBox(height: 16),
        _buildOrderSummaryCard(context),
      ],
    );
  }

  Widget _buildPrivilegeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.authFieldBorder,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherInputController,
                  style: AppFonts.font(
                    fontSize: 12,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Have another gift voucher?',
                    hintStyle: AppFonts.font(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final text = _voucherInputController.text;
                  if (text.trim().isNotEmpty) {
                    ref.read(cartNotifierProvider.notifier).applyPromo(text);
                    _voucherInputController.clear();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'APPLY',
                      style: AppFonts.font(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final subtotal = cartState.subtotal;
    final tax = cartState.taxAmount;
    final total = cartState.grandTotal;
    final itemCount = cartState.itemCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppFonts.font(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),
          _summaryRow(
            context,
            label: 'Subtotal ($itemCount ${itemCount == 1 ? "item" : "items"})',
            value: '\$${subtotal.toStringAsFixed(2)}',
            isBoldValue: true,
          ),
          // size product
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Size',
                style: AppFonts.font(
                  fontSize: 13,
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                cartState.cart.value!.items[0].variant?.size ?? 'Null',
                style: AppFonts.font(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),



          const SizedBox(height: 12),
          // Qt
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Quantity',
                style: AppFonts.font(
                  fontSize: 13,
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'x${cartState.cart.value!.items[0].quantity.toString()}',
                style: AppFonts.font(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          //Delivery

          const SizedBox(height: 12),
          _summaryRow(
            context,
            label: 'Estimated Tax',
            value: '\$${tax.toStringAsFixed(2)}',
            isBoldValue: true,
          ),
          const SizedBox(height: 22),

          // total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Amount',
                style: AppFonts.font(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppFonts.font(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.font(
            fontSize: 13,
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppFonts.font(
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
