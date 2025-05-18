import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogarya/application/controllers/helpers_controller.dart';
import 'package:hogarya/presentation/screens/helper/ratings_screen.dart';
import 'package:hogarya/presentation/screens/helper/requests_details_screen.dart';
import 'package:hogarya/presentation/screens/helper/select_skills_screen.dart';
import 'package:hogarya/presentation/screens/profile_screen.dart';
import 'package:hogarya/presentation/widgets/custom_header.dart';


class MainTabContent extends StatefulWidget {
  final HelpersController controller;
  final String? role;
  final List<String> selectedSkills;
  final VoidCallback onShowFilter;

  const MainTabContent({
    super.key,
    required this.controller,
    required this.role,
    required this.selectedSkills,
    required this.onShowFilter,
  });

  @override
  State<MainTabContent> createState() => _MainTabContentState();
}

class _MainTabContentState extends State<MainTabContent> {
  int _topTabSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CustomHeader(
              onProfileTap: () {
                if (widget.role != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(role: widget.role!),
                    ),
                  );
                }
              },
            ),
            _buildTopNavigation(),
            _buildTitleBox(_topTabSelected == 0
                ? "¡Estas personas te necesitan!"
                : "Mi perfil de habilidades"),
            Expanded(
              child: _topTabSelected == 0
                  ? _buildSolicitudesList()
                  : _buildSkillsSection(),
            ),
          ],
        ),
        if (_topTabSelected == 0) _buildFloatingFilterButton(),
        if (_topTabSelected == 1) _buildBottomSkillButtons(),
      ],
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

  Widget _buildTitleBox(String text) {
    return Container(
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
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Instrument Sans',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudesList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.controller.getSolicitudesConDatosContractor(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = widget.controller.filtrarSolicitudes(
          snapshot.data!,
          widget.selectedSkills,
        );

        if (items.isEmpty) {
          return const Center(child: Text('No hay solicitudes disponibles.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final contractor = items[index]['contractor'];
            final bool viveEnCoatza = contractor['viveEnCoatzacoalcos'] == true;
            final solicitudId = items[index]['solicitudId'];

            return Center(
              child: Container(
                width: double.infinity,
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
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        backgroundImage: contractor['photoUrl'] != null &&
                                contractor['photoUrl'].toString().isNotEmpty
                            ? NetworkImage(contractor['photoUrl'])
                            : null,
                        child: contractor['photoUrl'] == null ||
                                contractor['photoUrl'].toString().isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(contractor['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Sexo: ${contractor['sexo'] ?? 'N/D'}"),
                      Text("Edad: ${contractor['edad']?.toString() ?? 'N/D'}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(viveEnCoatza
                              ? "Radica en Coatzacoalcos"
                              : "Fuera de alcance"),
                          const SizedBox(width: 5),
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.red),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestsDetailsScreen(requestId: solicitudId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[200],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("Detalles"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkillsSection() {
    return FutureBuilder<List<String>>(
      future: widget.controller.getHabilidadesHelper(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final habilidades = snapshot.data ?? [];

        final cuidados = habilidades.where((h) =>
            ["Adultos mayores", "Niños", "Mascotas", "Acompañamiento"]
                .contains(h)).toList();
        final hogar = habilidades.where((h) =>
            !["Adultos mayores", "Niños", "Mascotas", "Acompañamiento"]
                .contains(h)).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSkillsGroup("Cuidados", cuidados),
            const SizedBox(height: 24),
            _buildSkillsGroup("Hogar", hogar),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildSkillsGroup(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF0FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (skills.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text("No hay habilidades en esta área",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          Column(children: skills.map(_buildSkillChip).toList()),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFCCEBFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: Text(label, textAlign: TextAlign.center)),
        ),
      ),
    );
  }

  Widget _buildFloatingFilterButton() {
    return Positioned(
      bottom: 10,
      right: 16,
      child: FloatingActionButton.extended(
        onPressed: widget.onShowFilter,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filtrar'),
        backgroundColor: Colors.lightBlue[400],
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildBottomSkillButtons() {
    return Positioned(
      bottom: 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RatingsScreen()));
            },
            child: Container(
              width: 196,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.lightBlue[300],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                "Ver mis calificaciones",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelectSkillsScreen()),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.lightBlue[300],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                'assets/icons/pencil.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
