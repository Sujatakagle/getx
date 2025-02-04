import 'package:newapp/data/repositories/product_repository.dart';
import 'package:newapp/logic/cubit/product/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/data/models/product/product_model.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitialState()) {
    _initialize();
  }

  final _productRepository = ProductRepository();

  // Method to initialize and fetch all products initially
  void _initialize() async {
    emit(ProductLoadingState([]));  // Show loading initially
    try {
      final products = await _productRepository.fetchAllProducts();
      emit(ProductLoadedState(products));
    } catch (ex) {
      emit(ProductErrorState(ex.toString(), []));
    }
  }

  // Helper method to handle product fetching with filters
  Future<void> _fetchProducts({
    required Future<List<ProductModel>> Function() fetchFunction,
    required List<ProductModel> currentProducts,
  }) async {
    emit(ProductLoadingState(currentProducts));
    try {
      final products = await fetchFunction();
      emit(ProductLoadedState(products));
    } catch (ex) {
      emit(ProductErrorState("Error: $ex", currentProducts));
    }
  }

  // Fetch products based on selected filter options
  void fetchProducts({
    String? connectorType,
    String? chargerType,
    double? rating,  // Added the rating filter parameter
  }) {
    _fetchProducts(
      fetchFunction: () {
        if (rating != null) {
          return _productRepository.fetchProductsByMinRating(rating);  // Fetch products by rating
        } else if (connectorType != null && chargerType != null) {
          return _productRepository.fetchProductsByConnectorAndChargerType(connectorType, chargerType);
        } else if (connectorType != null) {
          return _productRepository.fetchProductsByConnectorType(connectorType);
        } else if (chargerType != null) {
          return _productRepository.fetchProductsByChargerType(chargerType);
        } else {
          return _productRepository.fetchAllProducts();
        }
      },
      currentProducts: state.products,
    );
  }

  // Method to fetch all products (without filters)
  void fetchAllProducts() {
    _fetchProducts(
      fetchFunction: _productRepository.fetchAllProducts,
      currentProducts: state.products,
    );
  }
}
