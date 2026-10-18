import 'package:architecture_getx/app/core/network/api_client.dart';
import 'package:dio/dio.dart';


class ProductProvider {

  final ApiClient _apiClient;

  ProductProvider(this._apiClient);

  Future<Response> getProduct()async{
    return await _apiClient.get('/products');
  }
}