// =====================================================
// 🗺️ AR ROUTE CALCULATOR
// =====================================================
// Calcula bearings, distancias y waypoints
// =====================================================

import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class ArRouteCalculator {
  final List<Map<String, dynamic>> waypoints;
  final double targetLat;
  final double targetLon;

  ArRouteCalculator({
    required this.waypoints,
    required this.targetLat,
    required this.targetLon,
  });

  // =====================================================
  // 🧭 CALCULAR BEARING (AZIMUT)
  // =====================================================
  double calculateBearing(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    final dLon = _toRadians(endLon - startLon);
    final lat1 = _toRadians(startLat);
    final lat2 = _toRadians(endLat);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360; // Normalizar a 0-360°
  }

  // =====================================================
  // 📏 CALCULAR DISTANCIA RESTANTE TOTAL
  // =====================================================
  double calculateRemainingDistance(
    double currentLat,
    double currentLon,
    int currentWaypointIndex,
  ) {
    double totalDistance = 0;

    // Distancia al siguiente waypoint
    if (currentWaypointIndex < waypoints.length) {
      final nextWaypoint = waypoints[currentWaypointIndex];
      totalDistance += Geolocator.distanceBetween(
        currentLat,
        currentLon,
        nextWaypoint['lat']!,
        nextWaypoint['lon']!,
      );
    }

    // Distancia entre waypoints restantes
    for (int i = currentWaypointIndex; i < waypoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        waypoints[i]['lat']!,
        waypoints[i]['lon']!,
        waypoints[i + 1]['lat']!,
        waypoints[i + 1]['lon']!,
      );
    }

    // Distancia del último waypoint al destino
    if (waypoints.isNotEmpty) {
      final lastWaypoint = waypoints.last;
      totalDistance += Geolocator.distanceBetween(
        lastWaypoint['lat']!,
        lastWaypoint['lon']!,
        targetLat,
        targetLon,
      );
    }

    return totalDistance;
  }

  // =====================================================
  // 🔍 ENCONTRAR WAYPOINT MÁS CERCANO
  // =====================================================
  int findNearestWaypoint(double currentLat, double currentLon) {
    int nearestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < waypoints.length; i++) {
      final distance = Geolocator.distanceBetween(
        currentLat,
        currentLon,
        waypoints[i]['lat']!,
        waypoints[i]['lon']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  // =====================================================
  // 🧮 UTILIDADES TRIGONOMÉTRICAS
  // =====================================================
  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;
}