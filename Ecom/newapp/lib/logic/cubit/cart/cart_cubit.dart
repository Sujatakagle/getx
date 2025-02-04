import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/logic/cubit/cart/cart_state.dart';
import 'package:newapp/data/models/cart/cart_item_model.dart';
import 'package:newapp/data/repositories/cart_repository.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';
import 'package:newapp/data/models/product/product_model.dart';

class CartCubit extends Cubit<CartState> {
  final UserCubit _userCubit;
  StreamSubscription? _userSubscription;

  CartCubit(this._userCubit) : super(CartInitialState()) {
    _handleUserState(_userCubit.state);
    _userSubscription = _userCubit.stream.listen(_handleUserState);
  }

  void _handleUserState(UserState userState) {
    if (userState is UserLoggedInState) {
      _initialize(userState.userModel.sId!);
    } else if (userState is UserLoggedOutState) {
      emit(CartInitialState());
    }
  }

  final _cartRepository = CartRepository();

  void sortAndLoad(List<CartItemModel> items) {
    items.sort((a, b) => b.product!.brand!.compareTo(a.product!.brand!));
    emit(CartLoadedState(items));
  }

  void _initialize(String userId) async {
    emit(CartLoadingState(state.items));
    try {
      final items = await _cartRepository.fetchCartForUser(userId);
      sortAndLoad(items);
    } catch (ex) {
      _handleError(ex);
    }
  }

  void addToCart(ProductModel product, int quantity) async {
    emit(CartLoadingState(state.items));
    try {
      if (_userCubit.state is UserLoggedInState) {
        UserLoggedInState userState = _userCubit.state as UserLoggedInState;

        CartItemModel newItem = CartItemModel(
            product: product,
            quantity: quantity
        );

        final items = await _cartRepository.addToCart(newItem, userState.userModel.sId!);
        sortAndLoad(items);
      } else {
        throw Exception("User is not logged in.");
      }
    } catch (ex) {
      _handleError(ex);
    }
  }

  void removeFromCart(ProductModel product) async {
    emit(CartLoadingState(state.items));
    try {
      if (_userCubit.state is UserLoggedInState) {
        UserLoggedInState userState = _userCubit.state as UserLoggedInState;

        final items = await _cartRepository.removeFromCart(product.sId!, userState.userModel.sId!);
        sortAndLoad(items);
      } else {
        throw Exception("User is not logged in.");
      }
    } catch (ex) {
      _handleError(ex);
    }
  }

  bool cartContains(ProductModel product) {
    if (state.items.isNotEmpty) {
      final foundItem = state.items.where((item) => item.product!.sId! == product.sId!).toList();
      return foundItem.isNotEmpty;
    }
    return false;
  }

  void clearCart() {
    emit(CartLoadedState([]));
  }

  void removeItemsAfterPayment(List<CartItemModel> items) async {
    // Remove items from cart after payment is successful
    emit(CartLoadingState(state.items));
    try {
      if (_userCubit.state is UserLoggedInState) {
        UserLoggedInState userState = _userCubit.state as UserLoggedInState;

        // Loop through the items and remove them one by one
        for (var item in items) {
          await _cartRepository.removeFromCart(item.product!.sId!, userState.userModel.sId!);
        }

        // After removing all items, load the updated cart
        final updatedItems = await _cartRepository.fetchCartForUser(userState.userModel.sId!);
        sortAndLoad(updatedItems);
      } else {
        throw Exception("User is not logged in.");
      }
    } catch (ex) {
      _handleError(ex);
    }
  }


  void _handleError(Object ex) {
    String errorMessage = "An unknown error occurred";

    if (ex is FormatException) {
      errorMessage = "Data format error occurred. Please try again.";
    } else if (ex is TimeoutException) {
      errorMessage = "Request timed out. Please check your connection.";
    } else if (ex is Exception) {
      errorMessage = ex.toString();
    }

    emit(CartErrorState(errorMessage, state.items));
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
