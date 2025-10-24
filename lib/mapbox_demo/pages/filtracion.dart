import 'package:flutter/material.dart';
import '../../data/lugares_ueb.dart'; // ✅ Import del archivo de datos central

class FiltracionPage extends StatefulWidget {
  const FiltracionPage({super.key});

  @override
  State<FiltracionPage> createState() => _FiltracionPageState();
}

class _FiltracionPageState extends State<FiltracionPage> {
  final TextEditingController _searchController = TextEditingController();
  String filtroSeleccionado = "Todos";

  // ✅ Usamos los lugares desde lugares_ueb.dart
  final List<Map<String, dynamic>> lugares = lugaresUeb;

  // 🎯 Categorías visuales (se mantienen aquí)
  final List<String> categorias = [
    "Todos",
    "💻 Tecnología e Ingeniería",
    "📘 Aulas Académicas",
    "🔬 Laboratorios",
    "🧬 Medicina y Ciencias de la Salud",
    "🚻 Baños",
    "☕ Comida y Cafeterías",
    "📖 Biblioteca y Cómputo",
    "🎵 Arte y Cultura",
    "🗣 Comunicación y Humanidades",
    "🚪 Entradas y Accesos",
    "🧾 Administración y Oficinas",
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final lugaresFiltrados = lugares.where((l) {
      final matchTexto = l["nombre"].toLowerCase().contains(query);
      final matchCategoria = filtroSeleccionado == "Todos"
          ? true
          : l["categoria"] == filtroSeleccionado;
      return matchTexto && matchCategoria;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          "Buscar Lugares - UBICATEC",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Barra de búsqueda
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Buscar aulas, laboratorios o servicios...",
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.redAccent),
              ),
            ),
          ),

          // 🏷️ Filtros por categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: categorias.map((cat) {
                final activo = filtroSeleccionado == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: activo,
                    onSelected: (_) => setState(() => filtroSeleccionado = cat),
                    selectedColor: Colors.redAccent,
                    labelStyle: TextStyle(
                      color: activo ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 📋 Lista filtrada
          Expanded(
            child: ListView.builder(
              itemCount: lugaresFiltrados.length,
              itemBuilder: (context, index) {
                final l = lugaresFiltrados[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.location_on,
                        color: Colors.redAccent, size: 34),
                    title: Text(
                      l["nombre"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Text("${l["ubicacion"]} • ${l["categoria"]}"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          "nombre": l["nombre"],
                          "lat": l["lat"],
                          "lon": l["lon"],
                        });
                      },
                      child: const Text("Ir",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Botón final
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () =>
                  Navigator.pop(context, {"mostrarTodos": true}),
              icon: const Icon(Icons.map),
              label: const Text(
                "Mostrar todos los lugares",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
