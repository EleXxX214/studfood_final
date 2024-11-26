import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference restaurants =
      FirebaseFirestore.instance.collection("restaurants");

  final CollectionReference filters =
      FirebaseFirestore.instance.collection("filters");

//____________________________
//---------------------
//    RESTAURANTS
//---------------------
//____________________________

//---------------------
// ADD_RESTAURANT
//---------------------

  Future<void> addRestaurant(
    String name,
    String address,
    num? discountsAmount,
    String description,
    String monday,
    String tuesday,
    String wednesday,
    String thursday,
    String friday,
    String saturday,
    String sunday,
  ) {
    return restaurants.add({
      'name': name,
      'address': address,
      'discountsAmount': discountsAmount,
      'description': description,
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
    });
  }

// --------------------------
//     READ RESTAURANT
// --------------------------

  Future<DocumentSnapshot> getRestaurant(String docId) async {
    return await restaurants.doc(docId).get();
  }

// --------------------------
//  READ RESTAURANTS
// --------------------------

  Future<QuerySnapshot> getRestaurants() {
    final restaurantFuture = restaurants.orderBy('name').get();
    return restaurantFuture;
  }

// --------------------------
//  UPDATE_RESTAURANTS
// --------------------------

  Future<void> updateRestaurant(
    String docID,
    String newName,
    String newAddress,
    num? newDiscountsAmount,
    String newDescription,
    String monday,
    String tuesday,
    String wednesday,
    String thursday,
    String friday,
    String saturday,
    String sunday,
  ) {
    return restaurants.doc(docID).update({
      'name': newName,
      'address': newAddress,
      'discountsAmount': newDiscountsAmount,
      'description': newDescription,
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
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
//  UPDATE DISCOUNT COUNT
// Aktualizuje liczbe znizek w głownym widoku
// --------------------------

  Future<void> updateDiscountCount(String docId) async {
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);

    QuerySnapshot discountsSnapshot =
        await restaurantDoc.collection('discounts').get();

    int discountCount = discountsSnapshot.size;

    await restaurantDoc.update({'discountCount': discountCount});
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

// --------------------------
//        ADD DISCOUNT
// --------------------------

  Future<void> addDiscount(String discount, String docId) {
    return restaurants
        .doc(docId)
        .collection("discounts")
        .add({'discount': discount});
  }

// --------------------------
//        GET DISCOUNTS
// Pobiera liste zniżek w widoku restauracji
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
// Pobiera liste zniżek w widoku admina > zniżki restauracji
// --------------------------

  Future<Map<String, dynamic>?> getDiscount(
      String docId, String discountId) async {
    DocumentReference discountDoc =
        restaurants.doc(docId).collection('discounts').doc(discountId);
    DocumentSnapshot discountSnapshot = await discountDoc.get();
    return discountSnapshot.data() as Map<String, dynamic>?;
  }

// --------------------------
//        GET FILTERS
// --------------------------

  Future<QuerySnapshot<Object?>> getFilters() async {
    QuerySnapshot filtersSnapshot = await filters.get();
    return filtersSnapshot;
  }
}
