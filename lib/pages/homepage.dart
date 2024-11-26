import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:studfood/components/main_appbar.dart';
import 'package:studfood/components/my_drawer.dart';
import 'package:studfood/components/custom_list_tile.dart';
import 'package:studfood/services/firestore.dart';
import 'package:studfood/components/custom_search_bar.dart';
import 'package:string_extensions/string_extensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Logger logger = Logger();
bool isSearchBarOpened = false;
List<String> selectedFilters = [];

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  final firestoreService = FirestoreService();

  Future<String> getLogoUrl(String restaurantId) async {
    String url = await FirebaseStorage.instance
        .ref('restaurants_photos/$restaurantId/logo.jpg')
        .getDownloadURL();
    return url;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                Padding(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: FilterChip(
                                  backgroundColor:
                                      const Color.fromARGB(255, 250, 245, 226),
                                  selectedColor:
                                      const Color.fromRGBO(255, 255, 190, 1),
                                  selected: selectedFilters.contains(filter),
                                  onSelected: (bool value) {
                                    setState(() {
                                      if (value) {
                                        selectedFilters.add(filter);
                                      } else {
                                        selectedFilters.remove(filter);
                                      }
                                    });
                                  },
                                  label: Text(filters[index].id.capitalize),
                                ),
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
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FutureBuilder<QuerySnapshot>(
                        future: FirestoreService().getRestaurants(),
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
                                DocumentSnapshot document =
                                    restaurantList[index];
                                String docId = document.id;
                                Map<String, dynamic> restaurant =
                                    document.data() as Map<String, dynamic>;

                                return FutureBuilder<String>(
                                  future: getLogoUrl(docId),
                                  builder: (context, logoSnapshot) {
                                    if (logoSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        height: 100,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    firestoreService.updateDiscountCount(docId);
                                    String logoUrl = logoSnapshot.data ?? '';

                                    return CustomListTile(
                                      name: restaurant['name'],
                                      address: restaurant['address'],
                                      discountCount:
                                          restaurant['discountCount'],
                                      openingHour: restaurant[day] ?? "No data",
                                      imageUrl: logoUrl.isNotEmpty
                                          ? logoUrl
                                          : 'https://via.placeholder.com/80',
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
                              },
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ],
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
