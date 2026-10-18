import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../../../core/constants/constant.dart';
import '../../../core/network/api_client.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/variant_model.dart';

class AdminProvider {
  final ApiClient _apiClient;

  AdminProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  // ── 1. Categories (Postman: POST /admin/categories & GET /categories, PUT/DELETE) ─
  Future<List<AdminCategory>> getCategories() async {
    try {
      Response response;
      try {
        response = await _apiClient.get('$kAdminCategories?per_page=100');
      } catch (_) {
        response = await _apiClient.get(kCategories);
      }
      final rawData = response.data;
      final List list;
      if (rawData is Map) {
        final data = rawData['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }
      } else if (rawData is List) {
        list = rawData;
      } else {
        list = [];
      }
      return list.map((e) => AdminCategory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[AdminProvider] getCategories error: $e');
      rethrow;
    }
  }

  Future<AdminCategory> createCategory({
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
    try {
      dynamic payload;
      if (imageFile != null) {
        payload = FormData.fromMap({
          'name': name.trim(),
          if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
          if (description != null && description.isNotEmpty)
            'description': description.trim(),
          'is_active': isActive ? 1 : 0,
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split(Platform.pathSeparator).last,
          ),
        });
        final response = await _apiClient.post(kAdminCategories, data: payload);
        final rawData = response.data;
        final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
            ? rawData['data'] as Map<String, dynamic>
            : (rawData is Map ? rawData as Map<String, dynamic> : {});
        return AdminCategory.fromJson(data);
      } else {
        payload = {
          'name': name.trim(),
          if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
          if (description != null && description.isNotEmpty)
            'description': description.trim(),
          'is_active': isActive,
        };
        final response = await _apiClient.post(kAdminCategories, data: payload);
        final rawData = response.data;
        final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
            ? rawData['data'] as Map<String, dynamic>
            : (rawData is Map ? rawData as Map<String, dynamic> : {});
        return AdminCategory.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AdminProvider] createCategory error: $e');
      rethrow;
    }
  }

  Future<AdminCategory> updateCategory(
    int id, {
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
    try {
      dynamic payload;
      if (imageFile != null) {
        payload = FormData.fromMap({
          '_method': 'PUT',
          'name': name.trim(),
          if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
          if (description != null) 'description': description.trim(),
          'is_active': isActive ? 1 : 0,
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split(Platform.pathSeparator).last,
          ),
        });
        final response = await _apiClient.post('$kAdminCategories/$id', data: payload);
        final rawData = response.data;
        final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
            ? rawData['data'] as Map<String, dynamic>
            : (rawData is Map ? rawData as Map<String, dynamic> : {});
        return AdminCategory.fromJson(data);
      } else {
        payload = {
          'name': name.trim(),
          if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
          if (description != null) 'description': description.trim(),
          'is_active': isActive,
        };
        final response = await _apiClient.put('$kAdminCategories/$id', data: payload);
        final rawData = response.data;
        final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
            ? rawData['data'] as Map<String, dynamic>
            : (rawData is Map ? rawData as Map<String, dynamic> : {});
        return AdminCategory.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AdminProvider] updateCategory error: $e');
      rethrow;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _apiClient.delete('$kAdminCategories/$id');
      return true;
    } catch (e) {
      debugPrint('[AdminProvider] deleteCategory error: $e');
      rethrow;
    }
  }

  // ── 2. Products (Postman: GET /products, POST /admin/products, PUT, DEL) ────
  Future<List<AdminProduct>> getProducts({
    String? search,
    String? category,
    int perPage = 50,
  }) async {
    try {
      final query = <String, dynamic>{
        'per_page': perPage,
        'sort': '-created_at',
      };
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        final trimmed = category.trim();
        if (int.tryParse(trimmed) != null) {
          query['category_id'] = trimmed;
        } else {
          query['category'] = trimmed;
        }
      }

      final response = await _apiClient.get(kProducts, queryParameters: query);
      final rawData = response.data;
      final List list;
      if (rawData is Map && rawData['data'] is List) {
        list = rawData['data'] as List;
      } else if (rawData is List) {
        list = rawData;
      } else {
        list = [];
      }
      return list.map((e) => AdminProduct.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[AdminProvider] getProducts error: $e');
      rethrow;
    }
  }

  Future<AdminProduct> createProduct({
    required String name,
    required String description,
    required String shortDescription,
    required double price,
    double? salePrice,
    required int stock,
    required int categoryId,
    String status = 'active',
    bool isFeatured = true,
    List<Map<String, dynamic>> images = const [],
    File? imageFile,
    List<File> imageFiles = const [],
  }) async {
    try {
      final allFiles = <File>[];
      if (imageFile != null) allFiles.add(imageFile);
      for (final f in imageFiles) {
        if (!allFiles.any((existing) => existing.path == f.path)) {
          allFiles.add(f);
        }
      }

      dynamic payload;
      if (allFiles.isNotEmpty) {
        final formMap = <String, dynamic>{
          'name': name.trim(),
          'description': description.trim(),
          'short_description': shortDescription.trim(),
          'price': price,
          if (salePrice != null && salePrice > 0) 'sale_price': salePrice,
          'stock': stock,
          'category_id': categoryId,
          'status': status,
          'is_featured': isFeatured ? 1 : 0,
        };

        formMap['image'] = await MultipartFile.fromFile(
          allFiles.first.path,
          filename: allFiles.first.path.split(Platform.pathSeparator).last,
        );

        final multipartList = <MultipartFile>[];
        for (final f in allFiles) {
          multipartList.add(await MultipartFile.fromFile(
            f.path,
            filename: f.path.split(Platform.pathSeparator).last,
          ));
        }
        formMap['images[]'] = multipartList;

        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            if (images[i]['url'] != null) {
              formMap['image_urls[$i]'] = images[i]['url'];
            }
          }
        }

        payload = FormData.fromMap(formMap);
      } else {
        payload = {
          'name': name.trim(),
          'description': description.trim(),
          'short_description': shortDescription.trim(),
          'price': price,
          if (salePrice != null && salePrice > 0) 'sale_price': salePrice,
          'stock': stock,
          'category_id': categoryId,
          'status': status,
          'is_featured': isFeatured,
          'images': images.isNotEmpty
              ? images
              : [
                  {
                    'url': 'https://placehold.co/600x600/png?text=${Uri.encodeComponent(name)}',
                    'is_primary': true,
                  }
                ],
        };
      }

      final response = await _apiClient.post(kAdminProducts, data: payload);
      final rawData = response.data;
      final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
          ? rawData['data'] as Map<String, dynamic>
          : (rawData is Map ? rawData as Map<String, dynamic> : {});
      return AdminProduct.fromJson(data);
    } catch (e) {
      debugPrint('[AdminProvider] createProduct error: $e');
      rethrow;
    }
  }

  Future<dynamic> updateProduct(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
    List<File> imageFiles = const [],
    List<String>? existingImageUrls,
  }) async {
    try {
      final allFiles = <File>[];
      if (imageFile != null) allFiles.add(imageFile);
      for (final f in imageFiles) {
        if (!allFiles.any((existing) => existing.path == f.path)) {
          allFiles.add(f);
        }
      }

      if (allFiles.isNotEmpty) {
        final formMap = Map<String, dynamic>.from(data);
        formMap['_method'] = 'PUT';

        formMap['image'] = await MultipartFile.fromFile(
          allFiles.first.path,
          filename: allFiles.first.path.split(Platform.pathSeparator).last,
        );

        final multipartList = <MultipartFile>[];
        for (final f in allFiles) {
          multipartList.add(await MultipartFile.fromFile(
            f.path,
            filename: f.path.split(Platform.pathSeparator).last,
          ));
        }
        formMap['images[]'] = multipartList;

        if (existingImageUrls != null && existingImageUrls.isNotEmpty) {
          for (int i = 0; i < existingImageUrls.length; i++) {
            formMap['existing_images[$i]'] = existingImageUrls[i];
          }
        }

        final payload = FormData.fromMap(formMap);
        final response = await _apiClient.post('$kAdminProducts/$id', data: payload);
        return response.data;
      } else {
        final updatePayload = Map<String, dynamic>.from(data);
        if (existingImageUrls != null) {
          updatePayload['images'] = existingImageUrls.asMap().entries.map((e) {
            return {'url': e.value, 'is_primary': e.key == 0};
          }).toList();
        }
        final response = await _apiClient.put('$kAdminProducts/$id', data: updatePayload);
        return response.data;
      }
    } catch (e) {
      debugPrint('[AdminProvider] updateProduct error: $e');
      rethrow;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _apiClient.delete('$kAdminProducts/$id');
      return true;
    } catch (e) {
      debugPrint('[AdminProvider] deleteProduct error: $e');
      rethrow;
    }
  }

  // ── 3. Variants (Postman: POST /admin/products/{id}/variants) ─────────────
  Future<dynamic> addVariant(int productId, AdminVariant variant) async {
    try {
      final response = await _apiClient.post(
        '$kAdminProducts/$productId/variants',
        data: variant.toJson(),
      );
      return response.data;
    } catch (e) {
      debugPrint('[AdminProvider] addVariant error: $e');
      rethrow;
    }
  }

  // ── 4. Orders (Postman: GET /admin/orders & PATCH /admin/orders/{id}/status) ─
  Future<List<AdminOrder>> getOrders({
    String? status,
    String? paymentStatus,
    int perPage = 50,
  }) async {
    try {
      final query = <String, dynamic>{
        'per_page': perPage,
      };
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        query['status'] = status.toLowerCase();
      }
      if (paymentStatus != null &&
          paymentStatus.isNotEmpty &&
          paymentStatus.toLowerCase() != 'all') {
        query['payment_status'] = paymentStatus.toLowerCase();
      }

      final response = await _apiClient.get(kAdminOrders, queryParameters: query);
      final rawData = response.data;
      final List list;
      if (rawData is Map && rawData['data'] is List) {
        list = rawData['data'] as List;
      } else if (rawData is List) {
        list = rawData;
      } else {
        list = [];
      }
      return list.map((e) => AdminOrder.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[AdminProvider] getOrders error: $e');
      rethrow;
    }
  }

  Future<dynamic> updateOrderStatus(
    int orderId, {
    required String status,
    String? trackingNumber,
  }) async {
    try {
      final payload = <String, dynamic>{
        'status': status.toLowerCase().trim(),
        if (trackingNumber != null && trackingNumber.isNotEmpty)
          'tracking_number': trackingNumber.trim(),
      };

      final response = await _apiClient.patch(
        '$kAdminOrders/$orderId/status',
        data: payload,
      );
      return response.data;
    } catch (e) {
      debugPrint('[AdminProvider] updateOrderStatus error: $e');
      rethrow;
    }
  }

  // ── 5. Banners (CRUD: GET /admin/banners, POST, PUT, DELETE) ────
  Future<List<AdminBanner>> getBanners({String? search, int perPage = 50}) async {
    try {
      Response response;
      try {
        final query = <String, dynamic>{
          'per_page': perPage,
        };
        if (search != null && search.trim().isNotEmpty) {
          query['search'] = search.trim();
        }
        response = await _apiClient.get(kAdminBanners, queryParameters: query);
      } catch (_) {
        response = await _apiClient.get(kBanners);
      }
      final rawData = response.data;
      final List list;
      if (rawData is Map) {
        final data = rawData['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }
      } else if (rawData is List) {
        list = rawData;
      } else {
        list = [];
      }
      return list
          .map((e) => AdminBanner.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[AdminProvider] getBanners error: $e');
      rethrow;
    }
  }

  Future<AdminBanner> createBanner({
    String? title,
    String? subtitle,
    String? imageUrl,
    File? imageFile,
    String position = 'home_slider',
    bool isActive = true,
    int sortOrder = 0,
    String linkType = 'none',
    String? linkId,
    String? linkUrl,
    String? startAt,
    String? endAt,
  }) async {
    try {
      dynamic payload;
      if (imageFile != null) {
        final map = <String, dynamic>{
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          if (subtitle != null && subtitle.trim().isNotEmpty)
            'subtitle': subtitle.trim(),
          'position': position.trim(),
          'is_active': isActive ? 1 : 0,
          'sort_order': sortOrder,
          'link_type': linkType,
          if (linkId != null && linkId.trim().isNotEmpty)
            'link_id': linkId.trim(),
          if (linkUrl != null && linkUrl.trim().isNotEmpty)
            'link_url': linkUrl.trim(),
          if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
          if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split(Platform.pathSeparator).last,
          ),
        };
        payload = FormData.fromMap(map);
      } else {
        payload = <String, dynamic>{
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          if (subtitle != null && subtitle.trim().isNotEmpty)
            'subtitle': subtitle.trim(),
          if (imageUrl != null && imageUrl.trim().isNotEmpty)
            'image': imageUrl.trim(),
          'position': position.trim(),
          'is_active': isActive,
          'sort_order': sortOrder,
          'link_type': linkType,
          if (linkId != null && linkId.trim().isNotEmpty)
            'link_id': linkId.trim(),
          if (linkUrl != null && linkUrl.trim().isNotEmpty)
            'link_url': linkUrl.trim(),
          if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
          if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
        };
      }

      final response = await _apiClient.post(kAdminBanners, data: payload);
      final rawData = response.data;
      final Map<String, dynamic> data =
          (rawData is Map && rawData['data'] is Map)
              ? rawData['data'] as Map<String, dynamic>
              : (rawData is Map ? rawData as Map<String, dynamic> : {});
      return AdminBanner.fromJson(data);
    } catch (e) {
      debugPrint('[AdminProvider] createBanner error: $e');
      rethrow;
    }
  }

  Future<AdminBanner> updateBanner(
    int id, {
    String? title,
    String? subtitle,
    String? imageUrl,
    File? imageFile,
    String? position,
    bool? isActive,
    int? sortOrder,
    String? linkType,
    String? linkId,
    String? linkUrl,
    String? startAt,
    String? endAt,
  }) async {
    try {
      dynamic payload;
      if (imageFile != null) {
        final map = <String, dynamic>{
          '_method': 'PUT',
          if (title != null) 'title': title.trim(),
          if (subtitle != null) 'subtitle': subtitle.trim(),
          if (position != null) 'position': position.trim(),
          if (isActive != null) 'is_active': isActive ? 1 : 0,
          'sort_order': ?sortOrder,
          'link_type': ?linkType,
          if (linkId != null) 'link_id': linkId.trim(),
          if (linkUrl != null) 'link_url': linkUrl.trim(),
          'start_at': ?startAt,
          'end_at': ?endAt,
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split(Platform.pathSeparator).last,
          ),
        };
        payload = FormData.fromMap(map);
        final response =
            await _apiClient.post('$kAdminBanners/$id', data: payload);
        final rawData = response.data;
        final Map<String, dynamic> data =
            (rawData is Map && rawData['data'] is Map)
                ? rawData['data'] as Map<String, dynamic>
                : (rawData is Map ? rawData as Map<String, dynamic> : {});
        return AdminBanner.fromJson(data);
      } else {
        payload = <String, dynamic>{
          if (title != null) 'title': title.trim(),
          if (subtitle != null) 'subtitle': subtitle.trim(),
          if (imageUrl != null && imageUrl.trim().isNotEmpty)
            'image': imageUrl.trim(),
          if (position != null) 'position': position.trim(),
          'is_active': ?isActive,
          'sort_order': ?sortOrder,
          'link_type': ?linkType,
          if (linkId != null) 'link_id': linkId.trim(),
          if (linkUrl != null) 'link_url': linkUrl.trim(),
          'start_at': ?startAt,
          'end_at': ?endAt,
        };
        final response =
            await _apiClient.put('$kAdminBanners/$id', data: payload);
        final rawData = response.data;
        final Map<String, dynamic> data =
            (rawData is Map && rawData['data'] is Map)
                ? rawData['data'] as Map<String, dynamic>
                : (rawData is Map ? rawData as Map<String, dynamic> : {});
        return AdminBanner.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AdminProvider] updateBanner error: $e');
      rethrow;
    }
  }

  Future<bool> deleteBanner(int id) async {
    try {
      await _apiClient.delete('$kAdminBanners/$id');
      return true;
    } catch (e) {
      debugPrint('[AdminProvider] deleteBanner error: $e');
      rethrow;
    }
  }
}
