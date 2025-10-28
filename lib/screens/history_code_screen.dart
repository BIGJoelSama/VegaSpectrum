// lib/screens/history_code_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vega_spectrum_v2/widgets/glass_container.dart';

class HistoryCodeScreen extends StatelessWidget {
  const HistoryCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- CAMBIO: Se eliminaron las propiedades 'appBar' y 'extendBodyBehindAppBar' ---
      
      body: Stack(
        children: [
          // Capa 1: Fondo con degradado obsidiana
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2C2C2E), // Gris grafito
                    const Color(0xFF000000), // Negro puro
                  ],
                  center: Alignment.topLeft,
                  radius: 1.2,
                ),
              ),
            ),
          ),

          // Capa 2: Textura sutil para efecto metálico
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/fondo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Capa 3: Contenido de la UI (la lista del historial)
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scan_history')
                  .orderBy('scanDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar el historial.', style: TextStyle(color: Colors.white70)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aún no hay escaneos en tu historial.',
                      style: TextStyle(fontSize: 18, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(12.0),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    final data = document.data()! as Map<String, dynamic>;
                    final colorHex = data['valor_hex'] as String? ?? '000000';
                    final displayColor = Color(int.parse('FF$colorHex', radix: 16));

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: displayColor,
                            radius: 25,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              ),
                            ),
                          ),
                          title: Text(
                            data['nombre_color'] ?? 'Color Desconocido',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '${data['marca'] ?? ''} - ${data['codigo_pintura'] ?? ''}',
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}