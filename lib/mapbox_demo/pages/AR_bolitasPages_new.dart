import 'package:flutter/material.dart';

class ARBolitasPagesNew extends StatelessWidget {
  const ARBolitasPagesNew({super.key});

  @override
  Widget build(BuildContext context) {
    // 🧭 Coordenadas del camino (en orden)
    final List<Map<String, dynamic>> camino = [
      {'lat': -17.7815185, 'lon': -63.1612936, 'label': 'Inicio'},
      {'lat': -17.7815592, 'lon': -63.1613101, 'label': 'Pasillo 1'},
      {'lat': -17.7815990, 'lon': -63.1613355, 'label': 'Pasillo 2'},
      {'lat': -17.7816350, 'lon': -63.1613559, 'label': 'Entrada Tecno'},
      {'lat': -17.7815629, 'lon': -63.1614225, 'label': 'Entrada Tecno'},
      {'lat': -17.7815629, 'lon': -63.1614225, 'label': 'Entrada Tecno'},
    ];

    const baseLat = -17.7815185;
    const baseLon = -63.1612936;

    return Scaffold(
      backgroundColor: Colors.transparent, // 👈 Se ve la cámara de HomePage
      appBar: AppBar(
        title: const Text("Ruta en cámara"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔴 Dibuja las bolitas del camino
          ..._buildCamino(context, camino, baseLat, baseLon),

          // 🔙 Botón volver
          Positioned(
            top: 30,
            left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.redAccent,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 📍 Construye las bolitas y sus etiquetas (camino visual)
  List<Widget> _buildCamino(BuildContext context,
      List<Map<String, dynamic>> puntos, double baseLat, double baseLon) {
    final List<Widget> widgets = [];

    for (int i = 0; i < puntos.length; i++) {
      final p = puntos[i];

      final dx = (p['lon'] - baseLon) * 111320; // desplazamiento X (m)
      final dz = (p['lat'] - baseLat) * 110540; // desplazamiento Z (m)

      // 🔢 Escalamos para que queden distribuidas visualmente
      final posX = 0.5 + (dx / 100) / MediaQuery.of(context).size.width;
      final posY = 0.6 - (dz / 100) / MediaQuery.of(context).size.height;

      widgets.add(Positioned(
        left: MediaQuery.of(context).size.width * posX.clamp(0.05, 0.9),
        top: MediaQuery.of(context).size.height * posY.clamp(0.05, 0.9),
        child: Column(
          children: [
            Image.asset(
              'assets/icons/punto_mapa_rojo_f.png',
              width: 55,
              height: 55,
            ),
            const SizedBox(height: 4),
            Text(
              p['label'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                  )
                ],
              ),
            ),
          ],
        ),
      ));
    }

    return widgets;
  }
}
