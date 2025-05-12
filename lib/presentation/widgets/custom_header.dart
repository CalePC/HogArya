import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onProfileTap;
  final bool showBackButton;

  const CustomHeader({
    super.key,
    this.title,
    this.onProfileTap,
    this.showBackButton = false,
  });

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
              Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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
                ],
              ),
              GestureDetector(
                onTap: onProfileTap ?? () {},
                child: SvgPicture.asset(
                  'assets/customProfile.svg',
                  height: 28,
                  width: 28,
                  colorFilter: const ColorFilter.mode(Color(0xFF4ABAFF), BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
        if (title != null)
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
