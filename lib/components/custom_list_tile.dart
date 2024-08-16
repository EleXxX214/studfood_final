import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String name;
  final String address;
  final int? discountsAmount;
  final String openingHour;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    required this.name,
    required this.address,
    required this.discountsAmount,
    required this.openingHour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromRGBO(243, 236, 219, 1),
          ),
          child: Stack(
            children: [
              // Image.asset("assets/backgrounds/paper.webp"),
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        // --------------------
                        //  ICONA PROMOCJI
                        Row(children: [
                          const Icon(Icons.access_time),
                          Text(openingHour),
                          const Text("     "),
                          Text(discountsAmount?.toString() ?? ""),
                          const Icon(Icons.local_fire_department_rounded),
                        ])
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: const TextStyle(fontSize: 23)),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 220,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset("assets/backgrounds/fota1.jpg",
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          // --------------------
                          //  ICONA ADRESU
                          const Icon(Icons.location_on_outlined),
                          Text(address),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
