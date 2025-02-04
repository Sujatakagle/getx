import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:newapp/core/api.dart';
import 'package:newapp/data/models/review/review_model.dart';

class ReviewRepository {
  final _api = Api();

  Future<ReviewModel> addReview({
    required String productId,
    required String userId,
    int? rating, // Rating can be nullable
    String? comment, // Comment can be nullable
  }) async {
    try {
      Response response = await _api.sendRequest.post(
        "/review/add",
        data: jsonEncode({
          "productId": productId,
          "userId": userId,
          "rating": rating,
          "comment": comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewModel.fromMap(response.data);
      } else {
        throw Exception(response.data['message'] ?? "Failed to add review");
      }
    } catch (ex) {
      throw Exception("Error adding review: ${ex.toString()}");
    }
  }


  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      Response response = await _api.sendRequest.put(
        "/review/$reviewId",
        data: jsonEncode({
          "rating": rating,
          "comment": comment,
        }),
      );

      if (response.statusCode == 200) {
        return ReviewModel.fromMap(
            response.data['data']); // Adjusted for nested data
      } else {
        throw Exception(response.data['message'] ?? "Failed to update review");
      }
    } catch (ex) {
      throw Exception("Error updating review: ${ex.toString()}");
    }
  }

  Future<List<ReviewModel>> getProductReviews({
    required String productId,
  }) async {
    try {
      Response response = await _api.sendRequest.get("/review/$productId");

      if (response.statusCode == 200) {
        List<dynamic> reviews = response.data['data']['reviews']; // Corrected the path to reviews
        return reviews.map((review) => ReviewModel.fromMap(review)).toList();
      } else {
        throw Exception(response.data['message'] ?? "Failed to fetch reviews");
      }
    } catch (ex) {
      throw Exception("Error fetching reviews: ${ex.toString()}");
    }
  }
}