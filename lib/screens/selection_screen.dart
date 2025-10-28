// lib/screens/selection_screen.dart

import 'package:flutter/material.dart';
import 'package:vega_spectrum_v2/screens/home_screen.dart';
import 'package:vega_spectrum_v2/widgets/glass_container.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;

  final Map<String, List<String>> carData = {
    'Toyota': ['Corolla', 'Yaris', 'Hilux', 'RAV4'],
    'Chevrolet': ['Spark', 'Cruze', 'Onix', 'Silverado'],
    'Hyundai': ['Accent', 'Tucson', 'Santa Fe'],
    'Ford': ['Fiesta', 'Focus', 'Ranger', 'Explorer'],
    'Nissan': ['Versa', 'Sentra', 'Kicks', 'Frontier'],
    'Fiat': ['Mobi', 'Cronos', 'Argo', 'Strada', 'Brava']
  };

  List<String> _availableModels = [];
  final List<String> _years = List.generate(2025 - 1995, (index) => (2024 - index).toString());

  // Función de navegación al escáner (sin cambios)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Text('Identifica el Vehículo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 50),
                    _buildDropdown('Marca', _selectedBrand, carData.keys.toList(), (value) {
                      setState(() {
                        _selectedBrand = value;
                        _selectedModel = null;
                        _availableModels = carData[value] ?? [];
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildDropdown('Modelo', _selectedModel, _availableModels, _selectedBrand == null ? null : (value) {
                      setState(() => _selectedModel = value);
                    }),
                    const SizedBox(height: 20),
                    _buildDropdown('Año', _selectedYear, _years, (value) {
                      setState(() => _selectedYear = value);
                    }),
                    const SizedBox(height: 40),
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
                    // ✅ NOTA: Eliminamos el TextButton de la galería
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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