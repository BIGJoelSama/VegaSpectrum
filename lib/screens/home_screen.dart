// lib/screens/home_screen.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final String selectedBrand;
  final String selectedModel;
  final String selectedYear;

  const HomeScreen({
    super.key,
    required this.selectedBrand,
    required this.selectedModel,
    required this.selectedYear,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _colorMatchThreshold = 70.0;
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  String _statusText = 'Apunta con la mira y presiona el botón';
  Map<String, dynamic>? _paintCodeData;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.high, enableAudio: false);
    _initializeControllerFuture = _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  // ... (Todas las funciones de lógica: _captureAndProcess, _saveScanToHistory, _findClosestPaintCode, etc. no cambian) ...
  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      setState(() { _isSearching = true; _statusText = 'Analizando color...'; _paintCodeData = null; });
      final image = await _cameraController!.takePicture();
      final imageFile = File(image.path);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(FileImage(imageFile), maximumColorCount: 20);
      final dominantColor = paletteGenerator.dominantColor?.color;
      if (dominantColor != null) {
        setState(() { _statusText = 'Buscando en ${widget.selectedBrand}... 🔍'; });
        await _findClosestPaintCode(dominantColor);
      } else {
        setState(() => _statusText = 'No se pudo detectar un color.');
      }
    } catch (e) {
      print('Error al capturar imagen: $e');
      setState(() => _statusText = 'Error al capturar la imagen.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _saveScanToHistory(Map<String, dynamic> paintData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('scan_history').add({
        'idUsuario': user.uid,
        'marca': paintData['marca'],
        'modelo': paintData['modelo'] ?? widget.selectedModel,
        'nombre_color': paintData['nombre_color'],
        'codigo_pintura': paintData['codigo_pintura'],
        'valor_hex': paintData['valor_hex'],
        'scanDate': Timestamp.now(),
      });
      print(">>> Resultado guardado en el historial.");
    } catch (e) {
      print(">>> Error al guardar en el historial: $e");
    }
  }

  Future<void> _findClosestPaintCode(Color detectedColor) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('codigos_pintura')
          .where('marca', isEqualTo: widget.selectedBrand)
          .get();
      if (snapshot.docs.isEmpty) {
        setState(() => _statusText = 'No hay datos para la marca "${widget.selectedBrand}".');
        return;
      }
      double minDistance = double.infinity;
      DocumentSnapshot? bestMatch;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final hexString = data['valor_hex'] as String?;
        if (hexString != null) {
          final dbColor = _hexToColor(hexString);
          final distance = _calculateColorDifference(detectedColor, dbColor);
          if (distance < minDistance) {
            minDistance = distance;
            bestMatch = doc;
          }
        }
      }
      if (bestMatch != null && minDistance < _colorMatchThreshold) {
        final paintData = bestMatch.data() as Map<String, dynamic>;
         if (mounted) {
          setState(() { _paintCodeData = paintData; _statusText = '¡Coincidencia encontrada!'; });
        }
        await _saveScanToHistory(paintData);
      } else {
         if (mounted) {
          setState(() { _statusText = 'No se encontraron coincidencias confiables.'; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusText = 'Error al conectar con la base de datos.');
      }
      print('Error en Firestore: $e');
    }
  }

  double _calculateColorDifference(Color c1, Color c2) {
    return sqrt(pow(c1.red - c2.red, 2) + pow(c1.green - c2.green, 2) + pow(c1.blue - c2.blue, 2));
  }
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear: ${widget.selectedBrand}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      extendBodyBehindAppBar: true, 
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return buildScannerUI();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // --- ✅ FUNCIÓN DE UI ACTUALIZADA ---
  Widget buildScannerUI() {
    if (!_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    
    // Esta es la fórmula oficial para calcular la escala correcta
    // y rellenar la pantalla (BoxFit.cover)
    var scale = 1.0;
    try {
      scale = 1 / (_cameraController!.value.aspectRatio * size.aspectRatio);
    } catch (_) {
      // Maneja el caso en que el aspect ratio aún no esté listo
      print("Error al calcular el aspect ratio, usando escala 1.0");
    }

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        // --- CAMBIO CLAVE: Lógica de escalado oficial ---
        Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter, // Asegura que se alinee desde el centro
          child: CameraPreview(_cameraController!),
        ),
        
        // El resto de la UI (mira y panel inferior) no cambia
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: buildBottomPanel(),
        ),
      ],
    );
  }
  
  Widget buildBottomPanel() {
    return Column(
      children: [
        if (_isSearching)
          const CircularProgressIndicator(color: Colors.white)
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusText,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        if (_paintCodeData != null)
          Card(
            color: Colors.black.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Color: ${_paintCodeData!['nombre_color'] ?? 'N/A'}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                  Text('Código: ${_paintCodeData!['codigo_pintura'] ?? 'N/A'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        FloatingActionButton.large(
          onPressed: _isSearching ? null : _captureAndProcess,
          child: const Icon(Icons.camera),
        ),
      ],
    );
  }
}