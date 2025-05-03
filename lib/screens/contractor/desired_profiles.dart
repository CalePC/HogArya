import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:house_help/screens/contractor/add_job_profile_screen.dart';
import 'package:house_help/screens/contractor/contractor_resume_screen.dart';
import '../contractor/my_helpers_screen.dart';

class DesiredProfiles extends StatefulWidget {
  const DesiredProfiles({super.key});

  @override
  State<DesiredProfiles> createState() => _DesiredProfilesState();
}

class _DesiredProfilesState extends State<DesiredProfiles> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  int _currentIndex = 0;

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
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tareas')
          .where('solicitudId', isEqualTo: id)
          .get();
      for (var doc in tasksSnapshot.docs) {
        await doc.reference.delete();
      }
      await FirebaseFirestore.instance.collection('solicitudes').doc(id).delete();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solicitud y tareas eliminadas exitosamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar la solicitud: $e")),
      );
    }
  }

  Future<void> acceptPostulation(String postId, String helperId, String solicitudId) async {
    try {
      await FirebaseFirestore.instance
          .collection('postulaciones')
          .doc(postId)
          .update({
        'estado': 'aceptado',
        'contractorId': FirebaseAuth.instance.currentUser!.uid,
      });

      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tareas')
          .where('solicitudId', isEqualTo: solicitudId)
          .get();
      for (var doc in tasksSnapshot.docs) {
        await doc.reference.update({'helperId': helperId});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postulación aceptada y tareas asignadas')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al aceptar la postulación: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfiles deseados"),
      ),
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final cuidados =
                  (req['tasks']['cuidados'] as List?)?.join(", ") ?? '–';
              final hogar =
                  (req['tasks']['hogar'] as List?)?.join(", ") ?? '–';
              final start = req['fecha_inicio']?.substring(0, 10) ?? '–';
              final end = req['fecha_fin']?.substring(0, 10) ?? '–';
              final periodicidadPago = req['periodicidad_pago'] ?? '–';
              final cantidadPago = req['cantidad_pago'] ?? 0.0;

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Text(
                          "$start - $end",
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text("Cuidados",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(cuidados),
                                const SizedBox(height: 8),
                                const Text("Hogar",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(hogar),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text("Periodicidad",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(periodicidadPago),
                              const SizedBox(height: 8),
                              const Text("Pago",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("\$$cantidadPago"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddJobProfileScreen(editingRequest: req),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent),
                            child: const Text("Editar"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final postulaciones =
                              await fetchPostulaciones(req['id']);
                              if (postulaciones.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Aún no hay postulaciones.")),
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
                                      itemBuilder: (context, i) {
                                        final post = postulaciones[i];
                                        return Card(
                                          child: ListTile(
                                            title: FutureBuilder<
                                                DocumentSnapshot>(
                                              future: FirebaseFirestore
                                                  .instance
                                                  .collection('users')
                                                  .doc(post['helperId'])
                                                  .get(),
                                              builder: (context, snap) {
                                                if (snap.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Text(
                                                      "Cargando...");
                                                }
                                                final name = snap.data
                                                    ?.get(
                                                    'nombre') ??
                                                    'Sin nombre';
                                                return Text(name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold));
                                              },
                                            ),
                                            subtitle: Text(
                                                "Contraoferta: \$${post['contraoferta']}"),
                                            trailing: Row(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  ),
                                                  onPressed: () async {
                                                    await acceptPostulation(
                                                        post['id'],
                                                        post['helperId'],
                                                        req['id']);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('postulaciones')
                                                        .doc(post['id'])
                                                        .update({
                                                      'estado': 'rechazado'
                                                    });
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                        context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Postulación rechazada')),
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade600),
                            child: const Text("Solicitudes"),
                          ),
                          ElevatedButton(
                            onPressed: () => deleteRequest(req['id']),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text("Eliminar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Perfil de trabajo por defecto
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DesiredProfiles()), // Perfil de trabajo
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ContractorResumeScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyHelpersScreen()), // Redirigir a Ayudantes
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Perfil de trabajo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Ayudantes',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
