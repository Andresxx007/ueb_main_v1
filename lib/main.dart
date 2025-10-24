/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/intro/intro_screen.dart';
import 'features/mapar/map_ar_screen.dart';
// import 'package:ubicatec_unificado/main.dart'; // Removed unused import


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UbicatecApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/intro', builder: (c, s) => const IntroScreen()),
    GoRoute(path: '/mapar', builder: (c, s) => const MapArScreen()),
  ],
);

class UbicatecApp extends StatelessWidget {
  const UbicatecApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UBICATEC',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}*/
