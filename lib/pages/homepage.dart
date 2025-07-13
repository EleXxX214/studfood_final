import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  List<DocumentSnapshot> _filteredRestaurantList = [];
  List<String> selectedFilters = [];

  // Dodane do paginacji i optymalizacji
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    preloadFuture = preloadData();
  }

  Future<void> preloadData() async {
    try {
      QuerySnapshot snapshot =
          await FirestoreService().getRestaurantsPaginated(limit: _perPage);
      _restaurantList = snapshot.docs;
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == _perPage;
      _applyFilters();
    } catch (e) {
      logger.e('Error loading data: $e');
    }
  }

  Future<void> loadMoreRestaurants() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    try {
      QuerySnapshot snapshot = await FirestoreService().getRestaurantsPaginated(
        limit: _perPage,
        startAfter: _lastDocument,
      );
      if (snapshot.docs.isNotEmpty) {
        _restaurantList.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _perPage;
        _applyFilters();
      } else {
        _hasMore = false;
      }
    } catch (e) {
      logger.e('Error loading more: $e');
    }
    _isLoadingMore = false;
  }

  void _applyFilters() {
    setState(() {
      _filteredRestaurantList = _restaurantList.where((document) {
        final restaurant = document.data() as Map<String, dynamic>;
        final matchesSearch = searchQuery.isEmpty ||
            restaurant['name'].toString().toLowerCase().contains(searchQuery);
        final matchesFilter = selectedFilters.isEmpty ||
            selectedFilters.contains(restaurant['filter1']);
        return matchesSearch && matchesFilter;
      }).toList();
    });
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
        _applyFilters();
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
                      searchQuery = value.toLowerCase();
                      _applyFilters();
                    },
                  ),
                //-------------------------------------------
                //            FOOD FILTER LIST
                //-------------------------------------------
                FoodFilter(
                  selectedFilters: selectedFilters,
                  onFilterChanged: (List<String> newFilters) {
                    selectedFilters = newFilters;
                    _applyFilters();
                  },
                ),
                //-------------------------------------------
                //            RESTAURANT LIST
                //-------------------------------------------
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredRestaurantList.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document =
                          _filteredRestaurantList[index];
                      String docId = document.id;
                      Map<String, dynamic> restaurant =
                          document.data() as Map<String, dynamic>;
                      return CustomListTile(
                        docId: docId,
                        name: restaurant['name'],
                        address: restaurant['address'],
                        discountCount: restaurant['discountCount'],
                        openingHour: restaurant['openingHour'] ?? 'No data',
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
