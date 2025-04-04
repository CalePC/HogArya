import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'summary_screen.dart';

class AdditionalDetailsScreen extends StatefulWidget {
  final Map<String, List<String>> tasks;

  const AdditionalDetailsScreen({super.key, required this.tasks, Map<String, dynamic>? editingRequest});

  get editingRequest => null;

  @override
  State<AdditionalDetailsScreen> createState() => _AdditionalDetailsScreenState();
}

class _AdditionalDetailsScreenState extends State<AdditionalDetailsScreen> {
  String selectedPeriod = 'Diario';
  final TextEditingController amountController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  CalendarFormat calendarFormat = CalendarFormat.month;
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOn;

  void submitFullRequest() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final tasks = widget.tasks;
    final solicitudData = {
      'uid': uid,
      'tasks': tasks,
      'tiene_contrato': false,
      'periodicidad_pago': selectedPeriod,
      'cantidad_pago': double.tryParse(amountController.text) ?? 0,
      'fecha_inicio': startDate?.toIso8601String(),
      'fecha_fin': endDate?.toIso8601String(),
    };

    if (widget.editingRequest == null) {
      // Si no estamos editando, creamos una nueva solicitud
      await FirebaseFirestore.instance.collection('solicitudes').add(solicitudData);
    } else {
      // Si estamos editando, actualizamos la solicitud existente
      await FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(widget.editingRequest!['id'])
          .update(solicitudData);
    }

    if (!mounted) return;

    // Redirigir a la pantalla de resumen después de crear o actualizar la solicitud
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SummaryScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles adicionales")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("¿Cuál será tu periodicidad de pago?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Diario', 'Mensual', 'Anual'].map((option) {
                final isSelected = selectedPeriod == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedPeriod = option),
                  selectedColor: Colors.lightBlueAccent,
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            const Text("¿Cuánto estás dispuesto a pagar?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),
            const SizedBox(height: 30),

            const Text("¿Cuándo necesitarás esta ayuda?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
              rangeSelectionMode: rangeSelectionMode,
              onRangeSelected: (start, end, _) {
                setState(() {
                  startDate = start;
                  endDate = end;
                });
              },
              selectedDayPredicate: (day) => false,
              rangeStartDay: startDate,
              rangeEndDay: endDate,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: submitFullRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Continuar', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

