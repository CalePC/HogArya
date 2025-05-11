import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'desired_profiles_screen.dart';

class AdditionalDetailsScreen extends StatefulWidget {
  final Map<String, List<String>> tasks;
  final Map<String, dynamic>? editingRequest; 

  const AdditionalDetailsScreen({super.key, required this.tasks, this.editingRequest});

  @override
  State<AdditionalDetailsScreen> createState() => _AdditionalDetailsScreenState();
}

class _AdditionalDetailsScreenState extends State<AdditionalDetailsScreen> {
  String selectedPeriod = 'Diario';
  final TextEditingController amountController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

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
      final solicitudRef = await FirebaseFirestore.instance.collection('solicitudes').add(solicitudData);
      _createTasksForDates(solicitudRef.id, tasks, uid);  // Crea las tareas para cada fecha
    } else {
      await FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(widget.editingRequest!['id'])
          .update(solicitudData);
      _createTasksForDates(widget.editingRequest!['id'], tasks, uid);  // Actualiza las tareas asociadas
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DesiredProfilesScreen()),
    );
  }

  Future<void> _createTasksForDates(String solicitudId, Map<String, List<String>> tasks, String uid) async {
    DateTime current = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final lastDay = DateTime(endDate!.year, endDate!.month, endDate!.day);

    while (!current.isAfter(lastDay)) {
      for (final entry in tasks.entries) {
        final tipo = entry.key;
        final tareaList = entry.value;

        for (final descripcion in tareaList) {
          await FirebaseFirestore.instance.collection('tareas').add({
            'descripcion': descripcion,
            'tipo': tipo,
            'contratanteId': uid,
            'solicitudId': solicitudId,
            'fecha': Timestamp.fromDate(current),
            'fecha_creacion': Timestamp.now(),
            'imagen': '',
            'helperId': '',
          });
        }
      }
      current = current.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime futureLimit = DateTime(now.year + 5, 12, 31);

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: false,
              ),
            ),
            const SizedBox(height: 30),

            const Text("¿Desde y hasta cuándo necesitarás esta ayuda?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TableCalendar(
              locale: 'es_ES',
              focusedDay: today,
              firstDay: today,
              lastDay: futureLimit,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mes',
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              rangeSelectionMode: RangeSelectionMode.toggledOn,
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
