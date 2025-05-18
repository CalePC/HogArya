import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hogarya/presentation/screens/contractor/postulations_screen.dart';
import 'package:hogarya/presentation/screens/profile_screen.dart';

import '../../../application/controllers/desired_profiles_controller.dart';
import '../../widgets/custom_header.dart';
import 'add_job_profile_screen.dart';
import 'daily_resume_screen.dart';
import 'my_helpers_screen.dart';


class DesiredProfilesScreen extends StatefulWidget {
  const DesiredProfilesScreen({super.key});

  @override
  State<DesiredProfilesScreen> createState() => _DesiredProfilesScreenState();
}

class _DesiredProfilesScreenState extends State<DesiredProfilesScreen> {
  final controller = DesiredProfilesController();
  int _currentIndex = 0;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _role = doc['rol'];
        });
      }
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
              CustomHeader(
                title: 'Perfiles deseados',
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen(role: 'contractor')),
                  );
                },
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.fetchRequests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snapshot.data!;
                      if (requests.isEmpty) {
                        return const Center(child: Text("No hay solicitudes activas"));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 5, bottom: 80),
                        itemCount: requests.length,
                        itemBuilder: (context, index) => RequestCard(
                          request: requests[index],
                          controller: controller,
                          onUpdated: () => setState(() {}),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddJobProfileScreen()),
              ),
              backgroundColor: const Color(0xFF7BD8FF),
              label: const Text("Crear"),
              icon: const Icon(Icons.add),
            ),
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
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          final screens = [
            const DesiredProfilesScreen(),
            const DailyResumeScreen(),
            const MyHelpersScreen(),
          ];
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screens[index]));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Perfil de trabajo'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_outlined), label: 'Resumen'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Ayudantes'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}


class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final DesiredProfilesController controller;
  final VoidCallback onUpdated;

  const RequestCard({
    super.key,
    required this.request,
    required this.controller,
    required this.onUpdated,
  });

  Widget _gradientText(String text) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Color(0xFF4A66FF), Color(0xFF2C3D99)],
    ).createShader(bounds),
    child: Text(
      text,
      textAlign: TextAlign.left, 
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Instrument Sans',
        color: Colors.white, 
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final cuidados = (request['tasks']['cuidados'] as List?)?.join(", ") ?? '–';
    final hogar = (request['tasks']['hogar'] as List?)?.join(", ") ?? '–';
    final start = request['fecha_inicio']?.substring(0, 10) ?? '–';
    final end = request['fecha_fin']?.substring(0, 10) ?? '–';
    final periodicidadPago = request['periodicidad_pago'] ?? '–';
    final cantidadPago = request['cantidad_pago'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD9F4FF), Color(0xFF5DC1FF)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _gradientText("Cuidados"),
                                Text(cuidados),
                                const SizedBox(height: 6),
                                _gradientText("Hogar"),
                                Text(hogar),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _gradientText("Periodicidad"),
                              Text(periodicidadPago),
                              const SizedBox(height: 6),
                              _gradientText("Pago"),
                              Text(cantidadPago.toStringAsFixed(0)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7BD8FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$start - $end",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildButton("Editar", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddJobProfileScreen(editingRequest: request)),
                );
              }, const Color(0xFF7BD8FF)),
              _buildButton("Solicitudes", () => _showPostulacionesModal(context), const Color(0xFFBBE5FF)),
              _buildButton("Eliminar", () async {
                await controller.deleteRequest(request['id']);
                onUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Solicitud y tareas eliminadas exitosamente")),
                );
              }, const Color(0xFFFF7B7B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        elevation: 2,
      ),
      child: Text(label),
    );
  }

  void _showPostulacionesModal(BuildContext context) async {
    final postulaciones = await controller.fetchPostulaciones(request['id']);
    if (postulaciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aún no hay postulaciones.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostulacionesScreen(
          solicitudId: request['id'],
          controller: controller,
          onSuccess: onUpdated,
        ),
      ),
    );
  }

}
  
