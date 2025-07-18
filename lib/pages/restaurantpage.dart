// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:studfood/components/custom_appbar.dart';
import 'package:studfood/services/firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';

var logger = Logger();

Future<List<String>> getImageUrls(String restaurantId) async {
  final storage = FirebaseStorage.instance;
  final listResult =
      await storage.ref('restaurants_photos/$restaurantId').listAll();

  // Pobierz wszystkie URL-e równolegle
  final urls = await Future.wait(
    listResult.items.map((item) => item.getDownloadURL()),
  );

  return urls;
}

class RestaurantPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantPage({super.key, required this.restaurantId});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late Future<Map<String, dynamic>> _restaurantFuture;
  List<String> imageUrls = [];

  @override
  // ----------------------------------
  //              INIT
  // ----------------------------------
  void initState() {
    super.initState();
    if (widget.restaurantId.isNotEmpty) {
      _restaurantFuture = getRestaurantData(widget.restaurantId);
      _loadImageUrls();
    } else {
      _restaurantFuture = Future.error('restaurantId is empty');
    }
  }

  Future<void> _loadImageUrls() async {
    try {
      List<String> urls = await getImageUrls(widget.restaurantId);
      if (mounted) {
        // Sprawdź, czy widżet jest nadal w drzewie
        setState(() {
          imageUrls = urls;
        });
      }
    } catch (e) {
      print('Błąd podczas ładowania URL-i zdjęć: $e');
    }
  }

  // ----------------------------------
  //      Get restaurant data
  // ----------------------------------
  Future<Map<String, dynamic>> getRestaurantData(String docId) async {
    DocumentSnapshot<Object?> restaurantSnapshot =
        await FirestoreService().getRestaurant(docId);
    Map<String, dynamic> restaurantData =
        restaurantSnapshot.data() as Map<String, dynamic>;
    return restaurantData;
  }

  // ----------------------------------
  //      Get discounts list
  // ----------------------------------
  Future<QuerySnapshot<Object?>> getDiscounts(String docId) async {
    DocumentReference restaurantDoc =
        FirebaseFirestore.instance.collection('restaurants').doc(docId);
    CollectionReference discounts = restaurantDoc.collection('discounts');
    QuerySnapshot discountsSnapshot = await discounts.get();
    return discountsSnapshot;
  }

  Future<void> openMap(String address) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$address';
    String appleUrl = 'https://maps.apple.com/?q=$address';
    if (Platform.isAndroid) {
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(Uri.parse(googleUrl));
      } else {
        throw 'Could not launch $googleUrl';
      }
    } else if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(appleUrl))) {
        await launchUrl(Uri.parse(appleUrl));
      } else if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(Uri.parse(googleUrl));
      } else {
        throw 'Could not launch $appleUrl or $googleUrl';
      }
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 80, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

// ----------------------------------
//              BUILD
// ----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "StudFood"),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _restaurantFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
            }
            Map<String, dynamic> restaurantData = snapshot.data ?? {};
            return Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    // ----------------------------------
                    //         Restaurant name/title
                    // ----------------------------------
                    Text(
                      restaurantData['name'] ?? "",
                      style: const TextStyle(fontSize: 30),
                    ),
                    const Spacer(),
                  ],
                ),
                // ----------------------------------
                //            ___DIVIDER___
                // ----------------------------------
                const Divider(
                  indent: 30,
                  endIndent: 30,
                  color: Colors.white,
                ),

                // ----------------------------------
                //            Restaurant image
                // ----------------------------------
                SizedBox(
                  width: 450,
                  height: 300,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () => _showFullImage(url),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                      child:
                                          Icon(Icons.error, color: Colors.red),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.6)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  children: [
                    // ----------------------------------
                    //              HEART ICON
                    // ----------------------------------
                    //const Spacer(),
                    //IconButton(
                    //  onPressed: () {},
                    // icon: const Icon(Icons.favorite_border),
                    // iconSize: 80,
                    //  color: const Color.fromARGB(255, 0, 0, 0),
                    //),
                    // ----------------------------------
                    //              MENU ICON
                    // ----------------------------------
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final menuUrl = restaurantData['menuUrl'];
                        print('Menu URL: $menuUrl');
                        if (menuUrl != null &&
                            menuUrl.toString().trim().isNotEmpty) {
                          final uri = Uri.tryParse(menuUrl);
                          print('Uri: $uri');
                          if (uri != null) {
                            print('Launching...');
                            try {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } catch (e) {
                              print('Error with externalApplication: $e');
                              try {
                                await launchUrl(uri,
                                    mode: LaunchMode.platformDefault);
                              } catch (e2) {
                                print('Error with platformDefault: $e2');
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Błąd'),
                                      content: const Text(
                                          'Nie można otworzyć linku do menu.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            }
                          } else {
                            print('Cannot parse URI!');
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Błąd'),
                                  content: const Text(
                                      'Nieprawidłowy format linku do menu.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        } else {
                          print('Brak odnośnika do menu');
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Brak odnośnika'),
                                content: const Text(
                                    'Brak odnośnika do menu tej restauracji.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.menu_book),
                      tooltip: "Menu",
                      iconSize: 80,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    // ----------------------------------
                    //          NAVIGATION ICON
                    // ----------------------------------
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        openMap("${restaurantData['address']}");
                      },
                      icon: const Icon(Icons.near_me),
                      iconSize: 80,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    const Spacer(),
                  ],
                ),
                Row(
                  children: [
                    // ----------------------------------
                    //              DESCRIPTION
                    // ----------------------------------
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 32),
                        child: Text(
                          restaurantData['description'] ?? "",
                          overflow: TextOverflow.visible,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // ----------------------------------
                          //           ADDRESS/ICON
                          // ----------------------------------
                          const Icon(Icons.location_on, size: 35),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              restaurantData['address'] ?? "",
                              style: const TextStyle(fontSize: 20),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // ----------------------------------
                          //          OPENING HOURS/ICON
                          // ----------------------------------
                          const Icon(Icons.schedule, size: 35),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0; i < 7; i++)
                                      Text(
                                        [
                                          'Poniedziałek',
                                          'Wtorek',
                                          'Środa',
                                          'Czwartek',
                                          'Piątek',
                                          'Sobota',
                                          'Niedziela'
                                        ][i],
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0; i < 7; i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 30.0),
                                        child: Text(
                                          "${restaurantData[[
                                                'monday',
                                                'tuesday',
                                                'wednesday',
                                                'thursday',
                                                'friday',
                                                'saturday',
                                                'sunday'
                                              ][i]] ?? 'No data'}",
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      )
                                  ])
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                // ----------------------------------
                //            ___DIVIDER___
                // ----------------------------------
                const Divider(
                  indent: 30,
                  endIndent: 30,
                  color: Colors.white,
                ),
                // ----------------------------------
                //          DISCOUNTS LIST
                // ----------------------------------
                FutureBuilder<QuerySnapshot>(
                  future: getDiscounts(widget.restaurantId),
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
                          title: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(discount['discount'] ?? ""),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
