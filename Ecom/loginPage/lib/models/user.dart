import 'dart:convert';

class User {
  String id;
  String name;
  String email;
  String password;
  String address;
  String type;
  List<dynamic> cart;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.type,
    required this.cart,
  });

  // Converts a JSON map into a User object
  factory User.fromJson(String str) {
    final jsonData = json.decode(str);
    return User(
      id: jsonData['id'] ?? '', // Default to empty string if null
      name: jsonData['name'] ?? '', // Default to empty string if null
      email: jsonData['email'] ?? '', // Default to empty string if null
      password: jsonData['password'] ?? '', // Default to empty string if null
      address: jsonData['address'] ?? '', // Default to empty string if null
      type: jsonData['type'] ?? '', // Default to empty string if null
      cart: jsonData['cart'] ?? [], // Default to empty list if null
    );
  }

  // Converts a User object into a JSON string
  String toJson() {
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'type': type,
      'cart': cart,
    };
    return json.encode(data);
  }
}
