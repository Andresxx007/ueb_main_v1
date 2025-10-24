// =====================================================
// 📊 AR HUD OVERLAY
// =====================================================
// Información de navegación en pantalla
// =====================================================

import 'package:flutter/material.dart';

class ArHudOverlay extends StatelessWidget {
  final double distanceToNext;
  final double totalDistance;
  final int currentWaypoint;
  final int totalWaypoints;
  final String targetName;
  final double speed;
  final double compassAccuracy;
  final bool isCalibrated;

  const ArHudOverlay({
    super.key,
    required this.distanceToNext,
    required this.totalDistance,
    required this.currentWaypoint,
    required this.totalWaypoints,
    required this.targetName,
    required this.speed,
    required this.compassAccuracy,
    required this.isCalibrated,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 60), // Espacio para botones

          // 🎯 Panel principal de información
          _buildMainInfoPanel(context),

          const Spacer(),

          // 📍 Panel inferior con detalles
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildMainInfoPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Destino
          Text(
            targetName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Distancia al siguiente waypoint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                distanceToNext < 1000
                    ? distanceToNext.toStringAsFixed(0)
                    : (distanceToNext / 1000).toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                distanceToNext < 1000 ? 'm' : 'km',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Waypoint actual
          Text(
            'Punto $currentWaypoint de $totalWaypoints',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          // Barra de progreso
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = currentWaypoint / totalWaypoints;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% completado',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Velocidad
          _buildInfoChip(
            icon: Icons.speed,
            label: '${(speed * 3.6).toStringAsFixed(1)} km/h',
            color: Colors.blue,
          ),

          const SizedBox(width: 16),

          // Distancia total
          _buildInfoChip(
            icon: Icons.route,
            label: totalDistance < 1000
                ? '${totalDistance.toStringAsFixed(0)} m'
                : '${(totalDistance / 1000).toStringAsFixed(1)} km',
            color: Colors.orange,
          ),

          const SizedBox(width: 16),

          // Estado de calibración
          _buildInfoChip(
            icon: isCalibrated ? Icons.check_circle : Icons.warning_amber,
            label: isCalibrated ? 'OK' : 'Calibrar',
            color: isCalibrated ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}