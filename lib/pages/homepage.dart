import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:studfood/components/main_appbar.dart';
import 'package:studfood/components/my_drawer.dart';
import 'package:studfood/components/custom_list_tile.dart';
import 'package:studfood/components/food_filter.dart';
import 'package:studfood/services/firestore.dart';
import 'package:studfood/components/custom_search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Logger logger = Logger();
bool isSearchBarOpened = false;

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late Future<void> preloadFuture; // Future do ładowania danych
  List<DocumentSnapshot> _restaurantList = [];
  final Map<String, String> logoUrls = {}; // Cache URL-i logo
  List<String> selectedFilters = []; // Dodajemy to do stanu

  @override
  void initState() {
    super.initState();
    preloadFuture = preloadData();
  }

  Future<void> preloadData() async {
    try {
      QuerySnapshot snapshot = await FirestoreService().getRestaurants();
      _restaurantList = snapshot.docs;

      for (var restaurant in _restaurantList) {
        String docId = restaurant.id;

        if (!logoUrls.containsKey(docId)) {
          try {
            String url = await FirebaseStorage.instance
                .ref('restaurants_photos/$docId/logo.jpg')
                .getDownloadURL();
            logoUrls[docId] = url;
          } catch (e) {
            logger.e('Failed to load logo for $docId: $e');
            logoUrls[docId] = 'assets/images/paper.webp'; // Domyślny obrazek
          }
        }
      }
      setState(() {}); // Odśwież widok po załadowaniu
    } catch (e) {
      logger.e('Error loading data: $e');
    }
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: MyAppBar(onSearchButtonPressed: toggleSearchBar),
      drawer: const MyDrawer(),
      body: GestureDetector(
        onTap: () {
          if (searchFocus.hasFocus) {
            searchFocus.unfocus();
          }
        },
        child: FutureBuilder<void>(
          future: preloadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
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
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                //-------------------------------------------
                //            FOOD FILTER LIST
                //-------------------------------------------
                FoodFilter(
                  selectedFilters: selectedFilters,
                  onFilterChanged: (List<String> newFilters) {
                    setState(() {
                      selectedFilters = newFilters;
                    });
                  },
                ),
                //-------------------------------------------
                //            RESTAURANT LIST
                //-------------------------------------------
                Expanded(
                  child: ListView.builder(
                    itemCount: _restaurantList.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = _restaurantList[index];
                      String docId = document.id;
                      Map<String, dynamic> restaurant =
                          document.data() as Map<String, dynamic>;

                      // Filtracja wyników po wyszukiwarce
                      if (searchQuery.isNotEmpty &&
                          !restaurant['name']
                              .toString()
                              .toLowerCase()
                              .contains(searchQuery)) {
                        return const SizedBox.shrink();
                      }

                      // Filtracja po wybranych filtrach
                      if (selectedFilters.isNotEmpty &&
                          !selectedFilters.contains(restaurant['filter1'])) {
                        return const SizedBox.shrink();
                      }

                      // Pobierz URL logo z cache
                      String logoUrl =
                          logoUrls[docId] ?? 'assets/images/paper.webp';

                      return CustomListTile(
                        name: restaurant['name'],
                        address: restaurant['address'],
                        discountCount: restaurant['discountCount'],
                        openingHour: restaurant['openingHour'] ?? 'No data',
                        imageUrl: logoUrl,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            'RestaurantPage',
                            arguments: docId,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
