import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:house_help/screens/contractor/add_job_profile_screen.dart';

class DesiredProfiles extends StatefulWidget {
  const DesiredProfiles({super.key});

  @override
  State<DesiredProfiles> createState() => _DesiredProfilesState();
}

class _DesiredProfilesState extends State<DesiredProfiles> {
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

  Future<List<Map<String, dynamic>>> fetchPostulaciones(String solicitudId) async {
    final query = await FirebaseFirestore.instance
        .collection('postulaciones')
        .where('solicitudId', isEqualTo: solicitudId)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteRequest(String id) async {
    try {
      await FirebaseFirestore.instance.collection('solicitudes').doc(id).delete();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud eliminada exitosamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar la solicitud: \$e")),
      );
    }
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
              final cuidados = (req['tasks']['cuidados'] as List?)?.join(", ") ?? 'No hay tareas';
              final hogar = (req['tasks']['hogar'] as List?)?.join(", ") ?? 'No hay tareas';
              final start = req['fecha_inicio']?.substring(0, 10) ?? 'No disponible';
              final end = req['fecha_fin']?.substring(0, 10) ?? 'No disponible';
              final periodicidadPago = req['periodicidad_pago'] ?? 'No especificado';
              final cantidadPago = req['cantidad_pago'] ?? 0.0;

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
                              Text(periodicidadPago),
                              const SizedBox(height: 5),
                              const Text("Pago", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("\$$cantidadPago"),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddJobProfileScreen(editingRequest: req),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            child: const Text("Editar"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final postulaciones = await fetchPostulaciones(req['id']);

                              if (postulaciones.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Aún no hay postulaciones.")),
                                );
                                return;
                              }

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: ListView.builder(
                                      itemCount: postulaciones.length,
                                      itemBuilder: (context, index) {
                                        final post = postulaciones[index];
                                        return Card(
                                          child: ListTile(
                                            title: FutureBuilder<DocumentSnapshot>(
                                              future: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(post['helperId'])
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const Text("Cargando nombre...");
                                                } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                                  return const Text("Nombre no disponible");
                                                }

                                                final name = snapshot.data!.get('nombre') ?? 'Sin nombre';
                                                return Text(name, style: const TextStyle(fontWeight: FontWeight.bold));
                                              },
                                            ),
                                            subtitle: Text("Contraoferta: \$\${post['contraoferta']}"),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.check, color: Colors.green),
                                                  onPressed: () async {
                                                    await FirebaseFirestore.instance
                                                        .collection('postulaciones')
                                                        .doc(post['id'])
                                                        .update({'estado': 'aceptado'});
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Postulación aceptada')),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close, color: Colors.red),
                                                  onPressed: () async {
                                                    await FirebaseFirestore.instance
                                                        .collection('postulaciones')
                                                        .doc(post['id'])
                                                        .update({'estado': 'rechazado'});
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Postulación rechazada')),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddJobProfileScreen(),
              ),
            );
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
