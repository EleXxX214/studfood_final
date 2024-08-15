import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData customTheme() {
    return ThemeData(
      primaryColor: const Color.fromRGBO(244, 233, 203, 1),
      scaffoldBackgroundColor: const Color.fromRGBO(244, 233, 203, 1),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
              const Color.fromRGBO(244, 233, 203, 1)),
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
