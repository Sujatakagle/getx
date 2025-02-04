import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/data/models/product/product_model.dart';
import 'package:newapp/logic/cubit/product/product_cubit.dart';
import 'package:newapp/logic/cubit/product/product_state.dart';
import 'package:newapp/core/ui.dart';
import 'package:newapp/logic/services/formatter.dart';
import 'package:newapp/presentation/screens/home/filter_screen.dart';
import 'package:newapp/presentation/screens/products/product_screen.dart';
import 'package:share_plus/share_plus.dart';



class UserFeedScreen extends StatefulWidget {
  const UserFeedScreen({super.key});

  @override
  State<UserFeedScreen> createState() => _UserFeedScreenState();
}

class _UserFeedScreenState extends State<UserFeedScreen> {
  late final TextEditingController _searchController;
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(List<ProductModel> products) {
    setState(() {
      final searchText = _searchController.text.toLowerCase();
      _filteredProducts = products.where((product) {
        return (product.description?.toLowerCase().contains(searchText) ?? false) ||
            (product.chargerType?.toLowerCase().contains(searchText) ?? false) ||
            (product.connector?.type?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    });
  }

  void _updateRating(ProductModel product, double newRating) {
    setState(() {
      product.averageRating = newRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(builder: (context, state) {
      if (state is ProductLoadingState) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is ProductLoadedState) {
        final products = state.products;
        _filteredProducts = _searchController.text.isEmpty ? products : _filteredProducts;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for products...',
                            prefixIcon: const Icon(Icons.search),
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onChanged: (value) => _onSearchChanged(products),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FilterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ProductDetailsScreen.routeName,
                              arguments: product,
                            );
                          },
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: "${product.images?[0]}",
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.15),
                                            Colors.black.withOpacity(0.6),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.description ?? "No description available",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      if (product.chargerType != null)
                                        Text(
                                          'Charger Type: ${product.chargerType!}',
                                          style: const TextStyle(
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                      if (product.connector != null)
                                        Text(
                                          'Connector Type: ${product.connector!.type ?? "N/A"}',
                                          style: const TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      // Adding rating display with a star icon
                                      if (product.averageRating != null)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow[700],
                                              size: 18,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              product.averageRating!.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product.price != null
                                                ? Formatter.formatPrice(product.price!)
                                                : "Price not available",
                                            style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.share),
                                            onPressed: () {
                                              // Prepare the content you want to share
                                              String shareText = '''
    Check out this product:
    ${product.description ?? "No description available"}
    Price: ${product.price != null ? Formatter.formatPrice(product.price!) : "Price not available"}
    Charger Type: ${product.chargerType ?? "N/A"}
    Connector Type: ${product.connector?.type ?? "N/A"}
    Rating: ${product.averageRating != null ? product.averageRating!.toStringAsFixed(1) : "N/A"}
    ''';

                                              // Share the content using the share package
                                              Share.share(shareText);
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (state is ProductErrorState) {
        return Center(child: Text('Error: ${state.error}'));
      }

      return const Center(child: Text('No products available'));
    });
  }
}
