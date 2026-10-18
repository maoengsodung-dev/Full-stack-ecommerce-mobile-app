import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/product_images_picker.dart';

class CreateProductPage extends ConsumerStatefulWidget {
  const CreateProductPage({super.key});

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _shortDescCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  int? _selectedCategoryId;
  String _status = 'active';
  bool _isFeatured = true;

  List<String> _existingUrls = [];
  List<File> _localFiles = [];
  int _primaryIndex = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _shortDescCtrl.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final salePrice = double.tryParse(_salePriceCtrl.text.trim());
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final success = await ref.read(adminNotifierProvider.notifier).createProduct(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          shortDescription: _shortDescCtrl.text.trim().isNotEmpty
              ? _shortDescCtrl.text.trim()
              : _nameCtrl.text.trim(),
          price: price,
          salePrice: salePrice,
          stock: stock,
          categoryId: _selectedCategoryId!,
          status: _status,
          isFeatured: _isFeatured,
          imageFiles: _localFiles,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final isSubmitting = adminState.actionState.isLoading;
    final categories = adminState.categories.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'New Product',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images Picker
              ProductImagesPicker(
                initialUrls: _existingUrls,
                initialFiles: _localFiles,
                onChanged: (data) {
                  _existingUrls = data.existingUrls;
                  _localFiles = data.localFiles;
                  _primaryIndex = data.primaryIndex;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Please select category' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price (\$) *',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Sale Price (\$)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stock Quantity *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Stock required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _shortDescCtrl,
                decoration: InputDecoration(
                  labelText: 'Short Description',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Full Description *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description required' : null,
              ),
              const SizedBox(height: 14),

              SwitchListTile(
                title: const Text('Featured Product'),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
