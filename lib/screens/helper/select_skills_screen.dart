import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'helpers_screen.dart';

class SelectSkillsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const SelectSkillsScreen({super.key, required this.userData});

  @override
  State<SelectSkillsScreen> createState() => _SelectSkillsScreenState();
}

class _SelectSkillsScreenState extends State<SelectSkillsScreen> {
  final List<String> _skills = [
    'Adultos mayores',
    'Niños',
    'Mascotas',
    'Acompañamiento',
    'Limpieza',
    'Vigilancia',
    'Alimentación',
  ];

  final List<String> _selectedSkills = [];

  Future<void> _saveSkills() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
      'habilidades': _selectedSkills,
    });

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HelpersScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus habilidades'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _skills.length,
                itemBuilder: (context, index) {
                  final skill = _skills[index];
                  final isSelected = _selectedSkills.contains(skill);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1ECFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(skill, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline,
                          color: Colors.purple,
                        ),
                        onPressed: () {
                          setState(() {
                            isSelected
                                ? _selectedSkills.remove(skill)
                                : _selectedSkills.add(skill);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _selectedSkills.isEmpty ? null : _saveSkills,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AB9FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Continuar"),
            )
          ],
        ),
      ),
    );
  }
}
