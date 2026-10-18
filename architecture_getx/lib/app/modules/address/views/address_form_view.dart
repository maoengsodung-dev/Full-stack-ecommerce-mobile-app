import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:architecture_getx/app/core/theme/app_theme.dart';
import '../controllers/address_controller.dart';
import 'widgets/address_details_sheet.dart';

class AddressFormView extends GetView<AddressController> {
  const AddressFormView({super.key});

  // Default to Phnom Penh so the map shows immediately before GPS resolves
  static const _defaultPosition = CameraPosition(
    target: LatLng(11.5564, 104.9282),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            // Google Map — always rendered, camera animates on GPS fix
            GoogleMap(
              initialCameraPosition: _defaultPosition,
              onMapCreated: (mapCtrl) {
                controller.mapController.value = mapCtrl;
                // If GPS already resolved by the time map is created, jump to it
                final pos = controller.currentPosition.value;
                if (pos != null) {
                  mapCtrl.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
                }
              },
              onCameraMove: (pos) =>
                  controller.currentPosition.value = pos.target,
              onCameraIdle: () {
                final pos = controller.currentPosition.value;
                if (pos != null) controller.updateLocationDetails(pos);
              },
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),

            // Center Pin Overlay
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.l10n.movePinToSetLocation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            // Top Search Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search for delivery area',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          onSubmitted: (val) {
                            // Forward geocoding to move map could be added here
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Confirmation Card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Confirm your order delivery location',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.selectedAddressText.value
                                    .split(',')
                                    .first,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                controller.selectedAddressText.value,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // current location
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                          ),
                          onPressed: () {
                            controller.getCurrentLocation();
                          },
                          icon: controller.isMapLoading.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black54,
                                  ),
                                )
                              : const Icon(Icons.my_location, size: 18),
                          label: Text(
                            controller.isMapLoading.value
                                ? 'Getting location...'
                                : 'Get Current Address',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Get.bottomSheet(
                            const AddressDetailsSheet(),
                            isScrollControlled: true,
                          );
                        },
                        child: const Text('Confirm and add details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
