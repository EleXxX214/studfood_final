import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:studfood/components/main_appbar.dart';
import 'package:studfood/components/my_drawer.dart';
import 'package:studfood/components/custom_list_tile.dart';
import 'package:studfood/services/firestore.dart';

import 'package:studfood/components/custom_search_bar.dart';

import 'package:string_extensions/string_extensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

bool isSearchBarOpened = false;

Logger logger = Logger();

List<String> selectedFilters = [];

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  final ScrollController _scrollController = ScrollController();
  bool _showFilters = true;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.offset > 50 && _showFilters) {
      setState(() {
        _showFilters = false;
      });
    } else if (_scrollController.offset <= 50 && !_showFilters) {
      setState(() {
        _showFilters = true;
      });
    }
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

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  void toggleSearchBar() {
    setState(() {
      isSearchBarOpened = !isSearchBarOpened;
      if (!isSearchBarOpened) {
        searchController.clear();
        searchQuery = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String day = "";
    FirestoreService().getFilters();

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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: MyAppBar(onSearchButtonPressed: toggleSearchBar),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, "MapPage"),
        child: const Icon(Icons.map),
      ),
      drawer: const MyDrawer(),
      body: GestureDetector(
        onTap: () {
          // Unfocus search field when tapping outside
          if (searchFocus.hasFocus) {
            searchFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                //-------------------------------------------
                //                 SEARCH BAR
                //-------------------------------------------
                if (isSearchBarOpened)
                  CustomSearchBar(
                    searchController: searchController,
                    searchFocus: searchFocus,
                    onSearchChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),

                //-------------------------------------------
                //            FOOD FILTER LIST
                //-------------------------------------------
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showFilters ? 50 : 0,
                  child: AnimatedOpacity(
                      opacity: _showFilters ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                            height: 50,
                            child: FutureBuilder<QuerySnapshot>(
                              future: FirestoreService().getFilters(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final filters = snapshot.data!.docs;
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filters.length,
                                    itemBuilder: (context, index) {
                                      final filter = filters[index].id;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: FilterChip(
                                          backgroundColor: Color.fromARGB(
                                              255, 255, 255, 255),
                                          selectedColor: const Color.fromRGBO(
                                              255, 255, 190, 1),
                                          selected:
                                              selectedFilters.contains(filter),
                                          onSelected: (bool value) {
                                            setState(() {
                                              if (value) {
                                                selectedFilters.add(filter);
                                              } else {
                                                selectedFilters.remove(filter);
                                              }
                                            });
                                          },
                                          label: Text(
                                              filters[index].id.capitalize),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            )),
                      )),
                ),
                //-------------------------------------------

                //           BACKGROUND IMAGE

                //           BACKGROUND RESTAURANT LIST IMAGE

                //-------------------------------------------
                Expanded(
                  child: Container(
                    color: Color.fromARGB(
                        255, 255, 255, 255), // Zmień na dowolny kolor
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirestoreService().getRestaurants(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<DocumentSnapshot> restaurantList =
                              snapshot.data!.docs;
                          //-------------------------------------------
                          //              RESTAURANT SEARCH
                          //-------------------------------------------
                          if (searchQuery.isNotEmpty) {
                            restaurantList = restaurantList.where((doc) {
                              String name =
                                  (doc.data() as Map<String, dynamic>)['name']
                                      .toString()
                                      .toLowerCase();
                              return name.contains(searchQuery);
                            }).toList();
                          }
                          //-------------------------------------------
                          //              FOOD FILTERING
                          //-------------------------------------------
                          if (selectedFilters.isNotEmpty) {
                            restaurantList = restaurantList.where((doc) {
                              String? filter = (doc.data()
                                  as Map<String, dynamic>)['filter1'];

                              // Sprawdzenie, czy filter nie jest null
                              if (filter != null) {
                                return selectedFilters.contains(filter);
                              }
                              return false;
                            }).toList();
                          }

                          //-------------------------------------------
                          //        RESTAURANT TILES BUILDER
                          //-------------------------------------------

                          return ListView.builder(
                            itemCount: restaurantList.length,
                            controller: _scrollController,
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
