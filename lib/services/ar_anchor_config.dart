import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class ArPOI {
  final double latitude;
  final double longitude;
  final double? altitude;
  final String name;
  const ArPOI({required this.latitude, required this.longitude, this.altitude, required this.name});
}

class ArAnchorConfig {
  static const List<ArPOI> poiAnchors = [
    ArPOI(latitude: -17.781950, longitude: -63.182620, name: 'Laboratorios'),
  ];

  static Set<Polyline> get debugRoute => {
    const Polyline(
      polylineId: PolylineId('ruta_demo'),
      width: 5,
      color: Color(0xFFE53935),
      points: [
        LatLng(-17.783300, -63.182100),
        LatLng(-17.782500, -63.182400),
        LatLng(-17.781950, -63.182620),
      ],
    )
  };
}
