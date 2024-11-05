import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData customTheme() {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 255, 255, 255),
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
              const Color.fromARGB(255, 252, 252, 251)),
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
