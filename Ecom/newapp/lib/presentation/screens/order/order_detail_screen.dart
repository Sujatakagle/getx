import 'dart:developer';
import 'dart:developer';
import 'package:newapp/core/ui.dart';
import 'package:newapp/data/models/order/order_model.dart';
import 'package:newapp/data/models/user/user_model.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/logic/cubit/cart/cart_state.dart';
import 'package:newapp/logic/cubit/order/order_cubit.dart';
import 'package:newapp/logic/cubit/order/order_state.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';
import 'package:newapp/Presentation/screens/order/order_placed_screen.dart';
import 'package:newapp/Presentation/screens/order/provider/order_detail_provider.dart';
import 'package:newapp/presentation/screens/user/edit_profile_screen.dart';
import 'package:newapp/presentation/widgets/gap_widgets.dart';
import 'package:newapp/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:newapp/Presentation/widgets/cart_list_view.dart';
import 'package:newapp/logic/services/razorapy.dart';


class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  static const routeName = "order_detail";

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Order"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(4),
          children: [
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserLoggedInState) {
                  UserModel user = state.userModel;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal)),
                      const GapWidget(),
                      Text("${user.fullName}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("Email: ${user.email}", style: TextStyle(fontSize: 18)),
                      Text("Phone: ${user.phoneNumber}", style: TextStyle(fontSize: 18)),
                      Text("Address: ${user.address}, ${user.city}, ${user.state}", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, EditProfileScreen.routeName);
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, textStyle: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                        child: const Text("Edit Profile"),
                      ),
                    ],
                  );
                }

                if (state is UserErrorState) {
                  return Text(state.message);
                }

                return const SizedBox();
              },
            ),
            const GapWidget(size: 10),
            Divider(color: Colors.grey[300], thickness: 1),
            const GapWidget(size: 10),
            Text("Items", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            const GapWidget(),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is CartLoadingState && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CartErrorState && state.items.isEmpty) {
                  return Text(state.message);
                }

                return CartListView(
                  items: state.items,
                  shrinkWrap: true,
                  noScroll: true,  // Passing noScroll here instead of 'physics'
                );
              },
            ),
            const GapWidget(size: 10),
            Divider(color: Colors.grey[300], thickness: 1),
            const GapWidget(size: 10),
            Text("Payment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const GapWidget(),
            Consumer<OrderDetailProvider>(builder: (context, provider, child) {
              log("Selected Payment Method: ${provider.paymentMethod}");
              return Column(
                children: [
                  RadioListTile(
                    value: "pay-on-delivery",
                    groupValue: provider.paymentMethod,
                    contentPadding: EdgeInsets.zero,
                    onChanged: provider.changePaymentMethod,
                    title: const Text("Pay on Delivery"),
                  ),
                  RadioListTile(
                    value: "pay-now",
                    groupValue: provider.paymentMethod,
                    contentPadding: EdgeInsets.zero,
                    onChanged: provider.changePaymentMethod,
                    title: const Text("Pay Now (Razorpay)"),
                  ),
                ],
              );
            }),
            const GapWidget(size: 15),
            PrimaryButton(
              onPressed: () async {
                log("Validating user details before placing the order...");

                var userState = BlocProvider.of<UserCubit>(context).state;

                if (userState is! UserLoggedInState) {
                  log("User is not logged in.");
                  return;
                }

                UserModel user = userState.userModel;

                // Check if any user details are null or empty
                if ((user.fullName?.isEmpty ?? true) ||
                    (user.email?.isEmpty ?? true) ||
                    (user.phoneNumber?.isEmpty ?? true) ||
                    (user.address?.isEmpty ?? true) ||
                    (user.city?.isEmpty ?? true) ||
                    (user.state?.isEmpty ?? true)) {
                  log("User details are incomplete.");

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Incomplete Profile"),
                        content: const Text("Please complete your profile details before placing an order."),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Edit Profile"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, EditProfileScreen.routeName);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  return;
                }

                log("All user details are valid. Proceeding to place the order...");

                var cartItems = BlocProvider.of<CartCubit>(context).state.items;

                if (cartItems.isEmpty) {
                  log("No items in the cart.");
                  return;
                }

                String paymentMethod = Provider.of<OrderDetailProvider>(context, listen: false).paymentMethod.toString();
                log("Payment Method: $paymentMethod");

                OrderModel? newOrder = await BlocProvider.of<OrderCubit>(context).createOrder(
                  items: cartItems,
                  paymentMethod: paymentMethod,
                );

                if (newOrder == null) {
                  log("Order creation failed.");
                  return;
                }

                log("Order created, proceeding with payment...");

                if (newOrder.status == "payment-pending") {
                  bool? completePayment = await _showPaymentDialog(context, newOrder);
                  if (completePayment == true) {
                    // Proceed with Razorpay payment
                    await RazorPayServices.checkoutOrder(
                      newOrder,
                      onSuccess: (response) async {
                        log("Payment Success: $response");
                        newOrder.status = "order-placed"; // Update status after payment success

                        try {
                          bool success = await BlocProvider.of<OrderCubit>(context).updateOrder(
                            newOrder,
                            paymentId: response.paymentId,
                            signature: response.signature,
                          );

                          if (success) {
                            log("Order updated successfully!");
                            // Clear the cart only after successful payment and order placement
                            BlocProvider.of<CartCubit>(context).clearCart();

                            Navigator.popUntil(context, (route) => route.isFirst);
                            Navigator.pushNamed(context, OrderPlacedScreen.routeName);
                          } else {
                            log("Order update failed!");
                          }
                        } catch (e) {
                          log("Error updating order: $e");
                        }
                      },
                      onFailure: (response) {
                        log("Payment Failed: $response");
                      },
                    );
                  }
                } else if (newOrder.status == "order-placed") {
                  BlocProvider.of<CartCubit>(context).clearCart();

                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushNamed(context, OrderPlacedScreen.routeName);
                }
              },
              text: "Place Order",
            )


          ],
        ),
      ),
    );
  }

  Future<bool?> _showPaymentDialog(BuildContext context, OrderModel order) async {
    return showDialog<bool>(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Payment"),
        content: const Text("Do you want to proceed with the payment?"),
        actions: <Widget>[
          TextButton(
            child: const Text("No"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    });
  }
}
