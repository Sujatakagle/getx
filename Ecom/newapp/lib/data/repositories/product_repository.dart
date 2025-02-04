import 'package:dio/dio.dart';
import 'package:newapp/core/api.dart';
import 'package:newapp/data/models/product/product_model.dart';

class ProductRepository {
  final _api = Api();

  // Fetch all products
  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      Response response = await _api.sendRequest.get("/product");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (ex) {
      rethrow;
    }
  }

  // Fetch products by category
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    try {
      Response response = await _api.sendRequest.get("/product/category/$categoryId");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (ex) {
      rethrow;
    }
  }

  // Fetch products by charger type
  Future<List<ProductModel>> fetchProductsByChargerType(String chargerType) async {
    try {
      Response response = await _api.sendRequest.get("/product/chargerType/$chargerType");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (ex) {
      rethrow;
    }
  }

  // Fetch products by connector type
  Future<List<ProductModel>> fetchProductsByConnectorType(String connectorType) async {
    try {
      Response response = await _api.sendRequest.get("/product/connectorType/$connectorType");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (ex) {
      rethrow;
    }
  }

  // Fetch products by connector and charger type
  Future<List<ProductModel>> fetchProductsByConnectorAndChargerType(
      String connectorType, String chargerType) async {
    try {
      print("Fetching products with connectorType: $connectorType, chargerType: $chargerType");

      Response response = await _api.sendRequest.get(
          "/product/connectorAndCharger/$connectorType/$chargerType");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      List<ProductModel> products = (apiResponse.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();

      if (products.isEmpty) {
        print("No products found for the given filters.");
      }

      return products;
    } catch (ex) {
      print("Error fetching products: $ex");
      rethrow;
    }
  }

  // Fetch products by minimum rating
  Future<List<ProductModel>> fetchProductsByMinRating(double rating) async {
    try {
      Response response = await _api.sendRequest.get("/product/filter-by-rating/$rating");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (ex) {
      rethrow;
    }
  }
}
