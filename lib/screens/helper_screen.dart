// ✅ login_screen.dart
import 'package:flutter/material.dart';

class HelperScreen extends StatelessWidget {
  const HelperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla Ayudante')),
      body: const Center(child: Text('Soy un Ayudante')),
    );
  }
}