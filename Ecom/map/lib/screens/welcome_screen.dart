import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the LoginScreen instead of AboutScreen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
      // Navigate to LoginScreen after loading instead of AboutScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme data
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Set background color according to the theme
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor, // Set app bar background according to the theme
        iconTheme: theme.appBarTheme.iconTheme, // Apply app bar icon theme
        titleTextStyle: theme.appBarTheme.titleTextStyle, // Apply app bar title style
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enlarged Image (Use your hotel image here)
              Image.asset(
                'assets/map.png', // Replace with your map or logo image
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              // Welcome Text
              Text(
                "Welcome",
                style: theme.textTheme.headlineLarge, // Apply headlineLarge from the theme
              ),
              const SizedBox(height: 20),
              // Circular Progress Indicator
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 10),
              Text(
                "Loading...",
                style: theme.textTheme.bodyLarge, // Apply bodyLarge from the theme
              ),
            ],
          )
              : Container(), // Empty container while loading
        ),
      ),
    );
  }
}
