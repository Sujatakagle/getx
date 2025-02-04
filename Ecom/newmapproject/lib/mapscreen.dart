import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = LatLng(12.9716, 77.5946); // Bengaluru coordinates
  final Set<Marker> _markers = {};

  // Track the number of times permission has been denied
  int _permissionDeniedCount = 0;

  @override
  void initState() {
    super.initState();
    // Initially check for permission when the app starts
    _checkPermissionAndInitializeMap();
  }

  // Function to request location permission
  Future<void> _requestLocationPermission() async {
    // Request permission for location
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted, you can show the map
      print("Location permission granted");
    } else if (status.isDenied) {
      // If permission is denied, show the request dialog again
      print("Location permission denied");
      _permissionDeniedCount++;
      _showPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, recheck and handle appropriately
      print("Location permission permanently denied.");
      _permissionDeniedCount++;
      _showPermissionDialog();
    }
  }

  // Check the permission status and request if not granted
  Future<void> _checkPermissionAndInitializeMap() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      // If permission is granted, show the map
      print("Location permission already granted");
    } else if (status.isDenied) {
      // If permission is not granted, request it
      await _requestLocationPermission();
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, show the dialog again
      _showPermissionDialog();
    }
  }

  // Show a dialog when permission is denied
  void _showPermissionDialog() {
    // Show dialog only if the user has denied permission 0 or 1 times
    if (_permissionDeniedCount <= 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Permission'),
          content: Text('This app requires location access to display the map.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Re-request the permission when the user clicks 'Retry'
                await _requestLocationPermission();
              },
              child: Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Close the dialog if the user doesn't want to enable location
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      // After the second denial, ask the user to enable it manually
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Denied'),
          content: Text('You have denied location permission multiple times. Please enable it from the settings to continue using this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Open app settings if permission is permanently denied
                openAppSettings();
              },
              child: Text('Go to Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map Example"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12.0,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          PermissionStatus status = await Permission.location.status;

          if (status.isGranted) {
            // Permission granted, proceed to add marker or interact with the map
            _addMarker();
          } else if (status.isDenied) {
            // If permission is denied, show the dialog again
            _showPermissionDialog();
          } else if (status.isPermanentlyDenied) {
            // If permission is permanently denied, show a message or handle it
            _showPermissionDialog();
          }
        },
        child: Icon(Icons.add_location),
      ),
    );
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('new-marker'),
          position: LatLng(12.9716, 77.5946),  // Bengaluru coordinates
          infoWindow: InfoWindow(
            title: 'Bengaluru',
            snippet: 'Welcome to Bengaluru!',
          ),
        ),
      );
    });
  }
}
