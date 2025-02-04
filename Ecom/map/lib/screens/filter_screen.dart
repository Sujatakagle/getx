import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: const Text('Filter Options'),
        backgroundColor: Colors.blue, // Optional: Change the AppBar color if needed
      ),
      body: const Center(
        child: Placeholder(), // Replace with your actual filter content
      ),
    );
  }
}
