import 'package:flutter/material.dart';
import 'package:ecomweb/logic/services/app_colors.dart';

class TextStyles {
  static TextStyle heading1(BuildContext context) => TextStyle(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.lightText,
    fontSize: 48,
  );

  static TextStyle heading2(BuildContext context) => TextStyle(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.lightText,
    fontSize: 32,
  );

  static TextStyle heading3(BuildContext context) => TextStyle(   // Added heading3
    fontWeight: FontWeight.bold,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.lightText,
    fontSize: 24,
  );

  static TextStyle body1(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.normal,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkText
          : AppColors.lightText,
      fontSize: 18,
    );
  }

  static TextStyle body2(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.normal,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkText
          : AppColors.lightText,
      fontSize: 18,
    );
  }
}
