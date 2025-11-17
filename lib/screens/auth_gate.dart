// lib/screens/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vega_spectrum_v2/main.dart'; // Para obtener MainNavigator
import 'package:vega_spectrum_v2/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Se suscribe a los cambios de estado de autenticación
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si está cargando la verificación
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra una pantalla de carga temporal
          return const Scaffold(
            backgroundColor: Color(0xFF000000), // Fondo obsidiana
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si SÍ tiene datos (usuario logueado)
        if (snapshot.hasData) {
          return const MainNavigator(); // Muestra la app principal
        }

        // Si NO tiene datos (usuario no logueado)
        return const LoginScreen(); // Muestra la pantalla de login
      },
    );
  }
}