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

final TextEditingController discountController = TextEditingController();

Future<QuerySnapshot<Object?>> getDiscounts(String docId) async {
  DocumentReference restaurantDoc =
      FirebaseFirestore.instance.collection('restaurants').doc(docId);
  CollectionReference discounts = restaurantDoc.collection('discounts');
  QuerySnapshot discountsSnapshot = await discounts.get();
  return discountsSnapshot;
}

void openAddBox(BuildContext context, {String? docId}) {
  if (docId != null) {
    FirestoreService().getDiscount(docId).then((discountData) {
      discountController.text = discountData?['discount'];
    }).catchError((error) {
      print('Error fetching discount: $error');
    });
  }

  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(docId == null ? "Add discount" : "Update discount"),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: "Discount"),
                    ),
                  ],
                ),
              ),
            ),
          ));
}

class _DiscountsPageState extends State<DiscountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Edit discounts"),
      body: FutureBuilder<QuerySnapshot>(
        future: getDiscounts(widget.docId),
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
              Map<String, dynamic> discount =
                  discounts[index].data() as Map<String, dynamic>;
              // ----------------------------------
              //             LIST TILE
              // ----------------------------------
              return ListTile(
                title: Text(discount['discount'] ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //    Delete button
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete),
                    ),

                    // --------------------
                    //    Edit button
                    IconButton(
                      onPressed: () {
                        openAddBox(context, docId: widget.docId);
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
