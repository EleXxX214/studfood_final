import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studfood/components/main_appbar.dart';
import 'package:studfood/components/my_drawer.dart';
import 'package:studfood/components/custom_list_tile.dart';
import 'package:studfood/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<int> getDiscountCount(String docId) async {
    // ----------------------------------
    // Get discounts collection reference
    // ----------------------------------
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    CollectionReference discounts = restaurantDoc.collection('discounts');
    QuerySnapshot discountsSnapshot = await discounts.get();
    return discountsSnapshot.size;
  }

  // ----------------------------------
  // Update discount count
  // ----------------------------------
  Future<void> updateDiscountCount(String docId) async {
    int discountCount = await getDiscountCount(docId);
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    await restaurantDoc.update({'discountCount': discountCount});
  }

  // ----------------------------------
  //               BUILD
  // ----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      drawer: const MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List restaurantList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: restaurantList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = restaurantList[index];
                String docId = document.id;
                Map<String, dynamic> restaurant =
                    document.data() as Map<String, dynamic>;
                // Update discount count
                updateDiscountCount(docId);
                // ----------------------------------
                //             LIST TILE
                // ----------------------------------
                return CustomListTile(
                  name: restaurant['name'],
                  address: restaurant['address'],
                  discountsAmount: restaurant['discountCount'],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'RestaurantPage',
                      arguments: docId,
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
