import 'package:cached_network_image/cached_network_image.dart';
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
          height: 330, // Zwiększona wysokość kafelka
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromARGB(255, 253, 43, 225),
                Color.fromARGB(255, 255, 255, 255),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 23)),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: constraints
                        .maxWidth, // Dopasowanie do szerokości kafelka
                    height: 240, // Zwiększona wysokość obrazu
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      Text(address),
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
