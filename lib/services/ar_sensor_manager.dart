// =====================================================
// 🧭 AR SENSOR MANAGER
// =====================================================
// Gestiona todos los sensores del dispositivo:
// - Brújula (compass)
// - Acelerómetro (pitch/roll)
// - Giroscopio (rotación)
// =====================================================

import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ArSensorManager {
  // Streams de sensores
  Stream<double?> get compassStream => _compassController.stream;
  Stream<AccelerometerEvent> get accelerometerStream => accelerometerEvents;
  Stream<GyroscopeEvent> get gyroscopeStream => gyroscopeEvents;

  final _compassController = StreamController<double?>.broadcast();

  // Filtro Kalman simple para suavizar lecturas
  final KalmanFilter _compassFilter = KalmanFilter();
  final KalmanFilter _pitchFilter = KalmanFilter();
  final KalmanFilter _rollFilter = KalmanFilter();

  ArSensorManager() {
    _initCompass();
  }

  void _initCompass() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        // Aplicar filtro para suavizar
        final filtered = _compassFilter.filter(event.heading!);
        _compassController.add(filtered);
      }
    });
  }

  void dispose() {
    _compassController.close();
  }
}

// =====================================================
// 📊 FILTRO KALMAN (Suavizado de sensores)
// =====================================================
class KalmanFilter {
  double _q = 0.1; // Ruido del proceso
  double _r = 0.5; // Ruido de medición
  double _x = 0; // Estimación actual
  double _p = 1; // Error de estimación

  double filter(double measurement) {
    // Predicción
    _p = _p + _q;

    // Actualización
    final k = _p / (_p + _r); // Ganancia de Kalman
    _x = _x + k * (measurement - _x);
    _p = (1 - k) * _p;

    return _x;
  }

  void reset() {
    _x = 0;
    _p = 1;
  }
}