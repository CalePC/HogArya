import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class HelperResumeScreen extends StatefulWidget {
  const HelperResumeScreen({super.key});

  @override
  State<HelperResumeScreen> createState() => _HelperResumeScreenState();
}

class _HelperResumeScreenState extends State<HelperResumeScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedTasks();
  }

  Future<void> _fetchAssignedTasks() async {
    if (userId == null) return;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('tareas')
        .where('helperId', isEqualTo: userId)
        .where('fecha', isGreaterThanOrEqualTo: todayStart)
        .where('fecha', isLessThan: todayEnd)
        .orderBy('fecha', descending: true)
        .get();

    if (tasksSnapshot.docs.isEmpty) {
      setState(() => tasks = []);
      return;
    }

    List<Map<String, dynamic>> fetchedTasks = [];
    for (var doc in tasksSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final descripcion = data['descripcion'] ?? 'Sin descripción';
      final imagenUrl = data['imagen'] ?? '';
      final tipo = data['tipo'] ?? 'No especificado';
      final solicitudId = data['solicitudId'] ?? '';
      final fecha = data['fecha'] ?? '';
      final timestamp = data['fecha_creacion'] as Timestamp?;
      final formattedTime = timestamp != null
          ? '${timestamp.toDate().hour}:${timestamp.toDate().minute}'
          : 'Hora no disponible';

      fetchedTasks.add({
        'taskId': doc.id,
        'descripcion': descripcion,
        'imagen': imagenUrl,
        'tipo': tipo,
        'solicitudId': solicitudId,
        'fecha': fecha,
        'formattedTime': formattedTime,
      });
    }

    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<void> _takeAndUploadPhoto(String taskId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      final cloudinary = CloudinaryPublic(
        'dpct1rohg',
        'Prueba',
        cache: false,
      );

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );

      final imageUrl = response.secureUrl;

      await FirebaseFirestore.instance
          .collection('tareas')
          .doc(taskId)
          .update({'imagen': imageUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida correctamente')),
      );

      _fetchAssignedTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
    }
  }

  Future<void> _markTaskCompleted(String taskId) async {
    await FirebaseFirestore.instance
        .collection('tareas')
        .doc(taskId)
        .update({'completada': true});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea marcada como completada')),
    );

    _fetchAssignedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi resumen del día'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No hay tareas asignadas'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final taskData = tasks[index];
          final descripcion = taskData['descripcion'];
          final imageUrl = taskData['imagen'];
          final tipo = taskData['tipo'];
          final fecha = taskData['fecha'];
          final formattedTime = taskData['formattedTime'];
          final taskId = taskData['taskId'];

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
                Text(descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Fecha: $fecha'),
                const SizedBox(height: 4),
                Text('Hora: $formattedTime'),
                const SizedBox(height: 10),
                Text('Tipo: $tipo'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.green),
                      onPressed: () => _takeAndUploadPhoto(taskId),
                    ),
                    IconButton(
                      icon: Icon(
                        taskData['completada'] == true ? Icons.check_circle : Icons.check_circle_outline,
                        color: Colors.blue,
                      ),
                      onPressed: () => _markTaskCompleted(taskId),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
