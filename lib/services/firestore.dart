import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference restaurants =
      FirebaseFirestore.instance.collection("restaurants");

  //Create

  Future<void> addRestaurant(String name, String address, num? discountsAmount,
      String description, String imageUrl) {
    return restaurants.add({
      'name': name,
      'address': address,
      'discountsAmount': discountsAmount,
      'description': description,
      'imageUrl': imageUrl,
    });
  }

//Read restaurant

  Future<DocumentSnapshot> getRestaurant(String docId) async {
    return await restaurants.doc(docId).get();
  }

  //Read restaurants

  Stream<QuerySnapshot> getRestaurants() {
    final restaurantStream = restaurants.orderBy('name').snapshots();
    return restaurantStream;
  }

//Update

  Future<void> updateRestaurant(String docID, String newName, String newAddress,
      num? newDiscountsAmount, String newDescription, String newImageUrl) {
    return restaurants.doc(docID).update({
      'name': newName,
      'address': newAddress,
      'discountsAmount': newDiscountsAmount,
      'description': newDescription,
      'imageUrl': newImageUrl,
    });
  }

//Delete

  Future<void> deleteRestaurant(String docID) {
    return restaurants.doc(docID).delete();
  }
}
