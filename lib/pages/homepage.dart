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

                return CustomListTile(
                    name: restaurant['name'],
                    address: restaurant['address'],
                    discountsAmount: restaurant['discountsAmount'],
                    onTap: () {
                      Navigator.pushNamed(context, "RestaurantPage",
                          arguments: {
                            'restaurantId': docId,
                          });
                    });
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
