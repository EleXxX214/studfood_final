import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;

Future<String> downloadURLExample() async {
  String downloadURL = await storage
      .ref('gs://studfood-c8e12.appspot.com/filthy.png')
      .getDownloadURL();
  return downloadURL;
}
