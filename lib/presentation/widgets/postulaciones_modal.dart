import '../../../application/controllers/desired_profiles_controller.dart';
import 'package:flutter/material.dart';

class PostulacionesModal extends StatelessWidget {
  final String solicitudId;
  final DesiredProfilesController controller;
  final VoidCallback onSuccess;

  const PostulacionesModal({
    super.key,
    required this.solicitudId,
    required this.controller,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.fetchPostulaciones(solicitudId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final postulaciones = snapshot.data ?? [];

        if (postulaciones.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text("Aún no hay postulaciones.")),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: postulaciones.length,
          itemBuilder: (context, i) {
            final post = postulaciones[i];
            return _PostulacionCard(
              controller: controller,
              post: post,
              solicitudId: solicitudId,
              onSuccess: () {
                Navigator.pop(context);
                onSuccess();
              },
            );
          },
        );
      },
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
    print('Postulacion: $post');
    return FutureBuilder<String?>(
      future: controller.getHelperName(post['helperId']),
      builder: (context, snapshot) {
        final name = snapshot.data ?? "Sin nombre";
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
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14)),
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
                ),
                child: const Text("Aceptar"),
              )
            ],
          ),
        );
      },
    );
  }
}