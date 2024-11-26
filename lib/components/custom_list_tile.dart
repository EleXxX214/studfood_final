import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String name;
  final String address;
  final int? discountCount;
  final String openingHour;
  final VoidCallback onTap;
  final String imageUrl;
  const CustomListTile({
    super.key,
    required this.name,
    required this.address,
    required this.discountCount,
    required this.openingHour,
    required this.onTap,
    required this.imageUrl,
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
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.5),
                blurRadius: 2,
                spreadRadius: 3,
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromRGBO(255, 255, 255, 1),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time),
                                Text(openingHour),
                                const Text("     "),
                                Text(discountCount?.toString() ?? ""),
                                const Icon(Icons.local_fire_department_rounded),
                              ],
                            )
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
                            width: constraints.maxWidth *
                                1, // Szerokość względem kafelka
                            height: 220,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Icon(Icons.error, color: Colors.red),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined),
                              Text(address),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
