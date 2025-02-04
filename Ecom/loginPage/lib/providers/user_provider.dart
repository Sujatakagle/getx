import 'package:ecom/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    password: '',
    address: '',
    type: '',
    cart: [],
  );

  // Getter to access the user
  User get user => _user;

  // Method to set User object directly from a User model
  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
