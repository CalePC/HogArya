import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestsDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestsDetailsScreen({super.key, required this.requestId});

  @override
  _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestsDetailsScreen> {
  Map<String, dynamic>? requestData;
  Map<String, dynamic>? contractorData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('solicitudes') 
          .doc(widget.requestId)
          .get();

      if (requestDoc.exists) {
        requestData = requestDoc.data() as Map<String, dynamic>;
        final contractorId = requestData!['uid'] as String; //User ID

        final contractorDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(contractorId)
            .get();

        if (contractorDoc.exists) {
          contractorData = contractorDoc.data() as Map<String, dynamic>;
        } else {
          errorMessage = 'No se encontró el perfil del solicitante.';
        }
      } else {
        errorMessage = 'Solicitud no encontrada.';
      }
    } catch (e) {
      errorMessage = 'Error al cargar los detalles: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Solicitud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Aquí es un choto de info
              CircleAvatar(
                // Imagen del contractor
              ),
              const SizedBox(height: 16),
              const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Nombre: ${contractorData?['nombre'] ?? 'No disponible'}'),
              Text('Sexo: ${contractorData?['sexo'] ?? 'No disponible'}'),
              Text('Edad: ${contractorData?['edad'] ?? 'No disponible'}'),
              Text('Ubicación: ${contractorData?['ubicacion'] ?? 'No disponible'}'),

              const SizedBox(height: 16),
              const Text('Datos de trabajo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Cantidad Pago: ${requestData?['cantidad_pago'] ?? 'No disponible'}'),
              Text('Fecha Inicio: ${requestData?['fecha_inicio'] ?? 'No disponible'}'),
              Text('Fecha Fin: ${requestData?['fecha_fin'] ?? 'No disponible'}'),
              Text('Periodicidad Pago: ${requestData?['periodicidad_pago'] ?? 'No disponible'}'),

              const SizedBox(height: 16),
              const Text('Tareas que solicita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Cuidados', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: (requestData?['tasks']?['cuidados'] as List<dynamic>?)?.map((tarea) => Chip(label: Text(tarea as String))).toList() ?? [],
              ),
              const Text('Hogar', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: (requestData?['tasks']?['hogar'] as List<dynamic>?)?.map((tarea) => Chip(label: Text(tarea as String))).toList() ?? [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}