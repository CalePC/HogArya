import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/rate_helpers_list_controller.dart';
import 'package:hogarya/presentation/screens/contractor/rate_helper_screen.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';
import 'package:hogarya/presentation/widgets/persistent_bottom_nav.dart';
import 'package:hogarya/application/controllers/report_controller.dart';


class RateHelpersListScreen extends StatefulWidget {
  const RateHelpersListScreen({super.key});

  @override
  State<RateHelpersListScreen> createState() => _RateHelpersListScreenState();
}

class _RateHelpersListScreenState extends State<RateHelpersListScreen> {
  final controller = RateHelpersListController();
  final reportController = ReportController();
  

  void _mostrarModalDeReporte(BuildContext context, String nombreAyudante, String helperId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Estás por reportar a\n',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                        height: 3,
                      ),
                    ),
                    TextSpan(
                      text: nombreAyudante,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 12),
              const Text('Selecciona el motivo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 20),

              // Motivos
              ...[
                'No se presentó a trabajar / No respeta los horarios',
                'No cumple las tareas acordadas / Las cumple de manera deficiente',
                'Termina los trabajos sin motivo / Robo',
              ].map((motivo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC9C9),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await reportController.enviarReporte(
                        helperId: helperId,
                        motivo: motivo,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reporte enviado correctamente')),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Text(motivo, textAlign: TextAlign.center),
                ),
              )),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(242, 236, 236, 1),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ),
            ],
          ),
        );
      },
    );
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
              const CustomHeader(title: 'Calificar a Ayudantes'),
              const SizedBox(height: 8),
              Container(
                width: 311,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
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
                        final photoUrl = helper['photoUrl'];

                        return Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 280,
                                  height: 80,
                                  margin: const EdgeInsets.only(left: 50),
                                  padding: const EdgeInsets.only(left: 80, right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  top: -10,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black.withOpacity(0.5), width: 2),
                                      image: photoUrl != null && photoUrl.toString().isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(photoUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: Colors.grey[200],
                                    ),
                                    child: (photoUrl == null || photoUrl.toString().isEmpty)
                                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<bool>(
                                  future: controller.yaFueReportado(helperId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    final yaReportado = snapshot.data ?? false;

                                    return ElevatedButton(
                                      onPressed: yaReportado
                                          ? null
                                          : () => _mostrarModalDeReporte(context, nombre, helperId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: yaReportado
                                            ? Colors.grey
                                            : const Color.fromRGBO(255, 123, 123, 1),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      ),
                                      child: Text(yaReportado ? "Ya reportado" : "Reportar"),
                                    );
                                  },
                                ),


                                const SizedBox(width: 16),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7BD8FF),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: Text(rating == null ? "Calificar" : "Cambié de opinión"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
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
          
          const PersistentBottomNav(currentIndex: 2),
        ],
      ),
    );
  }
}
