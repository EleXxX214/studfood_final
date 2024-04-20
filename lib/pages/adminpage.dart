import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';
import 'package:studfood/components/custom_appbar.dart';
import 'package:studfood/services/firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // --------------------
  //  TextControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final discountsAmountController = NumberEditingTextController.integer();

// --------------------
//  FirestoreService
  final FirestoreService firestoreService = FirestoreService();

// --------------------
//       openAddBox
  void openAddBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docID == null ? "Add restaurant" : "Update restaurant"),
        content: TextField(
          controller: nameController,
        ),
        actions: [
          IconButton(
            //Jeżeli nie dostaniemy docID to dodajemy, w przeciwnym przypadku zaktualizujemy
            onPressed: () {
              if (docID == null) {
                firestoreService.addRestaurant(
                  nameController.text,
                  addressController.text,
                  discountsAmountController.number,
                  descriptionController.text,
                );
              } else {
                firestoreService.updateRestaurant(docID, nameController.text);
              }

              nameController.clear();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  //  openAddBox
  // --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => openAddBox(), child: const Icon(Icons.add)),
      appBar: const CustomAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List restaurantList = snapshot.data!.docs;

            // --------------------
            //    ListView builder

            return ListView.builder(
              itemCount: restaurantList.length,
              itemBuilder: (context, index) {
                // --------------------
                //Getting restaurant id

                DocumentSnapshot document = restaurantList[index];
                String docId = document.id;

                // --------------------
                //Getting restaurant parameters

                Map<String, dynamic> restaurant =
                    document.data() as Map<String, dynamic>;
                String restaurantName = restaurant['name'];
                String restaurantDiscounts =
                    restaurant['discountsAmount'] ?? "No discounts";

                // --------------------
                //Display as a list tile

                return ListTile(
                  title: Text(restaurantName),
                  subtitle: Text(restaurantDiscounts),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --------------------
                      //    Delete button
                      IconButton(
                        onPressed: () {
                          firestoreService.deleteRestaurant(docId);
                        },
                        icon: const Icon(Icons.delete),
                      ),

                      // --------------------
                      //    Edit button
                      IconButton(
                        onPressed: () {
                          openAddBox(docID: docId);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                );

                //Display as a list tile
                // --------------------
              },
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}


















              // PopupMenuButton for restaurants actions
             // Disabled to avoid errors
              // PopupMenuButton<String>(
              //   onSelected: (value) {
             //     if (value == 'Edit') {
             //       // Edit action for the restaurant
              //     } else if (value == 'Delete') {
              //       restaurant['name'];
              //     }
              //   },
              //   itemBuilder: (BuildContext context) => [
              //     const PopupMenuItem<String>(
              //       value: 'Edit',
              //       child: Text('Edit'),
              //     ),
              //     const PopupMenuItem<String>(
              //       value: 'Delete',
              //       child: Text('Delete'),
              //     ),
              //   ],