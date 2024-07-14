import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:studfood/components/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Map<String, Marker> _markers = {};
  Logger logger = Logger();
  //------------------------------------
  //         MAP STARTING ZOOM
  //------------------------------------
  static const LatLng krakow = LatLng(50.064650, 19.944980);

  //------------------------------------
  //            API KEY
  //------------------------------------
  final String apiKey = 'AIzaSyCxc04YNYPZNul3ziq2-hwoW_J4jFp8OJ8';

  @override
  void initState() {
    super.initState();
    _loadMarkersFromFirestore();
  }

//------------------------------------
//             BUILD
//------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Map"),
      body: GoogleMap(
        mapToolbarEnabled: true,
        initialCameraPosition: const CameraPosition(target: krakow, zoom: 14),
        onMapCreated: (controller) {},
        markers: _markers.values.toSet(),
      ),
    );
  }

//------------------------------------
//    LOADING MARKERS FROM FIRESTORE
//------------------------------------
  Future<void> _loadMarkersFromFirestore() async {
    var collection = FirebaseFirestore.instance.collection('restaurants');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      var address = data['address'];
      var name = data['name'];

      var location = await getLatLngFromAddress(address, apiKey);
      if (location != null) {
        addMarker(doc.id, location, name);
      }
    }
  }

//------------------------------------
// CONVERTING ADDRESS TO LAT/LNG
//------------------------------------
  Future<LatLng?> getLatLngFromAddress(String address, String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      logger.t(data);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

//------------------------------------
//    ADD MARKER
//------------------------------------
  addMarker(String id, LatLng location, String name) async {
    var markerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/map/restaurant_pin.png',
    );

    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(
          title: name,
          onTap: () {
            Navigator.pushNamed(context, "RestaurantPage", arguments: id);
          }),
      icon: markerIcon,
    );
    _markers[id] = marker;
    setState(() {});
  }
}
