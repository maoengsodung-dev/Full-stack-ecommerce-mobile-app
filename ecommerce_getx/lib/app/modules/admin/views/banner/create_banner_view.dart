import 'dart:io';
import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/admin_controller.dart';

class CreateBannerView extends StatefulWidget {
  const CreateBannerView({super.key});

  @override
  State<CreateBannerView> createState() => _CreateBannerViewState();
}

class _CreateBannerViewState extends State<CreateBannerView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _linkIdCtrl = TextEditingController();
  final _linkUrlCtrl = TextEditingController();
  final _sortOrderCtrl = TextEditingController(text: '0');
  final _customPositionCtrl = TextEditingController();

  final _titleFocusNode = FocusNode();
  final _subtitleFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _linkIdFocusNode = FocusNode();
  final _linkUrlFocusNode = FocusNode();
  final _sortOrderFocusNode = FocusNode();

  File? _pickedImage;
  String _selectedPosition = 'home_slider';
  String _linkType = 'none';
  bool _isActive = true;

  final List<String> _positionOptions = [
    'home_slider',
    'home_banner',
    'promo',
    'popup',
    'other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _imageUrlCtrl.dispose();
    _linkIdCtrl.dispose();
    _linkUrlCtrl.dispose();
    _sortOrderCtrl.dispose();
    _customPositionCtrl.dispose();

    _titleFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _linkIdFocusNode.dispose();
    _linkUrlFocusNode.dispose();
    _sortOrderFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _imageUrlCtrl.clear();
      });
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  Future<void> _submit(AdminController controller) async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null && _imageUrlCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Image Required',
        'Please upload an image file or provide an image URL.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    final effectivePosition = _selectedPosition == 'other'
        ? _customPositionCtrl.text.trim().isNotEmpty
              ? _customPositionCtrl.text.trim()
              : 'home_slider'
        : _selectedPosition;

    final sortOrder = int.tryParse(_sortOrderCtrl.text.trim()) ?? 0;

    final success = await controller.createBanner(
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : null,
      subtitle: _subtitleCtrl.text.trim().isNotEmpty
          ? _subtitleCtrl.text.trim()
          : null,
      imageUrl: _pickedImage == null && _imageUrlCtrl.text.trim().isNotEmpty
          ? _imageUrlCtrl.text.trim()
          : null,
      imageFile: _pickedImage,
      position: effectivePosition,
      isActive: _isActive,
      sortOrder: sortOrder,
      linkType: _linkType,
      linkId:
          (_linkType == 'product' || _linkType == 'category') &&
              _linkIdCtrl.text.trim().isNotEmpty
          ? _linkIdCtrl.text.trim()
          : null,
      linkUrl: _linkType == 'external' && _linkUrlCtrl.text.trim().isNotEmpty
          ? _linkUrlCtrl.text.trim()
          : null,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Create Banner',
          style: TextStyle(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner Image Section
                _buildSectionHeader(
                  title: 'Banner Image',
                  subtitle: 'Upload an image or enter a remote image URL',
                ),
                const SizedBox(height: 10),
                _buildImagePickerCard(),
                const SizedBox(height: 20),

                // 2. Banner Details Section
                _buildSectionHeader(
                  title: 'Banner Content',
                  subtitle: 'Title, subtitle and display settings',
                ),
                const SizedBox(height: 10),
                _buildCard([
                  _buildTextField(
                    controller: _titleCtrl,
                    focusNode: _titleFocusNode,
                    label: 'Banner Title (Optional)',
                    hint: 'e.g. Summer Flash Sale 2026',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _subtitleCtrl,
                    focusNode: _subtitleFocusNode,
                    label: 'Subtitle / Tagline (Optional)',
                    hint: 'e.g. Up to 50% discount on selected electronics',
                    icon: Icons.subtitles_outlined,
                    maxLines: 2,
                  ),
                ]),
                const SizedBox(height: 20),

                // 3. Placement & Position Section
                _buildSectionHeader(
                  title: 'Placement & Position',
                  subtitle: 'Where this banner is displayed in the application',
                ),
                const SizedBox(height: 10),
                _buildCard([
                  const Text(
                    'Position Slot',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _positionOptions.map((pos) {
                      final isSel = _selectedPosition == pos;
                      return ChoiceChip(
                        label: Text(
                          pos == 'other' ? 'Custom...' : pos,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                        selected: isSel,
                        selectedColor:AppColors.primaryLight,
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide.none,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPosition = pos;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedPosition == 'other') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _customPositionCtrl,
                      label: 'Custom Position Name',
                      hint: 'e.g. cart_header, checkout_promo',
                      icon: Icons.place_outlined,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _sortOrderCtrl,
                    focusNode: _sortOrderFocusNode,
                    label: 'Sort Order (0 = highest priority)',
                    hint: '0',
                    icon: Icons.sort_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ]),
                const SizedBox(height: 20),

                // 4. Link & Navigation Section
                _buildSectionHeader(
                  title: 'Action Link',
                  subtitle: 'Navigate when the user taps on this banner',
                ),
                const SizedBox(height: 10),
                _buildCard([
                  DropdownButtonFormField<String>(
                    initialValue: _linkType,
                    isExpanded: true, // ✅ Prevents horizontal overflow
                    decoration: InputDecoration(
                      labelText: 'Link Type',
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: const Icon(
                        Icons.link_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'none',
                        child: Text(
                          'None (Static display)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'product',
                        child: Text(
                          'Product (Opens product detail)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'category',
                        child: Text(
                          'Category (Opens category catalog)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'external',
                        child: Text(
                          'External Link (Opens browser)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _linkType = val;
                        });
                      }
                    },
                  ),
                  if (_linkType == 'product') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _linkIdCtrl,
                      focusNode: _linkIdFocusNode,
                      label: 'Product ID',
                      hint: 'e.g. 21, 22',
                      icon: Icons.shopping_bag_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    if (controller.products.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.products.take(6).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, idx) {
                            final p = controller.products[idx];
                            return ActionChip(
                              label: Text(
                                '#${p.id} ${p.name}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  _linkIdCtrl.text = p.id.toString();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ] else if (_linkType == 'category') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _linkIdCtrl,
                      focusNode: _linkIdFocusNode,
                      label: 'Category ID',
                      hint: 'e.g. 15, 16',
                      icon: Icons.folder_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    if (controller.categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.categories.take(6).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, idx) {
                            final c = controller.categories[idx];
                            return ActionChip(
                              label: Text(
                                '#${c.id} ${c.name}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  _linkIdCtrl.text = c.id.toString();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ] else if (_linkType == 'external') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _linkUrlCtrl,
                      focusNode: _linkUrlFocusNode,
                      label: 'External URL',
                      hint: 'https://example.com/promo',
                      icon: Icons.language_rounded,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ]),
                const SizedBox(height: 20),

                // 5. Visibility Status Section
                _buildCard([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enable or disable banner display in app',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isActive,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 32),

                // Submit Button
                Obx(() {
                  final loading = controller.isSubmitting.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : () => _submit(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor: const Color(
                          0xFF0F172A,
                        ).withValues(alpha: 0.5),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Create Banner',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pickedImage != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: const Color(0xFFF1F5F9),
                    child: Image.file(_pickedImage!, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: _clearImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(
                    _pickedImage == null ? 'Upload File' : 'Change Image',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR URL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _imageUrlCtrl,
            focusNode: _imageUrlFocusNode,
            label: 'Image URL',
            hint: 'https://images.unsplash.com/...',
            icon: Icons.link_rounded,
            onChanged: (val) {
              if (val.isNotEmpty && _pickedImage != null) {
                setState(() {
                  _pickedImage = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
