import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/core/utils/l10n_extensions.dart';
import '../../../../app/data/models/address.model.dart';

import '../providers/address_provider.dart';

class AddressDetailsSheet extends ConsumerStatefulWidget {
  final AddressModel? address;
  final String? initialAddress;
  final String? initialCountry;
  final String? initialProvince;
  final String? initialDistrict;
  final double? latitude;
  final double? longitude;

  const AddressDetailsSheet({
    super.key,
    this.address,
    this.initialAddress,
    this.initialCountry,
    this.initialProvince,
    this.initialDistrict,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<AddressDetailsSheet> createState() =>
      _AddressDetailsSheetState();
}

class _AddressDetailsSheetState extends ConsumerState<AddressDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _recipientCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _provinceCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _districtCtrl;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.address?.label ?? 'Home');
    _recipientCtrl =
        TextEditingController(text: widget.address?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: widget.address?.phone ?? '');
    _addressCtrl = TextEditingController(
      text: widget.address?.address ?? widget.initialAddress ?? '',
    );
    _provinceCtrl = TextEditingController(
      text: widget.address?.city.isNotEmpty == true
          ? widget.address!.city
          : (widget.initialProvince?.isNotEmpty == true
              ? widget.initialProvince!
              : 'Phnom Penh'),
    );
    _countryCtrl = TextEditingController(
      text: widget.address?.country.isNotEmpty == true
          ? widget.address!.country
          : (widget.initialCountry?.isNotEmpty == true
              ? widget.initialCountry!
              : 'Cambodia'),
    );
    _districtCtrl = TextEditingController(
      text: widget.address?.state ?? widget.initialDistrict ?? '',
    );
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _recipientCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _provinceCtrl.dispose();
    _countryCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final country = _countryCtrl.text.trim().isNotEmpty
        ? _countryCtrl.text.trim()
        : 'Cambodia';
    final province = _provinceCtrl.text.trim().isNotEmpty
        ? _provinceCtrl.text.trim()
        : 'Phnom Penh';
    final district = _districtCtrl.text.trim();

    final data = {
      'label': _labelCtrl.text.trim().isNotEmpty
          ? _labelCtrl.text.trim()
          : 'Home',
      'recipient_name': _recipientCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address_line_1': _addressCtrl.text.trim(),
      'country': country,
      'province': province,
      if (district.isNotEmpty) 'district': district,
      if (widget.latitude != null || widget.address?.latitude != null)
        'latitude': widget.latitude ?? widget.address?.latitude,
      if (widget.longitude != null || widget.address?.longitude != null)
        'longitude': widget.longitude ?? widget.address?.longitude,
      'is_default': _isDefault,
    };

    final success = await ref.read(addressNotifierProvider.notifier).saveAddress(
          data,
          id: widget.address?.id,
        );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.address == null
                ? 'Address added successfully'
                : 'Address updated successfully',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save address'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressNotifierProvider);

    return Container(
      padding: const EdgeInsets.only(
        top: 35,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.addressDetails,
                    style: AppFonts.font(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                context.l10n.addressDetailsSubtitle,
                style: AppFonts.font(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.selectAddressType,
                style: AppFonts.font(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeChip(
                    context.l10n.addressLabelHome,
                    Icons.home_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    context.l10n.addressLabelOffice,
                    Icons.work_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(
                    context.l10n.addressLabelFriend,
                    Icons.person_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _recipientCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.receiverName} *',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? context.l10n.nameRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.completeAddress} *',
                ),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty
                    ? context.l10n.addressRequiredValidation
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.phoneNumber} *',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.l10n.phoneRequired;
                  }
                  final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(cleaned)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _provinceCtrl,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.cityProvince} *',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Province required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _countryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Country *',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Country required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                title: Text(
                  context.l10n.setAsDefaultAddress,
                  style: AppFonts.font(fontSize: 14),
                ),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: addressState.isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: addressState.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(context.l10n.saveAddress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final isSelected = _labelCtrl.text == label;
    return InkWell(
      onTap: () {
        setState(() {
          _labelCtrl.text = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.font(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
