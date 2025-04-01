import 'package:flutter/material.dart';

class ContractorScreen extends StatelessWidget {
  const ContractorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla Cliente')),
      body: const Center(child: Text('Soy un Cliente')),
    );
  }
}