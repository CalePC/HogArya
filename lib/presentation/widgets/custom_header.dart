import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/login_screen.dart';
import '../screens/change_password_screen.dart';


class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔲 Parte negra con logo HouSeHelp
        Container(
          color: Colors.black,
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Hou",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D409B),
                      ),
                    ),
                    TextSpan(
                      text: "SeHelp",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF38A5D3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔲 Parte blanca con flecha + título centrado
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Título centrado con degradado
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // será sobreescrito por el shader
                  ),
                ),
              ),

              // Flechita en posición izquierda
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: onBack ?? () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
