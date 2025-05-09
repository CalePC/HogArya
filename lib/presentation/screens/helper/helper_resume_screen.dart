import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:intl/intl.dart';

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
    final todayEnd = todayStart.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('tareas')
        .where('helperId', isEqualTo: userId)
        .where('fecha', isGreaterThanOrEqualTo: todayStart)
        .where('fecha', isLessThan: todayEnd)
        .orderBy('fecha', descending: false)
        .get();

    List<Map<String, dynamic>> fetchedTasks = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['fecha'] as Timestamp?;
      final hora = timestamp != null ? DateFormat.jm('es_ES').format(timestamp.toDate()) : 'Hora no disponible';

      fetchedTasks.add({
        'taskId': doc.id,
        'descripcion': data['descripcion'] ?? '',
        'completada': data['completada'] is bool ? data['completada'] : false,
        'hora': hora,
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
      final cloudinary = CloudinaryPublic('dpct1rohg', 'Prueba', cache: false);
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );

      await FirebaseFirestore.instance
          .collection('tareas')
          .doc(taskId)
          .update({'imagen': response.secureUrl});

      _fetchAssignedTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir imagen: $e')),
      );
    }
  }

  Future<void> _markTaskCompleted(String taskId) async {
    await FirebaseFirestore.instance.collection('tareas').doc(taskId).update({'completada': true});
    _fetchAssignedTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea marcada como completada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi resumen del día'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE8E6F2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.camera_alt_outlined),
                    SizedBox(width: 6),
                    Text('Tomar foto'),
                  ],
                ),
                Text(
                  'Tareas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Text('Marcar completada'),
                    SizedBox(width: 6),
                    Icon(Icons.check_circle_outline),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No hay tareas asignadas'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1ECFF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt_outlined),
                                onPressed: () => _takeAndUploadPhoto(task['taskId']),
                              ),
                              Expanded(
                                child: Text(
                                  task['descripcion'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  task['completada']
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: Colors.black87,
                                ),
                                onPressed: () => _markTaskCompleted(task['taskId']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
