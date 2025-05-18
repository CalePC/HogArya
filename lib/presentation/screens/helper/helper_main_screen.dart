import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'helpers_screen.dart';
import 'assigned_tasks_screen.dart';
import 'summary_screen.dart';

class HelperMainScreen extends StatefulWidget {
  const HelperMainScreen({super.key});

  @override
  State<HelperMainScreen> createState() => _HelperMainScreenState();
}

class _HelperMainScreenState extends State<HelperMainScreen> {
  int _currentIndex = 2;

  final List<Widget> _screens = const [
    //SummaryScreen(),        // index 0
    Placeholder(),          // index 1 
    HelpersScreen(),        // index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: List.generate(3, (index) {
          final icons = [
            'assets/icons/perfil_trabajo.svg',
            'assets/icons/resumen.svg',
            'assets/icons/contratantes.svg',
          ];
          final labels = ['Perfil de trabajo', 'Resumen', 'Contratantes'];
          final isActive = _currentIndex == index;

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
}
