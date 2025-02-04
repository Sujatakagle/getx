import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecomweb/data/models/product/product_model.dart';
import 'package:ecomweb/logic/cubit/cart/cart_cubit.dart';
import 'package:ecomweb/logic/services/formatter.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecomweb/Presentation/widgets/gap_widgets.dart';
import 'package:ecomweb/Presentation/widgets/primary_button.dart';
import 'package:ecomweb/logic/services/app_colors.dart';
import 'package:ecomweb/logic/cubit/cart/cart_state.dart';
import 'package:ecomweb/core/ui.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  const ProductDetailsScreen({super.key, required this.productModel});

  static const routeName = "product_screen";

  @override
  State<ProductDetailsScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        title: Text(
          widget.productModel.brand ?? "Product",
          style: TextStyles.heading3(context),  // Applying TextStyle for the title
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel with Modern Transition
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: CarouselSlider.builder(
                  itemCount: widget.productModel.images?.length ?? 0,
                  itemBuilder: (context, index, realIndex) {
                    String url = widget.productModel.images![index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 1.1,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    scrollPhysics: const BouncingScrollPhysics(),
                  ),
                ),
              ),

              // Share Icon below the image carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.share, size: 30, color: Colors.blueAccent),
                    onPressed: () {
                      // Handle share action here
                    },
                  ),
                ),
              ),

              // Product Description Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.productModel.description ?? "No description available.",
                  style: TextStyles.body1(context),  // Applying TextStyle for body text
                ),
              ),

              // Price, Add to Cart, and Buy Now Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the price, formatted using the Formatter class
                    Text(
                      "${Formatter.formatPrice(widget.productModel.price!)}",
                      style: TextStyles.heading2(context).copyWith(
                          color: Colors.blueAccent,
                          fontSize: 28// Applying a custom color for price
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Add to Cart Button
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Add product to cart and show snackbar
                          BlocProvider.of<CartCubit>(context).addToCart(widget.productModel, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Product added to cart!"),
                              backgroundColor: Colors.grey,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Add to Cart",
                            style: TextStyles.body2(context).copyWith(
                              color: Colors.white,  // Custom color for button text
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Buy Now Button
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Navigate to checkout screen with product details
                          Navigator.pushNamed(context, "/checkout", arguments: widget.productModel);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Buy Now",
                            style: TextStyles.body2(context).copyWith(
                              color: Colors.white,  // Custom color for button text
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
