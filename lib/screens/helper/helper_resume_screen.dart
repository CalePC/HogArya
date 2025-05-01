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

  // Método para obtener las tareas asignadas a la solicitud aceptada
  Future<void> _fetchAssignedTasks() async {
    if (userId == null) return;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day); // Inicio del día
    final todayEnd = todayStart.add(Duration(days: 1)); // Fin del día

    // 1. Consultar las tareas donde el helperId coincide con el ID del usuario y que son para hoy
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('tareas')
        .where('helperId', isEqualTo: userId) // Filtrar por ID del ayudante
        .where('fecha', isGreaterThanOrEqualTo: todayStart)
        .where('fecha', isLessThan: todayEnd)
        .orderBy('fecha', descending: true)
        .get();

    if (tasksSnapshot.docs.isEmpty) {
      setState(() => tasks = []);
      return;
    }

    // 2. Mapear las tareas encontradas
    List<Map<String, dynamic>> fetchedTasks = [];
    for (var doc in tasksSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final descripcion = data['descripcion'] ?? 'Sin descripción';
      final imagenUrl = data['imagen'] ?? ''; // URL de la imagen
      final tipo = data['tipo'] ?? 'No especificado'; // Tipo de tarea
      final solicitudId = data['solicitudId'] ?? ''; // ID de la solicitud
      final fecha = data['fecha'] ?? ''; // Fecha de la tarea
      final timestamp = data['fecha_creacion'] as Timestamp?;
      final formattedTime = timestamp != null
          ? '${timestamp.toDate().hour}:${timestamp.toDate().minute}'
          : 'Hora no disponible';

      fetchedTasks.add({
        'taskId': doc.id, // ID de la tarea
        'descripcion': descripcion,   // Descripción de la tarea
        'imagen': imagenUrl,          // URL de la imagen
        'tipo': tipo,                 // Tipo de tarea (cuidados, hogar, etc.)
        'solicitudId': solicitudId,   // ID de la solicitud asociada
        'fecha': fecha,               // Fecha en que debe realizarse la tarea
        'formattedTime': formattedTime, // Hora de creación
      });
    }

    setState(() {
      tasks = fetchedTasks;
    });
  }

  // Método para subir la foto de la tarea
  Future<void> _takeAndUploadPhoto(String taskId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      final cloudinary = CloudinaryPublic(
        'dpct1rohg', // Reemplaza con tu Cloud Name
        'Prueba', // Reemplaza con tu Upload Preset (unsigned)
        cache: false,
      );

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );

      final imageUrl = response.secureUrl;

      // Subir la URL de la imagen a Firestore
      await FirebaseFirestore.instance
          .collection('tareas')
          .doc(taskId)
          .update({'imagen': imageUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida correctamente')),
      );

      _fetchAssignedTasks(); // Actualizamos las tareas
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

    _fetchAssignedTasks(); // Actualizar lista de tareas
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
                // Imagen de la tarea
                imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image, size: 80, color: Colors.grey),
                const SizedBox(height: 8),
                // Descripción de la tarea
                Text(descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Fecha: $fecha'),
                const SizedBox(height: 4),
                Text('Hora: $formattedTime'),
                const SizedBox(height: 10),
                // Tipo de tarea
                Text('Tipo: $tipo'),
                const SizedBox(height: 12),
                // Botones de acción
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

