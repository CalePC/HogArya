import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hogarya/application/controllers/add_job_profile_controller.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';
import 'additional_details_screen.dart';

class AddJobProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? editingRequest;

  const AddJobProfileScreen({super.key, this.editingRequest});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ChangeNotifierProvider(
        create: (_) {
          final controller = AddJobProfileController();
          if (editingRequest != null) {
            controller.initFromEditing(editingRequest!);
          }
          return controller;
        },
        child: const _AddJobProfileView(),
      ),
    );
  }
}

class _AddJobProfileView extends StatelessWidget {
  const _AddJobProfileView();

  @override
  Widget build(BuildContext context) {
  final controller = Provider.of<AddJobProfileController>(context);

  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
          color: Colors.black,
        ),

        const CustomHeader(),

        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                  ).createShader(bounds),
                  child: const Text(
                    "Selecciona las tareas",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
            const TabBar(
              indicatorColor: Color(0xFFB030FF),
              labelColor: Color(0xFFB030FF),
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: "Cuidados"),
                Tab(text: "Hogar"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTaskList(context, controller, 'Cuidados', [
                    'Adultos mayores',
                    'Niños',
                    'Mascotas',
                    'Acompañamiento',
                  ], controller.addedCuidados),
                  _buildTaskList(context, controller, 'Hogar', [
                    'Limpieza',
                    'Vigilancia',
                    'Alimentación',
                  ], controller.addedHogar),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ABAFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    final tasks = controller.getSelectedTasks();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdditionalDetailsScreen(
                          tasks: {
                            'cuidados': tasks.cuidados,
                            'hogar': tasks.hogar,
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildTaskList(
    BuildContext context,
    AddJobProfileController controller,
    String category,
    List<String> tasks,
    Map<String, bool> added,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: tasks.map((task) {
        final isSelected = added[task] == true;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: () => controller.toggleTask(category, task),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: const Color(0xFFB030FF),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
