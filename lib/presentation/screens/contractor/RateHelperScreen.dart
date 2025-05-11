import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateHelperScreen extends StatefulWidget {
  final String helperName;
  final String helperId;
  const RateHelperScreen({super.key, required this.helperName, required this.helperId});

  @override
  _RateHelperScreenState createState() => _RateHelperScreenState();
}

class _RateHelperScreenState extends State<RateHelperScreen> {
  double _rating = 3.0;
  final List<String> _areasDestacadas = [];
  final TextEditingController _comentariosController = TextEditingController();

  final List<String> areas = ["Niños", "Alimentación", "Mascotas", "Limpieza"];

  Future<void> _submitRating() async {
    final comentarios = _comentariosController.text;

    try {

      await FirebaseFirestore.instance.collection('calificaciones').add({
        'calificadoId': widget.helperId,
        'calificadorId': FirebaseAuth.instance.currentUser!.uid,
        'calificacion': _rating,
        'comentarios': comentarios,
        'areasDestacadas': _areasDestacadas,
        'fecha': FieldValue.serverTimestamp(),
      });

      final helperDoc = await FirebaseFirestore.instance.collection('usuarios').doc(widget.helperId).get();
      final helperData = helperDoc.data();
      if (helperData != null) {
        double currentAvg = helperData['calificacionPromedio'] ?? 0;
        int totalRatings = helperData['totalRatings'] ?? 0;

        double newAvg = (currentAvg * totalRatings + _rating) / (totalRatings + 1);

        await FirebaseFirestore.instance.collection('usuarios').doc(widget.helperId).update({
          'calificacionPromedio': newAvg,
          'totalRatings': totalRatings + 1,
        });
      }


      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calificación enviada con éxito')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al enviar la calificación: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calificar a ${widget.helperName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("¿Cómo ha sido tu experiencia con ?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            // Estrellas para calificación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),

            const Text("Áreas en las que destacó:", style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8.0,
              children: areas.map((area) {
                return FilterChip(
                  label: Text(area),
                  selected: _areasDestacadas.contains(area),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _areasDestacadas.add(area);
                      } else {
                        _areasDestacadas.remove(area);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text("Comentarios - opcional:", style: TextStyle(fontSize: 16)),
            TextField(
              controller: _comentariosController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Escribe tus comentarios aquí...",
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(minimumSize: const Size(150, 50)),
                child: const Text("Enviar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

