import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onProfileTap;

  const CustomHeader({super.key, this.title, this.onProfileTap});

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
        Container(
          color: Colors.black,
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text: 'Hog',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF2D409B), Color(0xFF2C3D99)],
                          ).createShader(const Rect.fromLTWH(0, 0, 80, 30)),
                      ),
                    ),
                    TextSpan(
                      text: 'Arya',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF38A5D3), Color(0xFF7BD8FF)],
                          ).createShader(const Rect.fromLTWH(0, 0, 80, 30)),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onProfileTap ?? () {},
                child: const Icon(
                  Icons.account_circle,
                  size: 32,
                  color: Color(0xFF4ABAFF),
                ),
              ),
            ],
          ),
        ),

        // Título degradado si se especifica
        if (title != null)
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
              ).createShader(bounds),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // se ve a través del shader
                ),
              ),
            ),
          ),
      ],
    );
  }
}
