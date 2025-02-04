import 'dart:async';
import 'package:newapp/data/models/order/order_model.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/logic/cubit/order/order_state.dart';
import 'package:newapp/logic/services/calculations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cart/cart_item_model.dart';
import '../user/user_cubit.dart';
import '../user/user_state.dart';
import './../../../data/repositories/order_repository.dart';
import 'package:newapp/logic/services/razorapy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OrderCubit extends Cubit<OrderState> {
  final UserCubit _userCubit;
  final CartCubit _cartCubit;
  StreamSubscription? _userSubscription;

  OrderCubit(this._userCubit, this._cartCubit) : super(OrderInitialState()) {
    _handleUserState(_userCubit.state);
    _userSubscription = _userCubit.stream.listen(_handleUserState);
  }

  void _handleUserState(UserState userState) {
    if (userState is UserLoggedInState) {
      _initialize(userState.userModel.sId!);
    } else if (userState is UserLoggedOutState) {
      emit(OrderInitialState());
    }
  }

  final _orderRepository = OrderRepository();

  void _initialize(String userId) async {
    emit(OrderLoadingState(state.orders));
    try {
      final orders = await _orderRepository.fetchOrdersForUser(userId);
      emit(OrderLoadedState(orders));
    } catch (ex) {
      emit(OrderErrorState(ex.toString(), state.orders));
    }
  }

  Future<OrderModel?> createOrder({
    required List<CartItemModel> items,
    required String paymentMethod,
  }) async {
    emit(OrderLoadingState(state.orders));
    try {
      if (_userCubit.state is! UserLoggedInState) {
        return null;
      }

      // Create the order model
      OrderModel newOrder = OrderModel(
        items: items,
        totalAmount: Calculations.cartTotal(items),
        user: (_userCubit.state as UserLoggedInState).userModel,
        status: (paymentMethod == "pay-on-delivery") ? "order-placed" : "payment-pending",
      );

      // Save the order to the repository
      final order = await _orderRepository.createOrder(newOrder);
      List<OrderModel> orders = [order, ...state.orders];
      emit(OrderLoadedState(orders));

      // Do not clear the cart here
      if (paymentMethod == "pay-on-delivery") {
        _cartCubit.clearCart();
      }

      return order;
    } catch (ex) {
      emit(OrderErrorState(ex.toString(), state.orders));
      return null;
    }
  }


  // Handle Razorpay payment and update the order status
  void _handleRazorpayPayment(OrderModel orderModel) {
    RazorPayServices.checkoutOrder(
      orderModel,
      onSuccess: (PaymentSuccessResponse response) async {
        // After successful payment, update the order status and clear the cart
        bool isUpdated = await updateOrder(orderModel, paymentId: response.paymentId);
        if (isUpdated) {
          _cartCubit.clearCart();  // Clear the cart only after payment is successful
        }
      },
      onFailure: (PaymentFailureResponse response) {
        // Handle failure, but keep the order as pending
        emit(OrderErrorState(response.message ?? "Payment Failed", state.orders));
      },
    );
  }



  // Update order status with payment details after successful payment
  Future<bool> updateOrder(OrderModel orderModel, {String? paymentId, String? signature}) async {
    try {
      // Update the order with new payment information (paymentId and signature)
      OrderModel updatedOrder = await _orderRepository.updateOrder(
        orderModel,
        paymentId: paymentId,
        signature: signature,
      );

      // Find the index of the updated order in the current orders list
      int index = state.orders.indexOf(updatedOrder);
      if (index == -1) return false;

      // Replace the old order with the updated one
      List<OrderModel> newList = List.from(state.orders);  // Create a copy of the list
      newList[index] = updatedOrder;

      // Emit the new state with updated orders
      emit(OrderLoadedState(newList));
      return true;
    } catch (ex) {
      emit(OrderErrorState(ex.toString(), state.orders));
      return false;
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
