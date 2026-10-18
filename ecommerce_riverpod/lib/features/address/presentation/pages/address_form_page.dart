import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/core/utils/l10n_extensions.dart';
import '../widgets/address_details_sheet.dart';

class AddressFormPage extends ConsumerStatefulWidget {
  const AddressFormPage({super.key});

  static const _defaultPosition = CameraPosition(
    target: LatLng(11.5564, 104.9282), // Phnom Penh
    zoom: 15,
  );

  @override
  ConsumerState<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends ConsumerState<AddressFormPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(11.5564, 104.9282);
  String _addressText = 'Locating...';
  String _detectedCountry = 'Cambodia';
  String _detectedProvince = 'Phnom Penh';
  String _detectedDistrict = '';
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _addressText = 'Location services disabled');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _addressText = 'Location permission denied');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      _currentPosition = latLng;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      await _updateAddressFromCoords(latLng);
    } catch (_) {
      setState(() => _addressText = 'Phnom Penh, Cambodia');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _updateAddressFromCoords(LatLng coords) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.name,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e.isNotEmpty && e != 'Unnamed Road');
        setState(() {
          _addressText = parts.join(', ');
          if (p.country != null && p.country!.isNotEmpty) {
            _detectedCountry = p.country!;
          }
          final prov = p.administrativeArea ?? p.locality;
          if (prov != null && prov.isNotEmpty) {
            _detectedProvince = prov;
          }
          _detectedDistrict = p.subAdministrativeArea ?? p.subLocality ?? '';
        });
      }
    } catch (_) {
      setState(() => _addressText = 'Selected Location');
    }
  }

  Future<void> _openDetailsSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddressDetailsSheet(
          initialAddress: _addressText != 'Locating...' &&
                  _addressText != 'Selected Location'
              ? _addressText
              : null,
          initialCountry: _detectedCountry,
          initialProvince: _detectedProvince,
          initialDistrict: _detectedDistrict,
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: AddressFormPage._defaultPosition,
            onMapCreated: (ctrl) => _mapController = ctrl,
            onCameraMove: (pos) => _currentPosition = pos.target,
            onCameraIdle: () => _updateAddressFromCoords(_currentPosition),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
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
                      style: AppFonts.font(
                        color: Colors.white,
                        fontSize: 12,
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _addressText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _openDetailsSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm Location & Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
