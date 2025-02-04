import 'package:ecom/common/widgets/bottom_bar.dart';
import 'package:ecom/constants/global_variables.dart';
import 'package:ecom/features/auth/screens/auth_screen.dart';
import 'package:ecom/features/auth/services/auth_service.dart';
import 'package:ecom/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom/models/user.dart';
import 'router.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => UserProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  // Method to check user session in SharedPreferences
  void _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      // If user data is available in SharedPreferences, set it in the provider
      Provider.of<UserProvider>(context, listen: false).setUserFromModel(User.fromJson(userJson));
    }

    setState(() {
      _isLoading = false; // Stop loading once session check is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amazon Clone',

      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: GlobalVariables.secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        useMaterial3: true, // can remove this line
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while checking session
          : Provider.of<UserProvider>(context).user.id.isNotEmpty
          ? (Provider.of<UserProvider>(context).user.type == 'user'
          ? const BottomBar()
          : Container()) // Placeholder for AdminScreen
          : const AuthScreen(), // Navigate to AuthScreen if no user data
    );
  }
}
