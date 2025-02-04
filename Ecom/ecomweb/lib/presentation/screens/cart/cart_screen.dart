import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecomweb/Presentation/screens/order/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecomweb/logic/cubit/cart/cart_cubit.dart';
import 'package:ecomweb/logic/cubit/cart/cart_state.dart';
import 'package:ecomweb/logic/services/calculations.dart';
import 'package:ecomweb/logic/services/formatter.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:ecomweb/presentation/widgets/link_button.dart';
import 'package:ecomweb/presentation/widgets/cart_list_view.dart'
;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static const routeName = "cart";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoadingState && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartErrorState && state.items.isEmpty) {
              return Center(child: Text(state.message));
            }

            if (state is CartLoadedState && state.items.isEmpty) {
              return const Center(child: Text("Your cart is empty!"));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Custom Animated Cart List
                  CartListView(items: state.items),
                  // Cart Summary Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cart Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${state.items.length} items",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "Total: ${Formatter.formatPrice(Calculations.cartTotal(state.items))}",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        // Checkout Button with Navigation
                        InkWell(
                          onTap: () {
                            // Navigate to OrderDetailScreen
                            Navigator.pushNamed(context, OrderDetailScreen.routeName);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Text(
                              "Place Order",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}