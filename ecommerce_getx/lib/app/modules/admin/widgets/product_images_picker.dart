import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImagesData {
  final List<String> existingUrls;
  final List<File> localFiles;
  final int primaryIndex;

  const ProductImagesData({
    required this.existingUrls,
    required this.localFiles,
    required this.primaryIndex,
  });

  int get totalCount => existingUrls.length + localFiles.length;

  /// Returns the primary image as a File if local, or null
  File? get primaryFile {
    if (primaryIndex >= existingUrls.length && primaryIndex < totalCount) {
      return localFiles[primaryIndex - existingUrls.length];
    }
    return localFiles.isNotEmpty ? localFiles.first : null;
  }

  /// Returns the primary image as a URL if network, or null
  String? get primaryUrl {
    if (primaryIndex < existingUrls.length) {
      return existingUrls[primaryIndex];
    }
    return existingUrls.isNotEmpty ? existingUrls.first : null;
  }

  /// Returns all local files with primary image first
  List<File> get sortedLocalFiles {
    if (localFiles.isEmpty) return [];
    final primary = primaryFile;
    if (primary == null) return List.from(localFiles);
    final rest = localFiles.where((f) => f.path != primary.path).toList();
    return [primary, ...rest];
  }

  /// Returns all existing URLs with primary URL first
  List<String> get sortedExistingUrls {
    if (existingUrls.isEmpty) return [];
    final primary = primaryUrl;
    if (primary == null) return List.from(existingUrls);
    final rest = existingUrls.where((u) => u != primary).toList();
    return [primary, ...rest];
  }
}

class ProductImagesPicker extends StatefulWidget {
  final List<String> initialUrls;
  final List<File> initialFiles;
  final ValueChanged<ProductImagesData> onChanged;

  const ProductImagesPicker({
    super.key,
    this.initialUrls = const [],
    this.initialFiles = const [],
    required this.onChanged,
  });

  @override
  State<ProductImagesPicker> createState() => _ProductImagesPickerState();
}

class _ProductImagesPickerState extends State<ProductImagesPicker> {
  late List<String> _existingUrls;
  late List<File> _localFiles;
  int _primaryIndex = 0;

  @override
  void initState() {
    super.initState();
    _existingUrls = List.from(widget.initialUrls);
    _localFiles = List.from(widget.initialFiles);
    _notify();
  }

  int get _totalCount => _existingUrls.length + _localFiles.length;

  void _notify() {
    if (_primaryIndex >= _totalCount && _totalCount > 0) {
      _primaryIndex = 0;
    }
    widget.onChanged(
      ProductImagesData(
        existingUrls: List.unmodifiable(_existingUrls),
        localFiles: List.unmodifiable(_localFiles),
        primaryIndex: _primaryIndex,
      ),
    );
  }

  Future<void> _pickMultiFromGallery() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedList.isNotEmpty) {
      setState(() {
        for (final p in pickedList) {
          final file = File(p.path);
          if (!_localFiles.any((f) => f.path == file.path)) {
            _localFiles.add(file);
          }
        }
        _notify();
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        final file = File(picked.path);
        _localFiles.add(file);
        _notify();
      });
    }
  }

  Future<void> _addViaUrlDialog() async {
    final urlCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.link_rounded, color: Color(0xFF2563EB), size: 22),
            SizedBox(width: 8),
            Text('Add Image URL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: TextField(
          controller: urlCtrl,
          autofocus: true,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              final val = urlCtrl.text.trim();
              if (val.isNotEmpty) Navigator.pop(ctx, val);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add URL'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (!_existingUrls.contains(result)) {
          _existingUrls.add(result);
          _notify();
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _existingUrls.length) {
        _existingUrls.removeAt(index);
      } else {
        _localFiles.removeAt(index - _existingUrls.length);
      }

      if (_primaryIndex >= _totalCount && _totalCount > 0) {
        _primaryIndex = _totalCount - 1;
      } else if (_totalCount == 0) {
        _primaryIndex = 0;
      }
      _notify();
    });
  }

  void _setPrimary(int index) {
    if (index >= 0 && index < _totalCount) {
      setState(() {
        _primaryIndex = index;
        _notify();
      });
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add Product Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You can select multiple images from your gallery',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _sourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery (Multi)',
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.pop(context);
                        _pickMultiFromGallery();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _sourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF0EA5E9),
                      onTap: () {
                        Navigator.pop(context);
                        _pickFromCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _sourceOption(
                      icon: Icons.link_rounded,
                      label: 'Image URL',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.pop(context);
                        _addViaUrlDialog();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = _totalCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.collections_rounded, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                const Text(
                  'Product Images',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                if (hasImages) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_totalCount photos',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (hasImages)
              InkWell(
                onTap: _showSourceSheet,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, size: 15, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text(
                        'Add More',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Primary Image Hero Preview or Empty State
        if (hasImages)
          _buildPrimaryPreview()
        else
          _buildEmptyUploadTile(),

        // Thumbnails Strip
        if (hasImages) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _totalCount + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == _totalCount) {
                  // "+ Add More" card
                  return InkWell(
                    onTap: _showSourceSheet,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF2563EB), size: 22),
                          SizedBox(height: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final isPrimary = index == _primaryIndex;
                final isUrl = index < _existingUrls.length;

                return InkWell(
                  onTap: () => _setPrimary(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPrimary ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: isPrimary ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isUrl
                              ? CachedNetworkImage(
                                  imageUrl: _existingUrls[index],
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9)),
                                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 20),
                                )
                              : Image.file(
                                  _localFiles[index - _existingUrls.length],
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      // Primary star badge
                      if (isPrimary)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 10, color: Color(0xFFFBBF24)),
                                SizedBox(width: 2),
                                Text(
                                  'Main',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Delete button
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '💡 Tap any thumbnail to set it as the Primary Image',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryPreview() {
    final isUrl = _primaryIndex < _existingUrls.length;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isUrl
                ? CachedNetworkImage(
                    imageUrl: _existingUrls[_primaryIndex],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9)),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_rounded, size: 36, color: Color(0xFF94A3B8)),
                    ),
                  )
                : Image.file(
                    _localFiles[_primaryIndex - _existingUrls.length],
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        // Primary Badge
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 13, color: Color(0xFFFBBF24)),
                SizedBox(width: 4),
                Text(
                  'PRIMARY DISPLAY IMAGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Action Buttons
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionIconBtn(
                icon: Icons.add_photo_alternate_rounded,
                color: const Color(0xFF2563EB),
                onTap: _showSourceSheet,
              ),
              const SizedBox(width: 8),
              _actionIconBtn(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFEF4444),
                onTap: () => _removeImage(_primaryIndex),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyUploadTile() {
    return InkWell(
      onTap: _showSourceSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                size: 28,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap to upload product images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Supports multiple images • Gallery, Camera or URL',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
