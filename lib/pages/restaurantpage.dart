import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studfood/components/custom_appbar.dart';
import 'package:studfood/services/firestore.dart';

class RestaurantPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantPage({super.key, required this.restaurantId});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late Future<Map<String, dynamic>> _restaurantFuture;

  Future<Map<String, dynamic>> getRestaurantData(String docId) async {
    DocumentSnapshot<Object?> restaurantSnapshot =
        await FirestoreService().getRestaurant(docId);
    Map<String, dynamic> restaurantData =
        restaurantSnapshot.data() as Map<String, dynamic>;
    return restaurantData;
  }

  @override
  void initState() {
    super.initState();
    print("Restaurant ID: ${widget.restaurantId}");
    if (widget.restaurantId.isNotEmpty) {
      _restaurantFuture = getRestaurantData(widget.restaurantId);
    } else {
      _restaurantFuture = Future.error('restaurantId is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
          }
          Map<String, dynamic> restaurantData = snapshot.data ?? {};

          return Column(
            children: [
              // Title
              Row(
                children: [
                  const Spacer(),
                  Text(
                    restaurantData['name'] ?? "",
                    style: const TextStyle(fontSize: 30),
                  ),
                  const Spacer(),
                ],
              ),
              // Divider
              const Divider(
                indent: 30,
                endIndent: 30,
                color: Colors.white,
              ),
              // Image
              SizedBox(
                width: 450,
                height: 200,
                child: Image.network(restaurantData['imageUrl'] ?? ""),
              ),
              // Buttons
              Row(
                children: [
                  const Spacer(),
                  //Heart
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                    iconSize: 80,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  //Menu
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu_book),
                    iconSize: 80,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  //Navigation
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.near_me),
                    iconSize: 80,
                    color: Colors.white,
                  ),
                  const Spacer(),
                ],
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 35),
                        const SizedBox(width: 10),
                        Text(
                          restaurantData['address'] ?? "",
                          style: const TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 35),
                        const SizedBox(width: 10),
                        Text(
                          restaurantData['openingHours'] ?? "",
                          style: const TextStyle(fontSize: 20),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const Divider(
                indent: 30,
                endIndent: 30,
                color: Colors.white,
              ),
            ],
          );
        },
      ),
    );
  }
}
