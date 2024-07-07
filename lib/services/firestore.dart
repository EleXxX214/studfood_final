import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference restaurants =
      FirebaseFirestore.instance.collection("restaurants");
//____________________________
//---------------------
//    RESTAURANTS
//---------------------
//____________________________

//---------------------
// ADD_RESTAURANT
//---------------------

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

  Future<void> addDiscount(String discount, String docId) {
    return restaurants
        .doc(docId)
        .collection("discounts")
        .add({'discount': discount});
  }

// --------------------------
//     READ RESTAURANT
// --------------------------

  Future<DocumentSnapshot> getRestaurant(String docId) async {
    return await restaurants.doc(docId).get();
  }

// --------------------------
//  READ RESTAURANTS STREAM
// --------------------------

  Stream<QuerySnapshot> getRestaurants() {
    final restaurantStream = restaurants.orderBy('name').snapshots();
    return restaurantStream;
  }

// --------------------------
//  UPDATE_RESTAURANTS
// --------------------------

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

  Future<void> updateDiscount(
      String docId, String discountId, String discount) {
    return restaurants
        .doc(docId)
        .collection('discounts')
        .doc(discountId)
        .update({'discount': discount});
  }

// --------------------------
//  DELETE_RESTAURANTS
// --------------------------

  Future<void> deleteRestaurant(String docID) {
    return restaurants.doc(docID).delete();
  }

  Future<void> deleteDiscount(String docId, String discountId) {
    return restaurants
        .doc(docId)
        .collection("discounts")
        .doc(discountId)
        .delete();
  }
//____________________________
// --------------------------
//        DISCOUNTS
// --------------------------
//____________________________

// --------------------------
//        GET DISCOUNTS
// --------------------------

  Future<QuerySnapshot<Object?>> getDiscounts(String docId) async {
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    CollectionReference discounts = restaurantDoc.collection('discounts');
    QuerySnapshot discountsSnapshot = await discounts.get();
    return discountsSnapshot;
  }

// --------------------------
//        GET DISCOUNT
// --------------------------

  Future<Map<String, dynamic>?> getDiscount(
      String docId, String discountId) async {
    DocumentReference discountDoc =
        restaurants.doc(docId).collection('discounts').doc(discountId);
    DocumentSnapshot discountSnapshot = await discountDoc.get();
    return discountSnapshot.data() as Map<String, dynamic>?;
  }

// --------------------------
//    GET DISCOUNT COUNT
// --------------------------

  Future<int> getDiscountCount(String docId) async {
    DocumentReference restaurantDoc = restaurants.doc(docId);
    CollectionReference discounts = restaurantDoc.collection('discounts');
    QuerySnapshot discountsSnapshot = await discounts.get();
    return discountsSnapshot.size;
  }

// --------------------------
//  UPADTE DISCOUNTS COUNT
// --------------------------

  Future<void> updateDiscountCount(String docId) async {
    int discountCount = await getDiscountCount(docId);
    DocumentReference restaurantDoc = restaurants.doc(docId);
    await restaurantDoc.update({'discountCount': discountCount});
  }
}
