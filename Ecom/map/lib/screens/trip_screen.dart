import'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'tripsearch_screen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;


class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}
class _TripScreenState extends State<TripScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _startLocation;
  LatLng? _endLocation;
  String? fromCity;
  String? toCity;
  LatLng? _currentLocation;
  int? _selectedRouteIndex;
  String totalDuration = '';
  int totalHotels = 0;
  String totalDistance = '';
  String routeSummary = '';
  String? selectedHotelName;
  String? selectedHotelAddress;
  int stationCount = 0;
  List<dynamic> selectedStations = [];


  // This will store the marker as the station
  Marker? stationMarker;

  final LatLng indiaCenter = LatLng(20.5937, 78.9629); // Central location of India

  @override
  void initState() {
    super.initState();
    _loadSavedCities();
    _getCurrentLocation();
  }



  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fromCity = prefs.getString('fromCity');
      toCity = prefs.getString('toCity');
    });

    if (fromCity != null && toCity != null) {
      final startCoordinates = await _getCoordinates(fromCity!);
      final endCoordinates = await _getCoordinates(toCity!);

      if (startCoordinates != null && endCoordinates != null) {
        setState(() {
          _startLocation = startCoordinates;
          _endLocation = endCoordinates;
        });

        _fetchHotels();
        _fetchRoute();
      }
    }
  }

  Future<void> _saveCities(String fromCity, String toCity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fromCity', fromCity);
    await prefs.setString('toCity', toCity);
  }

  Future<void> _resetCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fromCity');
    await prefs.remove('toCity');
    setState(() {
      _startLocation = null;
      _endLocation = null;
      fromCity = null;
      toCity = null;
      _markers.clear();
      _polylines.clear();
    });

    // Center the map back to India (zoomed out)
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: indiaCenter,
          zoom: 5, // Adjust the zoom level to show India
        ),
      ),
    );
  }

  Future<LatLng?> _getCoordinates(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$cityName&key=AIzaSyD4_6anlN09mZ1H6hhnfryibQdAWfygUbo'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  Future<void> _fetchRoute() async {
    setState(() {
      selectedStations.clear(); // Clear the selected stations list
      // Clear the polylines set
    });
    if (_startLocation != null && _endLocation != null) {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation!.latitude},${_startLocation!.longitude}&destination=${_endLocation!.latitude},${_endLocation!.longitude}&alternatives=true&key=AIzaSyD4_6anlN09mZ1H6hhnfryibQdAWfygUbo'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'];

        if (routes.isEmpty) {
          print("No routes found.");
          return;
        }

        // Extract information from the first route
        final legs = routes[0]['legs'][0];
        final duration = legs['duration']['text'];
        final distance = legs['distance']['text'];
        final summary = routes[0]['summary']; // E.g., NH48, SH4

        setState(() {
          totalDuration = duration;
          totalDistance = distance; // E.g., "886.55 km"
          routeSummary = summary; // E.g., "NH48, SH4"
        });

        // Add polylines for up to two routes
        setState(() {
          _polylines.clear();
          for (int i = 0; i < routes.length && i < 2; i++) {
            String encodedPolyline = routes[i]['overview_polyline']['points'];
            _addPolylineFromEncoded(encodedPolyline, i);
          }
        });
      } else {
        print("Error fetching route: ${response.statusCode}");
      }
    }
  }

  void _addPolylineFromEncoded(String encodedPolyline, int routeIndex) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);

    if (decodedPoints.isNotEmpty) {
      List<LatLng> latLngPoints = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      // Customize colors for differentiation between routes
      final colors = [Colors.green, Colors.blue, Colors.red, Colors.orange];

      final polyline = Polyline(
        polylineId: PolylineId('route_$routeIndex'),
        points: latLngPoints,
        color: _selectedRouteIndex == routeIndex
            ? Colors.purple
            : colors[routeIndex % colors.length],
        width: _selectedRouteIndex == routeIndex ? 6 : 4, // Increase width for selected route
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );

      setState(() {
        _polylines.add(polyline);
      });
    } else {
      print("Decoded points are empty for route $routeIndex");
    }
  }
  Future<void> _fetchHotels() async {
    String url;

    // Construct the URL based on the available data
    if (fromCity != null && toCity != null) {
      url = 'http://192.168.1.2:6386/api/trip/trip?fromCity=$fromCity&toCity=$toCity';
    } else {
      print('Insufficient data to fetch hotels.');
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final hotelsFromCity = data['sourceCityHotels'] ?? [];
        final hotelsToCity = data['destinationCityHotels'] ?? [];
        final waypointHotels = data['waypointHotels'] ?? [];

        setState(() {
          totalHotels = hotelsFromCity.length + hotelsToCity.length + waypointHotels.length;
        });

        _markers.clear();

        // Add markers for all hotel types if available
        if (hotelsFromCity.isNotEmpty) {
          _addMarkers(hotelsFromCity);
        }
        if (hotelsToCity.isNotEmpty) {
          _addMarkers(hotelsToCity);
        }
        if (waypointHotels.isNotEmpty) {
          _addMarkers(waypointHotels);
        }
      } else {
        print('Failed to fetch hotels. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching hotels: $error');
    }
  }
  Future<void> _addMarkers(List<dynamic> hotels) async {
    Set<Marker> markers = {};
    final ByteData data = await rootBundle.load('assets/hotelmarker.png');
    final Uint8List resizedImage = await _resizeMarkerImage(data, 140, 140);
    BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(resizedImage);

    for (var hotel in hotels) {
      if (hotel['coordinates'] != null) {
        double lat = (hotel['coordinates']['coordinates'][1] ?? 0.0);
        double lng = (hotel['coordinates']['coordinates'][0] ?? 0.0);

        if (lat != 0.0 && lng != 0.0) {
          final marker = Marker(
            markerId: MarkerId(hotel['name']),
            position: LatLng(lat, lng),
            icon: stationMarker != null && stationMarker!.position == LatLng(lat, lng)
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue) // Blue station marker
                : customIcon, // Original hotel marker
            infoWindow: InfoWindow(
              title: hotel['name'],
              snippet: hotel['address'],
              onTap: () {
                setState(() {
                  selectedHotelName = hotel['name'];
                  selectedHotelAddress = hotel['address'];
                });
                _showHotelInfoBottomSheet(hotel);
              },
            ),
          );
          markers.add(marker);
        }
      }
    }

    setState(() {
      _markers.addAll(markers);
    });
  }

  // This function will show a bottom sheet with hotel details and add/remove station options
  void _showHotelInfoBottomSheet(dynamic hotel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(selectedHotelName ?? ''),
                subtitle: Text(selectedHotelAddress ?? ''),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                    text: "Add Station",
                    onPressed: () {
                      _addStation(hotel); // Add station logic
                    },
                  ),
                  _buildButton(
                    text: "Remove Station",
                    onPressed: () {
                      _showRemoveConfirmationDialog(hotel); // Show confirmation dialog for remove
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(text),
    );
  }

  void _showRemoveConfirmationDialog(dynamic hotel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min, // Adjust size of the column to fit content
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                size: 30, // Smaller icon
                color: Colors.orange,
              ),
              const SizedBox(height: 8), // Reduced space between icon and text
              Text(
                "Are you sure?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Smaller title font size
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0), // Reduced padding for content
            child: Text(
              "Are you sure you want to remove the $selectedHotelName from your trip?",
              textAlign: TextAlign.center, // Centering the content text
              style: TextStyle(fontSize: 12), // Smaller content text size
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Neutral color for the cancel button
              ),
              child: const Text("No, Cancel", style: TextStyle(fontSize: 12)), // Smaller text
            ),
            SizedBox(
              height: 30, // Reduced button height for a smaller size
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _removeStation(hotel); // Perform the station removal action
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                  textStyle: const TextStyle(fontSize: 10), // Smaller button text size
                  backgroundColor: Colors.red, // Red color for the action button
                ),
                child: const Text("Yes, Remove", style: TextStyle(fontSize: 12)), // Smaller button text
              ),
            ),
          ],
        );
      },
    );
  }




  void _addStation(dynamic hotel) async {
    final ByteData data = await rootBundle.load('assets/hotelmarker.png');
    final Uint8List resizedImage = await _resizeMarkerImage(data, 140, 140);
    BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(resizedImage);

    setState(() {
      stationMarker = Marker(
        markerId: MarkerId(hotel['name']),
        position: LatLng(
          hotel['coordinates']['coordinates'][1],
          hotel['coordinates']['coordinates'][0],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: hotel['name'],
          snippet: hotel['address'],
          onTap: () {
            setState(() {
              selectedHotelName = hotel['name'];
              selectedHotelAddress = hotel['address'];
            });
            _showHotelInfoBottomSheet(hotel);
          },
        ),
      );

      // Update the markers and stations
      _markers.removeWhere((m) => m.markerId == stationMarker!.markerId);
      _markers.add(stationMarker!);
      selectedStations.add(hotel); // Add the hotel to the list of selected stations
    });
  }

// Update _removeStation to remove the station from the list
  void _removeStation(dynamic hotel) async {
    final ByteData data = await rootBundle.load('assets/hotelmarker.png');
    final Uint8List resizedImage = await _resizeMarkerImage(data, 140, 140);
    BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(resizedImage);

    setState(() {
      // Restore the original marker state with the InfoWindow callback
      final marker = Marker(
        markerId: MarkerId(hotel['name']),
        position: LatLng(
          hotel['coordinates']['coordinates'][1],
          hotel['coordinates']['coordinates'][0],
        ),
        icon: customIcon,
        infoWindow: InfoWindow(
          title: hotel['name'],
          snippet: hotel['address'],
          onTap: () {
            setState(() {
              selectedHotelName = hotel['name'];
              selectedHotelAddress = hotel['address'];
            });
            _showHotelInfoBottomSheet(hotel);
          },
        ),
      );

      _markers.removeWhere((m) => m.markerId == marker.markerId);
      _markers.add(marker);

      selectedStations.remove(hotel); // Remove the hotel from the list of selected stations
      stationMarker = null; // Clear the station marker
    });
  }



  Future<Uint8List> _resizeMarkerImage(ByteData data, int width, int height) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? resizedData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png);
    return resizedData!.buffer.asUint8List();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _startLocation = LatLng(position.latitude, position.longitude);
    });
  }
  List<Widget> _buildRouteWidgets() {
    List<Widget> routeWidgets = [];

    if (fromCity != null) {
      // Add the starting location with an icon
      routeWidgets.add(_buildLocationWithConnector(fromCity!, Colors.green, false));
    }

    for (var i = 0; i < selectedStations.length; i++) {
      // Add intermediate stations with a connector
      routeWidgets.add(_buildLocationWithConnector(selectedStations[i]['name'], Colors.orange, true));
    }

    if (toCity != null) {
      // Add the final destination without a connector
      routeWidgets.add(_buildLocationWithConnector(toCity!, Colors.red, false));
    }

    return routeWidgets;
  }

// Helper method to build each location widget with connector
  Widget _buildLocationWithConnector(String location, Color iconColor, bool hasConnector) {
    int stationCount = selectedStations.length;  // Count of stations

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon for the location
            Column(
              children: [
                // Original Round circle icon for intermediate and starting cities
                if (hasConnector || location == fromCity || location == toCity)
                  Container(
                    width: 30, // Circle size
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2), // White border for contrast
                    ),
                    child: Center(
                      child: Icon(
                        Icons.location_on, // Location icon
                        size: 20,
                        color: Colors.white, // Icon color inside circle
                      ),
                    ),
                  ),
                // Connector line between icons (for intermediate stations)
                if (hasConnector)
                  Container(
                    width: 2,
                    height: 30, // Connector line height
                    color: Colors.grey, // Line color
                  ),
              ],
            ),
            const SizedBox(width: 8),
            // Location text
            Expanded(
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // New location icon with count placed on the right
            if (location == fromCity)
              Container(
                width: 50, // Larger icon size
                height: 50,
                margin: EdgeInsets.only(top: 8), // Adjust position if needed
                decoration: BoxDecoration(
                  color: Colors.blue, // Different color for new icon
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2), // White border for contrast
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.location_on, // Different location icon
                        size: 30, // Icon size
                        color: Colors.white, // Icon color inside circle
                      ),
                    ),
                    // Display count of stations in the middle of the icon
                    if (stationCount > 0)
                      Positioned(
                        top: 10, // Adjust position to center the badge
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$stationCount', // Display the count
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Google Map widget
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _startLocation ?? indiaCenter, // Show India initially
                zoom: _startLocation == null ? 5 : 7, // Zoom level
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              zoomControlsEnabled: false,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
          Positioned(
            top: 390,
            right: 6,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.zoom_in_map_sharp),
                    iconSize: 30,
                    color: Colors.blueGrey,
                    onPressed: () async {
                      if (mapController != null) {
                        mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.zoom_out_map_sharp),
                    iconSize: 30,
                    color: Colors.blueGrey,
                    onPressed: () async {
                      if (mapController != null) {
                        mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Total Travel Time and Hotels
          Positioned(
            bottom: 10,
            left: 5,
            right: 5,
            child: (fromCity != null && toCity != null)
                ? Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route list with realistic spacing
                  ..._buildRouteWidgets(), // Dynamic route widgets
                  const Divider(
                    color: Colors.grey,
                    height: 10,
                    thickness: 1,
                  ),
                  // Second line: Total Travel Time | Total Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Time: $totalDuration', // Travel Time
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.directions_car, size: 18, color: Colors.brown),
                          SizedBox(width: 4),
                          Text(
                            'Distance: $totalDistance', // Distance
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
                : Container(), // If cities are not selected, show nothing
          ),


// Function to build the route text with stations

    // Buttons at the top-left corner
          // Buttons (Save and Reset) below Zoom icons
          Positioned(
            top: 280, // Adjust this value as per your UI requirements
            right: 6,
            child: Column(
              children: [
                // Save Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.save_outlined),
                    color: Colors.blueGrey,
                    onPressed: () {
                      if (fromCity != null && toCity != null) {
                        _saveCities(fromCity!, toCity!);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Reset Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.blueGrey,
                    onPressed: _resetCities,
                  ),
                ),
              ],
            ),
          ),

          // City Selection Box at the bottom
          if (fromCity == null || toCity == null)
            Positioned(
              bottom: 3,
              left: 2,
              right: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Select your source and destination cities, and let us help you plan your journey.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push<
                              Map<String, String>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );

                          if (result != null && result.isNotEmpty) {
                            setState(() {
                              fromCity = result['fromCity'];
                              toCity = result['toCity'];
                            });

                            _saveCities(fromCity!, toCity!);

                            final startCoordinates = await _getCoordinates(
                                fromCity!);
                            final endCoordinates = await _getCoordinates(
                                toCity!);

                            if (startCoordinates != null &&
                                endCoordinates != null) {
                              setState(() {
                                _startLocation = startCoordinates;
                                _endLocation = endCoordinates;
                              });

                              _fetchHotels();
                              _fetchRoute();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            'Plan Your Trip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}