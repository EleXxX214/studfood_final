import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:studfood/components/custom_appbar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng krakow = LatLng(50.064650, 19.944980);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Map"),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: krakow, zoom: 16),
        markers: {
          const Marker(
              markerId: MarkerId("krakow"),
              icon: BitmapDescriptor.defaultMarker,
              position: krakow),
        },
      ),
    );
  }
}
