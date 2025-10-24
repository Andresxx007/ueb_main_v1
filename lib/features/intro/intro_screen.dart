import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_ueb.png', width: 180, height: 180),
                const SizedBox(height: 24),
                const Text('Bienvenidos a Ubicatec',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.red)),
                const SizedBox(height: 8),
                const Text('Tu guía para moverte por el campus universitario',
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/mapar'),
                    child: const Text('COMENZAR'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
