import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/core/router/route_names.dart';
import '../../../../app/core/theme/app_colors.dart';
import '../../../../app/core/theme/app_fonts.dart';
import '../../../../app/core/utils/l10n_extensions.dart';
import '../../../../app/core/widgets/empty_state_widget.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../../app/data/models/address.model.dart';
import '../../../../app/core/constants/asset_constants.dart';

import '../providers/address_provider.dart';
import '../widgets/address_details_sheet.dart';

class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  bool _isSearchOpen = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddressDetails(AddressModel? address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddressDetailsSheet(address: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressNotifierProvider);

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
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
              Text(
                context.l10n.savedAddresses,
                style: AppFonts.font(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchCtrl.clear();
                  ref
                      .read(addressNotifierProvider.notifier)
                      .setSearchQuery('');
                }
              });
            },
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(RouteNames.addressForm);
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
      body: Column(
        children: [
          if (_isSearchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: (val) {
                    ref
                        .read(addressNotifierProvider.notifier)
                        .setSearchQuery(val);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search address...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          Expanded(
            child: addressState.addresses.when(
              loading: () => const LoadingWidget(),
              error: (err, _) => Center(
                child: Text('Error: $err'),
              ),
              data: (_) {
                final list = addressState.filteredAddresses;
                if (list.isEmpty) {
                  return EmptyStateWidget(
                    assetName: AssetConstants.location,
                    title: 'No Addresses Found',
                    subtitle: 'Add an address to easily checkout your orders.',
                    actionLabel: 'Add Address',
                    onAction: () {
                      Navigator.of(context).pushNamed(RouteNames.addressForm);
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(addressNotifierProvider.notifier)
                        .fetchAddresses();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isSelected =
                          addressState.selectedAddress?.id == item.id;

                      return _buildAddressCard(context, item, isSelected);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel item,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.divider.withValues(alpha: 0.6),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.isDefault
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : const Color(0xFFF1F1F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.label.toUpperCase(),
                  style: AppFonts.font(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.isDefault
                        ? AppColors.primary
                        : const Color(0xFF555555),
                  ),
                ),
              ),
              const Spacer(),
              if (item.isDefault)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => _showAddressDetails(item),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.error,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  ref
                      .read(addressNotifierProvider.notifier)
                      .deleteAddress(item.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.recipientName,
            style: AppFonts.font(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.fullAddress,
            style: AppFonts.font(
              fontSize: 13,
              color: const Color(0xFF666666),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.phone,
            style: AppFonts.font(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
          if (!item.isDefault) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                ref
                    .read(addressNotifierProvider.notifier)
                    .setDefault(item.id);
              },
              child: Text(
                'Set as Default',
                style: AppFonts.font(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
