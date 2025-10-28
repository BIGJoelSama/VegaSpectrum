// tool/upload_data.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ IMPORTANTE: Importamos los servicios de assets
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vega_spectrum_v2/firebase_options.dart';

// --- CONFIGURACIÓN ---
// ✅ CAMBIO: Ahora es una ruta de asset, no una ruta de disco
const String jsonAssetPath = 'assets/data/datos.json';
const String collectionName = 'codigos_pintura';
// --- FIN DE LA CONFIGURACIÓN ---

class UploaderApp extends StatelessWidget {
  const UploaderApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Center(child: Text("Subiendo datos..."))));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UploaderApp());

  print('>>> Entorno de Flutter listo. Iniciando subida de datos...');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('>>> Firebase inicializado correctamente.');

  final firestore = FirebaseFirestore.instance;
  
  try {
    // ✅ CAMBIO CLAVE: Leemos el archivo como un asset de la app
    final String content = await rootBundle.loadString(jsonAssetPath);
    print('>>> Archivo JSON encontrado y leído como asset.');

    final List<dynamic> data = json.decode(content);
    print('>>> Se encontraron ${data.length} registros para procesar.');

    final collectionRef = firestore.collection(collectionName);
    int addedCount = 0;
    int skippedCount = 0;

    for (var item in data) {
      final query = await collectionRef
          .where('marca', isEqualTo: item['marca'])
          .where('codigo_pintura', isEqualTo: item['codigo_pintura'])
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        await collectionRef.add(item);
        addedCount++;
        print('AGREGADO: ${item['marca']} ${item['nombre_color']}');
      } else {
        skippedCount++;
        print('OMITIDO (ya existe): ${item['marca']} ${item['nombre_color']}');
      }
    }

    print('\n>>> ¡PROCESO COMPLETADO!');
    print('   Registros nuevos agregados: $addedCount');
    print('   Registros omitidos (duplicados): $skippedCount');

  } catch (e) {
    print('>>> ERROR FATAL: No se pudo cargar o procesar el archivo de asset.');
    print('>>> Asegúrate de que la ruta "$jsonAssetPath" sea correcta y que esté declarada en pubspec.yaml.');
    print('>>> Error original: $e');
    exit(1);
  }
  
  exit(0);
}