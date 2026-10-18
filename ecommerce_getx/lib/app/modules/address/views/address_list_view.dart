import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/app/core/widgets/empty_state_widget.dart';
import 'package:architecture_getx/app/core/widgets/loading_widget.dart';
import 'package:architecture_getx/app/data/models/address.model.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import '../controllers/address_controller.dart';

class AddressListView extends GetView<AddressController> {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F8),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 64,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              // Circular Back Button
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
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
              const SizedBox(width: 14),

              // Title
              Text(
                context.l10n.savedAddresses,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Search Action Button
          GestureDetector(
            onTap: () => controller.isSearchOpen.toggle(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F1F3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.search, size: 19, color: Color(0xFF111111)),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Electric Lime Add Button
          GestureDetector(
            onTap: () {
              controller.prepareAdd();
              Get.toNamed(Routes.ADDRESS_FORM);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD4F835),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.add, size: 22, color: Color(0xFF111111)),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ShimmerList();

        if (controller.errorMessage.value.isNotEmpty &&
            controller.addresses.isEmpty) {
          return ErrorStateWidget(
            message: controller.errorMessage.value,
            onRetry: controller.fetchAddresses,
          );
        }

        final list = controller.filteredAddresses;

        return RefreshIndicator(
          color: const Color(0xFF111111),
          onRefresh: controller.fetchAddresses,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional Search Bar
                if (controller.isSearchOpen.value) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFECECF0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller.searchCtrl,
                            onChanged: (v) => controller.searchQuery.value = v,
                            decoration: InputDecoration(
                              hintText: context.l10n.searchAddressesHint,
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF999999),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                        if (controller.searchQuery.value.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              controller.searchCtrl.clear();
                              controller.searchQuery.value = '';
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF888888),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // If empty search results
                if (list.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        context.l10n.noMatchingAddresses,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // List of Address Cards
                  ...list.map((addr) {
                    final isSelected =
                        controller.selectedAddress.value?.id == addr.id;
                    return _AddressCard(
                      // key: ValueKey('addr_${addr.id}_${addr.isDefault}_$isSelected'),
                      address: addr,
                      isSelected: isSelected,
                      controller: controller,
                    );
                  }),
                ],

                // Bottom "Add New Delivery Address" Card
                GestureDetector(
                  onTap: () {
                    controller.prepareAdd();
                    Get.toNamed(Routes.ADDRESS_FORM);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // Location with plus icon circle
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAEAEE),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_location_alt_outlined,
                              size: 20,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.addNewDeliveryAddress,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.globalCourierConfig,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chevron Right
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Color(0xFF757575),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.controller,
  });

  final AddressModel address;
  final bool isSelected;
  final AddressController controller;

  @override
  Widget build(BuildContext context) {
    // Resolve secondary descriptor (e.g. VIP #042, Studio Atelier, Private Estate)
    String? descriptor;
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      descriptor = address.addressLine2;
    }

    final isVip =
        descriptor != null && descriptor.toUpperCase().contains('VIP');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECECF0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Badges & Radio Indicator
          Row(
            children: [
              // DEFAULT Badge
              if (address.isDefault) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.l10n.defaultBadge,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Label Badge (e.g. PRIMARY RESIDENCE, WORK / DESIGN ATELIER, SUMMER RESIDENCE)
              if (address.label.isNotEmpty)
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
                    address.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF555555),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              const Spacer(),

              // Radio / Default Address Indicator
              GestureDetector(
                onTap: () => controller.setDefault(address.id),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  child: address.isDefault
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4F835),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCCCCCC),
                              width: 1.8,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Recipient Name & Descriptor
          Row(
            children: [
              Text(
                address.recipientName.isNotEmpty
                    ? address.recipientName
                    : 'Recipient',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
              if (descriptor != null && descriptor.isNotEmpty) ...[
                if (isVip) ...[
                  const SizedBox(width: 8),
                  Text(
                    descriptor,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ] else ...[
                  Text(
                    '  •  $descriptor',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Row 3: Street Address
          Text(
            address.address,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: const Color(0xFF4A4A4A),
              height: 1.4,
            ),
          ),

          // Row 4: City, State, Postal Code, Country
          Text(
            '${address.city}, ${address.state} ${address.postalCode}, ${address.country}',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: const Color(0xFF4A4A4A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Row 5: Phone
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 14,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 6),
              Text(
                address.phone,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 6: Bottom Actions (Selected Destination / Deliver Here | Edit | More)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Selected Destination OR Deliver Here Button
              if (isSelected)
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD4F835),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.selectedDestination,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: () => controller.selectAddress(address),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.l10n.deliverHere,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                ),

              // Right: Edit & More Options
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.prepareEdit(address);
                      Get.toNamed(Routes.ADDRESS_FORM);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            size: 15,
                            color: Color(0xFF111111),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.editAddress,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete Button
                  GestureDetector(
                    onTap: () => _handleMenu('delete', context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F1F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_sharp,
                        color: AppColors.error,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenu(String action, BuildContext context) {
    switch (action) {
      case 'edit':
        controller.prepareEdit(address);
        Get.toNamed(Routes.ADDRESS_FORM);
        break;
      case 'default':
        controller.setDefault(address.id);
        break;
      case 'delete':
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              context.l10n.deleteAddressTitle,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            content: Text(
              context.l10n.deleteAddressConfirm,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF555555),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  context.l10n.cancel,
                  style: GoogleFonts.inter(color: const Color(0xFF666666)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.deleteAddress(address.id);
                },
                child: Text(
                  context.l10n.delete,
                  style: GoogleFonts.inter(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
