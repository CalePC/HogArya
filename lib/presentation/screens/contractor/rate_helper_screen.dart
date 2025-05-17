import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/rate_helper_controller.dart';


class RateHelperScreen extends StatefulWidget {
  final String helperName;
  final String helperId;

  const RateHelperScreen({
    super.key,
    required this.helperName,
    required this.helperId,
  });

  @override
  State<RateHelperScreen> createState() => _RateHelperScreenState();
}

class _RateHelperScreenState extends State<RateHelperScreen> {
  final RateHelperController controller = RateHelperController();

  double _rating = 3.0;
  final List<String> _areasDestacadas = [];
  final TextEditingController _comentariosController = TextEditingController();

  final List<String> areas = ["Niños", "Alimentación", "Mascotas", "Limpieza"];

  Future<void> _submitRating() async {
    try {
      await controller.submitRating(
        helperId: widget.helperId,
        rating: _rating,
        comentarios: _comentariosController.text,
        areasDestacadas: _areasDestacadas,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación enviada con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al enviar la calificación: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calificar a ${widget.helperName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("¿Cómo ha sido tu experiencia con?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow[700],
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

            const Text("Comentarios (opcional):", style: TextStyle(fontSize: 16)),
            TextField(
              controller: _comentariosController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Escribe tus comentarios aquí...",
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Enviar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
