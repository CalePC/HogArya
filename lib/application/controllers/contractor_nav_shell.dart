import 'package:flutter/material.dart';
import 'package:hogarya/presentation/screens/contractor/contractor_resume_screen.dart';
import 'package:hogarya/presentation/screens/contractor/desired_profiles_screen.dart';
import 'package:hogarya/presentation/screens/contractor/my_helpers_screen.dart';

class ContractorNavShell extends StatefulWidget {
  const ContractorNavShell({super.key});

  @override
  State<ContractorNavShell> createState() => _ContractorNavShellState();
}

class _ContractorNavShellState extends State<ContractorNavShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DesiredProfilesScreen(),
    ContractorResumeScreen(),
    MyHelpersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Fondo degradado global
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
          _pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Perfil de trabajo'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_outlined), label: 'Resumen'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Ayudantes'),
        ],
      ),
    );
  }
}
