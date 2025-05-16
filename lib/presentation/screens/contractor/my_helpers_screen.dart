import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/my_helpers_controller.dart';
import 'package:hogarya/presentation/screens/contractor/RateHelperScreen.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';
import 'package:hogarya/presentation/widgets/persistent_bottom_nav.dart';

class MyHelpersScreen extends StatefulWidget {
  const MyHelpersScreen({super.key});

  @override
  State<MyHelpersScreen> createState() => _MyHelpersScreenState();
}

class _MyHelpersScreenState extends State<MyHelpersScreen> {
  final controller = MyHelpersController();

  Future<void> _despedirAyudante(String postulacionId) async {
    try {
      await controller.despedirAyudante(postulacionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayudante despedido exitosamente')),
      );
      setState(() {}); // Recargar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al despedir ayudante: $e")),
      );
    }
  }

  void _administrarTareas(String helperId) {
    // Pendiente implementación
  }

  void _irACalificar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RateHelperScreen(
          helperName: 'Ayudantes',
          helperId: '', // opcional, dependerá de cómo implementes pestaña
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo degradado
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

          // Contenido principal
          Column(
            children: [
              const CustomHeader(title: 'Tus ayudantes'),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
              // Contenido limitado en altura
              SizedBox(
                height: 568,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.fetchAyudantes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final ayudantes = snapshot.data!;
                    if (ayudantes.isEmpty) {
                      return const Center(
                          child: Text("No tienes ayudantes vinculados."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      itemCount: ayudantes.length,
                      itemBuilder: (context, index) {
                        final ayudante = ayudantes[index];
                        final nombre =
                            ayudante['helper']['nombre'] ?? 'Nombre no disponible';
                        final helperId = ayudante['helperId'];
                        final solicitud = ayudante['solicitud'];
                        final postulacionId = ayudante['id'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.person, size: 40),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Solicitud: ${solicitud?['periodicidad_pago'] ?? 'No disponible'}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _despedirAyudante(postulacionId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text("Despedir"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _administrarTareas(helperId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text("Administrar tareas"),
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
              ),
            ],
          ),

          // ✅ Botón fijo para calificar
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _irACalificar,
              backgroundColor: Colors.green,
              label: const Text("Calificar"),
              icon: const Icon(Icons.star),
            ),
          ),

          // División decorativa sobre la barra de navegación
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

          // ✅ Barra inferior
          const PersistentBottomNav(currentIndex: 2),
        ],
      ),
    );
  }
}
