import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? color;
  final TextStyle? textStyle;  // Added textStyle parameter

  const LinkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textStyle,  // Include this in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle?.copyWith(
          fontSize: textStyle?.fontSize ?? 18, // Default font size to 24 if not provided
          color: textStyle?.color ?? color ?? Colors.blue, // Default to blue if no color provided
        ) ?? TextStyle(
          fontSize: 18, // Default font size to 24 if no textStyle is provided
          color: color ?? Colors.blue, // Default color to blue if no color is provided
        ),
      ),
    );
  }
}
