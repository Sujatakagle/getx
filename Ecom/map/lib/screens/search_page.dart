import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  List<dynamic> _suggestions = [];
  List<String> _recentSearches = [];
  String apiKey = 'AIzaSyD4_6anlN09mZ1H6hhnfryibQdAWfygUbo'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  // Save the selected city to SharedPreferences
  Future<void> _saveCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ensure the city is unique in the list
    if (_recentSearches.contains(city)) {
      // Move the city to the top if it already exists
      _recentSearches.remove(city);
      _recentSearches.insert(0, city);
    } else {
      // Add the city to the top and limit to 5 recent searches
      _recentSearches.insert(0, city);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast(); // Limit to 5 recent searches
      }
    }

    await prefs.setStringList('recentSearches', _recentSearches);
    setState(() {});
  }

  // Delete a city from recent searches
  Future<void> _deleteCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(city);
    });
    await prefs.setStringList('recentSearches', _recentSearches);
  }

  // Fetch city suggestions restricted to India
  Future<void> _fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&types=(cities)&components=country:in';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _suggestions = data['predictions'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Access the theme's text styles

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search City',
          style: textTheme.headlineLarge?.copyWith(color: Theme.of(context).appBarTheme.titleTextStyle?.color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box with Divider Below
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City',
                labelStyle: TextStyle(color: textTheme.bodyLarge?.color), // Use the theme's text color for label
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                _fetchCitySuggestions(value);
              },
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 2, color: Colors.grey),

            // Recent Search Section (only show when search box is empty)
            if (_recentSearches.isNotEmpty && _cityController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Searches',
                      style: textTheme.headlineLarge?.copyWith(color: textTheme.bodyLarge?.color), // Use the theme's text color for headings
                    ),
                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _recentSearches.length,
                      itemBuilder: (context, index) {
                        final city = _recentSearches[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              city,
                              style: textTheme.bodyLarge?.copyWith(color: textTheme.bodyLarge?.color), // Use the theme's text color
                            ),
                            leading: const Icon(
                              Icons.history,
                              color: Colors.blue,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteCity(city),
                            ),
                            onTap: () {
                              _saveCity(city); // Save the city to SharedPreferences
                              // Directly navigate to Hotel Screen with the selected city
                              Navigator.pop(context, city); // Pass the selected city back to the previous screen
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Suggestions List
            Expanded(
              child: ListView.separated(
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(
                      suggestion['description'],
                      style: textTheme.bodyLarge?.copyWith(color: textTheme.bodyLarge?.color), // Use the theme's text color
                    ),
                    leading: const Icon(
                      Icons.location_city,
                      color: Colors.blueAccent,
                    ),
                    onTap: () {
                      _saveCity(suggestion['description']);
                      Navigator.pop(context, suggestion['description']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
