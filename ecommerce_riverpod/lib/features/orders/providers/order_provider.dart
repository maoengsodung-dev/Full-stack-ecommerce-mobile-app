import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data/models/order.model.dart';
import '../../../app/data/repository/order_repository.dart';

class OrdersState {
  final AsyncValue<List<OrderRes>> orders;
  final int selectedTab;
  final String searchQuery;
  final AsyncValue<OrderRes?> selectedOrderDetail;
  final bool isCancelling;

  const OrdersState({
    this.orders = const AsyncValue.loading(),
    this.selectedTab = 0,
    this.searchQuery = '',
    this.selectedOrderDetail = const AsyncValue.data(null),
    this.isCancelling = false,
  });

  List<OrderRes> get allOrders => orders.valueOrNull ?? [];

  List<OrderRes> get activeOrders => allOrders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'processing' ||
            s == 'shipped' ||
            s == 'pending' ||
            s == 'in_transit' ||
            s == 'out_for_delivery';
      }).toList();

  List<OrderRes> get deliveredOrders => allOrders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'delivered' || s == 'completed';
      }).toList();

  List<OrderRes> get archivedOrders => allOrders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'cancelled' ||
            s == 'canceled' ||
            s == 'refunded' ||
            s == 'archive';
      }).toList();

  int get activeCount => activeOrders.length;
  int get deliveredCount => deliveredOrders.length;
  int get archiveCount => archivedOrders.length;

  List<OrderRes> get filteredOrders {
    List<OrderRes> list;
    switch (selectedTab) {
      case 0:
        list = activeOrders;
        break;
      case 1:
        list = deliveredOrders;
        break;
      case 2:
        list = archivedOrders;
        break;
      default:
        list = allOrders;
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((o) {
        final numMatch = o.orderNumber.toLowerCase().contains(q);
        final itemMatch =
            o.items.any((it) => it.product.name.toLowerCase().contains(q));
        return numMatch || itemMatch;
      }).toList();
    }
    return list;
  }

  OrdersState copyWith({
    AsyncValue<List<OrderRes>>? orders,
    int? selectedTab,
    String? searchQuery,
    AsyncValue<OrderRes?>? selectedOrderDetail,
    bool? isCancelling,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedOrderDetail: selectedOrderDetail ?? this.selectedOrderDetail,
      isCancelling: isCancelling ?? this.isCancelling,
    );
  }
}

class OrdersNotifier extends Notifier<OrdersState> {
  @override
  OrdersState build() {
    Future.microtask(() => fetchOrders());
    return const OrdersState();
  }

  Future<void> fetchOrders() async {
    if (!state.orders.hasValue) {
      state = state.copyWith(orders: const AsyncValue.loading());
    }
    try {
      final repo = ref.read(orderRepositoryProvider);
      final list = await repo.getOrders();
      state = state.copyWith(orders: AsyncValue.data(list));
    } catch (e, st) {
      if (!state.orders.hasValue) {
        state = state.copyWith(orders: AsyncValue.error(e, st));
      }
    }
  }

  void setTab(int tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> fetchOrderDetail(dynamic orderNumberOrId) async {
    state = state.copyWith(selectedOrderDetail: const AsyncValue.loading());
    try {
      final repo = ref.read(orderRepositoryProvider);
      final detail = await repo.getOrderDetail(orderNumberOrId);
      state = state.copyWith(selectedOrderDetail: AsyncValue.data(detail));
    } catch (e) {
      final cached = state.allOrders.cast<OrderRes?>().firstWhere(
            (o) =>
                o?.id == orderNumberOrId ||
                o?.orderNumber == orderNumberOrId.toString(),
            orElse: () => null,
          );
      state = state.copyWith(selectedOrderDetail: AsyncValue.data(cached));
    }
  }

  bool canCancelOrder(OrderRes? order) {
    if (order == null) return false;
    final s = order.status.toLowerCase();
    return s == 'processing' || s == 'pending';
  }

  Future<bool> cancelOrder(int id, {String? reason}) async {
    state = state.copyWith(isCancelling: true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      try {
        await repo.cancelOrder(id, reason: reason);
      } catch (_) {}
      try {
        await repo.deleteOrder(id);
      } catch (_) {}

      final updated = state.allOrders.where((o) => o.id != id).toList();
      state = state.copyWith(
        orders: AsyncValue.data(updated),
        isCancelling: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(isCancelling: false);
      return false;
    }
  }

  Future<bool> deleteProductFromOrder(int orderId, int itemId) async {
    final order = state.allOrders.cast<OrderRes?>().firstWhere(
          (o) => o?.id == orderId,
          orElse: () => null,
        );
    if (order == null || !canCancelOrder(order)) return false;

    if (order.items.length <= 1) {
      return cancelOrder(orderId);
    }

    try {
      final repo = ref.read(orderRepositoryProvider);
      try {
        await repo.deleteOrderItem(orderId, itemId);
      } catch (_) {}

      final updatedItems =
          order.items.where((it) => it.id != itemId).toList();
      final newSubtotal =
          updatedItems.fold<double>(0, (sum, it) => sum + it.subtotal);
      final newTotal = newSubtotal + order.shippingFee;

      final updatedOrder = order.copyWith(
        items: updatedItems,
        subtotal: newSubtotal,
        total: newTotal,
      );

      final updatedList = state.allOrders.map((o) {
        return o.id == orderId ? updatedOrder : o;
      }).toList();

      state = state.copyWith(
        orders: AsyncValue.data(updatedList),
        selectedOrderDetail: AsyncValue.data(updatedOrder),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final ordersNotifierProvider =
    NotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);
