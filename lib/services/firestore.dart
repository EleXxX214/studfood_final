import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference restaurants =
      FirebaseFirestore.instance.collection("restaurants");

  //Create

  Future<void> addRestaurant(
      String name, String address, num? discountsAmount, String description) {
    return restaurants.add({
      'name': name,
      'address': address,
      'discountsAmount': discountsAmount,
      'description': description,
    });
  }

  //Read

  Stream<QuerySnapshot> getRestaurants() {
    final restaurantStream = restaurants.orderBy('name').snapshots();
    return restaurantStream;
  }

//Update

  Future<void> updateRestaurant(String docID, String newName) {
    return restaurants.doc(docID).update({'name': newName});
  }

//Delete

  Future<void> deleteRestaurant(String docID) {
    return restaurants.doc(docID).delete();
  }
}
