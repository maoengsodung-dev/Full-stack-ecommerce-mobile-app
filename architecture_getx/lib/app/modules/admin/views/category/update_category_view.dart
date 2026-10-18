import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/media_url_resolver.dart';
import '../../controllers/admin_controller.dart';
import '../../models/category_model.dart';

class UpdateCategoryView extends StatefulWidget {
  const UpdateCategoryView({super.key});

  @override
  State<UpdateCategoryView> createState() => _UpdateCategoryViewState();
}

class _UpdateCategoryViewState extends State<UpdateCategoryView> {
  final _formKey = GlobalKey<FormState>();
  late AdminCategory _category;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descCtrl;
  late bool _isActive;

  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is AdminCategory) {
      _category = args;
    } else {
      _category = const AdminCategory(
        id: 0,
        name: '',
        slug: '',
      );
    }

    _nameCtrl = TextEditingController(text: _category.name);
    _slugCtrl = TextEditingController(text: _category.slug);
    _descCtrl = TextEditingController(text: _category.description ?? '');
    _isActive = _category.isActive;
  }

  final _nameFocusNode = FocusNode();
  final _slugFocusNode = FocusNode();
  final _descFocusNode = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _nameFocusNode.dispose();
    _slugFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
      });
    }
  }

  void _clearPickedImage() {
    setState(() {
      _newImageFile = null;
    });
  }

  Future<void> _submit(AdminController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await controller.updateCategory(
      _category.id,
      name: _nameCtrl.text.trim(),
      slug: _slugCtrl.text.trim().isNotEmpty ? _slugCtrl.text.trim() : null,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      isActive: _isActive,
      imageFile: _newImageFile,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _confirmDelete(BuildContext context, AdminController controller) {
    final hasProducts = _category.productsCount > 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Delete Category',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${_category.name}"?',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            if (hasProducts)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This category has ${_category.productsCount} products. The server will prevent deletion until all assigned products are reassigned or removed.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'This action is irreversible. The category will be permanently deleted from the database.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: Size.zero),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted = await controller.deleteCategory(_category.id);
              if (deleted && mounted) {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final existingImageUrl = MediaUrlResolver.resolve(_category.image ?? _category.icon);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Edit Category #${_category.id}',
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
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFDC2626),
            ),
            tooltip: 'Delete Category',
            onPressed: () => _confirmDelete(context, controller),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FocusScope(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Overview Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.folder_special_rounded,
                            color: Color(0xFF2563EB),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _category.name.isNotEmpty
                                    ? _category.name
                                    : 'Category Details',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID #${_category.id} • ${_category.productsCount} products assigned',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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

                  // Name Field
                  _buildLabel('Category Name *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _slugFocusNode.requestFocus(),
                    decoration: _inputDecoration('e.g. Hoodies & Sweatshirts'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter category name';
                      }
                      if (val.trim().length > 120) {
                        return 'Category name cannot exceed 120 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Slug Field
                  _buildLabel('URL Slug (Optional / Custom)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _slugCtrl,
                    focusNode: _slugFocusNode,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _descFocusNode.requestFocus(),
                    decoration: _inputDecoration('e.g. hoodies-sweatshirts'),
                  ),
                  const SizedBox(height: 18),

                  // Description Field
                  _buildLabel('Description (Optional)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    focusNode: _descFocusNode,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration('Short description of category contents...'),
                  ),
                  const SizedBox(height: 20),

                // Category Image Section
                _buildLabel('Category Image'),
                const SizedBox(height: 8),
                _buildImagePicker(existingImageUrl),
                const SizedBox(height: 20),

                // Active Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Active Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: const Text(
                      'Visible to customers in the public store',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    value: _isActive,
                    activeThumbColor: const Color(0xFF0F172A),
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                Obx(() {
                  final isBusy = controller.isSubmitting.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : () => _submit(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, controller),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    label: const Text(
                      'Delete Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildImagePicker(String existingImageUrl) {
    final hasNewFile = _newImageFile != null;
    final hasExisting = existingImageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Preview Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFFF1F5F9),
              child: hasNewFile
                  ? Image.file(_newImageFile!, fit: BoxFit.cover)
                  : (hasExisting
                      ? CachedNetworkImage(
                          imageUrl: existingImageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.folder_open_rounded,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0xFF94A3B8),
                            size: 28,
                          ),
                        )),
            ),
          ),
          const SizedBox(width: 14),

          // Action Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasNewFile
                      ? 'New image selected'
                      : (hasExisting ? 'Current Category Image' : 'No Image Uploaded'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_outlined, size: 14),
                      label: Text(
                        hasNewFile || hasExisting ? 'Change' : 'Pick Image',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                    if (hasNewFile) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _clearPickedImage,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
