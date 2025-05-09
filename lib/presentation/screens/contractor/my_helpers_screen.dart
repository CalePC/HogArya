import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RateHelperScreen.dart';

class MyHelpersScreen extends StatefulWidget {
  const MyHelpersScreen({super.key});

  @override
  _MyHelpersScreenState createState() => _MyHelpersScreenState();
}

class _MyHelpersScreenState extends State<MyHelpersScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchAyudantes() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('postulaciones')
        .where('contractorId', isEqualTo: uid)
        .where('estado', isEqualTo: 'aceptado')
        .get();

    List<Map<String, dynamic>> ayudantes = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      final solicitudDoc = await FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(data['solicitudId'])
          .get();
      final solicitudData = solicitudDoc.data();
      if (solicitudData != null) {
        data['solicitud'] = solicitudData;
      }

      final helperDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(data['helperId'])
          .get();
      final helperData = helperDoc.data();
      if (helperData != null) {
        data['helper'] = helperData;
      }

      ayudantes.add(data);
    }

    return ayudantes;
  }

  Future<void> _despedirAyudante(String helperId) async {
    try {
      await FirebaseFirestore.instance
          .collection('postulaciones')
          .doc(helperId)
          .update({'estado': 'despedido'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayudante despedido exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al despedir ayudante: $e")),
      );
    }
  }

  void _administrarTareas(String helperId) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tus ayudantes")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAyudantes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ayudantes = snapshot.data!;
          if (ayudantes.isEmpty) {
            return const Center(child: Text("No tienes ayudantes vinculados."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: ayudantes.length,
            itemBuilder: (context, index) {
              final ayudante = ayudantes[index];
              final nombre = ayudante['helper']['nombre'] ?? 'Nombre no disponible';
              final helperId = ayudante['helperId'];
              final solicitud = ayudante['solicitud'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),

                      Text("Solicitud: ${solicitud?['periodicidad_pago'] ?? 'No disponible'}"),
                      const SizedBox(height: 8),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _despedirAyudante(helperId);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text("Despedir"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _administrarTareas(helperId);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: const Text("Administrar tareas"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RateHelperScreen(helperName: nombre, helperId: helperId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text("Calificar"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
