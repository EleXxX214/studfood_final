import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final discountCountController = NumberEditingTextController.integer();
  final TextEditingController imageUrlController = TextEditingController();

// --------------------
//  FirestoreService
  final FirestoreService firestoreService = FirestoreService();

// --------------------
//       openAddBox
  void openAddBox({String? docID}) {
    //Jeżeli edytuje to pobiera dane edytującej restauracji
    if (docID != null) {
      // Edytujesz restaurację, pobierz jej aktualne wartości
      firestoreService.getRestaurant(docID).then((restaurantData) {
        nameController.text = restaurantData['name'];
        addressController.text = restaurantData['address'];
        discountCountController.text =
            restaurantData['discountCount'].toString();
        descriptionController.text = restaurantData['description'];
        imageUrlController.text = restaurantData['imageUrl'];
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docID == null ? "Add restaurant" : "Update restaurant"),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: discountCountController,
                  decoration:
                      const InputDecoration(labelText: 'Discounts Amount'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'imageUrl'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            //Jeżeli nie dostaniemy docID to dodajemy, w przeciwnym przypadku zaktualizujemy
            onPressed: () {
              if (docID == null) {
                firestoreService.addRestaurant(
                  nameController.text,
                  addressController.text,
                  discountCountController.number,
                  descriptionController.text,
                  imageUrlController.text,
                );
              } else {
                firestoreService.updateRestaurant(
                  docID,
                  nameController.text,
                  addressController.text,
                  discountCountController.number,
                  descriptionController.text,
                  imageUrlController.text,
                );
              }

              nameController.clear();
              addressController.clear();
              discountCountController.clear();
              descriptionController.clear();
              imageUrlController.clear();
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
      appBar: const CustomAppBar(
        title: "Admin Page",
      ),
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
                    restaurant['discountCount']?.toString() ?? "No discounts";

                // --------------------
                //Display as a list tile
                showAlertDialog(BuildContext context) {
                  // set up the buttons
                  Widget cancelButton = TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  );
                  Widget deleteButton = TextButton(
                    child: const Text("Delete"),
                    onPressed: () {
                      firestoreService.deleteRestaurant(docId);
                      Navigator.of(context).pop();
                    },
                  );

                  // set up the AlertDialog
                  AlertDialog alert = AlertDialog(
                    title: const Text("Delete restaurant?"),
                    content: const Text(
                        "Are you sure you want to delete this restaurant? This action cannot be undone."),
                    actions: [
                      cancelButton,
                      deleteButton,
                    ],
                  );

                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                }

                return ListTile(
                  title: Text(restaurantName),
                  subtitle: Text(restaurantDiscounts),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'DiscountsPage',
                                arguments: docId);
                          },
                          child: const Text("Edit discounts")),
                      // --------------------
                      //    Delete button
                      IconButton(
                        onPressed: () {
                          showAlertDialog(context);
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