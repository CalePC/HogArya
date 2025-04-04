import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_help/screens/helper/requests_details_screen.dart';

class HelpersScreen extends StatelessWidget {
  const HelpersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HouSeHelp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              //  Perfil de usuario
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    //  Aquí aún falta lo de "Buscar" we
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    //  Lógica del botón Mi perfil de trabajo
                  },
                  icon: const Icon(Icons.work),
                  label: const Text('Mi perfil de trabajo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Estas personas te necesitan!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('solicitudes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay solicitudes disponibles.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final document = snapshot.data!.docs[index];
                      return _buildRequestCard(context, document);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Perfil de trabajo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: 'Ayudantes',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    final cantidadPago = data['cantidad_pago'] as num? ?? 0;
    final fechaFin = data['fecha_fin'] as String? ?? 'Fecha fin no disponible';
    final fechaInicio = data['fecha_inicio'] as String? ?? 'Fecha inicio no disponible';
    final periodicidadPago = data['periodicidad_pago'] as String? ?? 'Pago no disponible';
    final uid = data['uid'] as String? ?? 'ID de usuario no disponible'; 
    final tieneContrato = data['tiene_contrato'] as bool? ?? false;
    final tasks = data['tasks'] as Map<String, dynamic>? ?? {}; // Este lo usé para obtener "cositas"

    //  Extraer tareas específicas (manejar nulos y tipos)
    final cuidados = (tasks['cuidados'] as List<dynamic>?)?.cast<String>() ?? [];
    final hogar = (tasks['hogar'] as List<dynamic>?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestsDetailsScreen(requestId: document.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cantidad Pago: $cantidadPago',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              //Esto es todo lo que mostramos 
              Text('Fecha Inicio: $fechaInicio'),
              Text('Fecha Fin: $fechaFin'),
              Text('Periodicidad Pago: $periodicidadPago'),
              Text('Cuidados: ${cuidados.join(', ')}'), 
              Text('Hogar: ${hogar.join(', ')}'), 
            
            ],
          ),
        ),
      ),
    );
  }
}