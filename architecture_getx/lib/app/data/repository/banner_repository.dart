import '../models/banner.model.dart';
import '../providers/banner_provider.dart';

class BannerRepository {
  final BannerProvider _provider;

  BannerRepository(this._provider);

  /// Retrieves banners, optionally filtered by position (e.g. 'home_slider')
  Future<List<BannerModel>> getBanners({String? position}) async {
    final response = await _provider.getBanners(position: position);
    final rawData = response.data;
    final List data;
    if (rawData is List) {
      data = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      data = rawData['data'] as List;
    } else {
      data = [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => BannerModel.fromJson(json))
        .toList();
  }

  /// Retrieves a specific banner by its ID
  Future<BannerModel?> getBannerById(dynamic id) async {
    final response = await _provider.getBannerById(id);
    final rawData = response.data;
    final Map<String, dynamic>? data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : null;

    return data != null ? BannerModel.fromJson(data) : null;
  }
}
