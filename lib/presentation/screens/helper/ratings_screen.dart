import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogarya/application/controllers/ratings_controller.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  final RatingsController _controller = RatingsController();

  int _bottomIndex = 0;
  List<String> _areas = [];
  double _promedio = 0;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final areas = await _controller.getAreasDestacadas();
    final promedio = await _controller.getPromedioCalificaciones();
    setState(() {
      _areas = areas;
      _promedio = promedio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4AB9FF), Color(0xFF4A79FF)],
                ).createShader(bounds),
                child: const Text(
                  "Mis calificaciones",
                  style: TextStyle(
                    fontFamily: 'Instrument Sans',
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1, indent: 40, endIndent: 40),
              const SizedBox(height: 20),
              const Text(
                "Áreas en las que destacaste",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),

              _areas.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3EEFF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          "Aún no has recibido calificaciones destacadas.\nSigue trabajando con dedicación.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  : Column(
                      children: _areas
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildTag(entry.value, highlighted: entry.key == 0),
                              ))
                          .toList(),
                    ),

              const SizedBox(height: 30),
              const Text(
                "Calificación promedio",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _promedio.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/star.svg',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
              const SizedBox(height: 200),
              const Text("El promedio máximo es 5 estrellas"),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (index) {
          setState(() => _bottomIndex = index);
          // Navegación funcional puedes integrarla aquí si es necesario
        },
        items: List.generate(3, (index) {
          final isActive = _bottomIndex == index;
          final icons = [
            'assets/icons/perfil_trabajo.svg',
            'assets/icons/resumen.svg',
            'assets/icons/contratantes.svg',
          ];
          final labels = ['Perfil de trabajo', 'Resumen', 'Contratantes'];

          return BottomNavigationBarItem(
            label: '',
            icon: Container(
              width: 148,
              height: 87,
              decoration: isActive
                  ? BoxDecoration(
                      color: const Color.fromRGBO(167, 216, 246, 0.5),
                      borderRadius: BorderRadius.circular(60),
                    )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    icons[index],
                    height: 35 + (index == 2 ? 15 : 0),
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        selectedFontSize: 0,
        unselectedFontSize: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  Widget _buildTag(String label, {bool highlighted = false}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD3EEFF),
        borderRadius: BorderRadius.circular(15),
        border: highlighted
            ? Border.all(
                width: 2,
                color: const Color(0xFF4AB9FF),
              )
            : null,
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4AB9FF), Color(0xFF4A79FF)],
          ).createShader(bounds),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
