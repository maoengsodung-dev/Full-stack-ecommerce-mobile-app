import 'dart:convert';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/models/address.model.dart';
import 'package:architecture_getx/app/data/repository/address_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../checkout/controllers/checkout_controller.dart';

class AddressController extends GetxController {
  final AddressRepository _repo;
  AddressController(this._repo);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddress = Rxn<AddressModel>();
  final errorMessage = ''.obs;

  // Search filter
  final isSearchOpen = false.obs;
  final searchQuery = ''.obs;
  final searchCtrl = TextEditingController();

  List<AddressModel> get filteredAddresses {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return addresses;
    return addresses.where((a) {
      return a.recipientName.toLowerCase().contains(q) ||
          a.label.toLowerCase().contains(q) ||
          a.address.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          (a.addressLine2 ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // Map state
  final mapController = Rxn<GoogleMapController>();
  final currentPosition = Rxn<LatLng>();
  final selectedAddressText = 'Locating...'.obs;
  final isMapLoading = false.obs;
  Placemark? selectedPlacemark;

  // Form
  final labelCtrl = TextEditingController();
  final recipientCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final postalCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: 'Cambodia');
  final isDefaultCtrl = false.obs;
  final formKey = GlobalKey<FormState>();

  AddressModel? _editingAddress;

  StorageService? get _storage =>
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : null;

  void _saveToLocalStorage() {
    try {
      final raw = addresses.map((a) => jsonEncode(a.toJson())).toList();
      _storage?.saveLocalAddresses(raw);
      final defaultAddr = addresses.firstWhereOrNull((a) => a.isDefault);
      if (defaultAddr != null) {
        _storage?.saveDefaultAddressId(defaultAddr.id);
      }
    } catch (_) {}
  }

  List<AddressModel> _loadFromLocalStorage() {
    try {
      final raw = _storage?.getLocalAddresses() ?? [];
      if (raw.isNotEmpty) {
        final list = raw.map((str) => AddressModel.fromJson(jsonDecode(str))).toList();
        final savedDefaultId = _storage?.getDefaultAddressId();
        if (savedDefaultId != null) {
          return list.map((a) => a.copyWith(isDefault: a.id == savedDefaultId)).toList();
        }
        return list;
      }
    } catch (_) {}
    return [];
  }

  @override
  void onReady() {
    super.onReady();
    fetchAddresses();
  }

  List<AddressModel> _buildDemoAddresses() {
    return [
      AddressModel(
        id: 1,
        label: 'PRIMARY RESIDENCE',
        recipientName: 'Alex Vance',
        addressLine2: 'VIP #042',
        address: 'Penthouse 4B, 742 Evergreen St',
        city: 'Manhattan',
        state: 'NY',
        postalCode: '10012',
        country: 'United States',
        phone: '+1 (555) 839-2041',
        isDefault: true,
      ),
      AddressModel(
        id: 2,
        label: 'WORK / DESIGN ATELIER',
        recipientName: 'Alex Vance',
        addressLine2: 'Studio Atelier',
        address: '512 Broadway, Floor 8',
        city: 'SoHo',
        state: 'NY',
        postalCode: '10012',
        country: 'United States',
        phone: '+1 (555) 839-2041',
        isDefault: false,
      ),
      AddressModel(
        id: 3,
        label: 'SUMMER RESIDENCE',
        recipientName: 'Alex Vance',
        addressLine2: 'Private Estate',
        address: '84 Ocean Dune Way',
        city: 'East Hampton',
        state: 'NY',
        postalCode: '11937',
        country: 'United States',
        phone: '+1 (555) 839-2041',
        isDefault: false,
      ),
    ];
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final list = await _repo.getAddresses();
      if (list.isNotEmpty) {
        final savedDefaultId = _storage?.getDefaultAddressId();
        if (savedDefaultId != null && !list.any((a) => a.isDefault)) {
          addresses.assignAll(
            list.map((a) => a.copyWith(isDefault: a.id == savedDefaultId)).toList(),
          );
        } else {
          addresses.assignAll(list);
        }
        _saveToLocalStorage();
      } else {
        final local = _loadFromLocalStorage();
        if (local.isNotEmpty) {
          addresses.assignAll(local);
        } else {
          addresses.assignAll(_buildDemoAddresses());
          _saveToLocalStorage();
        }
      }
    } on DioException {
      final local = _loadFromLocalStorage();
      if (local.isNotEmpty) {
        addresses.assignAll(local);
      } else if (addresses.isEmpty) {
        addresses.assignAll(_buildDemoAddresses());
      }
    } catch (e) {
      final local = _loadFromLocalStorage();
      if (local.isNotEmpty) {
        addresses.assignAll(local);
      } else if (addresses.isEmpty) {
        addresses.assignAll(_buildDemoAddresses());
      }
    } finally {
      if (addresses.isNotEmpty) {
        final defaultAddr = addresses.firstWhereOrNull((a) => a.isDefault);
        if (selectedAddress.value == null ||
            !addresses.any((a) => a.id == selectedAddress.value?.id)) {
          selectedAddress.value = defaultAddr ?? addresses.first;
        }
      }
      isLoading.value = false;
    }
  }

  void prepareAdd() {
    _editingAddress = null;
    labelCtrl.clear();
    recipientCtrl.clear();
    phoneCtrl.clear();
    addressCtrl.clear();
    cityCtrl.clear();
    stateCtrl.clear();
    postalCtrl.clear();
    countryCtrl.text = 'Cambodia';
    isDefaultCtrl.value = false;
    selectedPlacemark = null;
    selectedAddressText.value = 'Locating...';
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    isMapLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        selectedAddressText.value = 'Location services are disabled.';
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          selectedAddressText.value = 'Location permissions are denied';
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        selectedAddressText.value =
            'Location permissions are permanently denied.';
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      currentPosition.value = latLng;
      mapController.value?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 15),
      );
      await updateLocationDetails(latLng);
    } catch (e) {
      selectedAddressText.value = 'Failed to get location';
    } finally {
      isMapLoading.value = false;
    }
  }

  Future<void> updateLocationDetails(LatLng latLng) async {
    currentPosition.value = latLng;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        selectedPlacemark = placemarks.first;
        final name = selectedPlacemark!.name ?? '';
        final subLocality = selectedPlacemark!.subLocality ?? '';
        final locality = selectedPlacemark!.locality ?? '';

        final parts = [
          name,
          subLocality,
          locality,
        ].where((e) => e.isNotEmpty && e != 'Unnamed Road').toList();
        final addressString = parts.isNotEmpty
            ? parts.join(', ')
            : 'Unknown location';

        selectedAddressText.value = addressString;

        addressCtrl.text = addressString;
        cityCtrl.text = selectedPlacemark!.administrativeArea ?? '';
        stateCtrl.text = selectedPlacemark!.subAdministrativeArea ?? '';
        postalCtrl.text = selectedPlacemark!.postalCode ?? '';
        countryCtrl.text = selectedPlacemark!.country ?? 'Cambodia';
      }
    } catch (e) {
      selectedAddressText.value = 'Selected location';
    }
  }

  void prepareEdit(AddressModel addr) {
    _editingAddress = addr;
    labelCtrl.text = addr.label;
    recipientCtrl.text = addr.recipientName;
    phoneCtrl.text = addr.phone;
    addressCtrl.text = addr.address;
    cityCtrl.text = addr.city;
    stateCtrl.text = addr.state;
    postalCtrl.text = addr.postalCode;
    countryCtrl.text = addr.country;
    isDefaultCtrl.value = addr.isDefault;
    selectedAddressText.value = addr.fullAddress;
    _geocodeAddressForEdit(addr.fullAddress);
  }

  Future<void> _geocodeAddressForEdit(String addressStr) async {
    isMapLoading.value = true;
    try {
      List<Location> locations = await locationFromAddress(addressStr);
      if (locations.isNotEmpty) {
        final latLng = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        currentPosition.value = latLng;
        mapController.value?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );
      }
    } catch (e) {
      getCurrentLocation();
    } finally {
      isMapLoading.value = false;
    }
  }

  Future<void> saveAddress() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }
    try {
      isSaving.value = true;
      final data = {
        'label': labelCtrl.text.trim(),
        'recipient_name': recipientCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'address_line_1': addressCtrl.text.trim(),
        'province': cityCtrl.text.trim(),
        'district': stateCtrl.text.trim(),
        'postal_code': postalCtrl.text.trim(),
        'country': countryCtrl.text.trim(),
        'is_default': isDefaultCtrl.value,
      };
      if (_editingAddress == null) {
        final addr = await _repo.addAddress(data);
        addresses.add(addr);
        if (isDefaultCtrl.value) {
          final updated =
              addresses.map((a) => a.copyWith(isDefault: a.id == addr.id)).toList();
          addresses.assignAll(updated);
          selectedAddress.value = addr;
        }
      } else {
        final addr = await _repo.updateAddress(_editingAddress!.id, data);
        final idx = addresses.indexWhere((a) => a.id == addr.id);
        if (idx >= 0) addresses[idx] = addr;
        if (isDefaultCtrl.value) {
          final updated =
              addresses.map((a) => a.copyWith(isDefault: a.id == addr.id)).toList();
          addresses.assignAll(updated);
          selectedAddress.value = addr;
        }
      }
      _saveToLocalStorage();
      Get.back();
      Get.snackbar(
        'Success',
        _editingAddress == null ? 'Address added' : 'Address updated',
        snackPosition: SnackPosition.TOP,
      );
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
      final detail = errors?.values
          .expand((v) => v is List ? v : [v.toString()])
          .join('\n');
      Get.snackbar(
        'Error',
        detail ?? e.response?.data?['message'] ?? 'Failed to save address',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAddress(int id) async {
    addresses.removeWhere((a) => a.id == id);
    if (selectedAddress.value?.id == id) {
      selectedAddress.value = addresses.firstWhereOrNull((a) => a.isDefault) ??
          (addresses.isNotEmpty ? addresses.first : null);
    }
    _saveToLocalStorage();

    Get.snackbar(
      'Deleted',
      'Address removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111111),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    try {
      await _repo.deleteAddress(id);
    } catch (_) {}
  }

  Future<void> setDefault(int id) async {
    // 1. Instant optimistic update: update all items in memory immediately
    final updated = addresses.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
    addresses.assignAll(updated);
    addresses.refresh();
    selectedAddress.value = addresses.firstWhereOrNull((a) => a.id == id);

    // 2. Persist to local storage immediately so it stays saved
    _saveToLocalStorage();

    // 3. Update CheckoutController if active so checkout uses this saved default address
    if (Get.isRegistered<CheckoutController>() && selectedAddress.value != null) {
      Get.find<CheckoutController>().selectedAddress.value = selectedAddress.value;
    }

    Get.snackbar(
      'Default Address',
      'Default address saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111111),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // 4. Save to backend database via REST API (same as saveAddress does)
    try {
      await _repo.setDefaultAddress(id);
    } catch (_) {
      try {
        final target = addresses.firstWhereOrNull((a) => a.id == id);
        if (target != null) {
          final data = target.toJson();
          data['is_default'] = true;
          await _repo.updateAddress(id, data);
        }
      } catch (_) {}
    }
  }

  void selectAddress(AddressModel addr) {
    selectedAddress.value = addr;
    if (Get.isRegistered<CheckoutController>()) {
      Get.find<CheckoutController>().selectedAddress.value = addr;
      Get.back();
    } else {
      Get.snackbar(
        'Selected Destination',
        '${addr.recipientName} - ${addr.label.isNotEmpty ? addr.label : addr.address}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111111),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    labelCtrl.dispose();
    recipientCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    postalCtrl.dispose();
    countryCtrl.dispose();
    super.onClose();
  }
}
