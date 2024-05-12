import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studfood/firebase_options.dart';
import 'package:studfood/pages/homepage.dart';
import 'components/custom_theme.dart';
import 'package:studfood/pages/restaurantpage.dart';
import 'package:studfood/pages/adminpage.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
          'RestaurantPage': (context) => const RestaurantPage(
                restaurantId: '',
              ),
          'AdminPage': (context) => const AdminPage(),
        });
  }
}
