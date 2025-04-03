import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_help/screens/request_screen.dart';
import 'package:house_help/screens/summary_screen.dart';
import 'helper_screen.dart';

class ContractorScreen extends StatelessWidget {
  const ContractorScreen({super.key});

  Future<bool> hasContract(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists && doc.data()?['tiene_contrato'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<bool>(
      future: hasContract(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!) {
          // Si no tiene contrato, redirige a la pantalla de solicitud
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SummaryScreen()), // Redirige a la pantalla de solicitud
            );
          });
          return const Center(child: CircularProgressIndicator()); // Muestra un indicador mientras se redirige
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Pantalla Cliente')),
          body: const Center(child: Text('Ya has contratado a un ayudante')),
        );
      },
    );
  }
}
