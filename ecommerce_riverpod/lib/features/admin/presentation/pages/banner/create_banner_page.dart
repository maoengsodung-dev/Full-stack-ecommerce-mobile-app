import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/admin_provider.dart';

class CreateBannerPage extends ConsumerStatefulWidget {
  const CreateBannerPage({super.key});

  @override
  ConsumerState<CreateBannerPage> createState() => _CreateBannerPageState();
}

class _CreateBannerPageState extends ConsumerState<CreateBannerPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _linkIdCtrl = TextEditingController();
  final _sortCtrl = TextEditingController(text: '0');
  String _position = 'home_slider';
  String _linkType = 'none';
  bool _isActive = true;
  File? _imageFile;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _linkIdCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a banner image.')),
      );
      return;
    }

    final sort = int.tryParse(_sortCtrl.text.trim()) ?? 0;
    final success = await ref.read(adminNotifierProvider.notifier).createBanner(
          title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : null,
          subtitle:
              _subtitleCtrl.text.trim().isNotEmpty ? _subtitleCtrl.text.trim() : null,
          imageFile: _imageFile,
          position: _position,
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
          'New Banner',
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
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 36,
                              color: Color(0xFF64748B),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload banner image *',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Banner Title (optional)',
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
                  labelText: 'Subtitle / Description (optional)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _linkType,
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
                    labelText: _linkType == 'url'
                        ? 'External Web URL'
                        : 'Product Slug or Category ID',
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
                  labelText: 'Sort Order (0 = highest)',
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
                          'Create Banner',
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
