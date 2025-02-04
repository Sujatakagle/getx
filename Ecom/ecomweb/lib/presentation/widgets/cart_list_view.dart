import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecomweb/logic/cubit/cart/cart_cubit.dart';
import 'package:ecomweb/data/models/cart/cart_item_model.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:ecomweb/logic/services/formatter.dart';
import 'link_button.dart';

class CartListView extends StatelessWidget {
  final List<CartItemModel> items;
  final ScrollPhysics? physics;

  const CartListView({
    super.key,
    required this.items,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              // Larger Product Image without Box Shadow
              CachedNetworkImage(
                imageUrl: item.product!.images![0],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
              ),
              const SizedBox(width: 15),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product!.brand!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${Formatter.formatPrice(item.product!.price!)} x ${item.quantity} = ${Formatter.formatPrice(item.product!.price! * item.quantity!)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Remove Button
                    LinkButton(
                      onPressed: () {
                        BlocProvider.of<CartCubit>(context).removeFromCart(item.product!);
                      },
                      text: "Remove",
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              // Quantity Selector with Enhanced Styling
              Theme(
                data: ThemeData(
                  primaryColor: Colors.blueGrey,
                  textTheme: const TextTheme(
                    bodyMedium: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                child: InputQty(
                  maxVal: 99,
                  initVal: item.quantity!,
                  minVal: 1,
                  showMessageLimit: false,
                  onQtyChanged: (value) {
                    if (value == item.quantity) return;
                    BlocProvider.of<CartCubit>(context).addToCart(item.product!, value as int);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
