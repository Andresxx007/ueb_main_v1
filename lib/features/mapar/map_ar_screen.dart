import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

// ✅ Importa el AR plugin y sus managers explícitos - Temporalmente deshabilitado
// import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';

import '../../services/ar_anchor_config.dart';


class MapArScreen extends StatefulWidget {
  const MapArScreen({super.key});
  @override
  State<MapArScreen> createState() => _MapArScreenState();
}

class _MapArScreenState extends State<MapArScreen> {
  GoogleMapController? _gmap;
  // ARSessionManager? _arSessionManager;
  // ARObjectManager? _arObjectManager;
  // ARAnchorManager? _arAnchorManager;
  // bool _isARInitialized = false;
  // String? _arError;

  final PanelController _panel = PanelController();
  final _initialCam = const CameraPosition(
    target: LatLng(-17.7833, -63.1821),
    zoom: 17.2,
  );

  @override
  void dispose() {
    // _arSessionManager?.dispose();
    _gmap?.dispose();
    super.dispose();
  }

  // Future<void> _onARInit(
  //   ARSessionManager arSessionManager,
  //   ARObjectManager arObjectManager,
  //   ARAnchorManager arAnchorManager,
  //   ARLocationManager arLocationManager,
  // ) async {
  //   try {
  //     if (mounted) {
  //       setState(() {
  //         _arSessionManager = arSessionManager;
  //         _arObjectManager = arObjectManager;
  //         _arAnchorManager = arAnchorManager;
  //         _arError = null;
  //       });

  //       // Configuración básica de la sesión
  //       await _arSessionManager!.onInitialize(
  //         showFeaturePoints: false,
  //         showPlanes: false,
  //         showWorldOrigin: false,
  //       );
  //       await _arObjectManager!.onInitialize();
        
  //       if (mounted) {
  //         setState(() {
  //           _isARInitialized = true;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _arError = 'Error al inicializar AR: $e';
  //         _isARInitialized = false;
  //       });
  //     }
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _panel,
        minHeight: 68,
        maxHeight: MediaQuery.of(context).size.height * 0.95,
        parallaxEnabled: true,
        parallaxOffset: 0.2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        body: _buildMap(),
        panelBuilder: () => _buildARPanel(),
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        // Mapa con manejo de errores mejorado
        GoogleMap(
          initialCameraPosition: _initialCam,
          onMapCreated: (GoogleMapController controller) async {
            try {
              _gmap = controller;
              if (mounted) {
                // final style = await DefaultAssetBundle.of(context).loadString('assets/map_style_dark.json');
                // await _gmap?.setMapStyle(style); // Deprecated method - commented out
              }
            } catch (e) {
              debugPrint('Error al cargar el estilo del mapa: $e');
            }
          },
          myLocationEnabled: false, // Deshabilitado temporalmente para evitar errores
          myLocationButtonEnabled: false,
          compassEnabled: false,
          polylines: ArAnchorConfig.debugRoute,
          onTap: (LatLng position) {
            // Manejo de taps en el mapa si es necesario
          },
        ),
        Positioned(
          top: 40, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
            decoration: BoxDecoration(
              color: Colors.red.shade700, borderRadius: BorderRadius.circular(12)),
            child: const Text('Hacia Laboratorios de Tecnología',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
        Positioned(
          right: 16, bottom: 90,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () => _panel.open(),
            label: const Text('COMENZAR POR CÁMARA'),
          ),
        ),
      ],
    );
  }

  Widget _buildARPanel() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('moises • Entrada', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () => _panel.close(),
                child: const Text('CANCELAR'),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildARPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildARPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Cámara AR',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Funcionalidad AR temporalmente deshabilitada\npara resolver problemas de compatibilidad',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _panel.close(),
              child: const Text('Cerrar'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nota: Los errores de cámara en la terminal son normales\ncuando la funcionalidad AR está deshabilitada',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
