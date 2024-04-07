import 'package:flutter/material.dart';
import 'package:studfood/pages/homepage.dart';
import 'components/customtheme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.customDarkTheme(),
        home: const HomePage(),
        routes: {
          'HomePage': (context) => const HomePage(),
        });
  }
}
