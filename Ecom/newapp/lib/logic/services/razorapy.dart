// RazorPayServices.dart

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:newapp/data/models/order/order_model.dart';

class RazorPayServices {

  static final _instance = Razorpay();

  static Future<void> checkoutOrder(
      OrderModel orderModel, {
        required Function(PaymentSuccessResponse) onSuccess,
        required Function(PaymentFailureResponse) onFailure
      }
      ) async {
    var options = {
      'key': 'rzp_test_oHoZ3Q1fF6pYEI', // Replace with your Razorpay key
      'order_id': "${orderModel.razorPayOrderId}",
      'name': 'Ecommerce App',
      'description': "${orderModel.sId}",
      'prefill': {
        'contact': "${orderModel.user?.phoneNumber}",
        'email': "${orderModel.user?.email}"
      }
    };

    _instance.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      // On payment success, pass the response to onSuccess callback
      onSuccess(response);
      _instance.clear();
    });

    _instance.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      // On payment failure, pass the error response to onFailure callback
      onFailure(response);
      _instance.clear();
    });

    _instance.open(options);
  }
}
