import 'package:flutter/material.dart';

import 'screens/about_screen.dart';

//import 'screens/home_screen.dart';
import 'screens/about_screen.dart';

// Your theme if needed

void main() {
  runApp(
    const MyApp(),

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Finder',
      // Custom dark theme if you have defined it
      themeMode: ThemeMode.system, // Automatically adjusts based on system theme
        home: const AboutScreen() // Initial route when the app launches

    );
  }
}
