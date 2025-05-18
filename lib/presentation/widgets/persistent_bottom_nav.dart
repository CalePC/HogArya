import 'package:flutter/material.dart';
import '../screens/contractor/desired_profiles_screen.dart';
import '../screens/contractor/daily_resume_screen.dart';
import '../screens/contractor/my_helpers_screen.dart';

class PersistentBottomNav extends StatelessWidget {
  final int currentIndex;

  const PersistentBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          final screens = [
            const DesiredProfilesScreen(),
            const DailyResumeScreen(),
            const MyHelpersScreen(),
          ];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screens[index]),
          );
        },
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
