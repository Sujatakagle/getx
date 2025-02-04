import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newapp/data/models/product/product_model.dart';
import '../../core/ui.dart';
import '../../logic/services/formatter.dart';
import 'package:newapp/presentation/screens/products/product_screen.dart';
// Assuming you have a FilterScreen created for filters

class ProductListView extends StatefulWidget {
  final List<ProductModel> products;
  final TextEditingController? searchController;

  const ProductListView({
    super.key,
    required this.products,
    this.searchController,
  });

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    if (widget.searchController != null) {
      widget.searchController!.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    if (widget.searchController != null) {
      widget.searchController!.removeListener(_onSearchChanged);
      widget.searchController!.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredProducts = widget.products.where((product) {
        final searchText = widget.searchController!.text.toLowerCase();
        return (product.description != null &&
            product.description!.toLowerCase().contains(searchText)) ||
            (product.chargerType != null &&
                product.chargerType!.toLowerCase().contains(searchText)) ||
            (product.connector != null &&
                product.connector!.type != null &&
                product.connector!.type!.toLowerCase().contains(searchText));
      }).toList();
    });
  }

  // Navigate to the filter screen when the filter icon is clicked


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.searchController != null)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
              ]
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
                              placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
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
                            Positioned(
                              top: 12,
                              right: 12,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // Toggle Wishlist feature
                                },
                              ),
                            ),
                          ],
                        ),
                        // ChargerType Display Centered Below the Image
                        if (product.chargerType != null)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                'Charger Type: ${product.chargerType!}',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20, // Increased font size
                                  shadows: [
                                    Shadow(
                                      color: Colors.blueGrey,
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 2.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // ConnectorType Display Left-Aligned, Without Details
                        if (product.connector != null)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              'Connector Type: ${product.connector!.type ?? "N/A"}',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.normal,
                                fontSize: 20, // Increased font size
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(7.0),
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
                                      // Handle Share feature
                                    },
                                  ),
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
    );
  }
}
