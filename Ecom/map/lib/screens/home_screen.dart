import 'package:flutter/material.dart';
import 'package:map/screens/map_screen.dart';
import 'package:map/screens/profile_screen.dart';
import 'package:map/screens/trip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    MapScreen(),
    TripScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Access the current theme
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ?? Colors.black,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ?? Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Trip",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
