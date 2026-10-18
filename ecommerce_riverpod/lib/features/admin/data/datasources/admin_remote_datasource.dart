import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../app/core/constants/api_constants.dart';
import '../../../../app/core/network/api_client.dart';
import '../../../../app/core/providers/network_providers.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/variant_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminCategory>> getCategories();
  Future<AdminCategory> createCategory({
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  });
  Future<AdminCategory> updateCategory(
    int id, {
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  });
  Future<bool> deleteCategory(int id);

  Future<List<AdminProduct>> getProducts({
    String? search,
    String? category,
    int perPage = 50,
  });
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
  });
  Future<dynamic> updateProduct(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
    List<File> imageFiles = const [],
    List<String>? existingImageUrls,
  });
  Future<bool> deleteProduct(int id);

  Future<dynamic> addVariant(int productId, AdminVariant variant);

  Future<List<AdminOrder>> getOrders({
    String? status,
    String? paymentStatus,
    int perPage = 50,
  });
  Future<dynamic> updateOrderStatus(
    int orderId, {
    required String status,
    String? trackingNumber,
  });

  Future<List<AdminBanner>> getBanners({String? search, int perPage = 50});
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
  });
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
  });
  Future<bool> deleteBanner(int id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminCategory>> getCategories() async {
    Response response;
    try {
      response = await _apiClient.get('${ApiConstants.adminCategories}?per_page=100');
    } catch (_) {
      response = await _apiClient.get(ApiConstants.categories);
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
  }

  @override
  Future<AdminCategory> createCategory({
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
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
    } else {
      payload = {
        'name': name.trim(),
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        'is_active': isActive,
      };
    }
    final response = await _apiClient.post(ApiConstants.adminCategories, data: payload);
    final rawData = response.data;
    final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
        ? rawData['data'] as Map<String, dynamic>
        : (rawData is Map ? rawData as Map<String, dynamic> : {});
    return AdminCategory.fromJson(data);
  }

  @override
  Future<AdminCategory> updateCategory(
    int id, {
    required String name,
    String? slug,
    String? description,
    bool isActive = true,
    File? imageFile,
  }) async {
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
      final response =
          await _apiClient.post('${ApiConstants.adminCategories}/$id', data: payload);
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
      final response =
          await _apiClient.put('${ApiConstants.adminCategories}/$id', data: payload);
      final rawData = response.data;
      final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
          ? rawData['data'] as Map<String, dynamic>
          : (rawData is Map ? rawData as Map<String, dynamic> : {});
      return AdminCategory.fromJson(data);
    }
  }

  @override
  Future<bool> deleteCategory(int id) async {
    await _apiClient.delete('${ApiConstants.adminCategories}/$id');
    return true;
  }

  @override
  Future<List<AdminProduct>> getProducts({
    String? search,
    String? category,
    int perPage = 50,
  }) async {
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

    final response =
        await _apiClient.get(ApiConstants.products, queryParameters: query);
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
  }

  @override
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
                  'url':
                      'https://placehold.co/600x600/png?text=${Uri.encodeComponent(name)}',
                  'is_primary': true,
                }
              ],
      };
    }

    final response =
        await _apiClient.post(ApiConstants.adminProducts, data: payload);
    final rawData = response.data;
    final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
        ? rawData['data'] as Map<String, dynamic>
        : (rawData is Map ? rawData as Map<String, dynamic> : {});
    return AdminProduct.fromJson(data);
  }

  @override
  Future<dynamic> updateProduct(
    int id,
    Map<String, dynamic> data, {
    File? imageFile,
    List<File> imageFiles = const [],
    List<String>? existingImageUrls,
  }) async {
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
      final response = await _apiClient
          .post('${ApiConstants.adminProducts}/$id', data: payload);
      return response.data;
    } else {
      final updatePayload = Map<String, dynamic>.from(data);
      if (existingImageUrls != null) {
        updatePayload['images'] = existingImageUrls.asMap().entries.map((e) {
          return {'url': e.value, 'is_primary': e.key == 0};
        }).toList();
      }
      final response = await _apiClient
          .put('${ApiConstants.adminProducts}/$id', data: updatePayload);
      return response.data;
    }
  }

  @override
  Future<bool> deleteProduct(int id) async {
    await _apiClient.delete('${ApiConstants.adminProducts}/$id');
    return true;
  }

  @override
  Future<dynamic> addVariant(int productId, AdminVariant variant) async {
    final response = await _apiClient.post(
      '${ApiConstants.adminProducts}/$productId/variants',
      data: variant.toJson(),
    );
    return response.data;
  }

  @override
  Future<List<AdminOrder>> getOrders({
    String? status,
    String? paymentStatus,
    int perPage = 50,
  }) async {
    final query = <String, dynamic>{'per_page': perPage};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      query['status'] = status.toLowerCase();
    }
    if (paymentStatus != null &&
        paymentStatus.isNotEmpty &&
        paymentStatus.toLowerCase() != 'all') {
      query['payment_status'] = paymentStatus.toLowerCase();
    }

    final response =
        await _apiClient.get(ApiConstants.adminOrders, queryParameters: query);
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
  }

  @override
  Future<dynamic> updateOrderStatus(
    int orderId, {
    required String status,
    String? trackingNumber,
  }) async {
    final payload = <String, dynamic>{
      'status': status.toLowerCase().trim(),
      if (trackingNumber != null && trackingNumber.isNotEmpty)
        'tracking_number': trackingNumber.trim(),
    };

    final response = await _apiClient.patch(
      '${ApiConstants.adminOrders}/$orderId/status',
      data: payload,
    );
    return response.data;
  }

  @override
  Future<List<AdminBanner>> getBanners({String? search, int perPage = 50}) async {
    Response response;
    try {
      final query = <String, dynamic>{'per_page': perPage};
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      response =
          await _apiClient.get(ApiConstants.adminBanners, queryParameters: query);
    } catch (_) {
      response = await _apiClient.get(ApiConstants.banners);
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
    return list.map((e) => AdminBanner.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
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
        if (linkId != null && linkId.trim().isNotEmpty) 'link_id': linkId.trim(),
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
        if (linkId != null && linkId.trim().isNotEmpty) 'link_id': linkId.trim(),
        if (linkUrl != null && linkUrl.trim().isNotEmpty)
          'link_url': linkUrl.trim(),
        if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
        if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
      };
    }

    final response =
        await _apiClient.post(ApiConstants.adminBanners, data: payload);
    final rawData = response.data;
    final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
        ? rawData['data'] as Map<String, dynamic>
        : (rawData is Map ? rawData as Map<String, dynamic> : {});
    return AdminBanner.fromJson(data);
  }

  @override
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
    dynamic payload;
    if (imageFile != null) {
      final map = <String, dynamic>{
        '_method': 'PUT',
        if (title != null) 'title': title.trim(),
        if (subtitle != null) 'subtitle': subtitle.trim(),
        if (position != null) 'position': position.trim(),
        if (isActive != null) 'is_active': isActive ? 1 : 0,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (linkType != null) 'link_type': linkType,
        if (linkId != null) 'link_id': linkId.trim(),
        if (linkUrl != null) 'link_url': linkUrl.trim(),
        if (startAt != null) 'start_at': startAt,
        if (endAt != null) 'end_at': endAt,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      };
      payload = FormData.fromMap(map);
      final response =
          await _apiClient.post('${ApiConstants.adminBanners}/$id', data: payload);
      final rawData = response.data;
      final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
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
        if (isActive != null) 'is_active': isActive,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (linkType != null) 'link_type': linkType,
        if (linkId != null) 'link_id': linkId.trim(),
        if (linkUrl != null) 'link_url': linkUrl.trim(),
        if (startAt != null) 'start_at': startAt,
        if (endAt != null) 'end_at': endAt,
      };
      final response =
          await _apiClient.put('${ApiConstants.adminBanners}/$id', data: payload);
      final rawData = response.data;
      final Map<String, dynamic> data = (rawData is Map && rawData['data'] is Map)
          ? rawData['data'] as Map<String, dynamic>
          : (rawData is Map ? rawData as Map<String, dynamic> : {});
      return AdminBanner.fromJson(data);
    }
  }

  @override
  Future<bool> deleteBanner(int id) async {
    await _apiClient.delete('${ApiConstants.adminBanners}/$id');
    return true;
  }
}

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminRemoteDataSourceImpl(apiClient);
});
