import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studfood/components/custom_theme.dart';
import 'package:studfood/firebase_options.dart';
import 'package:studfood/pages/homepage.dart';
//import 'components/custom_theme.dart';
import 'package:studfood/pages/restaurantpage.dart';
import 'package:studfood/pages/adminpage.dart';
import 'package:studfood/pages/mappage.dart';
import 'package:studfood/pages/discountspage.dart';
import 'package:studfood/pages/contactpage.dart';
import 'package:studfood/pages/photopage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:studfood/pages/suggestpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.customTheme(),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'HomePage':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case 'RestaurantPage':
            final String restaurantId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => RestaurantPage(restaurantId: restaurantId),
            );
          case 'AdminPage':
            return MaterialPageRoute(builder: (context) => const AdminPage());
          case 'PhotoPage':
            final String docId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (context) => PhotoPage(docId: docId));
          case 'MapPage':
            return MaterialPageRoute(builder: (context) => const MapPage());
          case 'DiscountsPage':
            final String docId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => DiscountsPage(
                docId: docId,
              ),
            );
          case "ContactPage":
            return MaterialPageRoute(builder: (context) => const ContactPage());
          case "SuggestPage":
            return MaterialPageRoute(builder: (context) => const SuggestPage());
          default:
            return null;
        }
      },
    );
  }
}
