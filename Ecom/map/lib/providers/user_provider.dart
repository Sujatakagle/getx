import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map/core/usermodel.dart'; // Import the SignInResponse class

class UserProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isDarkTheme = false;
  String _userId = '';
  String _username = '';
  String _email = '';
  String _phoneNumber = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isDarkTheme => _isDarkTheme;
  String get userId => _userId;
  String get username => _username;
  String get email => _email;
  String get phoneNumber => _phoneNumber;

  // Constructor to check if user is authenticated on app launch
  UserProvider() {
    _loadUserData();
  }

  // Load user authentication status from SharedPreferences
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId') ?? '';
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    _phoneNumber = prefs.getString('phoneNumber') ?? '';
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }

  // Toggle Theme
  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }

  // Login Function
  Future<String> login(String emailOrPhone, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.2:6386/api/auth/signin'),
      body: json.encode({
        'emailOrPhone': emailOrPhone,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Parse the response
      final SignInResponse signInResponse = SignInResponse.fromJson(json.decode(response.body));

      // Store data in SharedPreferences
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isAuthenticated', true);
      prefs.setString('userId', signInResponse.userId);
      prefs.setString('username', signInResponse.username);
      prefs.setString('email', signInResponse.email);
      prefs.setString('phoneNumber', signInResponse.phoneNumber);

      // Update the local variables
      _userId = signInResponse.userId;
      _username = signInResponse.username;
      _email = signInResponse.email;
      _phoneNumber = signInResponse.phoneNumber;

      notifyListeners();
      return "success";
    } else {
      return "error";
    }
  }

  // Logout Function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isAuthenticated');
    prefs.remove('userId');
    prefs.remove('username');
    prefs.remove('email');
    prefs.remove('phoneNumber');
    _isAuthenticated = false;
    notifyListeners();
  }
}
