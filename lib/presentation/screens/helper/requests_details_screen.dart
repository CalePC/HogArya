import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/request_details_controller.dart';

class RequestsDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestsDetailsScreen({super.key, required this.requestId});

  @override
  State<RequestsDetailsScreen> createState() => _RequestsDetailsScreenState();
}

class _RequestsDetailsScreenState extends State<RequestsDetailsScreen> {
  final controller = RequestDetailsController();
  Map<String, dynamic>? requestData;
  Map<String, dynamic>? contractorData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _postular() async {
    try {
      final helperId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('postulaciones').add({
        'solicitudId': widget.requestId,
        'helperId': helperId,
        'estado': 'pendiente',
        'contraoferta': 0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has postulado a esta oferta')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al postularte: $e')),
      );
    }
  }



  Future<void> _loadData() async {
    try {
      requestData = await controller.fetchRequestData(widget.requestId);
      if (requestData == null) {
        errorMessage = 'Solicitud no encontrada.';
      } else {
        final contractorId = requestData!['uid'] as String;
        contractorData = await controller.fetchContractorData(contractorId);
        if (contractorData == null) {
          errorMessage = 'No se encontró el perfil del solicitante.';
        }
      }
    } catch (e) {
      errorMessage = 'Error al cargar los detalles: $e';
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text(errorMessage!)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalles de la solicitud',
          style: TextStyle(color: Color(0xFF4A66FF), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Datos personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Nombre: ${contractorData?['nombre'] ?? 'No disponible'}'),
                Text('Sexo: ${contractorData?['sexo'] ?? 'No disponible'}'),
                Text('Edad: ${contractorData?['edad'] ?? 'No disponible'}'),
                Row(
                  children: [
                    Expanded(child: Text('Ubicación: ${contractorData?['ubicacion'] ?? 'No disponible'}')),
                    const Icon(Icons.location_pin, size: 18, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Tareas que solicita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Cuidados', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: (requestData?['tasks']?['cuidados'] as List<dynamic>?)
                          ?.map((tarea) => Chip(
                                label: Text(tarea as String),
                                backgroundColor: const Color(0xFFBBE5FF),
                              ))
                          .toList() ??
                      [],
                ),
                const SizedBox(height: 10),
                const Text('Hogar', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: (requestData?['tasks']?['hogar'] as List<dynamic>?)
                          ?.map((tarea) => Chip(
                                label: Text(tarea as String),
                                backgroundColor: const Color(0xFFBBE5FF),
                              ))
                          .toList() ??
                      [],
                ),
                const SizedBox(height: 24),
                const Text('Datos de trabajo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Periodicidad: ${requestData?['periodicidad_pago'] ?? 'No disponible'}'),
                Text('Pago: \$${(requestData?['cantidad_pago'] ?? 0).toStringAsFixed(0)}'),
                Text('Fecha inicio: ${_formatDate(requestData?['fecha_inicio'])}'),
                Text('Fecha fin: ${_formatDate(requestData?['fecha_fin'])}'),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _postular,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Postularme a esta solicitud"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'No disponible';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
