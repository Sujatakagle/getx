import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const SimpleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isLoading
              ? Colors.grey
              : Theme.of(context).primaryColor, // Default color
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? SpinKitThreeBounce(
            color: Colors.white,
            size: 20.0, // You can adjust the size
          )
              : Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
