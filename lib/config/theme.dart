// lib/config/theme.dart

// lib/config/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  
  // Tema Claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue, // Color principal para botones, etc.
    scaffoldBackgroundColor: Colors.white, // Color de fondo de las pantallas
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  // Tema Oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.teal;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.teal.withOpacity(0.5);
        }
        return null; // A CADA 'return' LE CORRESPONDE UN 'if'
      }), // <-- ✅ FALTABA ESTE PARÉNTESIS Y COMA
    ),  // <-- ✅ FALTABA ESTE PARÉNTESIS Y COMA
  );    // <-- ✅ FALTABA ESTE PARÉNTESIS Y EL PUNTO Y COMA FINAL
}