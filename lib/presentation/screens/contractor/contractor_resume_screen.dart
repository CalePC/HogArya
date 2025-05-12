import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_comment_screen.dart'; 

class ContractorResumeScreen extends StatelessWidget {
  const ContractorResumeScreen({super.key});

  Future<List<Map<String, dynamic>>> _getTaskReports() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return [];
    }

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day); 
    final todayEnd = todayStart.add(Duration(days: 1)); 

    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('tareas')
        .where('contratanteId', isEqualTo: userId)
        .where('fecha', isGreaterThanOrEqualTo: todayStart)
        .where('fecha', isLessThan: todayEnd)
        .orderBy('fecha', descending: true)
        .get();

    List<Map<String, dynamic>> tasks = [];

    for (var doc in tasksSnapshot.docs) {
      final data = doc.data();

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
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // Usamos FutureBuilder para manejar los datos asincrónicos
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
             // final solicitudId = taskData['solicitudId'];
             // final tipo = taskData['tipo'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F0FF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de la tarea
                    imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image, size: 100, color: Colors.grey),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Hora: $formattedTime', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),

                          // Estado de la tarea (si está completada o no)
                          Text(isCompleted ? 'Tarea completada' : 'Tarea pendiente', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),

                  
                    Column(
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
