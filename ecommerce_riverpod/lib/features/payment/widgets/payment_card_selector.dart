import 'package:flutter/material.dart';
import '../../../app/core/theme/app_colors.dart';

class PaymentCardSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PaymentCardSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'title': 'ABA KHQR', 'icon': Icons.qr_code_2_rounded, 'subtitle': 'Scan with ABA Mobile'},
      {'title': 'Credit / Debit Card', 'icon': Icons.credit_card_rounded, 'subtitle': 'Visa, Mastercard, JCB'},
      {'title': 'UnionPay', 'icon': Icons.account_balance_rounded, 'subtitle': 'UnionPay International'},
    ];

    return Column(
      children: List.generate(methods.length, (index) {
        final m = methods[index];
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    m['icon'] as IconData,
                    size: 24,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
