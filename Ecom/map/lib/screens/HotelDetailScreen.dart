import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:map/providers/user_provider.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  _HotelDetailsScreenState createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
 // bool _isInWishlist = false;
  @override
  void initState() {
    super.initState();
   // _checkIfInWishlist();
  }

  // Check if hotel is in wishlist


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack for image and gradient overlay
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.hotel['image'],
                  height: 250.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.image, size: 150.0, color: Colors.white),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),

            // Padding for the rest of the content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0), // Left and Right padding applied here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name and Address with Wishlist and Share Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hotel Name
                      Row(
                        children: [
                          Icon(Icons.business_sharp, color: Colors.blue, size: 28.0), // Icon in front of the name
                          const SizedBox(width: 8.0), // Space between the icon and text
                          Text(
                            widget.hotel['name'],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),


                      // Wishlist Button
                      // Share Button
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.blue),
                        onPressed: () {
                          // Handle Share action
                          print('Hotel shared');
                        },

                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Address with Divider
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          widget.hotel['address'],
                          style: TextStyle(fontSize: 13.0, color: Colors.black),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1.0, color: Colors.grey), // Divider below the address
                  const SizedBox(height: 5.0),

                  // Facilities Section in a Box
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facilities',
                          style: TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10.0),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 2.0,
                          children: [
                            FacilityItem(icon: Icons.fitness_center, label: 'Gym'),
                            FacilityItem(icon: Icons.restaurant, label: 'Restaurant'),
                            FacilityItem(icon: Icons.local_parking, label: 'Parking'),
                            FacilityItem(icon: Icons.wifi, label: 'Free WiFi'),
                            FacilityItem(icon: Icons.pool, label: 'Swimming Pool'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Room Types & Prices in a Box
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room Types & Prices',
                          style: TextStyle(fontSize: 13.0, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10.0),
                        widget.hotel['priceDetails'] != null
                            ? Column(
                          children: List.generate(
                            widget.hotel['priceDetails'].length,
                                (index) {
                              var room = widget.hotel['priceDetails'][index];
                              return Card(
                                color: Colors.blueGrey,
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.hotel, color: Colors.orange, size: 28.0),
                                      const SizedBox(width: 15.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              room['type'],
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            Text(
                                              '₹${room['price']}',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Booking action
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Adjust button size
                                          minimumSize: Size(0, 30), // Ensure the button is not too large
                                        ),
                                        child: Text(
                                          'Book Now',
                                          style: TextStyle(fontSize: 12.0), // Smaller font size
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                            : Text(
                          'No price details available.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
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

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityItem({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.orange),
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueGrey,
    );
  }
}