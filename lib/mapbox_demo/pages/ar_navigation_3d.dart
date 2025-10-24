// =====================================================
// 🎯 AR NAVIGATION 3D - SISTEMA COMPLETO
// =====================================================
// Navegación AR con flecha 3D roja direccional
// Integra: Mapbox + Sensores + CustomPainter 3D
// =====================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../services/ar_sensor_manager.dart';
import '../../services/ar_route_calculator.dart';
import '../../services/ar_calibration_service.dart';
import '../../widgets/ar_arrow_painter.dart';
import '../../widgets/ar_calibration_dialog.dart';
import '../../widgets/ar_hud_overlay.dart';

class ArNavigation3D extends StatefulWidget {
  final double targetLat;
  final double targetLon;
  final String targetName;
  final List<Map<String, dynamic>> routeWaypoints; // Lista de puntos GPS de la ruta

  const ArNavigation3D({
    super.key,
    required this.targetLat,
    required this.targetLon,
    required this.targetName,
    required this.routeWaypoints,
  });

  @override
  State<ArNavigation3D> createState() => _ArNavigation3DState();
}

class _ArNavigation3DState extends State<ArNavigation3D>
    with TickerProviderStateMixin {
  // =====================================================
  // 📸 CÁMARA
  // =====================================================
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  // =====================================================
  // 🧭 SENSORES Y ORIENTACIÓN
  // =====================================================
  final ArSensorManager _sensorManager = ArSensorManager();
  late ArCalibrationService _calibrationService;

  double _compassHeading = 0; // 0-360° (Norte = 0°)
  double _pitch = 0; // Inclinación adelante/atrás (-90 a 90°)
  double _roll = 0; // Inclinación lateral (-180 a 180°)
  double _compassAccuracy = 100; // Precisión de brújula (0-100)

  // =====================================================
  // 📍 UBICACIÓN Y NAVEGACIÓN
  // =====================================================
  late ArRouteCalculator _routeCalculator;
  StreamSubscription<Position>? _positionStream;

  double _currentLat = 0;
  double _currentLon = 0;
  double _currentAltitude = 0;
  double _userSpeed = 0; // m/s

  int _currentWaypointIndex = 0;
  double _distanceToNextWaypoint = 0;
  double _bearingToWaypoint = 0;
  double _totalDistanceRemaining = 0;

  // =====================================================
  // 🎨 ANIMACIONES Y UI
  // =====================================================
  late AnimationController _arrowPulseController;
  late Animation<double> _arrowPulseAnimation;

  late AnimationController _arrowRotationController;
  late Animation<double> _arrowRotationAnimation;

  bool _showCalibrationDialog = false;
  bool _isNavigationActive = true;
  bool _hasReachedDestination = false;

  // =====================================================
  // ⚙️ CONFIGURACIÓN
  // =====================================================
  static const double _waypointProximityThreshold = 8.0; // metros
  static const double _destinationThreshold = 5.0; // metros
  static const double _minCompassAccuracy = 20.0; // grados

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  // =====================================================
  // 🚀 INICIALIZACIÓN
  // =====================================================
  Future<void> _initializeComponents() async {
    await _initCamera();
    _initCalibrationService();
    _initAnimations();
    _initSensors();
    _initLocationTracking();
    _initRouteCalculator();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Error al inicializar cámara: $e');
    }
  }


  void _initAnimations() {
    // Animación de pulso (respiración de la flecha)
    _arrowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _arrowPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _arrowPulseController,
      curve: Curves.easeInOut,
    ));

    // Animación de rotación suave
    _arrowRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _arrowRotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _arrowRotationController,
      curve: Curves.easeOut,
    ));
  }

  void _initSensors() {
    // 🧭 Brújula (orientación del dispositivo)
    _sensorManager.compassStream.listen((heading) {
      if (mounted && heading != null) {
        setState(() {
          _compassHeading = heading;
          _updateArrowRotation();
        });
      }
    });

    // 📐 Acelerómetro (inclinación del dispositivo)
    _sensorManager.accelerometerStream.listen((event) {
      if (mounted) {
        final pitch = _calculatePitch(event.x, event.y, event.z);
        final roll = _calculateRoll(event.x, event.y, event.z);

        setState(() {
          _pitch = pitch;
          _roll = roll;
        });

        // Verificar si necesita calibración
        _calibrationService.checkOrientation(pitch, roll);
      }
    });

    // 🎯 Precisión de brújula
    FlutterCompass.events?.listen((event) {
      if (event.accuracy != null) {
        setState(() => _compassAccuracy = event.accuracy!.toDouble());
        _calibrationService.updateAccuracy(event.accuracy!.toDouble());
      }
    });
  }

  void _initLocationTracking() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2, // Actualizar cada 2 metros
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) {
      if (mounted) {
        setState(() {
          _currentLat = position.latitude;
          _currentLon = position.longitude;
          _currentAltitude = position.altitude;
          _userSpeed = position.speed;
        });

        _updateNavigation();
      }
    });
  }

  void _initRouteCalculator() {
    _routeCalculator = ArRouteCalculator(
      waypoints: widget.routeWaypoints,
      targetLat: widget.targetLat,
      targetLon: widget.targetLon,
    );
  }

  // =====================================================
  // 🧮 CÁLCULOS TRIGONOMÉTRICOS
  // =====================================================
  double _calculatePitch(double x, double y, double z) {
    return math.atan2(y, math.sqrt(x * x + z * z)) * 180 / math.pi;
  }

  double _calculateRoll(double x, double y, double z) {
    return math.atan2(-x, math.sqrt(y * y + z * z)) * 180 / math.pi;
  }

  // =====================================================
  // 🗺️ ACTUALIZACIÓN DE NAVEGACIÓN
  // =====================================================
  void _updateNavigation() {
    if (_currentWaypointIndex >= widget.routeWaypoints.length) {
      _checkDestinationReached();
      return;
    }

    final currentWaypoint = widget.routeWaypoints[_currentWaypointIndex];

    // Calcular distancia al siguiente waypoint
    _distanceToNextWaypoint = Geolocator.distanceBetween(
      _currentLat,
      _currentLon,
      currentWaypoint['lat']!,
      currentWaypoint['lon']!,
    );

    // Calcular bearing (dirección) hacia el waypoint
    _bearingToWaypoint = _routeCalculator.calculateBearing(
      _currentLat,
      _currentLon,
      currentWaypoint['lat']!,
      currentWaypoint['lon']!,
    );

    // Calcular distancia total restante
    _totalDistanceRemaining = _routeCalculator.calculateRemainingDistance(
      _currentLat,
      _currentLon,
      _currentWaypointIndex,
    );

    // Avanzar al siguiente waypoint si estamos cerca
    if (_distanceToNextWaypoint < _waypointProximityThreshold) {
      setState(() => _currentWaypointIndex++);
      _playWaypointSound(); // Feedback sonoro
    }

    _updateArrowRotation();
  }

  void _checkDestinationReached() {
    final distanceToDestination = Geolocator.distanceBetween(
      _currentLat,
      _currentLon,
      widget.targetLat,
      widget.targetLon,
    );

    if (distanceToDestination < _destinationThreshold && !_hasReachedDestination) {
      setState(() {
        _hasReachedDestination = true;
        _isNavigationActive = false;
      });
      _showDestinationReachedDialog();
    }
  }

  void _updateArrowRotation() {
    if (_bearingToWaypoint == 0) return;

    // Calcular rotación relativa (diferencia entre bearing y orientación del dispositivo)
    final targetRotation = _normalizeAngle(_bearingToWaypoint - _compassHeading);

    // Animar transición suave
    _arrowRotationAnimation = Tween<double>(
      begin: _arrowRotationAnimation.value,
      end: targetRotation,
    ).animate(_arrowRotationController);

    _arrowRotationController.forward(from: 0);
  }

  double _normalizeAngle(double angle) {
    while (angle > 180) angle -= 360;
    while (angle < -180) angle += 360;
    return angle;
  }

  // =====================================================
  // 🎨 UI PRINCIPAL
  // =====================================================
  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 📸 Cámara de fondo (vista AR)
          _buildCameraView(),

          // 🎯 Flecha 3D roja direccional
          if (_isNavigationActive) _buildArrowOverlay(),

          // 📊 HUD con información de navegación
          ArHudOverlay(
            distanceToNext: _distanceToNextWaypoint,
            totalDistance: _totalDistanceRemaining,
            currentWaypoint: _currentWaypointIndex + 1,
            totalWaypoints: widget.routeWaypoints.length,
            targetName: widget.targetName,
            speed: _userSpeed,
            compassAccuracy: _compassAccuracy,
            isCalibrated: true,
          ),

          // 🔘 Botones de control
          _buildControlButtons(),

          // ⚠️ Diálogo de calibración
          if (_showCalibrationDialog)
            ArCalibrationDialog(
              onDismiss: () => setState(() => _showCalibrationDialog = false),
            ),

          // ✅ Mensaje de llegada
          if (_hasReachedDestination) _buildArrivalOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildArrowOverlay() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _arrowPulseAnimation,
        _arrowRotationAnimation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: ArArrowPainter(
            // Datos de orientación
            compassHeading: _compassHeading,
            pitch: _pitch,
            roll: _roll,

            // Datos de navegación
            currentLat: _currentLat,
            currentLon: _currentLon,
            targetLat: _currentWaypointIndex < widget.routeWaypoints.length
                ? widget.routeWaypoints[_currentWaypointIndex]['lat']!
                : widget.targetLat,
            targetLon: _currentWaypointIndex < widget.routeWaypoints.length
                ? widget.routeWaypoints[_currentWaypointIndex]['lon']!
                : widget.targetLon,

            // Estado de navegación
            distanceToTarget: _distanceToNextWaypoint,
            bearingToTarget: _bearingToWaypoint,
            relativeAngle: _arrowRotationAnimation.value,

            // Animaciones
            pulseScale: _arrowPulseAnimation.value,
            rotationAngle: _arrowRotationAnimation.value,

            // Configuración visual
            arrowColor: Colors.red,
            isCalibrated: _compassAccuracy > _minCompassAccuracy,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return SafeArea(
      child: Column(
        children: [
          // Botón cerrar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  onPressed: () => _showExitDialog(),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  onPressed: () => setState(() => _showCalibrationDialog = true),
                  child: Icon(
                    Icons.explore,
                    color: _compassAccuracy > _minCompassAccuracy
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Botón recalibrar
          if (_compassAccuracy < _minCompassAccuracy)
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => setState(() => _showCalibrationDialog = true),
                icon: const Icon(Icons.warning_amber),
                label: const Text('CALIBRAR BRÚJULA'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Inicializando AR...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            Text(
              '¡Has llegado!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.targetName,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('FINALIZAR'),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // 🔔 FEEDBACK Y DIÁLOGOS
  // =====================================================
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de navegación AR'),
        content: const Text('¿Deseas finalizar la navegación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar AR
            },
            child: const Text('SALIR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDestinationReachedDialog() {
    // Vibración de feedback (si está disponible)
    // HapticFeedback.heavyImpact();
  }

  void _playWaypointSound() {
    // Implementar audio feedback con audioplayers
    debugPrint('🎵 Waypoint alcanzado');
  }

  // =====================================================
  // 🧹 LIMPIEZA
  // =====================================================
  @override
  void dispose() {
    _cameraController?.dispose();
    _positionStream?.cancel();
    _sensorManager.dispose();
    _arrowPulseController.dispose();
    _arrowRotationController.dispose();
    super.dispose();
  }
}