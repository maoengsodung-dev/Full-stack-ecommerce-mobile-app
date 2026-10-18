import 'package:architecture_getx/app/data/models/order.model.dart';
import 'package:architecture_getx/app/data/repository/order_repository.dart';
import 'package:architecture_getx/app/modules/cart/controllers/cart_controller.dart';
import 'package:architecture_getx/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final OrderRepository _repo;
  OrdersController(this._repo);

  final isLoading = false.obs;
  final isCancelling = false.obs;
  final orders = <OrderRes>[].obs;
  final errorMessage = ''.obs;
  final selectedOrder = Rxn<OrderRes>();
  final isLoadingDetail = false.obs;
  final Set<int> _deletedOrderIds = <int>{};

  // 3 Tabs matching the design: Active, Delivered, Archive
  final selectedTab = 0.obs;
  final tabs = ['Active', 'Delivered', 'Archive'];
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  int get activeCount => activeOrders.length;
  int get deliveredCount => deliveredOrders.length;
  int get archiveCount => archivedOrders.length;

  List<OrderRes> get activeOrders => orders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'processing' ||
            s == 'shipped' ||
            s == 'pending' ||
            s == 'in_transit' ||
            s == 'out_for_delivery';
      }).toList();

  List<OrderRes> get deliveredOrders => orders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'delivered' || s == 'completed';
      }).toList();

  List<OrderRes> get archivedOrders => orders.where((o) {
        final s = o.status.toLowerCase();
        return s == 'cancelled' ||
            s == 'canceled' ||
            s == 'refunded' ||
            s == 'archive';
      }).toList();

  List<OrderRes> get filteredOrders {
    List<OrderRes> list;
    switch (selectedTab.value) {
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
        list = orders;
    }
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((o) {
        final numMatch = o.orderNumber.toLowerCase().contains(q);
        final itemMatch =
            o.items.any((it) => it.product.name.toLowerCase().contains(q));
        return numMatch || itemMatch;
      }).toList();
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final list = await _repo.getOrders();
      orders.assignAll(list);
    } catch (e) {
      debugPrint('[OrdersController] Error fetching orders: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


  void buyAgain(OrderItem item) {
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().addItem(
        item.product.id,
        quantity: 1,
        product: item.product,
      );
    }
    Get.snackbar(
      'Added to Cart',
      '${item.product.name} has been added to your cart.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFC6F432),
      colorText: Colors.black,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
    );
  }

  Future<void> fetchOrderDetail(dynamic orderNumberOrId) async {
    try {
      isLoadingDetail.value = true;
      selectedOrder.value = await _repo.getOrderDetail(orderNumberOrId);
    } catch (_) {
      selectedOrder.value = orders.firstWhereOrNull((o) =>
          o.id == orderNumberOrId || o.orderNumber == orderNumberOrId.toString());
    } finally {
      if (selectedOrder.value == null) {
        selectedOrder.value = orders.firstWhereOrNull((o) =>
            o.id == orderNumberOrId || o.orderNumber == orderNumberOrId.toString());
      }
      isLoadingDetail.value = false;
    }
  }

  bool canCancelOrder(OrderRes? order) {
    if (order == null) return false;
    final s = order.status.toLowerCase();
    return s == 'processing' || s == 'pending';
  }

  Future<void> cancelOrder(int id, {String? reason}) async {
    final order = orders.firstWhereOrNull((o) => o.id == id) ?? selectedOrder.value;
    if (order == null) return;

    final orderNumber = order.orderNumber.isNotEmpty == true
        ? order.orderNumber
        : '#$id';

    try {
      isCancelling.value = true;

      // 1. Delete order from "My Orders" list
      _deletedOrderIds.add(id);
      orders.removeWhere((o) => o.id == id);
      orders.refresh();
      if (selectedOrder.value?.id == id) {
        selectedOrder.value = null;
      }

      // 2. Return to My Orders screen if on Order Detail
      if (Get.isDialogOpen == true) {
        Get.back(); // close dialog if open
      }
      if (Get.currentRoute == Routes.ORDER_DETAIL) {
        Get.back(); // close OrderDetailView
      }

      // 3. Persist to API in background
      try {
        await _repo.cancelOrder(id, reason: reason);
      } catch (_) {}
      try {
        await _repo.deleteOrder(id);
      } catch (_) {}

      Get.snackbar(
        'Order Cancelled',
        'Order $orderNumber was cancelled and removed from My Orders.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E1E1E),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCancelling.value = false;
    }
  }

  Future<void> deleteProductFromOrder(int orderId, int itemId) async {
    final order = orders.firstWhereOrNull((o) => o.id == orderId) ?? selectedOrder.value;
    if (order == null) return;
    if (!canCancelOrder(order)) {
      Get.snackbar(
        'Cannot Modify',
        'This order is ${order.status} and cannot be modified.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // If only 1 product remains, deleting it cancels the whole order
    if (order.items.length <= 1) {
      await cancelOrder(orderId);
      return;
    }

    final itemToRemove = order.items.firstWhereOrNull((it) => it.id == itemId);
    final updatedItems = order.items.where((it) => it.id != itemId).toList();
    final newSubtotal = updatedItems.fold<double>(0, (sum, it) => sum + it.subtotal);
    final newTotal = newSubtotal + order.shippingFee;

    final updatedOrder = order.copyWith(
      items: updatedItems,
      subtotal: newSubtotal,
      total: newTotal,
    );

    // Update in list
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      orders[index] = updatedOrder;
      orders.refresh();
    }
    if (selectedOrder.value?.id == orderId) {
      selectedOrder.value = updatedOrder;
    }

    // Persist to API
    try {
      await _repo.deleteOrderItem(orderId, itemId);
    } catch (_) {}

    Get.snackbar(
      'Product Removed',
      '${itemToRemove?.product.name ?? 'Product'} removed from your order.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E1E1E),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}

