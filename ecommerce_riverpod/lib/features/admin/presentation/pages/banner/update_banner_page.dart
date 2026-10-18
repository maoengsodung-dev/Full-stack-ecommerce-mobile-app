import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/banner_model.dart';
import '../../providers/admin_provider.dart';

class UpdateBannerPage extends ConsumerStatefulWidget {
  final AdminBanner banner;

  const UpdateBannerPage({super.key, required this.banner});

  @override
  ConsumerState<UpdateBannerPage> createState() => _UpdateBannerPageState();
}

class _UpdateBannerPageState extends ConsumerState<UpdateBannerPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _linkIdCtrl;
  late final TextEditingController _sortCtrl;
  late String _linkType;
  late bool _isActive;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.banner.title ?? '');
    _subtitleCtrl = TextEditingController(text: widget.banner.subtitle ?? '');
    _linkIdCtrl = TextEditingController(text: widget.banner.linkId ?? widget.banner.linkUrl ?? '');
    _sortCtrl = TextEditingController(text: widget.banner.sortOrder.toString());
    _linkType = widget.banner.linkType;
    _isActive = widget.banner.isActive;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _linkIdCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Change Banner Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        color: const Color(0xFF2563EB),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        color: const Color(0xFF0EA5E9),
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.undo_rounded, color: Color(0xFFEF4444)),
                    title: const Text(
                      'Revert to Original Image',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _imageFile = null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final sort = int.tryParse(_sortCtrl.text.trim()) ?? 0;
    final success = await ref.read(adminNotifierProvider.notifier).updateBanner(
          widget.banner.id,
          title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : null,
          subtitle:
              _subtitleCtrl.text.trim().isNotEmpty ? _subtitleCtrl.text.trim() : null,
          imageFile: _imageFile,
          position: widget.banner.position,
          isActive: _isActive,
          sortOrder: sort,
          linkType: _linkType,
          linkId: _linkIdCtrl.text.trim().isNotEmpty ? _linkIdCtrl.text.trim() : null,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final isSubmitting = adminState.actionState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Banner',
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
              // Banner Image Section
              const Text(
                'Banner Image',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _imageFile != null
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      width: _imageFile != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_imageFile != null)
                          Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          )
                        else if (widget.banner.resolvedImageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: widget.banner.resolvedImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 36,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 36,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload banner image',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        // Overlay action pill at bottom-right
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _imageFile != null ? 'Change' : 'Edit Image',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // New badge if user chose a replacement image
                        if (_imageFile != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'New Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Revert button if user selected a new file
                        if (_imageFile != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _imageFile = null);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Banner Title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _subtitleCtrl,
                decoration: InputDecoration(
                  labelText: 'Subtitle',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _linkType,
                decoration: InputDecoration(
                  labelText: 'Link Action Type',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('None')),
                  DropdownMenuItem(value: 'product', child: Text('Open Product')),
                  DropdownMenuItem(value: 'category', child: Text('Open Category')),
                  DropdownMenuItem(value: 'url', child: Text('External URL')),
                ],
                onChanged: (v) => setState(() => _linkType = v ?? 'none'),
              ),
              if (_linkType != 'none') ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _linkIdCtrl,
                  decoration: InputDecoration(
                    labelText: 'Product Slug or Category ID / URL',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextFormField(
                controller: _sortCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sort Order',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                title: const Text('Active Status'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
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
                          'Update Banner',
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
