import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData customDarkTheme() {
    return ThemeData.dark().copyWith(
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ),
    );
  }
}
