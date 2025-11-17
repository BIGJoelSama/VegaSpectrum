// lib/screens/history_code_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vega_spectrum_v2/widgets/glass_container.dart';

class HistoryCodeScreen extends StatefulWidget {
  const HistoryCodeScreen({super.key});

  @override
  State<HistoryCodeScreen> createState() => _HistoryCodeScreenState();
}

class _HistoryCodeScreenState extends State<HistoryCodeScreen> {
  final _auth = FirebaseAuth.instance;

  Future<void> _confirmDeleteHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('¿Estás seguro de que quieres borrar todo tu historial? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteHistory();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('scan_history')
        .where('idUsuario', isEqualTo: user.uid)
        .get();
    if (querySnapshot.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial borrado con éxito.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // --- ✅ CAMBIO CLAVE: Hace que el título y los íconos sean blancos ---
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _confirmDeleteHistory,
            tooltip: 'Borrar historial',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [const Color(0xFF2C2C2E), const Color(0xFF000000)],
                  center: Alignment.topLeft,
                  radius: 1.2,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scan_history')
                  .where('idUsuario', isEqualTo: _auth.currentUser?.uid)
                  .orderBy('scanDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar el historial.', style: TextStyle(color: Colors.white70)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aún no hay escaneos en tu historial.',
                      style: TextStyle(fontSize: 18, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 50, 12, 12),
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
                            '${data['marca'] ?? ''} - ${data['modelo'] ?? 'N/A'} - ${data['codigo_pintura'] ?? ''}',
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