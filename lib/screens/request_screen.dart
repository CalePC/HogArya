import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'additional_details_screen.dart';

class RequestScreen extends StatefulWidget {
  final Map<String, dynamic>? editingRequest; // Solicitud a editar (opcional)

  const RequestScreen({super.key, this.editingRequest});

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> cuidadosTasks = [];
  List<String> hogarTasks = [];
  Map<String, bool> addedCuidados = {};
  Map<String, bool> addedHogar = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Si estamos editando, cargar las tareas existentes
    if (widget.editingRequest != null) {
      final request = widget.editingRequest!;
      cuidadosTasks = List<String>.from(request['tasks']['cuidados']);
      hogarTasks = List<String>.from(request['tasks']['hogar']);

      // Inicializamos los botones de tareas existentes como agregados
      for (var task in cuidadosTasks) {
        addedCuidados[task] = true;
      }
      for (var task in hogarTasks) {
        addedHogar[task] = true;
      }
    }
  }

  void addTask(String category, String task) {
    setState(() {
      if (category == "Cuidados") {
        cuidadosTasks.add(task);
        addedCuidados[task] = true;
      } else {
        hogarTasks.add(task);
        addedHogar[task] = true;
      }
    });
  }

  void removeTask(String category, String task) {
    setState(() {
      if (category == "Cuidados") {
        cuidadosTasks.remove(task);
        addedCuidados[task] = false;
      } else {
        hogarTasks.remove(task);
        addedHogar[task] = false;
      }
    });
  }

  void submitRequest() async {
    final tasks = {
      'cuidados': cuidadosTasks,
      'hogar': hogarTasks,
    };

    if (widget.editingRequest == null) {
      // Si no estamos editando, pasamos las tareas a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdditionalDetailsScreen(tasks: tasks)),
      );
    } else {
      // Si estamos editando, pasamos la solicitud completa a la siguiente pantalla
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdditionalDetailsScreen(
            tasks: tasks,
            editingRequest: widget.editingRequest, // Pasamos la solicitud para editarla
          ),
        ),
      );
    }
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
                  icon: Icon(addedCuidados['Adultos mayores'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedCuidados['Adultos mayores'] == true) {
                      removeTask("Cuidados", "Adultos mayores");
                    } else {
                      addTask("Cuidados", "Adultos mayores");
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Niños'),
                trailing: IconButton(
                  icon: Icon(addedCuidados['Niños'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedCuidados['Niños'] == true) {
                      removeTask("Cuidados", "Niños");
                    } else {
                      addTask("Cuidados", "Niños");
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Mascotas'),
                trailing: IconButton(
                  icon: Icon(addedCuidados['Mascotas'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedCuidados['Mascotas'] == true) {
                      removeTask("Cuidados", "Mascotas");
                    } else {
                      addTask("Cuidados", "Mascotas");
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Acompañamiento'),
                trailing: IconButton(
                  icon: Icon(addedCuidados['Acompañamiento'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedCuidados['Acompañamiento'] == true) {
                      removeTask("Cuidados", "Acompañamiento");
                    } else {
                      addTask("Cuidados", "Acompañamiento");
                    }
                  },
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
                  icon: Icon(addedHogar['Limpieza'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedHogar['Limpieza'] == true) {
                      removeTask("Hogar", "Limpieza");
                    } else {
                      addTask("Hogar", "Limpieza");
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Vigilancia'),
                trailing: IconButton(
                  icon: Icon(addedHogar['Vigilancia'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedHogar['Vigilancia'] == true) {
                      removeTask("Hogar", "Vigilancia");
                    } else {
                      addTask("Hogar", "Vigilancia");
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Alimentación'),
                trailing: IconButton(
                  icon: Icon(addedHogar['Alimentación'] == true ? Icons.remove : Icons.add),
                  onPressed: () {
                    if (addedHogar['Alimentación'] == true) {
                      removeTask("Hogar", "Alimentación");
                    } else {
                      addTask("Hogar", "Alimentación");
                    }
                  },
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

