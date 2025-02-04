import 'package:flutter/material.dart';
import 'mapscreen.dart';  // Make sure the file is correctly imported

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),  // Setting MapScreen as the home widget
    );
  }
}
