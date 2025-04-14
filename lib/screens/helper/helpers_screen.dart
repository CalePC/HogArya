import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:house_help/screens/helper/profile_screen_dart';
//import 'package:house_help/screens/helper/requests_details_screen.dart';

class HelpersScreen extends StatefulWidget {
  const HelpersScreen({Key? key}) : super(key: key);

  @override
  State<HelpersScreen> createState() => _HelpersScreenState();
}

class _HelpersScreenState extends State<HelpersScreen> {
  List<String> _selectedSkills = [];
  final Map<String, String> _proposedSalary = {};
  String? _expandedRequestId;

  final List<String> _availableSkills = [
    'adultos mayores',
    'niños',
    'limpieza',
    'mascotas',
    'acompañamiento',
    'vigilancia',
    'alimentación',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HouSeHelp'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/customProfile.svg',
              height: 24,
              width: 24,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.work),
                  label: const Text('Mi perfil de trabajo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Estas personas te necesitan!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('solicitudes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error: \${snapshot.error}'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay solicitudes disponibles.'));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    if (_selectedSkills.isEmpty) return true;
                    final data = doc.data() as Map<String, dynamic>;
                    final tasks = data['tasks'] as Map<String, dynamic>? ?? {};
                    final allTasks = <String>[
                      ...(tasks['cuidados'] ?? []),
                      ...(tasks['hogar'] ?? []),
                    ].cast<String>().map((t) => t.toLowerCase());
                    return _selectedSkills.any((skill) => allTasks.contains(skill));
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text('No hay solicitudes que coincidan con los filtros.'));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(context, filteredDocs[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Perfil de trabajo'),
          BottomNavigationBarItem(icon: Icon(Icons.summarize), label: 'Resumen'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Ayudantes'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filtrar por habilidades',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableSkills.map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setModalState(() {
                          if (selected) {
                            _selectedSkills.add(skill);
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final cantidadPago = data['cantidad_pago'] as num? ?? 0;
    final fechaFin = data['fecha_fin'] as String? ?? 'Fecha fin no disponible';
    final fechaInicio = data['fecha_inicio'] as String? ?? 'Fecha inicio no disponible';
    final periodicidadPago = data['periodicidad_pago'] as String? ?? 'Pago no disponible';
    final tasks = data['tasks'] as Map<String, dynamic>? ?? {};
    final cuidados = (tasks['cuidados'] as List<dynamic>?)?.cast<String>() ?? [];
    final hogar = (tasks['hogar'] as List<dynamic>?)?.cast<String>() ?? [];
    final isExpanded = _expandedRequestId == document.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedRequestId = isExpanded ? null : document.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cantidad Pago: \$${cantidadPago.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              Text('Fecha Inicio: $fechaInicio'),
              Text('Fecha Fin: $fechaFin'),
              Text('Periodicidad Pago: $periodicidadPago'),
              Text('Cuidados: ${cuidados.join(', ')}'),
              Text('Hogar: ${hogar.join(', ')}'),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Proponer contraoferta (\$)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _proposedSalary[document.id] = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final helperId = FirebaseAuth.instance.currentUser?.uid;
                    final contraoferta = _proposedSalary[document.id];

                    if (helperId != null && contraoferta != null) {
                      await FirebaseFirestore.instance.collection('postulaciones').add({
                        'solicitudId': document.id,
                        'helperId': helperId,
                        'contraoferta': double.tryParse(contraoferta) ?? 0.0,
                        'estado': 'pendiente',
                        'fecha': Timestamp.now(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solicitud enviada al contratante.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Aceptar y enviar contraoferta"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}