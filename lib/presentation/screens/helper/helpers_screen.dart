import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/helpers_controller.dart';
import 'package:hogarya/presentation/screens/profile_screen.dart';
import '../../widgets/custom_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpersScreen extends StatefulWidget {
  const HelpersScreen({super.key});

  @override
  State<HelpersScreen> createState() => _HelpersScreenState();
}

class _HelpersScreenState extends State<HelpersScreen> {
  final HelpersController _controller = HelpersController();
  final List<String> _selectedSkills = [];
  String? _role;
  int _currentIndex = 0;
  int _topTabSelected = 0;

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
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filtrar por habilidades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    'adultos mayores', 'niños', 'limpieza', 'mascotas', 'acompañamiento', 'vigilancia', 'alimentación'
                  ].map((skill) {
                    final isSelected = _selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _postular(String solicitudId) {
    _controller.postularAOferta(
      solicitudId: solicitudId,
      contraoferta: 0,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Te has postulado a esta oferta')),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTopNavItem(0, Icons.search, 'Buscar'),
          _buildTopNavItem(1, Icons.work, 'Mi perfil de trabajo'),
        ],
      ),
    );
  }

  Widget _buildTopNavItem(int index, IconData icon, String label) {
    final isSelected = _topTabSelected == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _topTabSelected = index;
        });
      },
      child: Container(
        width: 156,
        height: 82,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD3EEFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              CustomHeader(
                onProfileTap: () {
                  if (_role != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen(role: _role!)),
                    );
                  }
                },
              ),
              _buildTopNavigation(),
              Container(
                width: 412,
                height: 37,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                  ).createShader(bounds),
                  child: const Text(
                    '¡Estas personas te necesitan!',
                    style: TextStyle(
                      fontFamily: 'Instrument Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _controller.getSolicitudesConDatosContractor(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No hay solicitudes disponibles.'));
                    }

                    final items = _controller.filtrarSolicitudes(snapshot.data!, _selectedSkills);

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final solicitud = items[index]['solicitud'];
                        final contractor = items[index]['contractor'];
                        final bool viveEnCoatza = contractor['viveEnCoatzacoalcos'] == true;

                        return Center(
                          child: Container(
                            width: 380,
                            height: 341,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(202, 241, 255, 0.5),
                                  Color.fromRGBO(74, 186, 255, 0.5),
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person, size: 40),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    contractor['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Text("Sexo: ${contractor['sexo'] ?? 'N/D'}"),
                                  Text("Edad: ${contractor['edad']?.toString() ?? 'N/D'}"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        viveEnCoatza
                                            ? "Radica en Coatzacoalcos"
                                            : "Fuera de alcance",
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.location_on, size: 18, color: Colors.red),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => _postular(items[index]['solicitudId']),
                                    child: const Text("Postularse"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 5,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _showFilterSheet,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtrar'),
              backgroundColor: Colors.lightBlue[100],
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/perfil_trabajo.svg',
              height: 35,
            ),
            label: 'Perfil de trabajo',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/resumen.svg',
              height: 40,
            ),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/contratantes.svg',
              height: 50,
            ),
            label: 'Contratantes',
          ),
        ],
      ),
    );
  }
}
