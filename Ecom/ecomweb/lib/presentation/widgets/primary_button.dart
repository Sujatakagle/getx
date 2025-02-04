import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Ensure this import if using CupertinoButton
import 'package:ecomweb/core/ui.dart';
import 'package:ecomweb/logic/services/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme's primary color or fallback to passed color
    Color buttonColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        onPressed: onPressed,
        color: buttonColor, // Use the dynamic button color
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary, // Text color on primary
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}