import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_comment_screen.dart'; // Importar para agregar comentarios

class ContractorResumeScreen extends StatelessWidget {
  const ContractorResumeScreen({super.key});

  // Método para obtener los reportes de las tareas
  Future<List<Map<String, dynamic>>> _getTaskReports() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;


    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('tareas')
        .where('contratanteId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .get();

    List<Map<String, dynamic>> tasks = [];


    for (var doc in tasksSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;


      final descripcion = data['descripcion'] ?? 'Sin descripción';
      final imagenUrl = data['imagen'] ?? '';
      final isCompleted = data['completada'] ?? false;
      final timestamp = data['fecha'] as Timestamp?;
      final formattedTime = timestamp != null
          ? '${timestamp.toDate().hour}:${timestamp.toDate().minute}'
          : 'Hora no disponible';
      final solicitudId = data['solicitudId'] ?? '';
      final helperId = data['helperId'] ?? '';
      final tipo = data['tipo'] ?? 'No especificado';

      tasks.add({
        'taskId': doc.id,
        'descripcion': descripcion,
        'imagen': imagenUrl,
        'completada': isCompleted,
        'fecha': formattedTime,
        'solicitudId': solicitudId,
        'helperId': helperId,
        'tipo': tipo,
      });
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del día'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getTaskReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las tareas'));
          }

          final tasks = snapshot.data;

          if (tasks == null || tasks.isEmpty) {
            return const Center(child: Text('No hay tareas reportadas aún.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskData = tasks[index];
              final description = taskData['descripcion'];
              final imageUrl = taskData['imagen'];
              final isCompleted = taskData['completada'];
              final formattedTime = taskData['fecha'];
              final taskId = taskData['taskId'];
              final solicitudId = taskData['solicitudId'];
              final tipo = taskData['tipo'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1ECFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image, size: 80, color: Colors.grey),
                    const SizedBox(height: 8),

                    Text(description, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Hora: $formattedTime'),
                    const SizedBox(height: 10),

                    Text(isCompleted ? 'Tarea completada' : 'Tarea pendiente'),
                    const SizedBox(height: 12),

                    Text('Tipo: $tipo'),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddCommentScreen(
                                  tareaId: taskId,
                                  helperId: taskData['helperId'],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                           
                            FirebaseFirestore.instance
                                .collection('tareas')
                                .doc(taskId)
                                .update({'completada': true});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


