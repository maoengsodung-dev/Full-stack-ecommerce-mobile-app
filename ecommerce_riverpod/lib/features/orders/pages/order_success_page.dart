import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../../../app/core/theme/app_fonts.dart';
import '../../../app/core/utils/l10n_extensions.dart';
import '../../../app/data/models/order.model.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../providers/order_provider.dart';

class OrderSuccessPage extends ConsumerStatefulWidget {
  final OrderRes? order;
  final String paymentMethod;

  const OrderSuccessPage({
    super.key,
    this.order,
    this.paymentMethod = 'ABA Payway',
  });

  @override
  ConsumerState<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends ConsumerState<OrderSuccessPage> {
  OrderRes? _resolvedOrder;
  String? _resolvedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _resolvedOrder = widget.order;
    _resolvedPaymentMethod = widget.paymentMethod;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartNotifierProvider.notifier).clearCart();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedOrder == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is OrderRes) {
        _resolvedOrder = args;
      } else if (args is Map<String, dynamic>) {
        if (args['order'] is OrderRes) {
          _resolvedOrder = args['order'] as OrderRes;
        }
        if (args['paymentMethod'] is String) {
          _resolvedPaymentMethod = args['paymentMethod'] as String;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _resolvedOrder ?? widget.order;
    final paymentMethod = _resolvedPaymentMethod ?? widget.paymentMethod;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final orderNumber = order?.orderNumber ?? '';

    final userName = (order?.shippingAddress?.recipientName.isNotEmpty == true)
        ? order!.shippingAddress!.recipientName.split(' ').first
        : '';

    final subtotalVal = order?.subtotal ?? 0.0;
    final discountVal = order?.discount ?? 0.0;
    final shippingFeeVal = order?.shippingFee ?? 0.0;
    final totalVal =
        order?.total ?? (subtotalVal - discountVal + shippingFeeVal);

    final items = order?.items ?? [];
    final piecesCount = items.isNotEmpty
        ? items.fold<int>(0, (sum, it) => sum + it.quantity)
        : 0;

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
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.main,
                  (route) => false,
                );
              },
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
                    Icons.close_rounded,
                    size: 19,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          context.l10n.orderConfirmation,
          style: AppFonts.font(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111111),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        child: Column(
          children: [
            // Top Confirmation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFECECF0), width: 1.0),
              ),
              child: Column(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                    child: Center(
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.atelierDispatchConfirmed,
                    style: AppFonts.font(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: const Color(0xFF4D7C0F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.orderConfirmed,
                    style: AppFonts.font(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (orderNumber.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: orderNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order #$orderNumber copied to clipboard'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Order #$orderNumber',
                              style: AppFonts.font(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: Color(0xFF555555),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.orderThankYou(
                      userName.isNotEmpty ? userName : '',
                    ),
                    textAlign: TextAlign.center,
                    style: AppFonts.font(
                      fontSize: 12.5,
                      color: const Color(0xFF555555),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Manifest Card
            if (items.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFECECF0),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.orderManifest,
                          style: AppFonts.font(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECECEF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$piecesCount ${context.l10n.pieces}',
                            style: AppFonts.font(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF555555),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(items.length, (idx) {
                      final it = items[idx];
                      final variantStr = [
                        if (it.color != null && it.color!.isNotEmpty) it.color,
                        if (it.size != null && it.size!.isNotEmpty) it.size,
                      ].join(' • ');

                      return Column(
                        children: [
                          if (idx > 0)
                            const Divider(color: Color(0xFFF0F0F3), height: 24),
                          _buildManifestItem(
                            title: it.product.name,
                            category: it.product.category?.name.toUpperCase() ?? '',
                            variant: variantStr,
                            priceText: fmt.format(it.subtotal),
                            qty: it.quantity,
                            imageUrl: it.product.primaryImage?.url,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Payment & Total Authorized Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFECECF0), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.contactless_rounded,
                            size: 20,
                            color: Color(0xFF111111),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            paymentMethod,
                            style: AppFonts.font(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.l10n.paid,
                          style: AppFonts.font(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _costRow(context.l10n.subTotal, fmt.format(subtotalVal)),
                  if (discountVal > 0) ...[
                    const SizedBox(height: 10),
                    _costRow(
                      context.l10n.discount,
                      '-${fmt.format(discountVal)}',
                      isDiscount: true,
                    ),
                  ],
                  const SizedBox(height: 10),
                  _costRow(
                    context.l10n.courierService,
                    shippingFeeVal > 0
                        ? fmt.format(shippingFeeVal)
                        : context.l10n.free,
                    isBoldValue: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.totalAuthorized,
                        style: AppFonts.font(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      Text(
                        fmt.format(totalVal),
                        style: AppFonts.font(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (order != null) {
                    ref
                        .read(ordersNotifierProvider.notifier)
                        .fetchOrderDetail(order.id);
                    Navigator.of(context).pushNamed(
                      RouteNames.orderDetail,
                      arguments: order,
                    );
                  } else {
                    Navigator.of(context).pushNamed(RouteNames.orders);
                  }
                },
                child: Text(
                  '${context.l10n.trackLiveOrder} →',
                  style: AppFonts.font(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F1F3),
                  foregroundColor: const Color(0xFF111111),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.main,
                    (route) => false,
                  );
                },
                child: Text(
                  context.l10n.continueShopping,
                  style: AppFonts.font(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManifestItem({
    required String title,
    required String category,
    required String variant,
    required String priceText,
    required int qty,
    String? imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: Color(0xFF999999),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.checkroom_outlined,
                        size: 20,
                        color: Color(0xFF999999),
                      ),
                    ),
            ),
            Positioned(
              right: 3,
              bottom: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '${qty}x',
                  style: AppFonts.font(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: AppFonts.font(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppFonts.font(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                variant,
                style: AppFonts.font(
                  fontSize: 12,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                priceText,
                style: AppFonts.font(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _costRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.font(
            fontSize: 13,
            color: isDiscount
                ? const Color(0xFF4D7C0F)
                : const Color(0xFF555555),
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppFonts.font(
            fontSize: 13.5,
            fontWeight: (isDiscount || isBoldValue)
                ? FontWeight.bold
                : FontWeight.w600,
            color: isDiscount
                ? const Color(0xFF4D7C0F)
                : const Color(0xFF111111),
          ),
        ),
      ],
    );
  }
}
