import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference restaurants =
      FirebaseFirestore.instance.collection("restaurants");
}
