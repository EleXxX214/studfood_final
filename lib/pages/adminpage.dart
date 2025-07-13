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
  // --------------------
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final discountCountController = NumberEditingTextController.integer();
  final TextEditingController imageUrlController = TextEditingController();

  // --------------------------------
  //  TextControllers opening hours
  // -------------------------------

  final TextEditingController mondayController = TextEditingController();
  final TextEditingController tuesdayController = TextEditingController();
  final TextEditingController wednesdayController = TextEditingController();
  final TextEditingController thursdayController = TextEditingController();
  final TextEditingController fridayController = TextEditingController();
  final TextEditingController saturdayController = TextEditingController();
  final TextEditingController sundayController = TextEditingController();

// --------------------
//  FirestoreService
// --------------------
  final FirestoreService firestoreService = FirestoreService();

// --------------------
//       openAddBox
// --------------------
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
        imageUrlController.text = restaurantData['menuUrl'] ?? '';
        mondayController.text = restaurantData['monday'];
        tuesdayController.text = restaurantData['tuesday'];
        wednesdayController.text = restaurantData['wednesday'];
        thursdayController.text = restaurantData['thursday'];
        fridayController.text = restaurantData['friday'];
        saturdayController.text = restaurantData['saturday'];
        sundayController.text = restaurantData['sunday'];
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
                  decoration: const InputDecoration(
                      labelText: 'Menu URL (link do menu restauracji)'),
                ),
                const Divider(),
                const Text("Opening Hours"),
                const Divider(),
                TextField(
                  controller: mondayController,
                  decoration: const InputDecoration(labelText: 'Monday'),
                ),
                TextField(
                  controller: tuesdayController,
                  decoration: const InputDecoration(labelText: 'Tuesday'),
                ),
                TextField(
                  controller: wednesdayController,
                  decoration: const InputDecoration(labelText: 'Wednesday'),
                ),
                TextField(
                  controller: thursdayController,
                  decoration: const InputDecoration(labelText: 'Thursday'),
                ),
                TextField(
                  controller: fridayController,
                  decoration: const InputDecoration(labelText: 'Friday'),
                ),
                TextField(
                  controller: saturdayController,
                  decoration: const InputDecoration(labelText: 'Saturday'),
                ),
                TextField(
                  controller: sundayController,
                  decoration: const InputDecoration(labelText: 'Sunday'),
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
                  mondayController.text,
                  tuesdayController.text,
                  wednesdayController.text,
                  thursdayController.text,
                  fridayController.text,
                  saturdayController.text,
                  sundayController.text,
                );
              } else {
                firestoreService.updateRestaurant(
                  docID,
                  nameController.text,
                  addressController.text,
                  discountCountController.number,
                  descriptionController.text,
                  imageUrlController.text,
                  mondayController.text,
                  tuesdayController.text,
                  wednesdayController.text,
                  thursdayController.text,
                  fridayController.text,
                  saturdayController.text,
                  sundayController.text,
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => openAddBox(), child: const Icon(Icons.add)),
      appBar: const CustomAppBar(
        title: "Admin Page",
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: firestoreService.getRestaurants(),
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
                updateDiscountCount(docId);
                // --------------------
                //Getting restaurant parameters

                Map<String, dynamic> restaurant =
                    document.data() as Map<String, dynamic>;

                String restaurantName = restaurant['name'];

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
                  subtitle: Text(docId),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'PhotoPage',
                              arguments: docId);
                        },
                        icon:
                            const Icon(Icons.photo_size_select_actual_outlined),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'DiscountsPage',
                                arguments: docId);
                          },
                          icon:
                              const Icon(Icons.local_fire_department_rounded)),
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