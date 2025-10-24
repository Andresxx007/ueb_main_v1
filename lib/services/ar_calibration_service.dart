// =====================================================
// 🧭 AR CALIBRATION SERVICE
// =====================================================
// Detecta cuándo la brújula necesita calibración
// =====================================================

import 'dart:async';

class ArCalibrationService {
  final Function onCalibrationNeeded;

  double _currentAccuracy = 0;
  DateTime? _lastCalibrationCheck;
  bool _calibrationWarningShown = false;

  static const double _minAccuracyThreshold = 20.0; // grados
  static const Duration _checkInterval = Duration(seconds: 10);

  ArCalibrationService({required this.onCalibrationNeeded});

  void updateAccuracy(double accuracy) {
    _currentAccuracy = accuracy;
    _checkCalibrationStatus();
  }

  void checkOrientation(double pitch, double roll) {
    // Detectar si el dispositivo está en posición inestable
    if (pitch.abs() > 70 || roll.abs() > 70) {
      // Dispositivo muy inclinado, puede afectar precisión
    }
  }

  void _checkCalibrationStatus() {
    final now = DateTime.now();

    // Verificar solo cada X segundos
    if (_lastCalibrationCheck != null &&
        now.difference(_lastCalibrationCheck!) < _checkInterval) {
      return;
    }

    _lastCalibrationCheck = now;

    // Si la precisión es baja y no hemos mostrado advertencia
    if (_currentAccuracy < _minAccuracyThreshold && !_calibrationWarningShown) {
      _calibrationWarningShown = true;
      onCalibrationNeeded();

      // Reset después de 30 segundos
      Future.delayed(const Duration(seconds: 30), () {
        _calibrationWarningShown = false;
      });
    }
  }

  void resetCalibrationWarning() {
    _calibrationWarningShown = false;
  }
}