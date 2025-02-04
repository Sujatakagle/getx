import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newapp/logic/cubit/order/order_cubit.dart';
import 'package:newapp/logic/cubit/order/order_state.dart';
import 'package:newapp/logic/services/calculations.dart';
import 'package:newapp/logic/services/formatter.dart';
import 'package:newapp/presentation/widgets/gap_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/core/ui.dart';
import 'order_detail_screen.dart';

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
              return Center(
                child: Text(state.message ?? "An error occurred"),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Order ID, Date, Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header: Order ID, Date, Status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order ID: ${order.sId ?? 'N/A'}", // No truncation
                                  style: TextStyles.body1.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Reduced font size
                                  ),
                                  softWrap: true, // Allow wrapping to next line
                                ),
                                const SizedBox(height: 4), // Add space between lines
                                Text(
                                  "Date: ${Formatter.formatDate(order.createdOn ?? DateTime.now())}",
                                  style: TextStyles.body1.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4), // Add space between lines
                                Text(
                                  "Status: ${order.status ?? 'Unknown'}",
                                  style: TextStyles.body1.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: order.status == "order-placed"
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                        const GapWidget(),

                        // Items in the order
                        Column(
                          children: order.items!.map((item) {
                            final product = item.product!;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: product.images?.first ??
                                          'https://example.com/placeholder.png',
                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.brand ?? 'Unknown Brand',
                                          style: TextStyles.body1.copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Qty: ${item.quantity ?? 0}",
                                          style: TextStyles.body1.copyWith(
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Product Price
                                  Text(
                                    Formatter.formatPrice(
                                      (product.price ?? 0) *
                                          (item.quantity ?? 1),
                                    ),
                                    style: TextStyles.body1.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const GapWidget(),

                        // Order Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyles.body1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Formatter.formatPrice(
                                Calculations.cartTotal(order.items!),
                              ),
                              style: TextStyles.body1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const GapWidget(),

                        // Action Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                OrderDetailScreen.routeName,
                                arguments: order,
                              );
                            },
                            child: const Text("View Details"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
