import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart'; // To get the current location

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController fromCityController = TextEditingController();
  TextEditingController toCityController = TextEditingController();
  List<String> fromCitySuggestions = [];
  List<String> toCitySuggestions = [];
  bool useCurrentLocation = false;
  double? currentLatitude;
  double? currentLongitude;


  // List to store recent searches
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  // Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentSearches', recentSearches);
  }

  Future<void> _getCitySuggestions(String query, String field) async {
    if (query.isEmpty) {
      setState(() {
        if (field == 'from') {
          fromCitySuggestions.clear();
        } else {
          toCitySuggestions.clear();
        }
      });
      return;
    }

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&components=country:IN&key=AIzaSyD4_6anlN09mZ1H6hhnfryibQdAWfygUbo'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'];

      setState(() {
        if (field == 'from') {
          fromCitySuggestions = predictions
              .map<String>((prediction) => prediction['description'] as String)
              .toList();
        } else {
          toCitySuggestions = predictions
              .map<String>((prediction) => prediction['description'] as String)
              .toList();
        }
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      fromCityController.text = '${position.latitude}, ${position.longitude}';
      setState(() {
        useCurrentLocation = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location')),
      );
    }
  }

  // Remove a recent search from the list and update SharedPreferences
  Future<void> _removeRecentSearch(int index) async {
    setState(() {
      recentSearches.removeAt(index);
    });
    await _saveRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 5, right: 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Cities for Your Trip',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),

              // From City Input Field with Current Location Button
              _buildCityInputField(
                controller: fromCityController,
                hint: 'Enter starting city',
                icon: Icons.location_city,
                suggestions: fromCitySuggestions,
                field: 'from',
                onCurrentLocationPressed: _getCurrentLocation, // Button to get current location
              ),

              const SizedBox(height: 16),

              // To City Input Field
              _buildCityInputField(
                controller: toCityController,
                hint: 'Enter destination city',
                icon: Icons.location_on,
                suggestions: toCitySuggestions,
                field: 'to',
              ),

              const SizedBox(height: 16),

              // Search Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final fromCity = fromCityController.text;
                    final toCity = toCityController.text;

                    if (fromCity.isNotEmpty && toCity.isNotEmpty) {
                      if (useCurrentLocation) {
                        // Request from current location to destination city
                        final url = 'http://192.168.1.2:6386/api/trip/trip?currentLat=useCurrentLocation&currentLng=useCurrentLocation&toCity=$toCity';
                        print(url);
                      } else {
                        final url = 'http://192.168.1.2:6386/api/trip/trip?fromCity=$fromCity&toCity=$toCity';
                        print(url);
                      }
                      Navigator.pop(context, {'fromCity': fromCity, 'toCity': toCity});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter both cities')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Search', style: TextStyle(fontSize: 16)),
                ),
              ),
              const Divider(
                thickness: 1,
                color: Colors.black38,
              ),

              const SizedBox(height: 16),

              // Display recent searches below the search button
              if (recentSearches.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Searches', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      for (var i = 0; i < recentSearches.length; i++)
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                recentSearches[i],
                                style: TextStyle(fontSize: 12),
                              ),
                              onTap: () {
                                var cities = recentSearches[i].split('→');
                                fromCityController.text = cities[0].trim();
                                toCityController.text = cities[1].trim();
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeRecentSearch(i),
                              ),
                            ),
                            if (i < recentSearches.length - 1) const Divider(),
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
  }

  // Helper method to build text field with suggestions
  Widget _buildCityInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required List<String> suggestions,
    required String field,
    VoidCallback? onCurrentLocationPressed, // Button callback for current location
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              suffixIcon: onCurrentLocationPressed != null
                  ? IconButton(
                icon: Icon(Icons.gps_fixed),
                onPressed: onCurrentLocationPressed, // Trigger location fetch
              )
                  : null,
            ),
            onChanged: (query) {
              _getCitySuggestions(query, field);
            },
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  spreadRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
            child: ListView.separated(
              itemCount: suggestions.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    suggestions[index],
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    setState(() {
                      controller.text = suggestions[index];
                      suggestions.clear();
                    });
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
      ],
    );
  }
}
