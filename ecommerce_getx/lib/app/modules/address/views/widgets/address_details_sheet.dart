import 'package:architecture_getx/app/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import '../../controllers/address_controller.dart';

class AddressDetailsSheet extends GetView<AddressController> {
  const AddressDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
        key: controller.formKey,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Text(
                context.l10n.addressDetailsSubtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.selectAddressType,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              GetBuilder<AddressController>(
                id: 'type_chips',
                builder: (ctrl) => Row(
                  children: [
                    _buildTypeChip(context.l10n.addressLabelHome, Icons.home_rounded, ctrl),
                    const SizedBox(width: 8),
                    _buildTypeChip(context.l10n.addressLabelOffice, Icons.work_rounded, ctrl),
                    const SizedBox(width: 8),
                    _buildTypeChip(context.l10n.addressLabelFriend, Icons.person_rounded, ctrl),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controller.recipientCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.receiverName} *',
                ),
                validator: (v) => v!.isEmpty ? context.l10n.nameRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.addressCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.completeAddress} *',
                ),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? context.l10n.addressRequiredValidation : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.phoneCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.phoneNumber} *',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return context.l10n.phoneRequired;
                  final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(cleaned)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(() => SwitchListTile(
                value: controller.isDefaultCtrl.value,
                onChanged: (v) => controller.isDefaultCtrl.value = v,
                title: Text(context.l10n.setAsDefaultAddress, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.saveAddress,
                child: controller.isSaving.value
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(context.l10n.saveAddress),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon, AddressController ctrl) {
    final isSelected = ctrl.labelCtrl.text == label;
    return InkWell(
      onTap: () {
        ctrl.labelCtrl.text = label;
        ctrl.update(['type_chips']);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
