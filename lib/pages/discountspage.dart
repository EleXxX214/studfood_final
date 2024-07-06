import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studfood/components/custom_appbar.dart';
import 'package:studfood/pages/restaurantpage.dart';
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
  final TextEditingController discountController = TextEditingController();

  Future<QuerySnapshot<Object?>> getDiscounts(String docId) async {
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    CollectionReference discounts = restaurantDoc.collection('discounts');
    QuerySnapshot discountsSnapshot = await discounts.get();
    return discountsSnapshot;
  }

  void openAddBox({String? discountId, required String docId}) {
    logger.w(discountId);
    if (discountId != null) {
      logger.t(discountId);
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
            ));
  }

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
                    //    Delete button
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete),
                    ),

                    // --------------------
                    //    Edit button
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
