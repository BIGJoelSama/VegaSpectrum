

// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Necesario para el efecto de desenfoque (blur)

import 'firebase_options.dart';
import 'package:vega_spectrum_v2/providers/theme_provider.dart';
import 'package:vega_spectrum_v2/config/theme.dart';
import 'package:vega_spectrum_v2/screens/splash_screen.dart';
import 'package:vega_spectrum_v2/screens/history_code_screen.dart';
import 'package:vega_spectrum_v2/screens/selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const VegaSpectrumApp(),
    ),
  );
}

class VegaSpectrumApp extends StatelessWidget {
  const VegaSpectrumApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Vega Spectrum',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const SelectionScreen(),
    const HistoryCodeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permite que el cuerpo se dibuje detrás de la barra de navegación
      extendBody: true,
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // Envolvemos la barra para aplicar el efecto de vidrio
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: BottomNavigationBar(
            // Hacemos la barra transparente y ajustamos colores
            backgroundColor: Colors.white.withOpacity(0.1),
            elevation: 0, // Quitamos la sombra
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                // ✅ Ícono actualizado para "Escanear"
                icon: Icon(Icons.center_focus_strong),
                label: 'Escanear',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historial',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}