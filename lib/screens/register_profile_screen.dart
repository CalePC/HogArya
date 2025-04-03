import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_help/screens/helper_screen.dart';
import 'contractor_screen.dart';

class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  String selectedRole = '';
  String selectedGender = 'Masculino';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  Future<void> finishRegistration(Map<String, dynamic> args) async {
    final uid = args['uid'];
    final email = args['email'];
    final password = args['password'];
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;

    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un rol antes de continuar')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'nombre': name,
      'sexo': selectedGender,
      'rol': selectedRole,
      'edad': age,
      'email': email,
      'password': password,
    });

    if (!mounted) return;

    if (selectedRole == 'ayudante') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HelperScreen()),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ContractorScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Selecciona tu rol:'),
            ElevatedButton(
              onPressed: () => setState(() => selectedRole = 'ayudante'),
              child: const Text('Ayudante'),
            ),
            ElevatedButton(
              onPressed: () => setState(() => selectedRole = 'necesita_ayuda'),
              child: const Text('Necesito ayuda'),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Edad')),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
              ],
              onChanged: (value) => setState(() => selectedGender = value!),
              decoration: const InputDecoration(labelText: 'Sexo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => finishRegistration(args),
              child: const Text('Finalizar registro'),
            ),
          ],
        ),
      ),
    );
  }
}