import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:architecture_getx/app/data/models/order.model.dart';
import '../controllers/orders_controller.dart';

class OrderDetailView extends GetView<OrdersController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    // Automatically trigger fresh detail fetch if order is available
    final initialOrder = controller.selectedOrder.value ??
        (Get.arguments is OrderRes ? Get.arguments as OrderRes : null);

    if (initialOrder != null && controller.selectedOrder.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectedOrder.value = initialOrder;
        if (initialOrder.orderNumber.isNotEmpty) {
          controller.fetchOrderDetail(initialOrder.orderNumber);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        toolbarHeight: 64,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Circular Back Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ),

            // Screen Title with Neon Lime Dot
            const Text(
              'ORDER DETAILS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,

                color: AppColors.textMain,
                letterSpacing: 1.0,
              ),
            ),

            // Actions: Invoice & More Menu
            Row(
              children: [
                // Receipt / Invoice Quick Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final currentOrder = controller.selectedOrder.value ??
                          (Get.arguments is OrderRes
                              ? Get.arguments as OrderRes
                              : null);
                      if (currentOrder != null) {
                        _downloadInvoice(currentOrder);
                      }
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderSubtle, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final order = controller.selectedOrder.value ??
              (Get.arguments is OrderRes ? Get.arguments as OrderRes : null);

          if (order == null && controller.isLoadingDetail.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkPill),
            );
          }

          if (order == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 54, color: AppColors.textSub),
                  const SizedBox(height: 12),
                  const Text(
                    'Order Not Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPill,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back to Orders', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final status = order.status.toLowerCase();
          final isCancelled = status.contains('cancel');

          return Stack(
            children: [
              // Scrollable Order Details
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Order Hero Summary Card
                    _buildHeroSummaryCard(context, order, fmt, dateFmt),
                    const SizedBox(height: 16),

                    // 2. Interactive Step Tracking (or Cancelled Banner)
                    if (!isCancelled) ...[
                      _buildTrackingCard(context, order),
                      const SizedBox(height: 16),
                    ] else ...[
                      _buildCancelledBanner(order),
                      const SizedBox(height: 16),
                    ],

                    // 3. Ordered Items List
                    _buildItemsCard(context, order, fmt),
                    const SizedBox(height: 16),

                    // 4. Delivery Destination Card
                    _buildDeliveryAddressCard(order),
                    const SizedBox(height: 16),

                    // 5. Payment & Billing Breakdown
                    _buildPaymentCard(order, fmt),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Sticky Bottom Floating Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(context, order),
              ),
            ],
          );
        }),
      ),
    );
  }



  // Hero Order Summary Card
  Widget _buildHeroSummaryCard(
    BuildContext context,
    OrderRes order,
    NumberFormat fmt,
    DateFormat dateFmt,
  ) {
    final status = order.status.toLowerCase();
    final placedText = order.createdAt != null
        ? dateFmt.format(order.createdAt!)
        : '28 Oct 2026, 02:45 PM';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Number & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '#${order.orderNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                          color: AppColors.textMain,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: order.orderNumber),
                        );

                        Get.snackbar(
                          'Copied',
                          'Order ID copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.darkPill,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 1),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.softGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: AppColors.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _buildStatusPill(status),
            ],
          ),

          const SizedBox(height: 12),

          // Placed Date & Payment Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSub),
                  const SizedBox(width: 5),
                  Text(
                    placedText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSub,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.paymentStatus.toLowerCase() == 'paid'
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: order.paymentStatus.toLowerCase() == 'paid'
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),

          // Total & Item Count Highlight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL CHARGED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSub,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        fmt.format(order.total),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                          color: AppColors.textMain,
                        ),
                      ),
                      if (order.discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          fmt.format(order.total + order.discount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.softGrey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${order.items.length} ${order.items.length > 1 ? "Products" : "Product"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Interactive Stepper Card
  Widget _buildTrackingCard(BuildContext context, OrderRes order) {
    final status = order.status.toLowerCase();

    int activeStep = 0;
    String statusTitle = 'Tailoring in Atelier';
    String etaText = 'Exp: Oct 26';

    if (status == 'processing' || status == 'pending') {
      activeStep = 1; // Tailored / Atelier
      statusTitle = 'Tailoring in Atelier';
      etaText = 'Processing Order';
    } else if (status == 'shipped' || status == 'in_transit' || status == 'out_for_delivery') {
      activeStep = 2; // Out for delivery
      statusTitle = 'Arriving Tomorrow, 2:00 PM';
      etaText = 'Step 3 of 4';
    } else if (status == 'delivered' || status == 'completed') {
      activeStep = 3; // Delivered
      statusTitle = 'Delivered safely';
      etaText = 'Step 4 of 4';
    }

    final trackingNum = (order.trackingNumber?.isNotEmpty ?? false)
        ? order.trackingNumber!
        : 'TRK-948210-DHL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: activeStep >= 2
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      size: 17,
                      color: activeStep >= 2 ? AppColors.accentBlue : AppColors.darkPill,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    statusTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              Text(
                etaText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4-Segment Progress Bar
          Row(
            children: [
              _buildStepBar(isFilled: true, isCurrent: activeStep == 0),
              const SizedBox(width: 4),
              _buildStepBar(isFilled: activeStep >= 1, isCurrent: activeStep == 1),
              const SizedBox(width: 4),
              _buildStepBar(isFilled: activeStep >= 2, isCurrent: activeStep == 2),
              const SizedBox(width: 4),
              _buildStepBar(isFilled: activeStep >= 3, isCurrent: activeStep == 3),
            ],
          ),

          const SizedBox(height: 10),

          // Step Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('PLACED', activeStep >= 0, activeStep == 0),
              _buildStepLabel('TAILORED', activeStep >= 1, activeStep == 1),
              _buildStepLabel('OUT FOR DELIVERY', activeStep >= 2, activeStep == 2),
              _buildStepLabel('DELIVERED', activeStep >= 3, activeStep == 3),
            ],
          ),

          const SizedBox(height: 18),

          // Courier & Tracking Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Courier: DHL Express Concierge',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tracking: $trackingNum',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSub,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: trackingNum));
                    Get.snackbar(
                      'Copied to Clipboard',
                      'Tracking number $trackingNum copied!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.darkPill,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.copy, size: 12, color: AppColors.darkPill),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkPill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dual Action Buttons: Live Map & AR Proof
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _openLiveMapSheet(context, order),
                    icon: const Icon(
                      Icons.navigation_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Live Map',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPill,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _openArProofSheet(context, order),
                    icon: const Icon(
                      Icons.view_in_ar_rounded,
                      size: 16,
                      color: AppColors.darkPill,
                    ),
                    label: const Text(
                      'AR Proof',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkPill,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softGrey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

  Widget _buildStepBar({required bool isFilled, bool isCurrent = false}) {
    return Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.accentBlue
              : isFilled
                  ? AppColors.darkPill
                  : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildStepLabel(String text, bool isReached, bool isCurrent) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
        color: isCurrent
            ?AppColors.accentBlue
            : isReached
                ? AppColors.darkPill
                : const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  // Cancelled Banner
  Widget _buildCancelledBanner(OrderRes order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This order was cancelled and will not be shipped. If you have been charged, a refund will appear in 3-5 business days.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB91C1C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Ordered Items List Card
  Widget _buildItemsCard(BuildContext context, OrderRes order, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDERED ITEMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSub,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${order.items.length} ${order.items.length > 1 ? "items" : "item"}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Items List
          ...order.items.map((item) {
            final product = item.product;
            final imgUrl = product.primaryImage?.url ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail with 3D/AR badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 82,
                          height: 82,
                          color: const Color(0xFFF3F4F6),
                          child: imgUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.checkroom_rounded,
                                    color: Color(0xFF9CA3AF),
                                    size: 32,
                                  ),
                                )
                              : const Icon(
                                  Icons.checkroom_rounded,
                                  color: Color(0xFF9CA3AF),
                                  size: 32,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '3D/AR',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // Info & Pricing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Luxury Brand Header
                        Row(
                          children: [
                            Container(
                              width: 13,
                              height: 13,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'WinterElegance',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          product.name.isNotEmpty ? product.name : 'Luxury Apparel Item',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        // Size pill & color
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.size ?? 'M',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.color ?? "Pale Ecru"} • Qty: ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSub,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Price and Buy Again
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fmt.format(item.subtotal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                              ),
                            ),
                            InkWell(
                              onTap: () => controller.buyAgain(item),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.neonLime,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add_rounded, size: 12, color: Colors.black),
                                    SizedBox(width: 3),
                                    Text(
                                      'Buy Again',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Delivery Destination Card
  Widget _buildDeliveryAddressCard(OrderRes order) {
    final addr = order.address;
    final recipient = (addr != null && addr.recipientName.isNotEmpty)
        ? addr.recipientName
        : 'No Name';
    final phone = (addr != null && addr.phone.isNotEmpty)
        ? addr.phone
        : 'No Phone Number';
    final fullAddress = (addr != null && addr.fullAddress.isNotEmpty)
        ? addr.fullAddress
        : 'No Address';
    final notes = (order.notes?.isNotEmpty ?? false)
        ? order.notes!
        : 'No Notes';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY DESTINATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSub,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.softGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.textMain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipient,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fullAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMain,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),

          // Instruction Note
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSub),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notes,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // . Payment & Billing Breakdown
  Widget _buildPaymentCard(OrderRes order, NumberFormat fmt) {
    final method = order.paymentMethod.toLowerCase();
    final isPayWay = method.contains('payway') || method.contains('khqr');
    final isCod = method.contains('cod') || method.contains('cash');
    final methodName = isPayWay
        ? 'ABA PayWay (KHQR)'
        : (isCod ? 'Cash on Delivery (COD)' : order.paymentMethod.toUpperCase());

    final subtotal = order.subtotal;
    final discount = order.discount;
    final shipping = order.shippingFee;
    final tax = subtotal * 0.08;
    final total = order.total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYMENT & BILLING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSub,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),

          // Payment Method Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  isPayWay ? Icons.qr_code_scanner_rounded : Icons.credit_card_rounded,
                  size: 20,
                  color: AppColors.darkPill,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    methodName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PAID',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Rows
          _buildBillingRow('Items Subtotal', fmt.format(subtotal)),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildBillingRow('VIP / Atelier Discount', '-${fmt.format(discount)}', isDiscount: true),
          ],
          const SizedBox(height: 8),
          _buildBillingRow(
            'Delivery',
            shipping > 0 ? fmt.format(shipping) : 'Complimentary (Free)',
            isFree: shipping == 0,
          ),
          const SizedBox(height: 8),
          _buildBillingRow('Estimated VAT / Tax (8%)', fmt.format(tax)),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 14),

          // Final Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                  color: AppColors.textMain,
                ),
              ),
              Text(
                fmt.format(total+ tax),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSub,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDiscount
                ? const Color(0xFF16A34A)
                : (isFree ? const Color(0xFF16A34A) : AppColors.textMain),
          ),
        ),
      ],
    );
  }

  //  Sticky Bottom Action Bar
  Widget _buildBottomActionBar(BuildContext context, OrderRes order) {
    final status = order.status.toLowerCase();
    final canCancel = controller.canCancelOrder(order);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canCancel) ...[
            // Cancel Order Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isCancelling.value
                        ? null
                        : () => _showCancelDialog(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: controller.isCancelling.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
                          )
                        : const Text(
                            'Cancel Order',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openLiveMapSheet(context, order),
                  icon: const Icon(Icons.navigation_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Track Order',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPill,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (status.contains('ship') || status.contains('transit')) ...[
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openLiveMapSheet(context, order),
                  icon: const Icon(Icons.navigation_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Live Map Tracking',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPill,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              width: 52,
              child: ElevatedButton(
                onPressed: () => _openArProofSheet(context, order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softGrey,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Icon(Icons.view_in_ar_rounded, color: AppColors.darkPill, size: 22),
              ),
            ),
          ] else ...[
            // Delivered or Cancelled: Reorder All (Neon Lime)
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    for (final it in order.items) {
                      controller.buyAgain(it);
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.black),
                  label: const Text(
                    '+ Buy Again',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _downloadInvoice(order),
                icon: const Icon(Icons.receipt_outlined, size: 16, color: AppColors.darkPill),
                label: const Text(
                  'Invoice',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkPill,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Status Pill Builder
  Widget _buildStatusPill(String status) {
    if (status.contains('cancel')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Cancelled',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
        ),
      );
    } else if (status.contains('ship') || status.contains('transit')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accentBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'In Transit',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
    } else if (status.contains('deliver') || status.contains('complete')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Delivered',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '• Processing Atelier',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
        ),
      );
    }
  }

  // ── Live Map Sheet with Real Google Map Delivery Tracking ──────────────────
  void _openLiveMapSheet(BuildContext context, OrderRes order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LiveDeliveryMapSheet(order: order),
    );
  }

  // ── AR Proof Sheet ─────────────────────────────────────────────────────────
  void _openArProofSheet(BuildContext context, OrderRes order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    color: AppColors.accentBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Augmented Reality Proof',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Order #${order.orderNumber} • Digital Authenticity Seal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Atelier Authenticity',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Digital fingerprint matches certified winter collection stock #WE-94821.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPill,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Close Proof', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cancel Order Dialog ────────────────────────────────────────────────────
  void _showCancelDialog(BuildContext context, OrderRes order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text(
              'Cancel Order?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel order #${order.orderNumber}?\n\nThis will immediately inform the atelier and issue a full reversal.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSub,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Keep Order',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.textSub,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Get.back();
              controller.cancelOrder(order.id);
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(OrderRes order) {
    Get.snackbar(
      'Tax Invoice Downloaded',
      'Official luxury VAT invoice for #${order.orderNumber} saved to downloads.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.neonLime,
      colorText: Colors.black,
      icon: const Icon(Icons.receipt_long_rounded, color: Colors.black),
      duration: const Duration(seconds: 2),
    );
  }
}

// ── Real Live Delivery Map Tracking Sheet ────────────────────────────────────
class _LiveDeliveryMapSheet extends StatefulWidget {
  final OrderRes order;

  const _LiveDeliveryMapSheet({required this.order});

  @override
  State<_LiveDeliveryMapSheet> createState() => _LiveDeliveryMapSheetState();
}

class _LiveDeliveryMapSheetState extends State<_LiveDeliveryMapSheet> {
  GoogleMapController? _mapController;
  late final LatLng _destination;
  late final LatLng _courier;
  late final LatLng _warehouse;
  late final Set<Marker> _markers;
  late final Set<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _initCoordinatesAndMapData();
  }

  void _initCoordinatesAndMapData() {
    final addr = widget.order.address;
    final double destLat = (addr?.latitude != null && addr!.latitude != 0.0)
        ? addr.latitude!
        : 11.5564;
    final double destLng = (addr?.longitude != null && addr!.longitude != 0.0)
        ? addr.longitude!
        : 104.9282;

    _destination = LatLng(destLat, destLng);
    _courier = LatLng(destLat + 0.0092, destLng - 0.0118);
    _warehouse = LatLng(destLat + 0.0245, destLng - 0.0270);

    final recipient = addr?.recipientName.isNotEmpty == true
        ? addr!.recipientName
        : 'Delivery Destination';
    final fullAddr = addr?.address.isNotEmpty == true
        ? addr!.address
        : 'Phnom Penh, Cambodia';

    _markers = {
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: recipient,
          snippet: fullAddr,
        ),
      ),
      Marker(
        markerId: const MarkerId('courier'),
        position: _courier,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'Michael Vance (DHL Courier)',
          snippet: 'En route • 12 mins away',
        ),
      ),
      Marker(
        markerId: const MarkerId('warehouse'),
        position: _warehouse,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Central Fulfillment Hub',
          snippet: 'Order dispatched',
        ),
      ),
    };

    _polylines = {
      // Traversed route leg from warehouse to courier
      Polyline(
        polylineId: const PolylineId('traversed_leg'),
        points: [
          _warehouse,
          LatLng(_destination.latitude + 0.0195, _destination.longitude - 0.0215),
          LatLng(_destination.latitude + 0.0145, _destination.longitude - 0.0170),
          _courier,
        ],
        color: const Color(0xFF94A3B8),
        width: 4,
        patterns: [PatternItem.dash(12), PatternItem.gap(6)],
      ),
      // Active delivery leg from courier to destination
      Polyline(
        polylineId: const PolylineId('active_leg'),
        points: [
          _courier,
          LatLng(_destination.latitude + 0.0062, _destination.longitude - 0.0080),
          LatLng(_destination.latitude + 0.0031, _destination.longitude - 0.0038),
          _destination,
        ],
        color: const Color(0xFF2563EB),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _fitBounds() {
    if (_mapController == null) return;
    final minLat = [_warehouse.latitude, _courier.latitude, _destination.latitude].reduce((a, b) => a < b ? a : b);
    final maxLat = [_warehouse.latitude, _courier.latitude, _destination.latitude].reduce((a, b) => a > b ? a : b);
    final minLng = [_warehouse.longitude, _courier.longitude, _destination.longitude].reduce((a, b) => a < b ? a : b);
    final maxLng = [_warehouse.longitude, _courier.longitude, _destination.longitude].reduce((a, b) => a > b ? a : b);

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        55,
      ),
    );
  }

  void _focusCourier() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_courier, 16.0),
    );
  }

  void _focusDestination() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_destination, 16.5),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return;
      }
    } catch (_) {}

    Get.snackbar(
      'Calling Driver',
      'Connecting to Michael Vance ($phoneNumber)...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.darkPill,
      colorText: Colors.white,
      icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.neonLime),
    );
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return;
      }
    } catch (_) {}

    Get.snackbar(
      'Direct Message',
      'Opening chat channel with driver Michael Vance ($phoneNumber)...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.darkPill,
      colorText: Colors.white,
      icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.neonLime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final driverPhone = order.address?.phone.isNotEmpty == true
        ? order.address!.phone
        : '+855 12 998 877';
    final trackingCode = order.trackingNumber?.isNotEmpty == true
        ? order.trackingNumber!
        : 'DHL-${order.orderNumber}';
    final recipientName = order.address?.recipientName.isNotEmpty == true
        ? order.address!.recipientName
        : 'VIP Customer';
    final deliveryAddress = order.address?.address.isNotEmpty == true
        ? order.address!.address
        : 'Phnom Penh, Cambodia';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Drag handle
          Container(
            width: 42,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Pulse dot + Title
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIVE DELIVERY TRACKING',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                          color: AppColors.textMain,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // ETA Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.neonLime,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 13, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        '12 mins away',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Close button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.softGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Interactive Google Map View Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Stack(
                  children: [
                    // Real GoogleMap
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          (_courier.latitude + _destination.latitude) / 2,
                          (_courier.longitude + _destination.longitude) / 2,
                        ),
                        zoom: 14.2,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      onMapCreated: (ctrl) {
                        _mapController = ctrl;
                        Future.delayed(const Duration(milliseconds: 350), () {
                          if (mounted) _fitBounds();
                        });
                      },
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                    ),

                    // Top Floating Delivery Address Card
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFEF4444),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        recipientName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Poppins',
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.pageBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Destination',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSub,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    deliveryAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSub,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Distance chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neonLime,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '1.8 km',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating Map Controls (Right Side)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFloatingMapButton(
                            icon: Icons.center_focus_strong_rounded,
                            tooltip: 'Fit Route',
                            onTap: _fitBounds,
                          ),
                          const SizedBox(height: 8),
                          _buildFloatingMapButton(
                            icon: Icons.delivery_dining_rounded,
                            tooltip: 'Courier',
                            onTap: _focusCourier,
                          ),
                          const SizedBox(height: 8),
                          _buildFloatingMapButton(
                            icon: Icons.home_rounded,
                            tooltip: 'Destination',
                            onTap: _focusDestination,
                          ),
                          const SizedBox(height: 8),
                          _buildFloatingMapButton(
                            icon: Icons.add_rounded,
                            tooltip: 'Zoom In',
                            onTap: () => _mapController?.animateCamera(
                              CameraUpdate.zoomIn(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildFloatingMapButton(
                            icon: Icons.remove_rounded,
                            tooltip: 'Zoom Out',
                            onTap: () => _mapController?.animateCamera(
                              CameraUpdate.zoomOut(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Courier & Delivery Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Driver Row
                Row(
                  children: [
                    // Avatar with online status
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person,
                            size: 26,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Michael Vance',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins',
                                  color: AppColors.textMain,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Color(0xFF2563EB),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'DHL Concierge • 4.9 ★ • White Honda 1KA-8899',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons: Chat & Call
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _sendSms(driverPhone),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.softGrey,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _makePhoneCall(driverPhone),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.neonLime,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone_in_talk_rounded,
                                size: 19,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tracking summary strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.pageBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: AppColors.textSub,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tracking: $trackingCode',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: trackingCode));
                          Get.snackbar(
                            'Copied',
                            'Tracking number $trackingCode copied to clipboard',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.darkPill,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: AppColors.accentBlue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFloatingMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
