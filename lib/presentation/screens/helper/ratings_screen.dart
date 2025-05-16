import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "Mis calificaciones"),
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
              _buildTag("Niños", highlighted: true),
              const SizedBox(height: 12),
              _buildTag("Alimentación"),
              const SizedBox(height: 30),
              const Text("Calificación promedio",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "4.5",
                    style: TextStyle(
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
