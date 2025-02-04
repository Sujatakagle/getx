import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecomweb/core/api.dart';
import 'package:ecomweb/data/models/product/product_model.dart';

class ProductRepository {
  final _api = Api();

  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      Response response = await _api.sendRequest.get("/product");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if(!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>).map((json) => ProductModel.fromJson(json)).toList();
    }
    catch(ex) {
      rethrow;
    }
  }

}

