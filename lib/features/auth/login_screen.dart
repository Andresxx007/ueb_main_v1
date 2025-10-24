// file: lib/features/auth/login_screen.dart
// file: lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
// import 'package:permission_handler/permission_handler.dart'; // Temporalmente deshabilitado


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _error = '';

  /// Validación de número de teléfono más flexible
  String? _validatePhone(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Ingresa tu teléfono';
    
    String phone = raw.trim();
    
    // Remover espacios, guiones y paréntesis
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si no empieza con +, asumir que es número boliviano
    if (!phone.startsWith('+')) {
      // Si empieza con 591, agregar +
      if (phone.startsWith('591')) {
        phone = '+$phone';
      }
      // Si empieza con 7, agregar +591
      else if (phone.startsWith('7') && phone.length >= 8) {
        phone = '+591$phone';
      }
      // Si es un número local, agregar +5917
      else if (phone.length >= 7 && phone.length <= 8) {
        phone = '+5917$phone';
      }
    }
    
    try {
      final parsed = PhoneNumber.parse(phone, callerCountry: IsoCode.BO);
      if (!parsed.isValid()) {
        return 'Número inválido. Ej: 7xxxxxxx o +5917xxxxxxx';
      }
    } catch (_) {
      return 'Formato inválido. Ej: 7xxxxxxx o +5917xxxxxxx';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UBICATEC')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Coloca tu nombre',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      key: const Key('name_field'),
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre (por defecto: Visitante)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('phone_field'),
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Número de teléfono',
                        hintText: 'Ej: 7xxxxxxx o +5917xxxxxxx',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                    if (_error.isNotEmpty)
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final ok = _formKey.currentState?.validate() ?? false;
                          if (ok) {
                            context.go('/intro'); // navega a intro
                          }
                        },
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
