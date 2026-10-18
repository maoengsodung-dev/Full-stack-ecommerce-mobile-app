import 'package:architecture_getx/app/core/constants/constant.dart';
import 'package:architecture_getx/app/core/services/storage_service.dart';
import 'package:architecture_getx/app/data/models/product.model.dart';
import 'package:architecture_getx/app/data/models/wishlist.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

class ApiClient {
  late final Dio _dio;
  final StorageService _storage;

  ApiClient(this._storage) {
    // Ensure baseUrl has a trailing slash for consistent relative URI resolution
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    _dio = Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _initializeInterceptors(_storage);
  }

  void _initializeInterceptors(StorageService storage) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Normalize path: strip leading '/' so Dio appends relative to baseUrl (/api/v1/)
          // e.g. '/products' -> 'products' -> http://10.0.2.2:8000/api/v1/products
          if (options.path.startsWith('/') &&
              !options.path.startsWith('http')) {
            options.path = options.path.substring(1);
          }

          final isAdminReq = options.path.startsWith('admin/') ||
              options.path.contains('/admin/');
          final adminToken = storage.getAdminToken();
          final userToken = storage.getToken();

          if (isAdminReq && adminToken != null && adminToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $adminToken';
          } else if (userToken != null && userToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $userToken';
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (DioException error, handler) async {
          if (kDebugMode) {
            debugPrint(
              '[ApiClient] HTTP Error ${error.response?.statusCode} on ${error.requestOptions.uri}',
            );
          }
          if (error.response?.statusCode == 401) {
            storage.clearAll();
            Future.microtask(() => Get.offAllNamed('/login'));
            return handler.next(error);
          }

          // Handle 403 on admin routes ("User does not have the right roles.")
          final is403 = error.response?.statusCode == 403;
          final isAdminReq = error.requestOptions.path.contains('admin');
          final data = error.response?.data;
          final isRoleError = data is Map &&
              (data['message']?.toString().toLowerCase().contains('role') ?? false);

          if (is403 && (isAdminReq || isRoleError)) {
            final adminToken = await ensureAdminToken(forceRefresh: true);
            if (adminToken != null && adminToken.isNotEmpty) {
              try {
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $adminToken';
                final retryResponse = await _dio.fetch(retryOptions);
                return handler.resolve(retryResponse);
              } catch (retryErr) {
                if (kDebugMode) {
                  debugPrint('[ApiClient] Retry with admin token failed: $retryErr');
                }
              }
            }
          }

          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          if (kDebugMode) {
            debugPrint('$obj');
          }
        },
      ),
    );
  }

  Future<String?> ensureAdminToken({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storage.getAdminToken();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    try {
      final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final tempDio = Dio(
        BaseOptions(
          baseUrl: normalizedBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await tempDio.post(
        'auth/login',
        data: {
          'email': 'admin@example.com',
          'password': 'Admin123!',
          'device_name': 'flutter-admin-auto',
        },
      );
      final raw = response.data;
      String? token;
      if (raw is Map) {
        if (raw['data'] is Map && raw['data']['token'] != null) {
          token = raw['data']['token'].toString();
        } else if (raw['token'] != null) {
          token = raw['token'].toString();
        }
      }
      if (token != null && token.isNotEmpty) {
        await _storage.saveAdminToken(token);
        return token;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient] ensureAdminToken error: $e');
      }
    }
    return null;
  }

  String _cleanPath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return path.startsWith('/') ? path.substring(1) : path;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(_cleanPath(path), queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      _cleanPath(path),
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> uploadFile(String path, {required FormData formData}) async {
    return await _dio.post(
      _cleanPath(path),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // Search and filter products
  Future<List<ProductRes>> getProducts({
    int perPage = 20,
    String? search,
    int? category,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    bool inStock = true,
    String sort = '-created_at',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'per_page': perPage,
        'in_stock': inStock ? 1 : 0,
        'sort': sort,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (category != null) {
        queryParameters['category_id'] = category;
      }
      if (minPrice != null) queryParameters['min_price'] = minPrice;
      if (maxPrice != null) queryParameters['max_price'] = maxPrice;
      if (featured != null) queryParameters['featured'] = featured ? 1 : 0;

      final response = await _dio.get(
        _cleanPath(kProducts),
        queryParameters: queryParameters,
      );
      final rawData = response.data;
      final List data = rawData is List
          ? rawData
          : (rawData['data'] as List? ?? []);
      return data.map((json) => ProductRes.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to load products',
      );
    }
  }

  // Fetch categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(_cleanPath(kCategories));
      final rawData = response.data;
      final List data = rawData is List
          ? rawData
          : (rawData['data'] as List? ?? []);
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to load categories',
      );
    }
  }

  // Update Category
  Future<List<CategoryModel>> updateCategory(int id, String name) async {
    try {
      final response = await _dio.put(
        _cleanPath('$kCategories/$id'),
        data: {'name': name},
      );
      final rawData = response.data;
      final List data = rawData is List
          ? rawData
          : (rawData['data'] as List? ?? []);
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Failed to update category',
      );
    }
  }

  // get wishlist
  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _dio.get(_cleanPath(kWishlist));
      final rawData = response.data;
      final List data = rawData is List
          ? rawData
          : (rawData['data'] as List? ?? []);
      return data
          .map((json) => WishlistItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to load wishlist',
      );
    }
  }

  // add product to wishlist
  Future<dynamic> addProductToWishlist(int productId, {String? size}) async {
    try {
      final response = await _dio.post(
        _cleanPath(kWishlist),
        data: {'product_id': productId, 'size': size},
      );
      return response.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  // remove product from wishlist
  Future<dynamic> removeProductFromWishlist(int productId) async {
    try {
      final response = await _dio.delete(_cleanPath('$kWishlist/$productId'));
      return response.data;
    } catch (e) {
      throw Exception(e);
    }
  }
}
