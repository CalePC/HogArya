import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogarya/application/controllers/helpers_controller.dart';
import 'package:hogarya/presentation/screens/helper/assigned_tasks_screen.dart';
import 'package:hogarya/presentation/widgets/main_tab_content.dart';

class HelpersScreen extends StatefulWidget {
  const HelpersScreen({super.key});

  @override
  State<HelpersScreen> createState() => _HelpersScreenState();
}

class _HelpersScreenState extends State<HelpersScreen> {
  final HelpersController _controller = HelpersController();
  final List<String> _selectedSkills = [];
  String? _role;
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    _role = await _controller.getUserRole();
    setState(() {});
  }

  void _showFilterSheet() {
    final cuidados = ['adultos mayores', 'niños', 'mascotas', 'acompañamiento'];
    final hogar = ['limpieza', 'vigilancia', 'alimentación'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildChips(String title, List<String> items) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items.map((skill) {
                      final isSelected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill[0].toUpperCase() + skill.substring(1), style: const TextStyle(fontSize: 14)),
                        selected: isSelected,
                        selectedColor: Colors.lightBlue[100],
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (bool selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filtrar por habilidades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),
                  buildChips('Cuidados', cuidados),
                  const SizedBox(height: 16),
                  buildChips('Hogar', hogar),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Aplicar filtros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4AB9FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_bottomIndex) {
      case 0:
        return MainTabContent(
          controller: _controller,
          role: _role,
          selectedSkills: _selectedSkills,
          onShowFilter: _showFilterSheet,
        );
      case 1:
        return Center(child: Text("Resumen (pendiente de implementar)"));
      case 2:
        return AssignedTasksScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (index) => setState(() => _bottomIndex = index),
        items: List.generate(3, (index) {
          final isActive = _bottomIndex == index;
          final icons = [
            'assets/icons/perfil_trabajo.svg',
            'assets/icons/resumen.svg',
            'assets/icons/contratantes.svg',
          ];
          final labels = ['Perfil de trabajo', 'Resumen', 'Contratantes'];

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
                  Text(labels[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
