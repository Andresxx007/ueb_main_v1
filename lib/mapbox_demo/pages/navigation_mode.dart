import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🚗 Navegación estilo Google Maps (modo Auto / A pie)
class MapNavigationPage extends StatefulWidget {
  final double destLat;
  final double destLon;
  final String destName;

  const MapNavigationPage({
    super.key,
    required this.destLat,
    required this.destLon,
    required this.destName,
  });

  @override
  State<MapNavigationPage> createState() => _MapNavigationPageState();
}

class _MapNavigationPageState extends State<MapNavigationPage> {
  mp.MapboxMap? map;
  mp.PolylineAnnotationManager? _routeManager;
  mp.PolylineAnnotation? _route;

  gl.Position? _currentPos;
  StreamSubscription<gl.Position>? _posStream;

  bool _loading = true;
  bool _recalculando = false;
  bool _isDriving = false; // 🚗 modo por defecto

  String _tiempoEstimado = "";
  String _distancia = "";

  List<String> _instrucciones = [];
  int _paso = 0;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            onMapCreated: _onMapCreated,
            styleUri: mp.MapboxStyles.MAPBOX_STREETS,
          ),

          // 🧭 Indicaciones paso a paso
          if (_instrucciones.isNotEmpty)
            Positioned(
              top: 40,
              left: 15,
              right: 15,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _instrucciones[_paso],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "⏱ $_tiempoEstimado • 📍 $_distancia",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // 🔘 Botones flotantes (cerrar / cambiar modo)
          Positioned(
            top: 40,
            left: 15,
            child: FloatingActionButton.small(
              backgroundColor: Colors.red,
              onPressed: () {
                _posStream?.cancel();
                Navigator.pop(context);
              },
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),

          Positioned(
            top: 110,
            left: 15,
            child: FloatingActionButton.small(
              backgroundColor: Colors.blueGrey,
              onPressed: () async {
                setState(() {
                  _isDriving = !_isDriving;
                  _loading = true;
                });
                if (_currentPos != null) {
                  await _dibujarRuta(widget.destLat, widget.destLon);
                }
                setState(() => _loading = false);
              },
              child: Icon(
                _isDriving ? Icons.directions_car : Icons.directions_walk,
                color: Colors.white,
              ),
            ),
          ),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 📍 Inicializa ubicación y escucha cambios
  // ============================================================
  Future<void> _initLocation() async {
    await _checkPermisos();

    const settings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.best,
      distanceFilter: 3,
    );

    _posStream?.cancel();
    _posStream = gl.Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) async {
      _currentPos = pos;
      if (map != null) {
        _centrarCamara(pos.latitude, pos.longitude, heading: pos.heading);
      }
      if (_route != null) {
        await _actualizarProgreso(widget.destLat, widget.destLon);
      }
    });
  }

  // ============================================================
  // 🗺️ Configura el mapa
  // ============================================================
  Future<void> _onMapCreated(mp.MapboxMap controller) async {
    map = controller;

    await map!.location.updateSettings(
      mp.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: false,
      ),
    );

    await map!.gestures.updateSettings(
      mp.GesturesSettings(
        rotateEnabled: true,
        scrollEnabled: true,
        pitchEnabled: true,
        pinchToZoomEnabled: true,
      ),
    );

    _routeManager = await map!.annotations.createPolylineAnnotationManager();

    _currentPos = await gl.Geolocator.getCurrentPosition(
      locationSettings: const gl.LocationSettings(
        accuracy: gl.LocationAccuracy.best,
      ),
    );

    if (_currentPos != null) {
      await _dibujarRuta(widget.destLat, widget.destLon);
      await _centrarCamara(_currentPos!.latitude, _currentPos!.longitude);
    }

    setState(() => _loading = false);
  }

  // ============================================================
  // 🎯 Dibuja ruta y obtiene datos
  // ============================================================
  Future<void> _dibujarRuta(double destLat, double destLon) async {
    final start = "${_currentPos!.longitude},${_currentPos!.latitude}";
    final end = "$destLon,$destLat";
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    final profile = _isDriving ? "driving" : "walking";

    final url = Uri.parse(
      "https://api.mapbox.com/directions/v5/mapbox/$profile/$start;$end"
      "?geometries=geojson&overview=full&steps=true&access_token=$token",
    );

    try {
      final res = await http.get(url);
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      final route = data['routes'][0];
      final coords = route['geometry']['coordinates'] as List;

      final puntos = coords
          .map((c) => mp.Position(c[0].toDouble(), c[1].toDouble()))
          .toList();

      await _routeManager?.deleteAll();
      _route = await _routeManager!.create(
        mp.PolylineAnnotationOptions(
          geometry: mp.LineString(coordinates: puntos),
          lineColor: 0xFF007AFF,
          lineWidth: 6.0,
        ),
      );

      // 🕓 Estimación de tiempo y distancia
      final distanciaMetros = route['distance'] ?? 0;
      final duracionSeg = route['duration'] ?? 0;
      _distancia = (distanciaMetros / 1000).toStringAsFixed(1) + " km";
      _tiempoEstimado =
          (duracionSeg / 60).toStringAsFixed(0) + " min aprox";

      // 🧭 Instrucciones paso a paso
      final pasos = route['legs'][0]['steps'] as List;
      setState(() {
        _instrucciones = pasos.map<String>((s) {
          final maniobra = s['maneuver']['modifier'] ?? 'seguir';
          final nombre = s['name'] ?? 'camino';
          switch (maniobra) {
            case 'left':
              return "⬅️ Girar a la izquierda por $nombre";
            case 'right':
              return "➡️ Girar a la derecha por $nombre";
            default:
              return "⬆️ Seguir por $nombre";
          }
        }).toList();
        _paso = 0;
      });
    } catch (e) {
      debugPrint("❌ Error al generar ruta: $e");
    }
  }

  // ============================================================
  // 📡 Centra cámara en el usuario
  // ============================================================
  Future<void> _centrarCamara(double lat, double lon, {double? heading}) async {
    await map?.flyTo(
      mp.CameraOptions(
        center: mp.Point(coordinates: mp.Position(lon, lat)),
        zoom: 16.5,
        pitch: 50,
        bearing: heading ?? 0,
      ),
      mp.MapAnimationOptions(duration: 500),
    );
  }

  // ============================================================
  // 🚶 Actualiza progreso
  // ============================================================
  Future<void> _actualizarProgreso(double destLat, double destLon) async {
    if (_currentPos == null || _route == null || _recalculando) return;

    final distancia = gl.Geolocator.distanceBetween(
      _currentPos!.latitude,
      _currentPos!.longitude,
      destLat,
      destLon,
    );

    if (distancia < 5) {
      _posStream?.cancel();
      await _routeManager?.deleteAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎯 Has llegado al destino"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (!_estasEnRuta()) {
      _recalculando = true;
      await _dibujarRuta(destLat, destLon);
      _recalculando = false;
    }
  }

  bool _estasEnRuta() {
    if (_route == null || _currentPos == null) return true;
    const tolerancia = 15.0;
    for (final p in _route!.geometry.coordinates) {
      final dist = gl.Geolocator.distanceBetween(
        _currentPos!.latitude,
        _currentPos!.longitude,
        p.lat.toDouble(),
        p.lng.toDouble(),
      );
      if (dist < tolerancia) return true;
    }
    return false;
  }

  Future<void> _checkPermisos() async {
    bool activo = await gl.Geolocator.isLocationServiceEnabled();
    if (!activo) return Future.error('⚠️ GPS apagado');

    gl.LocationPermission permiso = await gl.Geolocator.checkPermission();
    if (permiso == gl.LocationPermission.denied) {
      permiso = await gl.Geolocator.requestPermission();
      if (permiso == gl.LocationPermission.denied) {
        return Future.error('❌ Permiso de ubicación denegado');
      }
    }
    if (permiso == gl.LocationPermission.deniedForever) {
      return Future.error('🚫 Permiso denegado permanentemente');
    }
  }
}
//comentario de mierda solo para ver si sube git o no 