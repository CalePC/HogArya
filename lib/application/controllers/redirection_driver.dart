import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hogarya/presentation/screens/contractor/desired_profiles_screen.dart';
import 'package:hogarya/presentation/screens/helper/helpers_screen.dart';
import 'package:hogarya/presentation/screens/login_screen.dart';
import 'package:hogarya/presentation/screens/super/super_user_screen.dart';


class RedirectionDriver extends StatefulWidget {
  const RedirectionDriver({super.key});

  @override
  State<RedirectionDriver> createState() => _RedirectionDriverState();
}

class _RedirectionDriverState extends State<RedirectionDriver> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectUser());
  }

  Future<void> _redirectUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    final data = doc.data();

    Widget target = const LoginScreen();

    if (data != null) {
      final role = data['rol'];
      if (role == 'contractor') {
        final tieneContrato = data['tiene_contrato'] == true;
        target = tieneContrato
            ? const _ContratoActivoScreen()
            : const DesiredProfilesScreen();
      } else if (role == 'helper') {
        target = const HelpersScreen();
      } else if (role == 'super') {
        target = const SuperUserScreen();
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFA4DCFF),
              Color(0xFF4ABAFF),
            ],
            stops: [0.78, 0.95, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 120),
            Transform.translate(
              offset: const Offset(0, -120.0),
              child: Image.asset(
                'assets/LogoHH.png',
                height: 200,
              ),
            ),
            
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _ContratoActivoScreen extends StatelessWidget {
  const _ContratoActivoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla Cliente')),
      body: const Center(
        child: Text('Ya has contratado a un ayudante'),
      ),
    );
  }
}
