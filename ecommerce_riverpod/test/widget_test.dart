import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_getx/app/data/models/order.model.dart';
import 'package:architecture_getx/app/data/models/product.model.dart';
import 'package:architecture_getx/features/orders/pages/orders_page.dart';
import 'package:architecture_getx/features/orders/providers/order_provider.dart';
import 'package:architecture_getx/features/orders/widgets/order_card.dart';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:architecture_getx/l10n/app_localizations.dart';

class TestOrdersNotifier extends OrdersNotifier {
  final List<OrderRes> initialOrders;
  TestOrdersNotifier(this.initialOrders);

  @override
  OrdersState build() {
    return OrdersState(
      orders: AsyncValue.data(initialOrders),
      selectedTab: 0,
    );
  }

  @override
  Future<void> fetchOrders() async {
    if (!state.orders.hasValue) {
      state = state.copyWith(orders: const AsyncValue.loading());
    }
    await Future.delayed(const Duration(milliseconds: 10));
    state = state.copyWith(orders: AsyncValue.data(initialOrders));
  }
}

void main() {
  final sampleOrders = [
    OrderRes(
      id: 1,
      orderNumber: 'ORD-1001',
      status: 'pending',
      paymentStatus: 'paid',
      subtotal: 50.0,
      shippingFee: 5.0,
      total: 55.0,
      createdAt: DateTime.now(),
      items: [
        OrderItem(
          id: 1,
          quantity: 2,
          price: 25.0,
          product: ProductRes(
            id: 10,
            name: 'Test Sneaker',
            slug: 'test-sneaker',
            description: 'A great shoe',
            shortDescription: 'Shoe',
            price: 25.0,
            effectivePrice: 25.0,
            onSale: false,
            stock: 10,
            status: 'active',
            isFeatured: true,
            rating: 4.5,
            reviewsCount: 12,
            soldCount: 30,
            primaryImage: PrimaryImageModel(
              id: 1,
              url: 'https://example.com/shoe.png',
              alt: 'Shoe',
            ),
          ),
        ),
      ],
    ),
    OrderRes(
      id: 2,
      orderNumber: '',
      status: 'delivered',
      paymentStatus: 'paid',
      subtotal: 100.0,
      shippingFee: 0.0,
      total: 100.0,
      createdAt: null,
      items: [],
    ),
    OrderRes(
      id: 3,
      orderNumber: 'ORD-1003',
      status: 'cancelled',
      paymentStatus: 'refunded',
      subtotal: 30.0,
      shippingFee: 5.0,
      total: 35.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        OrderItem(
          id: 2,
          quantity: 1,
          price: 30.0,
          product: ProductRes(
            id: 20,
            name: 'Archived Item',
            slug: 'archived-item',
            description: '',
            shortDescription: '',
            price: 30.0,
            effectivePrice: 30.0,
            onSale: false,
            stock: 0,
            status: 'inactive',
            isFeatured: false,
            rating: 0.0,
            reviewsCount: 0,
            soldCount: 0,
            primaryImage: null,
          ),
        ),
      ],
    ),
  ];

  Widget buildTestWidget(List<OrderRes> orders) {
    return ProviderScope(
      overrides: [
        ordersNotifierProvider.overrideWith(() => TestOrdersNotifier(orders)),
      ],
      child: MaterialApp(
        theme: AppTheme.getTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OrdersPage(),
      ),
    );
  }

  testWidgets('OrdersPage renders active orders and handles tab switching', (tester) async {
    await tester.pumpWidget(buildTestWidget(sampleOrders));
    await tester.pumpAndSettle();

    // Verify Active order
    expect(find.text('#ORD-1001'), findsOneWidget);
    expect(find.text('Test Sneaker'), findsOneWidget);
    expect(find.byType(OrderCard), findsOneWidget);

    // Switch to Delivered tab
    await tester.tap(find.text('Delivered'));
    await tester.pumpAndSettle();

    // In Delivered tab, order #2 has empty orderNumber so it falls back to #2
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('Delivered'), findsWidgets);

    // Switch to Archive tab
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('#ORD-1003'), findsOneWidget);
    expect(find.text('Archived Item'), findsOneWidget);

    // Switch back to Active tab
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('#ORD-1001'), findsOneWidget);
  });

  testWidgets('Pull to refresh smoothly refreshes without unmounting or paint crash', (tester) async {
    await tester.pumpWidget(buildTestWidget(sampleOrders));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);

    // Drag down to trigger RefreshIndicator
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('#ORD-1001'), findsOneWidget);
  });

  testWidgets('Empty state renders correctly and allows pull to refresh', (tester) async {
    await tester.pumpWidget(buildTestWidget([]));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsNothing);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // Fling empty state
    await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  });

  testWidgets('Orders with same id or duplicate keys in ListView.builder', (tester) async {
    final duplicateIdOrders = [
      OrderRes(
        id: 0,
        orderNumber: 'ORD-001',
        status: 'pending',
        paymentStatus: 'paid',
        subtotal: 10.0,
        shippingFee: 2.0,
        total: 12.0,
        createdAt: DateTime.now(),
        items: [],
      ),
      OrderRes(
        id: 0,
        orderNumber: 'ORD-002',
        status: 'pending',
        paymentStatus: 'paid',
        subtotal: 20.0,
        shippingFee: 2.0,
        total: 22.0,
        createdAt: DateTime.now(),
        items: [],
      ),
    ];

    await tester.pumpWidget(buildTestWidget(duplicateIdOrders));
    await tester.pumpAndSettle();
  });
}
