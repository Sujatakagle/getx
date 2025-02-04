// cart_screen.dart
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart'; // Static route name

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Screen'),
      ),
      body: Center(
        child: const Text(
          'Your Cart is Empty!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
