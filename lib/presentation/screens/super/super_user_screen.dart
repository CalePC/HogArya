import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuperUserScreen extends StatelessWidget {
  const SuperUserScreen({super.key});

  Future<void> logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Super Usuario',
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: const Color(0xFF4ABAFF), 
        elevation: 0,
      ),
      body: Container(
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Reportes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                print('Navegar a la pantalla de reportes de Contratantes');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ABAFF),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), 
                ),
              ),
              child: const Text(
                'Contratantes',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
          
            ElevatedButton(
              onPressed: () {
                print('Navegar a la pantalla de reportes de Ayudantes');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ABAFF),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), 
                ),
              ),
              child: const Text(
                'Ayudantes',
                style: TextStyle(fontSize: 24, color: Colors.black), 
              ),
            ),
            const SizedBox(height: 40),
          
            ElevatedButton(
              onPressed: () => logoutUser(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
