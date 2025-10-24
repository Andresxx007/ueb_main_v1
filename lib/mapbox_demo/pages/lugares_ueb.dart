// 📍 Archivo central de lugares UEB
// Todos los lugares de la universidad — unificados para mapa y buscador

final List<Map<String, dynamic>> lugaresUeb = [
  // 💻 TECNOLOGÍA E INGENIERÍA
  {"nombre": "Facultad de Tecnología (Nueva)", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Edificio Principal", "lat": -17.8347233, "lon": -63.2041646},
  {"nombre": "Ingeniería de Software", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Bloque de Tecnología", "lat": -17.8343737, "lon": -63.2042894},
  {"nombre": "Área Industrial", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Zona Industrial", "lat": -17.8342716, "lon": -63.204314},
  {"nombre": "Laboratorio de Tecnología", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Zona de Laboratorios", "lat": -17.834294, "lon": -63.2042903},
  {"nombre": "CAD / Simulación", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Laboratorio de Simulación", "lat": -17.8343566, "lon": -63.2043036},
  {"nombre": "Fab Lab", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Laboratorio de Fabricación", "lat": -17.8343654, "lon": -63.2042389},
  {"nombre": "Laboratorio de Robótica", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Zona Robótica", "lat": -17.8343273, "lon": -63.204222},
  {"nombre": "Sala de Aplicaciones", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Sala Académica", "lat": -17.8343152, "lon": -63.2042299},
  {"nombre": "Laboratorio de Electrónica", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Bloque 6", "lat": -17.8363048, "lon": -63.2042021},
  {"nombre": "Laboratorio de Automatización", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Bloque 6", "lat": -17.8362729, "lon": -63.204274},
  {"nombre": "Electromecánica", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Bloque 7", "lat": -17.8362153, "lon": -63.2040908},
  {"nombre": "Laboratorio de Física", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Bloque 7", "lat": -17.8361273, "lon": -63.204051},
  {"nombre": "Centro de Sistemas (CSI)", "categoria": "💻 Tecnología e Ingeniería", "ubicacion": "Bloque 3", "lat": -17.8348701, "lon": -63.2040434},

  // 📘 AULAS ACADÉMICAS
  {"nombre": "Aula 106", "categoria": "📘 Aulas Académicas", "ubicacion": "Pabellón Aula Magna", "lat": -17.8355283, "lon": -63.2045451},
  {"nombre": "Aula 107", "categoria": "📘 Aulas Académicas", "ubicacion": "Pabellón Aula Magna", "lat": -17.8355549, "lon": -63.2046055},
  {"nombre": "Aula 108", "categoria": "📘 Aulas Académicas", "ubicacion": "Pabellón Aula Magna", "lat": -17.8355816, "lon": -63.2045724},
  {"nombre": "Aula 221", "categoria": "📘 Aulas Académicas", "ubicacion": "Bloque 6", "lat": -17.836124, "lon": -63.2046356},
  {"nombre": "Aula 222", "categoria": "📘 Aulas Académicas", "ubicacion": "Bloque 6", "lat": -17.8360743, "lon": -63.2045532},
  {"nombre": "Aula 223", "categoria": "📘 Aulas Académicas", "ubicacion": "Bloque 6", "lat": -17.8361271, "lon": -63.204476},
  {"nombre": "Aula 224", "categoria": "📘 Aulas Académicas", "ubicacion": "Bloque 6", "lat": -17.8361893, "lon": -63.2043644},
  {"nombre": "Aulas 225 a 240", "categoria": "📘 Aulas Académicas", "ubicacion": "Bloques 6–7", "lat": -17.8361017, "lon": -63.2040222},
  {"nombre": "CS1 a CS5", "categoria": "📘 Aulas Académicas", "ubicacion": "Bloque 3 Medicina", "lat": -17.8348701, "lon": -63.2040434},
  {"nombre": "Aula Magna", "categoria": "📘 Aulas Académicas", "ubicacion": "Centro Académico", "lat": -17.8360723, "lon": -63.2044647},

  // 🔬 LABORATORIOS
  {"nombre": "Laboratorio de Simulación Médica", "categoria": "🔬 Laboratorios", "ubicacion": "Bloque 4", "lat": -17.8348833, "lon": -63.2040148},
  {"nombre": "Laboratorio de Anatomía", "categoria": "🔬 Laboratorios", "ubicacion": "Bloque Medicina Antigua", "lat": -17.8349962, "lon": -63.2044123},
  {"nombre": "Laboratorio de Histología y Fisiología", "categoria": "🔬 Laboratorios", "ubicacion": "Medicina Antigua", "lat": -17.8350219, "lon": -63.2044212},

  // 🧬 MEDICINA Y CIENCIAS DE LA SALUD
  {"nombre": "Facultad de Medicina Antigua", "categoria": "🧬 Medicina y Ciencias de la Salud", "ubicacion": "Zona Sur", "lat": -17.8348986, "lon": -63.2045476},
  {"nombre": "Anfiteatro de Medicina", "categoria": "🧬 Medicina y Ciencias de la Salud", "ubicacion": "Facultad de Medicina", "lat": -17.8348879, "lon": -63.2044798},

  // ☕ COMIDA Y CAFETERÍAS
  {"nombre": "Cafetería Central", "categoria": "☕ Comida y Cafeterías", "ubicacion": "Bloque 1", "lat": -17.8343371, "lon": -63.2043598},
  {"nombre": "Cafetería Medicina", "categoria": "☕ Comida y Cafeterías", "ubicacion": "Zona Medicina", "lat": -17.8356784, "lon": -63.2039997},

  // 📖 BIBLIOTECA Y CÓMPUTO
  {"nombre": "Biblioteca Central", "categoria": "📖 Biblioteca y Cómputo", "ubicacion": "Bloque 5", "lat": -17.8358866, "lon": -63.204959},
  {"nombre": "Centro de Cómputo", "categoria": "📖 Biblioteca y Cómputo", "ubicacion": "Bloque 5", "lat": -17.8360213, "lon": -63.2049052},

  // 🎵 ARTE Y CULTURA
  {"nombre": "Sala de Música (Guitar 1,211,210)", "categoria": "🎵 Arte y Cultura", "ubicacion": "Bloque 5", "lat": -17.8359781, "lon": -63.2049467},

  // 🚪 ENTRADAS Y ACCESOS
  {"nombre": "Entrada Principal UEB", "categoria": "🚪 Entradas y Accesos", "ubicacion": "Acceso Norte Universidad", "lat": -17.8367295, "lon": -63.2050577},
];
