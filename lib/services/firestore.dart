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

  Future<Map<String, dynamic>?> getDiscount(
      String docId, String discountId) async {
    DocumentReference discountDoc = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(docId)
        .collection('discounts')
        .doc(discountId);

    DocumentSnapshot discountSnapshot = await discountDoc.get();
    return discountSnapshot.data() as Map<String, dynamic>?;
  }

  Future<int> getDiscountCount(String docId) async {
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    CollectionReference discounts = restaurantDoc.collection('discounts');
    QuerySnapshot discountsSnapshot = await discounts.get();
    return discountsSnapshot.size;
  }

  Future<void> updateDiscountCount(String docId) async {
    int discountCount = await getDiscountCount(docId);
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    await restaurantDoc.update({'discountCount': discountCount});
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

// --------------------------
//        DISCOUNTS
// --------------------------
}
