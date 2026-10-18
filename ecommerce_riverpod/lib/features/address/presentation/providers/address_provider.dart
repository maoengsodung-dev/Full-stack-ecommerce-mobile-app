import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/data/models/address.model.dart';
import '../../../../app/data/repository/address_repository.dart';
import '../../../../app/core/providers/storage_providers.dart';

class AddressState {
  final AsyncValue<List<AddressModel>> addresses;
  final AddressModel? selectedAddress;
  final String searchQuery;
  final bool isSaving;

  const AddressState({
    this.addresses = const AsyncValue.loading(),
    this.selectedAddress,
    this.searchQuery = '',
    this.isSaving = false,
  });

  List<AddressModel> get addressList => addresses.valueOrNull ?? [];

  List<AddressModel> get filteredAddresses {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return addressList;
    return addressList.where((a) {
      return a.recipientName.toLowerCase().contains(q) ||
          a.label.toLowerCase().contains(q) ||
          a.address.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          (a.addressLine2 ?? '').toLowerCase().contains(q);
    }).toList();
  }

  AddressState copyWith({
    AsyncValue<List<AddressModel>>? addresses,
    AddressModel? Function()? selectedAddress,
    String? searchQuery,
    bool? isSaving,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress:
          selectedAddress != null ? selectedAddress() : this.selectedAddress,
      searchQuery: searchQuery ?? this.searchQuery,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AddressNotifier extends Notifier<AddressState> {
  @override
  AddressState build() {
    // Delay initial fetch until after build or trigger directly
    Future.microtask(() => fetchAddresses());
    return const AddressState();
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
    ];
  }

  void _persistToLocal(List<AddressModel> list) {
    try {
      final storage = ref.read(storageServiceProvider);
      final raw = list.map((a) => jsonEncode(a.toJson())).toList();
      storage.saveLocalAddresses(raw);
      final defaultAddr = list.where((a) => a.isDefault).firstOrNull;
      if (defaultAddr != null) {
        storage.saveDefaultAddressId(defaultAddr.id);
      }
    } catch (_) {}
  }

  List<AddressModel> _readFromLocal() {
    try {
      final storage = ref.read(storageServiceProvider);
      final raw = storage.getLocalAddresses();
      if (raw.isNotEmpty) {
        final list = raw
            .map((str) => AddressModel.fromJson(jsonDecode(str)))
            .toList();
        final savedDefaultId = storage.getDefaultAddressId();
        if (savedDefaultId != null) {
          return list
              .map((a) => a.copyWith(isDefault: a.id == savedDefaultId))
              .toList();
        }
        return list;
      }
    } catch (_) {}
    return [];
  }

  Future<void> fetchAddresses() async {
    state = state.copyWith(addresses: const AsyncValue.loading());
    try {
      final repo = ref.read(addressRepositoryProvider);
      final storage = ref.read(storageServiceProvider);

      final list = await repo.getAddresses();
      List<AddressModel> result;
      if (list.isNotEmpty) {
        final savedDefaultId = storage.getDefaultAddressId();
        if (savedDefaultId != null && !list.any((a) => a.isDefault)) {
          result = list
              .map((a) => a.copyWith(isDefault: a.id == savedDefaultId))
              .toList();
        } else {
          result = list;
        }
        _persistToLocal(result);
      } else {
        final local = _readFromLocal();
        if (local.isNotEmpty) {
          result = local;
        } else {
          result = _buildDemoAddresses();
          _persistToLocal(result);
        }
      }

      final defaultItem = result.where((a) => a.isDefault).firstOrNull ??
          (result.isNotEmpty ? result.first : null);

      state = state.copyWith(
        addresses: AsyncValue.data(result),
        selectedAddress: () => defaultItem,
      );
    } catch (e, st) {
      final local = _readFromLocal();
      final result = local.isNotEmpty ? local : _buildDemoAddresses();
      state = state.copyWith(
        addresses: AsyncValue.data(result),
        selectedAddress: () => result.firstOrNull,
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: () => address);
  }

  Future<void> setDefault(int id) async {
    final currentList = state.addressList;
    final updated = currentList.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();

    final selected = updated.where((a) => a.id == id).firstOrNull;

    state = state.copyWith(
      addresses: AsyncValue.data(updated),
      selectedAddress: () => selected,
    );

    _persistToLocal(updated);

    try {
      final repo = ref.read(addressRepositoryProvider);
      await repo.setDefaultAddress(id);
    } catch (_) {}
  }

  Future<void> deleteAddress(int id) async {
    final currentList = state.addressList;
    final updated = currentList.where((a) => a.id != id).toList();

    AddressModel? nextSelected = state.selectedAddress;
    if (nextSelected?.id == id) {
      nextSelected = updated.where((a) => a.isDefault).firstOrNull ??
          updated.firstOrNull;
    }

    state = state.copyWith(
      addresses: AsyncValue.data(updated),
      selectedAddress: () => nextSelected,
    );

    _persistToLocal(updated);

    try {
      final repo = ref.read(addressRepositoryProvider);
      await repo.deleteAddress(id);
    } catch (_) {}
  }

  Future<bool> saveAddress(Map<String, dynamic> data, {int? id}) async {
    state = state.copyWith(isSaving: true);
    try {
      final repo = ref.read(addressRepositoryProvider);
      final payload = Map<String, dynamic>.from(data);
      if (payload['country'] == null ||
          payload['country'].toString().trim().isEmpty) {
        payload['country'] = 'Cambodia';
      }
      if (payload['province'] == null ||
          payload['province'].toString().trim().isEmpty) {
        payload['province'] = 'Phnom Penh';
      }

      AddressModel saved;
      if (id == null) {
        saved = await repo.addAddress(payload);
      } else {
        saved = await repo.updateAddress(id, payload);
      }

      final current = [...state.addressList];
      final isDefault = data['is_default'] == true;

      if (id == null) {
        current.add(saved);
      } else {
        final idx = current.indexWhere((a) => a.id == id);
        if (idx >= 0) {
          current[idx] = saved;
        } else {
          current.add(saved);
        }
      }

      List<AddressModel> updatedList;
      if (isDefault) {
        updatedList = current
            .map((a) => a.copyWith(isDefault: a.id == saved.id))
            .toList();
      } else {
        updatedList = current;
      }

      state = state.copyWith(
        addresses: AsyncValue.data(updatedList),
        selectedAddress: () => isDefault ? saved : state.selectedAddress,
        isSaving: false,
      );

      _persistToLocal(updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

final addressNotifierProvider =
    NotifierProvider<AddressNotifier, AddressState>(AddressNotifier.new);
