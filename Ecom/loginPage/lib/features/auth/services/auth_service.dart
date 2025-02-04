import 'dart:convert';
import 'package:ecom/common/widgets/bottom_bar.dart';
import 'package:ecom/constants/error_handling.dart';
import 'package:ecom/constants/global_variables.dart';
import 'package:ecom/constants/utils.dart';
import 'package:ecom/models/user.dart';
import 'package:ecom/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        address: '',
        type: '',
        cart: [], // Initialize with an empty cart
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Sign in user (without token)
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          // Parse the response body into a User object
          User user = User.fromJson(res.body);

          // Save user data (User object) to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Set user data in the provider using the correct method
          Provider.of<UserProvider>(context, listen: false).setUserFromModel(user);

          // Store user data (as JSON string) in SharedPreferences for session-based auth
          await prefs.setString('user', res.body);

          // Navigate to the home screen (after successful login)
          Navigator.pushNamedAndRemoveUntil(
            context,
            BottomBar.routeName,
                (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Get user data (session-based)
  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Retrieve the user data from SharedPreferences
      String? userJson = prefs.getString('user');

      if (userJson != null) {
        // Convert stored JSON back into a User object
        var user = User.fromJson(jsonDecode(userJson));

        // Use provider to set user data in the app
        Provider.of<UserProvider>(context, listen: false).setUserFromModel(user);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Log out user (clear session)
  void logOutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove user data from SharedPreferences to clear session
    await prefs.remove('user');

    // Navigate to the login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',  // Update with your actual login route name
          (route) => false,
    );
  }
}
