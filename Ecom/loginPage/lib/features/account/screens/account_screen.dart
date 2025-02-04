// account_screen.dart
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  static const String routeName = '/account'; // Static route name

  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Screen'),
      ),
      body: Center(
        child: const Text(
          'This is the Account Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
