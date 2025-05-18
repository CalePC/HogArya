
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hogarya/application/controllers/assigned_tasks_controller.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';

class AssignedTasksScreen extends StatelessWidget {
  final AssignedTasksController controller = AssignedTasksController();

  AssignedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.78, 0.95, 1.0],
                colors: [Colors.white, Color(0xFFA4DCFF), Color(0xFF4ABAFF)],
              ),
            ),
          ),
          Column(
            children: [
              const CustomHeader(title: "Mis tareas asignadas"),
              const SizedBox(height: 12),
              if (userId == null)
                const Expanded(child: Center(child: Text("No autenticado")))
              else
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.fetchTasksForHelper(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No tienes tareas asignadas."));
                      }

                      final tareas = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = tareas[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tarea['descripcion'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Tipo: ${tarea['tipo']}"),
                                const SizedBox(height: 4),
                                Text("Desde: ${_format(tarea['fecha_inicio'])}"),
                                Text("Hasta: ${_format(tarea['fecha_fin'])}"),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day.toString().padLeft(2, '0')}/"
           "${date.month.toString().padLeft(2, '0')}/"
           "${date.year}";
  }
}
