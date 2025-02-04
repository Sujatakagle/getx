import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'search_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:map/screens/HotelDetailScreen.dart';
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Location _location = Location();
  double? userLat;
  double? userLng;
  bool _isLocationEnabled = false;
  Set<Marker> _markers = {};
  List<dynamic> _hotels = [];
  CameraPosition? _initialPosition;
  String? selectedCity;
  double? cityLat;
  double? cityLng;
  double _radius = 500; // Default radius value
  bool _isSliderVisible = false;
  bool _isViewingCurrentLocation = true;
  double _compassHeading = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    // _listenToCompass();
  }

  // void _listenToCompass() {
  //   FlutterCompass.events?.listen((event) {
  //     if (event.heading != null) {
  //       setState(() {
  //         _compassHeading = event.heading!;
  //       });
  //     }
  //   });
  // }


  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return;
    }

    final locationData = await _location.getLocation();
    setState(() {
      userLat = locationData.latitude;
      userLng = locationData.longitude;
      _isLocationEnabled = true;
      _isViewingCurrentLocation = true; // Set flag for current location
      _initialPosition = CameraPosition(
        target: LatLng(userLat!, userLng!),
        zoom: 10.0,
      );
      selectedCity = null;
      cityLat = null;  // Clear city coordinates
      cityLng = null;
    });

    // Fetch hotels for the current location
    _fetchHotels(userLat: userLat, userLng: userLng);
  }


  Future<void> _fetchCityCoordinates(String city) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=AIzaSyD4_6anlN09mZ1H6hhnfryibQdAWfygUbo'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];
        setState(() {
          cityLat = lat;
          cityLng = lng;
          _isViewingCurrentLocation = false; // Set flag for city search
          _initialPosition = CameraPosition(
            target: LatLng(cityLat!, cityLng!),
            zoom: 12.0,
          );
        });

        // Animate the camera to the new city location
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(cityLat!, cityLng!),
              zoom: 12.0, // Adjust zoom level to fit the city view
            ),
          ),
        );

        // Fetch hotels for the selected city (using cityLat and cityLng)
        _fetchHotels(city: city);

      }
    }
  }


  Future<void> _fetchHotels({
    String? city,
    double? userLat,
    double? userLng,
    double? radius,
  }) async {
    String requestUrl;

    // Use radius from the slider if provided
    radius = radius ?? _radius; // Default to _radius if not passed

    if (city != null && city.isNotEmpty) {
      requestUrl = 'http://192.168.1.2:6386/api/hotels/search?city=$city&radius=10km'; // Set fixed radius for city
    } else if (userLat != null && userLng != null) {
      requestUrl = 'http://192.168.1.2:6386/api/hotels/search?userLat=$userLat&userLng=$userLng&radius=${radius / 1000}km';
    } else {
      print('Either city or current location coordinates are required');
      return;
    }

    try {
      final response = await http.get(Uri.parse(requestUrl));

      // Debug the response here
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _hotels = data['hotels'];
          _markers.clear(); // Clear previous markers
        });
        _addHotelMarkers(data['hotels']);
      } else {
        print('Error fetching hotels: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }


  void _addHotelMarkers(List hotels) async {
    Set<Marker> markers = {};

    final ByteData data = await rootBundle.load('assets/hotelmarker.png');
    final Uint8List resizedImage = await _resizeMarkerImage(data, 140, 140);
    BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(resizedImage);

    // Check if hotels are received and have valid coordinates
    for (var hotel in hotels) {
      final hotelLat = hotel['coordinates']['coordinates'][1];
      final hotelLng = hotel['coordinates']['coordinates'][0];

      if (hotelLat != null && hotelLng != null) {
        final hotelName = hotel['name'];
        final distance = hotel['distanceFromSearchLocation'];
        final pricedetails=hotel['priceDetails'];

        markers.add(
          Marker(
            markerId: MarkerId(hotelName),
            position: LatLng(hotelLat, hotelLng),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: hotelName,
              snippet: 'Distance: $distance',
            ),
          ),
        );
      } else {
        print('Invalid coordinates for hotel: $hotel');
      }
    }

    setState(() {
      _markers = markers; // Update the markers on the map
    });
  }

  Future<Uint8List> _resizeMarkerImage(ByteData data, int width,
      int height) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width, // Increased width
      targetHeight: height, // Increased height
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? resizedData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png);
    return resizedData!.buffer.asUint8List();
  }


  void _animateToHotel(double lat, double lng) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 17.0, // Adjust zoom level for closer view
        ),
      ),
    );
  }

  LinearGradient _getSliderGradient(double radius) {
    if (radius <= 3000) {
      // Gradient from red to yellow
      return LinearGradient(
        colors: [Colors.red, Colors.yellow],
        stops: [0.0, 1.0],
      );
    } else if (radius <= 7000) {
      // Gradient from green to blue
      return LinearGradient(
        colors: [Colors.green, Colors.blue],
        stops: [0.0, 1.0],
      );
    } else {
      // Gradient from blue to purple for higher radius
      return LinearGradient(
        colors: [Colors.blue, Colors.purple],
        stops: [0.0, 1.0],
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  backgroundColor: Colors.black,
      body: Material(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  _isLocationEnabled && _initialPosition != null
                      ?GoogleMap(
                    initialCameraPosition: _initialPosition!,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                     // mapController?.setMapStyle(_mapStyle); // Apply the style
                    },
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false, // Disable default zoom controls
                    markers: _markers,
                  )

                      : const Center(child: CircularProgressIndicator()),
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

                  // Positioned(
                  //   top: 300,
                  //   right: 5,
                  //   child: Transform.rotate(
                  //     angle: -math.pi / 180* _compassHeading, // Rotate compass dynamically
                  //     child: Container(
                  //       width: 49,
                  //       height: 50,
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         shape: BoxShape.circle,
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black26,
                  //             blurRadius: 8,
                  //             offset: Offset(0, 2),
                  //           ),
                  //         ],
                  //       ),
                  //       child: Icon(
                  //         Icons.navigation,
                  //         color: Colors.grey,
                  //         size: 30,
                  //       ),
                  //     ),
                  //   ),
                  // ),


                  Positioned(
                    top: 30,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final city = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchScreen()),
                            );
                            if (city != null) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('selectedCity', city);
                              setState(() {
                                selectedCity = city;
                              });
                              _fetchCityCoordinates(city);
                            }
                          },
                          child: AbsorbPointer(
                            child: Container(
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Colors.grey,  // Use grey color for the background
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: selectedCity ?? 'Search City.......',
                                  hintStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,  // Grey background color
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search, color: Colors.black),
                                    onPressed: () async {
                                      final city = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SearchScreen()),
                                      );
                                      if (city != null) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setString('selectedCity', city);
                                        setState(() {
                                          selectedCity = city;
                                        });
                                        _fetchCityCoordinates(city);
                                      }
                                    },
                                  ),
                                  prefixIcon: selectedCity != null
                                      ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.blueGrey),
                                    onPressed: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.remove('selectedCity');
                                      setState(() {
                                        selectedCity = null;
                                        cityLat = null;
                                        cityLng = null;
                                        _markers.clear();
                                        _hotels.clear();
                                        _initialPosition = null;
                                      });
                                      _initializeLocation();
                                    },
                                  )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 95,
                    left: 10,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSliderVisible = !_isSliderVisible;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 35.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                _isSliderVisible
                                    ? Icons.arrow_right
                                    : Icons.arrow_left,
                                color: Colors.white,
                                size: 35.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 60,
                    right: 20,
                    child: AnimatedOpacity(
                      opacity: (_isSliderVisible && _isViewingCurrentLocation) ? 1.0 : 0.0, // Only show slider for current location
                      duration: const Duration(milliseconds: 300),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 6.0,
                            decoration: BoxDecoration(
                              gradient: _getSliderGradient(_radius),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12.0,
                              ),
                              overlayColor: Colors.blueAccent.withOpacity(0.2),
                              thumbColor: Colors.white,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                            ),
                            child: Slider(
                              value: _radius,
                              min: 50,
                              max: 10000,
                              divisions: 199,
                              label: "${(_radius / 1000).toStringAsFixed(1)} km",
                              onChanged: (value) {
                                setState(() {
                                  _radius = value;
                                });

                                // Only fetch hotels when viewing current location
                                if (_isViewingCurrentLocation) {
                                  _fetchHotels(userLat: userLat, userLng: userLng, radius: _radius);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Positioned(
                    top: 335,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          size: 30,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () {
                          // Reset the selected city when current location is clicked
                          setState(() {
                            selectedCity = null;  // Clear the selected city in the search box
                          });

                          _fetchHotels(userLat: userLat, userLng: userLng);
                          if (userLat != null && userLng != null) {
                            mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(userLat!, userLng!),
                                  zoom: 16.0,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _hotels.isNotEmpty
                  ? Container(
                padding: const EdgeInsets.all(0.0),  // Optional padding around PageView
                // Add background color to the container
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.99),
                  itemCount: _hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _hotels[index];
                    return GestureDetector(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => HotelDetailsScreen(hotel: hotel),
    ),
    );
    },



                      child: Container( // Wrap the Card inside a Container
                        padding: const EdgeInsets.all(0.0), // Optional padding
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                          color: Colors.white, // Dark card background
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotel['name'],
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black, // Dark theme text color
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      const Divider(height: 10),
                                      // Row(
                                      //   children: [
                                      //     Icon(Icons.room,color:Colors.blue,size:20.0),
                                      //     const SizedBox(width:5.0),
                                      //     Expanded(child: Text(
                                      //       hotel['priceDetails']
                                      //     ))
                                      //   ],
                                      // )
                                      const SizedBox(height: 6.0),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, color: Colors.red, size: 22.0),
                                          const SizedBox(width: 6.0),
                                          Expanded(
                                            child: Text(
                                              hotel['address'],
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                color: Colors.black, // Dark theme text color
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 9.0),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, color: Colors.blue, size: 20.0),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            'Distance: ${hotel['distanceFromSearchLocation']}',
                                            style: TextStyle(
                                              fontSize: 11.0,
                                              color: Colors.black, // Dark theme text color
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: hotel['image'],
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(Icons.image, size: 50.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    final hotel = _hotels[index];
                    _animateToHotel(
                      hotel['coordinates']['coordinates'][1],
                      hotel['coordinates']['coordinates'][0],
                    );
                  },
                ),
              )
                  : const Center(child: Text('No hotels found', style: TextStyle(color: Colors.white))),
            ),


          ],
        ),
      ),
    );
  }
}