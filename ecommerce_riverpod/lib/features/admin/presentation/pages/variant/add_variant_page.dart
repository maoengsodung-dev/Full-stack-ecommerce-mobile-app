import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/product_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/variant_form.dart';

class AddVariantPage extends ConsumerWidget {
  final AdminProduct? product;

  const AddVariantPage({super.key, this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prod = product ??
        const AdminProduct(
          id: 0,
          name: 'Product',
          slug: '',
          price: 0,
          stock: 0,
        );
    final adminState = ref.watch(adminNotifierProvider);
    final isSubmitting = adminState.actionState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Add Variant - #${prod.id}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Base Price: \$${prod.price.toStringAsFixed(2)} | Stock: ${prod.stock}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            VariantForm(
              initialSkuPrefix: prod.slug.isNotEmpty ? prod.slug : 'SKU',
              isSubmitting: isSubmitting,
              onSubmit: (variant) async {
                final ok = await ref
                    .read(adminNotifierProvider.notifier)
                    .addVariant(prod.id, variant);
                if (ok && context.mounted) {
                  Navigator.of(context).pop();
                } else if (!ok && context.mounted) {
                  final error =
                      ref.read(adminNotifierProvider).actionState.error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(error?.toString() ?? 'Failed to add variant'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onSubmitMultiple: (variants) async {
                final ok = await ref
                    .read(adminNotifierProvider.notifier)
                    .addVariants(prod.id, variants);
                if (ok && context.mounted) {
                  Navigator.of(context).pop();
                } else if (!ok && context.mounted) {
                  final error =
                      ref.read(adminNotifierProvider).actionState.error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(error?.toString() ?? 'Failed to add variants'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
