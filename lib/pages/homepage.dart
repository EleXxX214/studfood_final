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
  late Future<void> preloadFuture; // Future do ładowania danych
  List<DocumentSnapshot> _restaurantList = [];
  final Map<String, String> logoUrls = {}; // Cache URL-i logo

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
