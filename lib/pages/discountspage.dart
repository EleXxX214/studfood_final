import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studfood/components/custom_appbar.dart';

import 'package:studfood/services/firestore.dart';

class DiscountsPage extends StatefulWidget {
  const DiscountsPage({
    super.key,
    required this.docId,
  });
  final String docId;

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
// ----------------------------------
//              INIT
// ----------------------------------

  final TextEditingController discountController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  void openAddBox({String? discountId, required String docId}) {
    if (discountId != null) {
      FirestoreService().getDiscount(docId, discountId).then((discountData) {
        discountController.text = discountData?['discount'] ?? '';
      }).catchError((error) {
        print('Error fetching discount: $error');
      });
    } else {
      discountController.clear();
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title:
                  Text(discountId == null ? "Add discount" : "Update discount"),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: discountController,
                        decoration:
                            const InputDecoration(labelText: "Discount"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if (discountId == null) {
                      firestoreService.addDiscount(
                          discountController.text, docId);
                      setState(() {});
                    } else {
                      firestoreService.updateDiscount(
                          docId, discountId, discountController.text);
                      setState(() {});
                    }

                    discountController.clear();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(discountId == null ? Icons.add : Icons.edit),
                ),
              ],
            ));
  }

// ----------------------------------
//              BUILD
// ----------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => openAddBox(docId: widget.docId),
          child: const Icon(Icons.add)),
      appBar: const CustomAppBar(title: "Edit discounts"),
      body: FutureBuilder<QuerySnapshot>(
        future: firestoreService.getDiscounts(widget.docId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Obecnie brak zniżek'));
          }
          var discounts = snapshot.data!.docs;

          // ----------------------------------
          //           LISTVIEW.BUILDER
          // ----------------------------------
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: discounts.length,
            itemBuilder: (context, index) {
              showAlertDialog(BuildContext context, String discountId) {
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
                    firestoreService.deleteDiscount(widget.docId, discountId);
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: const Text("Delete discount?"),
                  content: const Text(
                      "Are you sure you want to delete this discount? This action cannot be undone."),
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

              DocumentSnapshot discount = discounts[index];
              String discountId = discount.id;
              // ----------------------------------
              //             LIST TILE
              // ----------------------------------
              return ListTile(
                title: Text(discount['discount'] ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --------------------
                    //    Delete button
                    // --------------------
                    IconButton(
                      onPressed: () {
                        showAlertDialog(context, discountId);
                      },
                      icon: const Icon(Icons.delete),
                    ),

                    // --------------------
                    //    Edit button
                    // --------------------
                    IconButton(
                      onPressed: () {
                        openAddBox(discountId: discountId, docId: widget.docId);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
