// file: lib/mapbox_demo/pages/home_page.dart
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:permission_handler/permission_handler.dart';

import 'filtracion.dart';
import 'navigation_mode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  mp.MapboxMap? mapboxMapController;
  mp.PointAnnotationManager? _pinManager;
  final List<mp.PointAnnotation> _pinesCreados = [];

  gl.Position? currentPosition;
  StreamSubscription<gl.Position>? userPositionStream;

  bool showCamera = false;
  CameraController? _controller;
  bool _cameraReady = false;
  double _panelSize = 0.4;

  int _selectedIndex = 0;
  bool _modoOscuro = false;

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
    _initCamera();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            onMapCreated: _onMapCreated,
            styleUri: _modoOscuro
                ? mp.MapboxStyles.DARK
                : mp.MapboxStyles.MAPBOX_STREETS,
          ),

          // 🎥 Panel cámara
          if (_cameraReady && showCamera)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * _panelSize,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _panelSize -= details.primaryDelta! /
                        MediaQuery.of(context).size.height;
                    _panelSize = _panelSize.clamp(0.3, 1.0);
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      child: CameraPreview(_controller!),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 70,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: FloatingActionButton.small(
                        heroTag: "close_cam",
                        backgroundColor: Colors.redAccent,
                        onPressed: () => _toggleCamera(false),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 📸 Abrir cámara
          if (!showCamera)
            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton(
                heroTag: "open_cam",
                backgroundColor: Colors.indigo,
                onPressed: () => _toggleCamera(true),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),

          // 📍 Botón de ubicación actual
          Positioned(
            bottom: 160,
            right: 20,
            child: FloatingActionButton(
              heroTag: "my_loc",
              onPressed: _goToMyLocation,
              backgroundColor: Colors.redAccent,
              child:
                  const Icon(Icons.my_location, color: Colors.white, size: 28),
            ),
          ),

          // 🌗 Modo día/noche
          Positioned(
            bottom: 240,
            right: 20,
            child: FloatingActionButton(
              heroTag: "toggle_mode",
              backgroundColor: _modoOscuro ? Colors.black87 : Colors.blueAccent,
              onPressed: () async {
                setState(() => _modoOscuro = !_modoOscuro);
                await mapboxMapController?.loadStyleURI(
                  _modoOscuro
                      ? mp.MapboxStyles.DARK
                      : mp.MapboxStyles.MAPBOX_STREETS,
                );
              },
              child: Icon(
                _modoOscuro ? Icons.nightlight_round : Icons.wb_sunny,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      // 🔻 Barra inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.redAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            final lugar = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FiltracionPage()),
            );
            if (lugar != null) await _mostrarSoloLugar(lugar);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        ],
      ),
    );
  }

  // =====================================================
  // 📍 Mostrar lugar y navegación
  // =====================================================
  Future<void> _mostrarSoloLugar(Map<String, dynamic> lugar) async {
    if (_pinManager == null) return;

    for (final p in _pinesCreados) {
      p.iconOpacity = 0.0;
      await _pinManager!.update(p);
    }

    mp.PointAnnotation? existente;
    for (final p in _pinesCreados) {
      if (p.textField == lugar['nombre']) {
        existente = p;
        break;
      }
    }

    if (existente == null) {
      final bytes = await rootBundle.load('assets/icons/punto_mapa_rojo_f.png');
      final imageData = bytes.buffer.asUint8List();
      existente = await _pinManager!.create(
        mp.PointAnnotationOptions(
          geometry: mp.Point(
            coordinates:
                mp.Position(lugar['lon'] as double, lugar['lat'] as double),
          ),
          image: imageData,
          iconSize: 0.45,
          textField: lugar['nombre'] as String,
          textSize: 13,
          textColor: 0xFF000000,
        ),
      );
      _pinesCreados.add(existente);
    } else {
      existente.iconOpacity = 1.0;
      await _pinManager!.update(existente);
    }

    await mapboxMapController?.flyTo(
      mp.CameraOptions(
        center: mp.Point(
          coordinates:
              mp.Position(lugar['lon'] as double, lugar['lat'] as double),
        ),
        zoom: 18.0,
        pitch: 45.0,
      ),
      mp.MapAnimationOptions(duration: 2000),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapNavigationPage(
          destLat: (lugar['lat'] as num).toDouble(),
          destLon: (lugar['lon'] as num).toDouble(),
          destName: lugar['nombre'].toString(),
        ),
      ),
    );
  }

  // =====================================================
  // 🎥 Cámara
  // =====================================================
  Future<void> _initCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    setState(() => _cameraReady = true);
  }

  void _toggleCamera(bool value) {
    setState(() {
      showCamera = value;
      if (!value) _panelSize = 0.4;
    });
  }


// =====================================================
// 🌍 MAPBOX — CONFIGURACIÓN INICIAL Y PUNTOS UBICATEC
// =====================================================
Future<void> _onMapCreated(mp.MapboxMap controller) async {
  mapboxMapController = controller;
  await _checkAndRequestLocationPermission();

  await mapboxMapController?.location.updateSettings(
    mp.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      showAccuracyRing: true,
    ),
  );

  _pinManager ??=
      await mapboxMapController!.annotations.createPointAnnotationManager();

  final bytes = await rootBundle.load('assets/icons/punto_mapa_rojo_f.png');
  final imageData = bytes.buffer.asUint8List();

  // 📍 LUGARES PRINCIPALES — UBICATEC COMPLETO
  final lugares = [
    // 🧭 Zona Tecnología
    {'nombre': 'Entrada Principal UEB', 'lat': -17.8367295, 'lon': -63.2050577},
    {'nombre': 'Facultad de Tecnología (Nueva)', 'lat': -17.8347233, 'lon': -63.2041646},
    {'nombre': 'Área Industrial', 'lat': -17.8342716, 'lon': -63.204314},
    {'nombre': 'Laboratorio de Tecnología', 'lat': -17.834294, 'lon': -63.2042903},
    {'nombre': 'Ingeniería de Software', 'lat': -17.8343737, 'lon': -63.2042894},
    {'nombre': 'CAD / Simulación', 'lat': -17.8343566, 'lon': -63.2043036},
    {'nombre': 'Fab Lab', 'lat': -17.8343654, 'lon': -63.2042389},
    {'nombre': 'Sala de Aplicaciones', 'lat': -17.8343152, 'lon': -63.2042299},

    // 🧭 Zona Robótica / Conexión
    {'nombre': 'Laboratorio de Robótica', 'lat': -17.8343273, 'lon': -63.204222},
    {'nombre': 'Área de Información', 'lat': -17.834309, 'lon': -63.204261},
    {'nombre': 'Baños de Tecnología', 'lat': -17.8343155, 'lon': -63.2042999},

    // 🧭 Zona Medicina
    {'nombre': 'Laboratorio de Simulación Médica', 'lat': -17.8348833, 'lon': -63.2040148},
    {'nombre': 'Facultad de Medicina Antigua', 'lat': -17.8348986, 'lon': -63.2045476},
    {'nombre': 'Laboratorio de Anatomía', 'lat': -17.8349962, 'lon': -63.2044123},
    {'nombre': 'Laboratorio de Histología y Fisiología', 'lat': -17.8350219, 'lon': -63.2044212},
    {'nombre': 'Anfiteatro de Medicina', 'lat': -17.8348879, 'lon': -63.2044798},

    // 🧭 Zona Aula Magna y Biblioteca
    {'nombre': 'Aula Magna', 'lat': -17.8360723, 'lon': -63.2044647},
    {'nombre': 'Biblioteca Central', 'lat': -17.8358866, 'lon': -63.204959},
    {'nombre': 'Centro de Cómputo', 'lat': -17.8360213, 'lon': -63.2049052},
    {'nombre': 'Sala de Música (Guitar 1,211,210)', 'lat': -17.8359781, 'lon': -63.2049467},
    {'nombre': 'Cafetería', 'lat': -17.8356784, 'lon': -63.2039997},
  ];

  // 🧭 Crear pines en el mapa
  final puntos = <mp.Point>[];

  for (final l in lugares) {
    final pin = await _pinManager!.create(
      mp.PointAnnotationOptions(
        geometry: mp.Point(
          coordinates: mp.Position(l['lon'] as double, l['lat'] as double),
        ),
        image: imageData,
        iconSize: 0.35,
        textField: l['nombre'] as String,
        textSize: 12,
        textColor: 0xFF000000,
        textOffset: [0.0, 2.0],
      ),
    );
    _pinesCreados.add(pin);
    puntos.add(mp.Point(
      coordinates: mp.Position(l['lon'] as double, l['lat'] as double),
    ));
  }

  // ✅ Ajuste automático de cámara al cargar
  if (puntos.isNotEmpty) {
    double minLat = puntos.first.coordinates.lat.toDouble();
    double maxLat = puntos.first.coordinates.lat.toDouble();
    double minLon = puntos.first.coordinates.lng.toDouble();
    double maxLon = puntos.first.coordinates.lng.toDouble();

    for (var p in puntos) {
      final lat = p.coordinates.lat.toDouble();
      final lon = p.coordinates.lng.toDouble();

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    await mapboxMapController?.flyTo(
      mp.CameraOptions(
        center: mp.Point(coordinates: mp.Position(centerLon, centerLat)),
        zoom: 14.3,
        pitch: 0,
      ),
      mp.MapAnimationOptions(duration: 1500),
    );
  }
}

  // =====================================================
  // 🚶‍♂️ POSICIÓN Y PERMISOS
  // =====================================================
  Future<void> _setupPositionTracking() async {
    await _checkAndRequestLocationPermission();
    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
      locationSettings: const gl.LocationSettings(
        accuracy: gl.LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((gl.Position? pos) {
      if (pos != null) currentPosition = pos;
    });
  }

  Future<void> _goToMyLocation() async {
    if (currentPosition == null || mapboxMapController == null) return;
    await mapboxMapController!.flyTo(
      mp.CameraOptions(
        center: mp.Point(
          coordinates: mp.Position(
              currentPosition!.longitude, currentPosition!.latitude),
        ),
        zoom: 17.5,
        pitch: 45.0,
      ),
      mp.MapAnimationOptions(duration: 2000),
    );
  }

  Future<void> _checkAndRequestLocationPermission() async {
    bool enabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!enabled) return;
    gl.LocationPermission perm = await gl.Geolocator.checkPermission();
    if (perm == gl.LocationPermission.denied) {
      perm = await gl.Geolocator.requestPermission();
    }
  }
}
