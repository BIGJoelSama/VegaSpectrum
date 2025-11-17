// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
// 1. Importamos el AuthGate que acabamos de crear
import 'package:vega_spectrum_v2/screens/auth_gate.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Espera 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    // Comprobación de seguridad
    if (!mounted) return;

    // 2. Navegamos al AuthGate en lugar de al MainNavigator
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Usamos el color de fondo obsidiana
      backgroundColor: Color(0xFF000000), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'VegaSpectrum',
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.white, // Color de texto blanco
              ),
            ),
          ],
        ),
      ),
    );
  }
}