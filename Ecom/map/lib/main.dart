import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map/screens/welcome_screen.dart';
import 'package:map/theme/app_theme.dart'; // Import the AppTheme
import 'package:map/providers/user_provider.dart'; // Import your UserProvider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(), // Initialize UserProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Apply the light theme from AppTheme
        initialRoute: '/',
        routes: {
          '/': (context) => WelcomeScreen(),
        },
      ),
    );
  }
}
