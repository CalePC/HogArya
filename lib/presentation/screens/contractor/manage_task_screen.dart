import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';

class ManageTasksScreen extends StatefulWidget {
  final String helperId;
  final String helperName;
  final String helperPhotoUrl;
  final String solicitudId;

  const ManageTasksScreen({
    super.key,
    required this.helperId,
    required this.helperName,
    required this.helperPhotoUrl,
    required this.solicitudId,
  });

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  final List<String> _tareasDisponibles = [
    "Sacar la basura",
    "Despertar a los niños",
    "Alistar los niños",
    "Preparar desayuno",
    "Alimentar a los niños",
    "Limpiar cocina",
    "Jugar con los niños",
    "Lavar ropa",
  ];

  final List<String> _tareasSeleccionadas = [];

  Future<void> _guardarTareas() async {
    final docRef = FirebaseFirestore.instance.collection('solicitudes').doc(widget.solicitudId);

    await docRef.set({
      'tasks': {
        'hogar': _tareasSeleccionadas,
      },
      'tiene_contrato': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tareas guardadas correctamente')),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    final doc = await FirebaseFirestore.instance.collection('solicitudes').doc(widget.solicitudId).get();
    if (doc.exists && doc.data()?['tasks']?['hogar'] is List) {
      setState(() {
        _tareasSeleccionadas.addAll(List<String>.from(doc.data()!['tasks']['hogar']));
      });
    }
  }

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
              const CustomHeader(title: "Administrar tareas"),
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: widget.helperPhotoUrl.isNotEmpty ? NetworkImage(widget.helperPhotoUrl) : null,
                child: widget.helperPhotoUrl.isEmpty ? const Icon(Icons.person, size: 40) : null,
              ),
              const SizedBox(height: 8),
              Text(widget.helperName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              SizedBox(
                height: 328,
                width: 412,
                child: ListView.builder(
                  itemCount: _tareasSeleccionadas.length,
                  itemBuilder: (context, index) {
                    final tarea = _tareasSeleccionadas[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tarea, style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => _tareasSeleccionadas.remove(tarea));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text("Banco de tareas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),

           
              SizedBox(
                height: 95,
                width: 397,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _tareasDisponibles.map((tarea) {
                    final yaSeleccionada = _tareasSeleccionadas.contains(tarea);
                    return GestureDetector(
                      onTap: () {
                        if (!yaSeleccionada) {
                          setState(() => _tareasSeleccionadas.add(tarea));
                        }
                      },
                      child: Container(
                        width: 150,
                        height: 75,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: yaSeleccionada ? Colors.grey[400] : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Center(
                          child: Text(
                            tarea,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarTareas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ABAFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Guardar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
