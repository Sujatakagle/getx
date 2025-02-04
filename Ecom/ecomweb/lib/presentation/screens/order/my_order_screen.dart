import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecomweb/logic/services/app_colors.dart';
import 'package:ecomweb/logic/cubit/order/order_cubit.dart';
import 'package:ecomweb/logic/cubit/order/order_state.dart';
import 'package:ecomweb/logic/services/calculations.dart';
import 'package:ecomweb/logic/services/formatter.dart';
import 'package:ecomweb/presentation/widgets/gap_widgets.dart';
import 'package:ecomweb/core/ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecomweb/logic/services/app_colors.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  static const routeName = "my_orders";

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: SafeArea(
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderLoadingState && state.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderErrorState && state.orders.isEmpty) {
              return Center(child: Text(state.message));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (context, index) => Column(
                children: [
                  const GapWidget(),
                  Divider(color: AppColors.textLight),
                  const GapWidget(),
                ],
              ),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "# - ${order.sId}",
                      style: TextStyles.body2(context).copyWith(color: AppColors.textLight),
                    ),
                    Text(
                      Formatter.formatDate(order.createdOn!),
                      style: TextStyles.body2(context).copyWith(color: AppColors.accent),
                    ),
                    Text(
                      "Order Total: ${Formatter.formatPrice(Calculations.cartTotal(order.items!))}",
                      style: TextStyles.body1(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,

                      ),
                    ),

                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: order.items!.length,
                      itemBuilder: (context, index) {
                        final item = order.items![index];
                        final product = item.product!;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CachedNetworkImage(imageUrl: product.images![0]),
                          title: Text("${product.brand}"),
                          subtitle: Text("Qty: ${item.quantity}"),
                          trailing: Text(
                            Formatter.formatPrice(product.price! * item.quantity!),
                            style: TextStyle(
                              fontSize: 20, // Increase the font size as per your need
                              fontWeight: FontWeight.bold, // Optionally, make the price bold
                              color: Colors.green, // You can also customize the color if you want
                            ),
                          ),
                        );
                      },
                    ),
                    Text("Status: ${order.status}"),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
