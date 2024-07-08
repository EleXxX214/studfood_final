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
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[350]?.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Row(
                      children: [
                        // --------------------
                        //  ICONY TYPU JEDZENIA
                        Icon(Icons.local_pizza, size: 30),
                        Icon(Icons.ramen_dining, size: 30),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // --------------------
                        //  ICONA CZASU
                        const Icon(Icons.access_time),
                        Text(openingHour),
                      ],
                    ),
                    const Row(
                      children: [
                        // --------------------
                        //  ICONA ODLEGLOSCI
                        Icon(Icons.navigation_rounded),
                        Text("300m"),
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
                          const Text(" "),
                          Text(name, style: const TextStyle(fontSize: 23)),
                        ],
                      ),
                      Row(
                        children: [
                          // --------------------
                          //  ICONA PROMOCJI
                          const Icon(Icons.local_fire_department_rounded),
                          Text(discountsAmount?.toString() ?? ""),
                        ],
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
