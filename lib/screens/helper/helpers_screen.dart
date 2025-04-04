import 'package:flutter/material.dart';
import 'package:house_help/screens/contractor/resume_screen.dart';  // Pantalla 2
// Pantalla 3
import 'package:house_help/screens/contractor/summary_screen.dart';

class HelpersScreen extends StatelessWidget {
  const HelpersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayudantes")),
      body: const Center(child: Text("Lista de ayudantes disponibles")),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Ayudantes',
          ),
        ],
        onTap: (index) {
          // Navegar a la pantalla correspondiente dependiendo de la opción seleccionada
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()), // Redirige a la pantalla de perfil
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ResumeScreen()), // Redirige a la pantalla de resumen
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HelpersScreen()), // Redirige a la pantalla de ayudantes
              );
              break;
          }
        },
      ),
    );
  }
}
