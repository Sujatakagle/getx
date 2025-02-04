import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:newapp/data/models/product/product_model.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/logic/cubit/review/review_cubit.dart';
import 'package:newapp/logic/cubit/review/review_state.dart';
import 'package:newapp/logic/cubit/cart/cart_state.dart';
import 'package:newapp/Presentation/widgets/primary_button.dart';
import 'package:newapp/data/models/review/review_model.dart';
import 'package:newapp/logic/services/formatter.dart';
import 'package:intl/intl.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';
import 'package:newapp/core/ui.dart'; // Importing UI styles

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';
  final ProductModel productModel;

  ProductDetailsScreen({required this.productModel});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? userId;
  int rating = 0;
  String comment = "";

  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().getProductReviews(productId: widget.productModel.sId ?? "");
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productModel.brand ?? "Product Details", style: TextStyles.heading2),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            widget.productModel.images != null && widget.productModel.images!.isNotEmpty
                ? CarouselSlider(
              items: widget.productModel.images?.map((imageUrl) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                );
              }).toList() ?? [],
              options: CarouselOptions(
                height: 300,
                viewportFraction: 1.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
            )
                : SizedBox.shrink(), // If no images available, hide carousel

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productModel.brand ?? "Unknown Brand",
                    style: TextStyles.heading3.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color,fontSize: 20,),
                  ),
                  SizedBox(height: 8),
                  Text(
                    Formatter.formatPrice(widget.productModel.price ?? 0),
                    style: TextStyles.body1.copyWith(
                      color: AppColors.success,
                      fontSize: 20, // Increase the font size here
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 16),

                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      final isInCart = context.read<CartCubit>().cartContains(widget.productModel);
                      return PrimaryButton(
                        onPressed: isInCart
                            ? null
                            : () {
                          context.read<CartCubit>().addToCart(widget.productModel, 1);
                        },
                        text: isInCart ? "Added to Cart" : "Add to Cart",
                        color: isInCart ? Colors.pinkAccent : Colors.orangeAccent,
                      );
                    },
                  ),
                  SizedBox(height: 20),

                  Text("Description", style: TextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(widget.productModel.description ?? "No description available.", style: TextStyles.body2.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color)),
                  SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Customer Ratings and Reviews",
                      style: TextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey[300]),

                  BlocBuilder<ReviewCubit, ReviewState>(
                    builder: (context, state) {
                      if (state is ReviewLoading) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (state is ReviewSuccess) {
                        List<ReviewModel> reviews = state.reviews;
                        if (reviews.isEmpty) {
                          return Center(child: Text("No reviews yet.", style: TextStyles.body2.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color)));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              i < reviews[index].rating! ? Icons.star : Icons.star_border,
                                              color: Colors.orange,
                                              size: 20,
                                            );
                                          }),
                                        ),
                                        SizedBox(width: 8),
                                        // Modified to handle userId overflow
                                        Expanded( // Add Expanded widget to prevent overflow
                                          child: Text(
                                            "By ${reviews[index].userId}",
                                            style: TextStyles.body2.copyWith(
                                              color: Theme.of(context).textTheme.bodyMedium!.color,fontSize: 11,
                                               // Ensures overflow is handled
                                            ),
                                            maxLines: 1, // Limit the text to one line
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      reviews[index].comment ?? "No comment",
                                      style: TextStyles.body2.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Posted on ${formatDate(reviews[index].createdOn)}",
                                      style: TextStyles.body2.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Text("Please purchase the product to give reviews.", style: TextStyles.body2.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color));
                    },
                  ),
                  SizedBox(height: 16),

                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      if (state is UserLoggedInState) {
                        userId = state.userModel?.sId;

                        return Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Add a Comment",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.accent),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  comment = value;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < rating ? Icons.star : Icons.star_border,
                                    color: Colors.orange,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      rating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                            SizedBox(height: 10),
                            PrimaryButton(
                              text: "Submit Review",
                              onPressed: () {
                                if (rating > 0 || comment.isNotEmpty) {
                                  context.read<ReviewCubit>().addReview(
                                    productId: widget.productModel.sId ?? "",
                                    rating: rating > 0 ? rating : null,
                                    comment: comment.isNotEmpty ? comment : null,
                                  );

                                  setState(() {
                                    rating = 0;
                                    comment = "";
                                  });

                                  context.read<ReviewCubit>().getProductReviews(productId: widget.productModel.sId ?? "");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Please provide either a rating or a comment!")),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
