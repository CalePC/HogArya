import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/contractor_resume_controller.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';
import 'package:hogarya/presentation/widgets/persistent_bottom_nav.dart';
import 'add_comment_screen.dart';

class DailyResumeScreen extends StatefulWidget {
  const DailyResumeScreen({super.key});

  @override
  State<DailyResumeScreen> createState() => _DailyResumeScreenState();
}

class _DailyResumeScreenState extends State<DailyResumeScreen> {
  final controller = ContractorResumeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.78, 0.95, 1.0],
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFA4DCFF),
                  Color(0xFF4ABAFF),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const CustomHeader(title: 'Resumen del día'),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.fetchTodayTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error al cargar el resumen.'));
                    }

                    final tasks = snapshot.data ?? [];
                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text('Aún no se ha reportado ninguna tarea.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task['descripcion'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              task['imagen'] != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        task['imagen'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.image, size: 50),
                                    ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hora: ${task['fecha']}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.lightbulb_outline,
                                            color: Colors.amber),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddCommentScreen(
                                                tareaId: task['taskId'],
                                                helperId: task['helperId'],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
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
              ),
            ],
          ),
          Positioned(
            bottom: 76,
            left: 0,
            right: 0,
            child: Container(
              height: 10,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(52, 52, 52, 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const PersistentBottomNav(currentIndex: 1),
        ],
      ),
    );
  }
}
