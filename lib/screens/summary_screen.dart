import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final query = await FirebaseFirestore.instance
        .collection('solicitudes')
        .where('uid', isEqualTo: uid)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteRequest(String id) async {
    await FirebaseFirestore.instance.collection('solicitudes').doc(id).delete();
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfiles deseados")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return const Center(child: Text("No hay solicitudes activas"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              final cuidados = (req['tasks']['cuidados'] as List).join(", ");
              final hogar = (req['tasks']['hogar'] as List).join(", ");
              final start = req['fecha_inicio']?.substring(0, 10) ?? '';
              final end = req['fecha_fin']?.substring(0, 10) ?? '';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("$start - $end",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Cuidados", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(cuidados),
                                const SizedBox(height: 5),
                                const Text("Hogar", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(hogar),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Periodicidad", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(req['periodicidad_pago']),
                              const SizedBox(height: 5),
                              const Text("Pago", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("\$${req['cantidad_pago']}"),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Navegar a pantalla de edición
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            child: const Text("Editar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Mostrar número de solicitudes recibidas
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Tienes 2 solicitudes")),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade600),
                            child: const Text("Solicitudes"),
                          ),
                          ElevatedButton(
                            onPressed: () => deleteRequest(req['id']),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Eliminar"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/request'); // ruta de tu pantalla para crear solicitud
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Crear", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
