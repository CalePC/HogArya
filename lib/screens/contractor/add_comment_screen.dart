import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCommentScreen extends StatefulWidget {
  final String tareaId;
  final String helperId;

  const AddCommentScreen({super.key, required this.tareaId, required this.helperId});

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController commentController = TextEditingController();

  Future<void> _submitComment() async {
    final comment = commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un comentario')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('comentarios').add({
        'tareaId': widget.tareaId,
        'helperId': widget.helperId,
        'comentario': comment,
        'fecha': Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection('notificaciones').add({
        'helperId': widget.helperId,
        'mensaje': 'Nuevo comentario sobre tu tarea.',
        'fecha': Timestamp.now(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario enviado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Comentario'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Aceptar', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
