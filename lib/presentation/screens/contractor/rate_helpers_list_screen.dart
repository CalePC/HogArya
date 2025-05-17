import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/rate_helpers_list_controller.dart';
import 'package:hogarya/presentation/screens/contractor/rate_helper_screen.dart';

class RateHelpersListScreen extends StatefulWidget {
  const RateHelpersListScreen({super.key});

  @override
  State<RateHelpersListScreen> createState() => _RateHelpersListScreenState();
}

class _RateHelpersListScreenState extends State<RateHelpersListScreen> {
  final controller = RateHelpersListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.fetchHelpersWithRatings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final helpers = snapshot.data!;
          if (helpers.isEmpty) {
            return const Center(child: Text('No tienes ayudantes para calificar.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: helpers.length,
            itemBuilder: (context, i) {
              final helper = helpers[i];
              final nombre = helper['nombre'];
              final helperId = helper['helperId'];
              final rating = helper['calificacionPromedio'];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < (rating ?? 0).round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RateHelperScreen(
                                    helperName: nombre,
                                    helperId: helperId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                            child: Text(rating == null ? "Calificar" : "Cambié de opinión"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              //Fucnión de reportar
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Reportar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
