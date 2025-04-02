import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          return Scaffold(
            appBar: AppBar(title: const Text('Pantalla Cliente')),
            body: const Center(child: Text('Aún no has contratado a un ayudante')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Pantalla Cliente')),
          body: const Center(child: Text('Ya has contratado a un ayudante')),
        );
      },
    );
  }
}
