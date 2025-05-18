import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/desired_profiles_controller.dart';
import 'package:hogarya/presentation/screens/contractor/daily_resume_screen.dart';
import 'package:hogarya/presentation/screens/contractor/desired_profiles_screen.dart';
import 'package:hogarya/presentation/screens/contractor/my_helpers_screen.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';

class PostulacionesScreen extends StatefulWidget {
  final String solicitudId;
  final DesiredProfilesController controller;
  final VoidCallback onSuccess;

  const PostulacionesScreen({
    super.key,
    required this.solicitudId,
    required this.controller,
    required this.onSuccess,
  });

  @override
  State<PostulacionesScreen> createState() => _PostulacionesScreenState();
}

class _PostulacionesScreenState extends State<PostulacionesScreen> {
  int _currentIndex = 0;

  void _onNavTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

    final screens = [
      const DesiredProfilesScreen(),
      const DailyResumeScreen(),
      const MyHelpersScreen(),
    ];

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screens[index]));
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
                title: 'Solicitudes',
                onProfileTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: widget.controller.fetchPostulaciones(widget.solicitudId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final postulaciones = snapshot.data ?? [];
                    if (postulaciones.isEmpty) {
                      return const Center(child: Text("Aún no hay postulaciones."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: postulaciones.length,
                      itemBuilder: (context, i) {
                        final post = postulaciones[i];
                        return _PostulacionCard(
                          post: post,
                          solicitudId: widget.solicitudId,
                          controller: widget.controller,
                          onSuccess: widget.onSuccess,
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
        ],  
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
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

class _PostulacionCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String solicitudId;
  final DesiredProfilesController controller;
  final VoidCallback onSuccess;

  const _PostulacionCard({
    required this.post,
    required this.controller,
    required this.solicitudId,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getHelperData(post['helperId']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final helper = snapshot.data!;
        final name = helper['nombre'] ?? "Sin nombre";
        final photo = helper['photoUrl'] ?? '';
        final edad = helper['edad']?.toString() ?? 'N/D';
        final rating = (helper['calificacionPromedio'] ?? 0).toStringAsFixed(1);

        final contraoferta = post['contraoferta'];
        final subtitle = contraoferta == null || contraoferta == 0
            ? "Acepta los términos"
            : "Sugiere \$${contraoferta.toStringAsFixed(0)}";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF8FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                backgroundColor: Colors.grey,
                child: photo.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("Edad: $edad años", style: const TextStyle(fontSize: 14)),
                    Text("Calificación: ⭐ $rating", style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  await controller.acceptPostulation(
                    postId: post['id'],
                    helperId: post['helperId'],
                    solicitudId: solicitudId,
                  );
                  onSuccess();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Postulación aceptada')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BD8FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(80, 48),
                ),
                child: const Text("Aceptar"),
              ),
            ],
          ),
        );
      },
    );
  }
}

