import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'additional_details_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> cuidadosTasks = [];
  List<String> hogarTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void addTask(String category, String task) {
    setState(() {
      if (category == "Cuidados") {
        cuidadosTasks.add(task);
      } else {
        hogarTasks.add(task);
      }
    });
  }

  void submitRequest() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final tasks = {
      'cuidados': cuidadosTasks,
      'hogar': hogarTasks,
    };

    // Save the request to Firestore
    await FirebaseFirestore.instance.collection('solicitudes').add({
      'uid': uid,
      'tasks': tasks,
      'tiene_contrato': false, // As no helper is assigned yet
    });

    // Navigate to the next screen for further details
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdditionalDetailsScreen(tasks: tasks)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecciona las tareas"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Cuidados"),
            Tab(text: "Hogar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Cuidados Tab
          ListView(
            children: [
              ListTile(
                title: const Text('Adultos mayores'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Cuidados", "Adultos mayores"),
                ),
              ),
              ListTile(
                title: const Text('Niños'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Cuidados", "Niños"),
                ),
              ),
              ListTile(
                title: const Text('Mascotas'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Cuidados", "Mascotas"),
                ),
              ),
              ListTile(
                title: const Text('Acompañamiento'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Cuidados", "Acompañamiento"),
                ),
              ),
            ],
          ),
          // Hogar Tab
          ListView(
            children: [
              ListTile(
                title: const Text('Limpieza'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Hogar", "Limpieza"),
                ),
              ),
              ListTile(
                title: const Text('Vigilancia'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Hogar", "Vigilancia"),
                ),
              ),
              ListTile(
                title: const Text('Alimentación'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask("Hogar", "Alimentación"),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: submitRequest,
        child: const Text('Continuar'),
      ),
    );
  }
}
