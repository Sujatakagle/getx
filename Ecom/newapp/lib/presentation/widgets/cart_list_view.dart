import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/data/models/cart/cart_item_model.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:newapp/logic/services/formatter.dart';
import 'link_button.dart';

class CartListView extends StatelessWidget {
  final List<CartItemModel> items;
  final bool shrinkWrap;
  final bool noScroll;

  const CartListView({
    super.key,
    required this.items,
    this.shrinkWrap = false,
    this.noScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: noScroll ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    width: 120,
                    height: 170,
                    fit: BoxFit.cover,
                    imageUrl: item.product!.images![0],
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error, size: 50, color: Colors.redAccent),
                  ),
                ),
                const SizedBox(width: 20),

                // Details Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        item.product?.brand ?? 'Product Name',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Price and Quantity
                      Row(
                        children: [
                          Text(
                            "${Formatter.formatPrice(item.product!.price!)} x ${item.quantity} = ${Formatter.formatPrice(item.product!.price! * item.quantity!)}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Quantity Input
                      Container(
                        width: 160,
                        child: InputQty(
                          maxVal: 99,
                          initVal: item.quantity!,
                          minVal: 1,
                          btnColor1: Colors.grey[200] ?? Colors.black,
                          btnColor2: Colors.grey[200] ?? Colors.black,
                          onQtyChanged: (value) {
                            if (value != item.quantity) {
                              BlocProvider.of<CartCubit>(context).addToCart(item.product!, value as int);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Remove Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: LinkButton(
                          onPressed: () {
                            BlocProvider.of<CartCubit>(context).removeFromCart(item.product!);
                          },
                          text: "Remove",
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}