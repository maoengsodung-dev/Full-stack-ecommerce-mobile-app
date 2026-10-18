import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/theme/app_colors.dart';
import '../providers/checkout_provider.dart';

class PromoCodeSection extends ConsumerStatefulWidget {
  const PromoCodeSection({super.key});

  @override
  ConsumerState<PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends ConsumerState<PromoCodeSection> {
  final _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promo code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFEFEF)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCtrl,
                  decoration: InputDecoration(
                    hintText: state.appliedPromo.isNotEmpty
                        ? 'Applied: ${state.appliedPromo}'
                        : 'Add a code (e.g. NEORA)',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final ok = ref
                      .read(checkoutNotifierProvider.notifier)
                      .applyPromo(_promoCtrl.text);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Promo code ${_promoCtrl.text.toUpperCase()} applied!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid promo code. Try NEORA or SAVE.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111111),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text('APPLY'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
