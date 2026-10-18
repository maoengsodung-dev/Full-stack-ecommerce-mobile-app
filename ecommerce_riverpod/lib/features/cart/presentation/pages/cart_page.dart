import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


import '../../../../app/core/constants/asset_constants.dart';
import '../../../../app/core/router/route_names.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/core/utils/l10n_extensions.dart';
import '../../../../app/core/widgets/empty_state_widget.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final fmt = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: _buildAppBar(context, ref, cartState),
      body: cartState.cart.when(
        loading: () => const ShimmerList(count: 3),
        error: (err, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load cart: $err', textAlign: TextAlign.center,),
                  const SizedBox(height: 12),
                  SizedBox(height: 45,
                    child: ElevatedButton(
                      onPressed: () =>
                          ref.read(cartNotifierProvider.notifier).fetchCart(),
                      child: Text(context.l10n.retry),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        data: (cart) {
          final items = cart.items;

          if (items.isEmpty) {
            return EmptyStateWidget(
              assetName: AssetConstants.product,
              title: context.l10n.yourShoppingBagIsEmpty,
              subtitle: context.l10n.emptyCartSubtitle,
              actionLabel: context.l10n.shopNow,
              onAction: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.shell,
                  (route) => false,
                );
              },
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF0F172A),
                  onRefresh: () async {
                    await ref
                        .read(cartNotifierProvider.notifier)
                        .fetchCart();
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Column(
                      children: [
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: CartItemCard(
                              item: item,
                              formatter: fmt,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        CartSummary(formatter: fmt),
                      ],
                    ),
                  ),
                ),
              ),
              _buildCheckoutBottomBar(context, ref, cartState),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final hasItems = cartState.cartData?.items.isNotEmpty ?? false;

    return AppBar(
      backgroundColor: const Color(0xFFFAF9F6),
      automaticallyImplyLeading: false,
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
        if (hasItems)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _showClearDialog(context, ref),
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 23,
                color: Color(0xFF475569),
              ),
              tooltip: context.l10n.clearShoppingBag,
            ),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildCheckoutBottomBar(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final total = cartState.grandTotal;

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
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(RouteNames.checkout);
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                Text(
                  context.l10n.proceedToCheckout,
                  style: AppFonts.font(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color:AppColors.surface,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppFonts.font(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.surface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          context.l10n.clearShoppingBag,
          style: AppFonts.font(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          context.l10n.clearCartConfirm,
          style: AppFonts.font(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.cancel,
              style: AppFonts.font(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cartNotifierProvider.notifier).clearCart();
            },
            child: Text(
              context.l10n.clear,
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
