import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/select_skills_controller.dart';
import 'package:hogarya/presentation/screens/helper/helpers_screen.dart';

class SelectSkillsScreen extends StatefulWidget {
  final bool fromRegistro;

  const SelectSkillsScreen({super.key, this.fromRegistro = false});

  @override
  State<SelectSkillsScreen> createState() => _SelectSkillsScreenState();
}

class _SelectSkillsScreenState extends State<SelectSkillsScreen> {
  final SelectSkillsController _controller = SelectSkillsController();
  final List<String> _allSkills = [
    'Adultos mayores',
    'Niños',
    'Mascotas',
    'Acompañamiento',
    'Limpieza',
    'Vigilancia',
    'Alimentación',
  ];
  final List<String> _selectedSkills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final habilidades = await _controller.getHabilidadesUsuario();
    setState(() {
      _selectedSkills.addAll(habilidades);
      _loading = false;
    });
  }

  Future<void> _saveSkills() async {
    await _controller.guardarHabilidades(_selectedSkills);
    if (!context.mounted) return;
    if (!mounted) return;

    if (widget.fromRegistro) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HelpersScreen()),
          (route) => false,
        );
    } else {
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar habilidades'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: _allSkills.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final skill = _allSkills[index];
                        final isSelected = _selectedSkills.contains(skill);

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1ECFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            title: Text(skill, style: const TextStyle(fontWeight: FontWeight.w600)),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSelected
                                      ? _selectedSkills.remove(skill)
                                      : _selectedSkills.add(skill);
                                });
                              },
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedSkills.isEmpty ? null : _saveSkills,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4AB9FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Guardar cambios"),
                  ),
                ],
              ),
            ),
    );
  }
}
