import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:newapp/core/api.dart';
import 'package:newapp/data/models/order/order_model.dart';

class OrderRepository {
  final _api = Api();

  // Fetch Orders for a user
  Future<List<OrderModel>> fetchOrdersForUser(String userId) async {
    try {
      Response response = await _api.sendRequest.get("/order/$userId");

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return (apiResponse.data as List<dynamic>)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (ex) {
      rethrow;
    }
  }

  // Create a new order
  Future<OrderModel> createOrder(OrderModel orderModel) async {
    try {
      Response response = await _api.sendRequest.post(
        "/order",
        data: jsonEncode(orderModel.toJson()),
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return OrderModel.fromJson(apiResponse.data);
    } catch (ex) {
      rethrow;
    }
  }

  // Update order status after payment (including Razorpay payment details)
  Future<OrderModel> updateOrder(OrderModel orderModel, {
    String? paymentId,
    String? signature
  }) async {
    try {
      Response response = await _api.sendRequest.put(
          "/order/updateStatus",
          data: jsonEncode({
            "orderId": orderModel.sId,
            "status": orderModel.status,
            "razorPayPaymentId": paymentId,
            "razorPaySignature": signature
          })
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      return OrderModel.fromJson(apiResponse.data);
    } catch (ex) {
      rethrow;
    }
  }

  // Complete payment for a pending order
  Future<String> completePayment(String orderId, String userId) async {
    try {
      // Make a call to the backend to generate Razorpay order ID for pending payment
      Response response = await _api.sendRequest.put(
        "/order/completePayment",
        data: jsonEncode({"orderId": orderId, "userId": userId}),
      );

      ApiResponse apiResponse = ApiResponse.fromResponse(response);

      if (!apiResponse.success) {
        throw apiResponse.message.toString();
      }

      // Return the Razorpay order ID so that it can be used to complete the payment
      return apiResponse.data['razorPayOrderId'];
    } catch (ex) {
      rethrow;
    }
  }
}
