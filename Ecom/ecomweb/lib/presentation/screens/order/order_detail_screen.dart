import 'dart:developer';

import 'package:ecomweb/core/ui.dart';
import 'package:ecomweb/data/models/order/order_model.dart';
import 'package:ecomweb/data/models/user/user_model.dart';
import 'package:ecomweb/logic/cubit/cart/cart_cubit.dart';
import 'package:ecomweb/logic/cubit/cart/cart_state.dart';
import 'package:ecomweb/logic/cubit/order/order_cubit.dart';
import 'package:ecomweb/logic/cubit/user/user_cubit.dart';
import 'package:ecomweb/logic/cubit/user/user_state.dart';
import 'package:ecomweb/Presentation/screens/order/order_placed_screen.dart';
import 'package:ecomweb/Presentation/screens/order/provider/order_detail_provider.dart';
import 'package:ecomweb/presentation/screens/user/edit_profile_screen.dart';
import 'package:ecomweb/presentation/widgets/gap_widgets.dart';
import 'package:ecomweb/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:ecomweb/Presentation/widgets/cart_list_view.dart';
import 'package:ecomweb/logic/services/razorapy.dart';

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
          padding: const EdgeInsets.all(16),
          children: [
            // User details section
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
                      Text(
                        "User Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const GapWidget(),
                      Text("${user.fullName}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      Text("Email: ${user.email}",
                          style: TextStyle(fontSize: 18)),
                      Text("Phone: ${user.phoneNumber}",
                          style: TextStyle(fontSize: 18)),
                      Text(
                        "Address: ${user.address}, ${user.city}, ${user.state}",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      // Edit Profile button
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, EditProfileScreen.routeName);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            const GapWidget(size: 10),

            // Items list section
            Text(
              "Items",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  physics: const NeverScrollableScrollPhysics(),
                );
              },
            ),
            const GapWidget(size: 10),

            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            const GapWidget(size: 10),

            // Payment section
            Text(
              "Payment",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const GapWidget(),
            Consumer<OrderDetailProvider>(
              builder: (context, provider, child) {
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
                      title: const Text("Pay Now"),
                    ),
                  ],
                );
              },
            ),
            const GapWidget(),

            // Place Order button
            PrimaryButton(
              onPressed: () async {
                OrderModel? newOrder = await BlocProvider.of<OrderCubit>(context).createOrder(
                  items: BlocProvider.of<CartCubit>(context).state.items,
                  paymentMethod: Provider.of<OrderDetailProvider>(context, listen: false)
                      .paymentMethod
                      .toString(),
                );

                if (newOrder == null) return;

                if (newOrder.status == "payment-pending") {
                  await RazorPayServices.checkoutOrder(
                    newOrder,
                    onSuccess: (response) async {
                      newOrder.status = "order-placed";

                      bool success = await BlocProvider.of<OrderCubit>(context)
                          .updateOrder(newOrder, paymentId: response.paymentId, signature: response.signature);

                      if (!success) {
                        log("Can't update the order!");
                        return;
                      }

                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushNamed(context, OrderPlacedScreen.routeName);
                    },
                    onFailure: (response) {
                      log("Payment Failed!");
                    },
                  );
                }

                if (newOrder.status == "order-placed") {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushNamed(context, OrderPlacedScreen.routeName);
                }
              },
              text: "Place Order",
            ),
          ],
        ),
      ),
    );
  }
}

