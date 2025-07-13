import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.docId,
    required this.name,
    required this.address,
    required this.discountCount,
    required this.openingHour,
    required this.onTap,
  });

  final String docId;
  final String address;
  final int? discountCount;
  final String name;
  final VoidCallback onTap;
  final String openingHour;

  Future<String> _getLogoUrl() async {
    try {
      return await FirebaseStorage.instance
          .ref('restaurants_photos/$docId/logo.jpg')
          .getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<String>(
              future: _getLogoUrl(),
              builder: (context, snapshot) {
                Widget imageWidget;
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty) {
                  imageWidget = CachedNetworkImage(
                    width: double.infinity,
                    height: double.infinity,
                    imageUrl: snapshot.data!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                        'assets/images/paper.webp',
                        fit: BoxFit.cover),
                  );
                } else {
                  imageWidget = Image.asset('assets/images/paper.webp',
                      fit: BoxFit.cover);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: constraints.maxWidth,
                          height: 240,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                imageWidget,
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Text(
                                  address,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
