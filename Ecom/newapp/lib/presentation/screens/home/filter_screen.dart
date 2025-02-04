import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/logic/cubit/product/product_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedConnectorType;
  String? selectedChargerType;
  String? selectedRating;

  String? activeFilterCategory = 'Connector Type';

  final connectorTypes = ['Single', 'Dual'];
  final chargerTypes = ['AC', 'DC'];
  final ratingOptions = ['4.5+', '4.0+', '3.5+', '3.0+', '2.0+'];

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  // Load filters from SharedPreferences
  Future<void> _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedConnectorType = prefs.getString('connectorType');
      selectedChargerType = prefs.getString('chargerType');
      selectedRating = prefs.getString('rating');
    });
  }

  // Save selected filters to SharedPreferences
  Future<void> _saveFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('connectorType', selectedConnectorType ?? '');
    prefs.setString('chargerType', selectedChargerType ?? '');
    prefs.setString('rating', selectedRating ?? '');
  }

  // Clear selected filters and reset the active category
  void _clearFilters() {
    setState(() {
      selectedConnectorType = null;
      selectedChargerType = null;
      selectedRating = null;
      activeFilterCategory = 'Connector Type';
    });
    context.read<ProductCubit>().fetchAllProducts();
    _clearSavedFilters();
  }

  // Remove filters from SharedPreferences
  Future<void> _clearSavedFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('connectorType');
    prefs.remove('chargerType');
    prefs.remove('rating');
  }

  // Get the filter count for each category
  String _getFilterCount(String filterType) {
    if (filterType == 'Connector Type') {
      return selectedConnectorType != null ? '(1)' : '';
    } else if (filterType == 'Charger Type') {
      return selectedChargerType != null ? '(1)' : '';
    } else if (filterType == 'Ratings') {
      return selectedRating != null ? '(1)' : '';
    }
    return '';
  }

  // Build the filter category list
  Widget _buildFilterCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...['Connector Type', 'Charger Type', 'Ratings'].map(
              (category) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildFilterCategoryItem(category),
          ),
        ),
      ],
    );
  }

  // Build individual filter category list item
  Widget _buildFilterCategoryItem(String category) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      tileColor: activeFilterCategory == category
          ? Colors.blue.shade100
          : Colors.white,
      title: Text(
        '$category ${_getFilterCount(category)}',
        style: const TextStyle(fontSize: 15),
      ),
      onTap: () {
        setState(() {
          activeFilterCategory = category;
        });
      },
    );
  }

  // Build the filter options based on selected category
  Widget _buildFilterOptions() {
    if (activeFilterCategory == 'Ratings') {
      return Column(
        children: ratingOptions.map((rating) {
          return RadioListTile<String>(
            title: Text(rating),
            value: rating,
            groupValue: selectedRating,
            onChanged: (value) {
              setState(() {
                selectedRating = value;
              });
              _saveFilters();
            },
          );
        }).toList(),
      );
    }

    final options = activeFilterCategory == 'Connector Type'
        ? connectorTypes
        : chargerTypes;

    final selectedValue = activeFilterCategory == 'Connector Type'
        ? selectedConnectorType
        : selectedChargerType;

    return Column(
      children: options.map((type) {
        return RadioListTile<String>(
          title: Text(type),
          value: type,
          groupValue: selectedValue,
          onChanged: (value) {
            setState(() {
              if (activeFilterCategory == 'Connector Type') {
                selectedConnectorType = value;
              } else {
                selectedChargerType = value;
              }
            });
            _saveFilters();
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filter Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20.0), // Height of the divider
          child: Divider(
            thickness: 1,
            color: Colors.grey, // Divider color
          ),
        ),
      ),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter categories
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: const Color(0xFFB0C4DE),
              child: _buildFilterCategoryList(),
            ),
          ),
          // Vertical divider
          const VerticalDivider(thickness: 1, width: 20),
          // Filter options
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeFilterCategory ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildFilterOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Apply filters button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Fetch products based on selected filters, including rating
              context.read<ProductCubit>().fetchProducts(
                connectorType: selectedConnectorType,
                chargerType: selectedChargerType,
                rating: _getRatingFromSelection(selectedRating),
              );
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ),
    );
  }

  // Helper function to convert selected rating to double value
  double? _getRatingFromSelection(String? rating) {
    switch (rating) {
      case '4.5+':
        return 4.5;
      case '4.0+':
        return 4.0;
      case '3.5+':
        return 3.5;
      case '3.0+':
        return 3.0;
      case '2.0+':
        return 2.0;
      default:
        return null;
    }
  }
}
