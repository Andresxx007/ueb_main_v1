import 'package:flutter/material.dart';
import 'home_page.dart'; // ✅ Usa import RELATIVO (no de paquete)

class LoginNewPage extends StatefulWidget {
  const LoginNewPage({super.key});

  @override
  State<LoginNewPage> createState() => _LoginNewPageState();
}

class _LoginNewPageState extends State<LoginNewPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _continue() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()), // ✅ ahora sí reconoce
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color rojoPrincipal = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'UBICATEC',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: rojoPrincipal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bienvenido a UBICATEC 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: rojoPrincipal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Campo nombre
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre (por defecto: Visitante)',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: rojoPrincipal, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo teléfono
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Número de teléfono',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: rojoPrincipal, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu teléfono';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Botón continuar
                  FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: rojoPrincipal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: rojoPrincipal.withOpacity(0.5), // 🔧 .withOpacity está bien aquí
                      elevation: 6,
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
