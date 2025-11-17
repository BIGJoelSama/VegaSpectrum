// lib/screens/selection_screen.dart

import 'package:flutter/material.dart';
import 'package:vega_spectrum_v2/screens/home_screen.dart';
import 'package:vega_spectrum_v2/widgets/glass_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  // --- CAMBIO CLAVE 1: Nueva Estructura de Datos ---
  // Ahora usamos un mapa anidado. Cada modelo tiene una lista [año_inicio, año_fin].
  final Map<String, Map<String, List<int>>> carData = {
    'Toyota': {
      'Corolla': [1995, 2024],
      'Yaris': [1999, 2024],
      'Hilux': [1995, 2024],
      'RAV4': [1995, 2024]
    },
    'Chevrolet': {
      'Spark': [2007, 2022],
      'Cruze': [2008, 2024],
      'Onix': [2012, 2024],
      'Silverado': [1999, 2024]
    },
    'Hyundai': {
      'Accent': [1995, 2024],
      'Tucson': [2004, 2024],
      'Santa Fe': [2000, 2024]
    },
    'Ford': {
      'Fiesta': [1995, 2019],
      'Focus': [1998, 2024],
      'Ranger': [1995, 2024],
      'Explorer': [1995, 2024]
    },
    'Nissan': {
      'Versa': [2006, 2024],
      'Sentra': [1995, 2024],
      'Kicks': [2016, 2024],
      'Frontier': [1998, 2024]
    },
    'Fiat': {
      'Mobi': [2016, 2024],
      'Cronos': [2018, 2024],
      'Argo': [2017, 2024],
      'Strada': [1996, 2024],
      'Brava': [1995, 2001]
    }
  };

  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;

  List<String> _availableModels = [];
  List<String> _availableYears = []; // <-- Nueva lista para los años

  void _navigateToScanner() {
    if (_selectedBrand != null && _selectedModel != null && _selectedYear != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            selectedBrand: _selectedBrand!,
            selectedModel: _selectedModel!,
            selectedYear: _selectedYear!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }

  // --- CAMBIO CLAVE 2: Lógica para generar la lista de años ---
  void _updateAvailableYears(String? brand, String? model) {
    if (brand == null || model == null) {
      _availableYears = [];
      return;
    }
    
    // Busca el rango de años [año_inicio, año_fin] en nuestro mapa
    final yearRange = carData[brand]?[model];
    
    if (yearRange != null && yearRange.length == 2) {
      final int startYear = yearRange[0];
      final int endYear = yearRange[1];
      
      // Genera la lista de años (ej. de 2024 a 2005)
      _availableYears = List.generate(
        endYear - startYear + 1,
        (index) => (endYear - index).toString()
      );
    } else {
      // Si no hay datos, usa una lista por defecto (opcional)
      _availableYears = List.generate(2025 - 1995, (index) => (2024 - index).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('VegaSpectrum'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/images/fondo.png"),
                  fit: BoxFit.cover,
                ),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2C2C2E).withOpacity(0.8),
                    const Color(0xFF000000).withOpacity(0.9),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.2,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: kToolbarHeight), 
                    const Text(
                      'Identifica el Vehículo',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

                    // --- Dropdown de MARCA ---
                    _buildDropdown('Marca', _selectedBrand, carData.keys.toList(), (value) {
                      setState(() {
                        _selectedBrand = value;
                        // Actualiza la lista de modelos
                        _availableModels = carData[value]?.keys.toList() ?? [];
                        // Resetea las selecciones de modelo y año
                        _selectedModel = null;
                        _availableYears = [];
                        _selectedYear = null;
                      });
                    }),
                    const SizedBox(height: 20),

                    // --- Dropdown de MODELO ---
                    _buildDropdown('Modelo', _selectedModel, _availableModels, 
                      // Se deshabilita si no hay marca
                      _selectedBrand == null ? null : (value) {
                        setState(() {
                          _selectedModel = value;
                          // Actualiza la lista de años
                          _updateAvailableYears(_selectedBrand, value);
                          // Resetea la selección de año
                          _selectedYear = null;
                        });
                      }
                    ),
                    const SizedBox(height: 20),

                    // --- Dropdown de AÑO ---
                    _buildDropdown('Año', _selectedYear, _availableYears,
                      // Se deshabilita si no hay modelo
                      _selectedModel == null ? null : (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      }
                    ),
                    const SizedBox(height: 60),

                    ElevatedButton.icon(
                      onPressed: _navigateToScanner,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Continuar al Escáner'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // (El widget _buildDropdown no cambia)
  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?>? onChanged) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: onChanged == null ? Colors.grey.withOpacity(0.5) : Colors.white.withOpacity(0.7))),
          value: value,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, color: onChanged == null ? Colors.grey.withOpacity(0.5) : Colors.white.withOpacity(0.7)),
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}