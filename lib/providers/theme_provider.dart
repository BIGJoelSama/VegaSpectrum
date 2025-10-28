// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Por defecto, usa el tema del sistema
  
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // Carga el tema guardado cuando la app inicia
  }

  // Método para cambiar el tema
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(); // Guarda la nueva preferencia
    notifyListeners(); // Notifica a los widgets que el estado ha cambiado
  }

  // Cargar la preferencia de tema desde el almacenamiento
  _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Leemos el valor 'isDark'. Si no existe, devuelve 'null'.
    final isDark = prefs.getBool('isDark');
    
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    // Si es null, se queda en ThemeMode.system
    notifyListeners();
  }

  // Guardar la preferencia de tema
  _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Guardamos 'true' si es oscuro, 'false' si es claro.
    prefs.setBool('isDark', _themeMode == ThemeMode.dark);
  }
}