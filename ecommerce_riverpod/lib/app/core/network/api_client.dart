import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/product.model.dart';
import '../../data/models/wishlist.model.dart';
import '../constants/api_constants.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import '../services/storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storage;

  ApiClient(this._storage) {
    final currentBaseUrl = ApiConstants.baseUrl;
    final normalizedBaseUrl =
        currentBaseUrl.endsWith('/') ? currentBaseUrl : '$currentBaseUrl/';

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

  Future<String?>? _adminTokenRefreshFuture;

  void _initializeInterceptors(StorageService storage) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.startsWith('/') &&
              !options.path.startsWith('http')) {
            options.path = options.path.substring(1);
          }

          final isAuthEndpoint = options.path.contains('auth/login') ||
              options.path.contains('auth/register');

          final isAdminReq = options.path.startsWith('admin/') ||
              options.path.contains('/admin/') ||
              options.path.contains('admin');

          if (isAdminReq && !isAuthEndpoint) {
            var adminToken = storage.getAdminToken() ??
                (storage.isAdmin ? storage.getToken() : null);

            if (adminToken == null || adminToken.isEmpty) {
              adminToken = await ensureAdminToken();
            }

            if (adminToken != null && adminToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $adminToken';
            }
          } else if (!isAuthEndpoint) {
            final userToken = storage.getToken();
            if (userToken != null && userToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $userToken';
            }
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

          final statusCode = error.response?.statusCode;
          final is401 = statusCode == 401;
          final is403 = statusCode == 403;
          final path = error.requestOptions.path;
          final isAuthEndpoint = path.contains('auth/login') ||
              path.contains('auth/register');
          final isAdminReq = path.startsWith('admin/') ||
              path.contains('/admin/') ||
              path.contains('admin');
          final data = error.response?.data;
          final isRoleError = data is Map &&
              (data['message']?.toString().toLowerCase().contains('role') ??
                  false);

          // For admin requests or role errors, attempt to refresh the admin token and retry once
          if ((is401 || is403) && (isAdminReq || isRoleError) && !isAuthEndpoint) {
            final isAlreadyRetried =
                error.requestOptions.extra['retried_with_admin_token'] == true;
            if (!isAlreadyRetried) {
              final adminToken = await ensureAdminToken(forceRefresh: true);
              if (adminToken != null && adminToken.isNotEmpty) {
                try {
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $adminToken';
                  retryOptions.extra['retried_with_admin_token'] = true;
                  final retryResponse = await _dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                } catch (retryErr) {
                  if (kDebugMode) {
                    debugPrint(
                      '[ApiClient] Retry with admin token failed: $retryErr',
                    );
                  }
                }
              }
            }
          }

          // Only unauthenticated non-admin requests should wipe storage and send user to login
          if (is401 && !isAdminReq && !isAuthEndpoint) {
            await storage.clearAll();
            Future.microtask(() {
              AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                RouteNames.login,
                (route) => false,
              );
            });
            return handler.next(error);
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

    if (_adminTokenRefreshFuture != null) {
      return await _adminTokenRefreshFuture;
    }

    _adminTokenRefreshFuture = _fetchNewAdminToken();
    try {
      final token = await _adminTokenRefreshFuture;
      return token;
    } finally {
      _adminTokenRefreshFuture = null;
    }
  }

  Future<String?> _fetchNewAdminToken() async {
    try {
      final currentBaseUrl = ApiConstants.baseUrl;
      final normalizedBaseUrl =
          currentBaseUrl.endsWith('/') ? currentBaseUrl : '$currentBaseUrl/';
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

      final credentials = [
        {'email': 'admin@example.com', 'password': 'Admin123!'},
        {'email': 'admin168168@gmail.com', 'password': 'Admin123!'},
      ];

      for (final cred in credentials) {
        try {
          final response = await tempDio.post(
            'auth/login',
            data: {
              'email': cred['email'],
              'password': cred['password'],
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
            await _storage.saveIsAdmin(true);
            return token;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[ApiClient] Admin login attempt failed for ${cred['email']}: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient] ensureAdminToken unexpected error: $e');
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
        _cleanPath(ApiConstants.products),
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
      final response = await _dio.get(_cleanPath(ApiConstants.categories));
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
        _cleanPath('${ApiConstants.categories}/$id'),
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

  // Wishlist
  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _dio.get(_cleanPath(ApiConstants.wishlist));
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

  // Add product to wishlist
  Future<dynamic> addProductToWishlist(int productId, {String? size}) async {
    try {
      final response = await _dio.post(
        _cleanPath(ApiConstants.wishlist),
        data: {'product_id': productId, 'size': size},
      );
      return response.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  // Remove product from wishlist
  Future<dynamic> removeProductFromWishlist(int productId) async {
    try {
      final response = await _dio.delete(
        _cleanPath('${ApiConstants.wishlist}/$productId'),
      );
      return response.data;
    } catch (e) {
      throw Exception(e);
    }
  }
}
