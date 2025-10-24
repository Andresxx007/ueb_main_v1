// ar_calibration_service.dart
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class ARCalibrationService {
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _isCalibrated = true; // ✅ CAMBIO: Siempre calibrado por defecto
  
  // Stream controller para notificar cambios
  final StreamController<bool> _calibrationController = 
      StreamController<bool>.broadcast();
  
  Stream<bool> get calibrationStream => _calibrationController.stream;
  bool get isCalibrated => _isCalibrated;

  void startMonitoring() {
    // ✅ CAMBIO: Eliminamos la lógica de monitoreo
    // Ya no verificamos la precisión del compass
    _isCalibrated = true;
    _calibrationController.add(true);
  }

  void stopMonitoring() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  // ✅ NUEVO: Método dummy para compatibilidad
  void forceCalibrated() {
    _isCalibrated = true;
    _calibrationController.add(true);
  }

  void dispose() {
    stopMonitoring();
    _calibrationController.close();
  }
}