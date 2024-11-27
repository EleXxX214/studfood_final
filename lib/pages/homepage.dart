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
  final ValueNotifier<bool> isSearchBarOpenedNotifier = ValueNotifier(false);

  late Future<QuerySnapshot> _restaurantFuture;
  List<DocumentSnapshot> _restaurantList = [];

  @override
  void initState() {
    super.initState();
    _restaurantFuture = FirestoreService().getRestaurants().then((snapshot) {
      _restaurantList = snapshot.docs;
      return snapshot;
    });
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
    isSearchBarOpenedNotifier.dispose();
    super.dispose();
  }

  void toggleSearchBar() {
    isSearchBarOpenedNotifier.value = !isSearchBarOpenedNotifier.value;
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
      //floatingActionButton: FloatingActionButton(
      // backgroundColor: Colors.white,
      // foregroundColor: Colors.black,
      //  onPressed: () => Navigator.pushNamed(context, "MapPage"),
      //  child: const Icon(Icons.map),
      // ),
      drawer: const MyDrawer(),
      body: GestureDetector(
        onTap: () {
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
                ValueListenableBuilder<bool>(
                  valueListenable: isSearchBarOpenedNotifier,
                  builder: (context, isSearchBarOpened, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isSearchBarOpened
                          ? CustomSearchBar(
                              key: const ValueKey('searchBar'),
                              searchController: searchController,
                              searchFocus: searchFocus,
                              onSearchChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            )
                          : const SizedBox.shrink(),
                    );
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
                                  side: BorderSide.none,
                                  elevation: 3,
                                  shadowColor:
                                      const Color.fromARGB(255, 197, 43, 164),
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  selectedColor:
                                      const Color.fromARGB(255, 255, 205, 244),
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
                                  label: Text(
                                    filters[index].id.capitalize,
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 43, 191)),
                                  ),
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
                        future: _restaurantFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<DocumentSnapshot> restaurantList =
                                _restaurantList;

                            //-------------------------------------------
                            //              RESTAURANT SEARCH
                            //-------------------------------------------
                            if (searchQuery.isNotEmpty) {
                              restaurantList = restaurantList.where((doc) {
                                String name =
                                    (doc.data() as Map<String, dynamic>)['name']
                                        .toString()
                                        .toLowerCase();
                                return name.contains(searchQuery.toLowerCase());
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
                                          : 'assets/images/paper.webp',
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
