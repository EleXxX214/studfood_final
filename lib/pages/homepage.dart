import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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

Logger logger = Logger();

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String day = "";

    DateTime today = DateTime.now();
    var weekday = today.weekday;

    if (weekday == 7) day = "sunday";
    if (weekday == 1) day = "monday";
    if (weekday == 2) day = "tuesday";
    if (weekday == 3) day = "wednesday";
    if (weekday == 4) day = "thursday";
    if (weekday == 5) day = "friday";
    if (weekday == 6) day = "saturday";

    return Scaffold(
      appBar: const MyAppBar(),
      drawer: const MyDrawer(),
      body: GestureDetector(
        onTap: () {
          // Unfocus search field when tapping outside
          if (_searchFocus.hasFocus) {
            _searchFocus.unfocus();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Wyszukaj restauracje...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        searchQuery = "";
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> restaurantList = snapshot.data!.docs;

                    if (searchQuery.isNotEmpty) {
                      restaurantList = restaurantList.where((doc) {
                        String name =
                            (doc.data() as Map<String, dynamic>)['name']
                                .toString()
                                .toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();
                    }

                    return ListView.builder(
                      itemCount: restaurantList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = restaurantList[index];
                        String docId = document.id;
                        Map<String, dynamic> restaurant =
                            document.data() as Map<String, dynamic>;
                        updateDiscountCount(docId);
                        return CustomListTile(
                          name: restaurant['name'],
                          address: restaurant['address'],
                          discountsAmount: restaurant['discountCount'],
                          openingHour: restaurant[day] ?? "No data",
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
            ),
          ],
        ),
      ),
    );
  }
}
