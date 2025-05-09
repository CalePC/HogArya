import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hogarya/presentation/screens/contractor/desired_profiles.dart';

class RedirectionDriver extends StatelessWidget {
  const RedirectionDriver({super.key});

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
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DesiredProfiles()),
            );
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Pantalla Cliente')),
          body: const Center(child: Text('Ya has contratado a un ayudante')),
        );
      },
    );
  }
}
