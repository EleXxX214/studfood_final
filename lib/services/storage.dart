// ignore_for_file: avoid_print

import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;

Future<String> downloadURL(String imageUrl) async {
  try {
    // Pobranie URL-a dla określonego pliku w Storage
    String downloadURL = await storage.ref(imageUrl).getDownloadURL();
    return downloadURL;
  } catch (e) {
    // Obsługa błędów
    print('Error getting download URL: $e');
    throw Exception(
        'Failed to get download URL'); // Rzuć wyjątek, aby FutureBuilder obsłużył błąd
  }
}
