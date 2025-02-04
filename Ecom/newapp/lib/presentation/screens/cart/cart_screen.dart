import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/logic/cubit/cart/cart_state.dart';
import 'package:newapp/logic/services/calculations.dart';
import 'package:newapp/logic/services/formatter.dart';
import 'package:newapp/presentation/widgets/cart_list_view.dart';
import 'package:flutter/cupertino.dart';

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
              return const Center(child: Text("Your cart is empty."));
            }

            return Column(
              children: [
                Expanded(
                  child: CartListView(items: state.items),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${state.items.length} items",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Total: ${Formatter.formatPrice(Calculations.cartTotal(state.items))}",
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: CupertinoButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "order_detail");
                          },
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.teal,
                          child: const Text(
                            "Place Order",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}