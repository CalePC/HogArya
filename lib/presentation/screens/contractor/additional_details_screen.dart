import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hogarya/application/controllers/additional_details_controller.dart';
import 'desired_profiles_screen.dart';

class AdditionalDetailsScreen extends StatefulWidget {
  final Map<String, List<String>> tasks;
  final Map<String, dynamic>? editingRequest;

  const AdditionalDetailsScreen({super.key, required this.tasks, this.editingRequest});

  @override
  State<AdditionalDetailsScreen> createState() => _AdditionalDetailsScreenState();
}

class _AdditionalDetailsScreenState extends State<AdditionalDetailsScreen> {
  final controller = AdditionalDetailsController();

  String selectedPeriod = 'Diario';
  final TextEditingController amountController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  void submitFullRequest() async {
    await controller.submitRequest(
      tasks: widget.tasks,
      selectedPeriod: selectedPeriod,
      cantidadPago: double.tryParse(amountController.text) ?? 0,
      startDate: startDate,
      endDate: endDate,
      editingRequest: widget.editingRequest,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DesiredProfilesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime futureLimit = DateTime(now.year + 5, 12, 31);

    return Scaffold(
      appBar: AppBar(title: const Text("Detalles adicionales")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("¿Cuál será tu periodicidad de pago?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Diario', 'Mensual', 'Anual'].map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: selectedPeriod == option,
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
                onRangeSelected: (start, end, _) => setState(() {
                  startDate = start;
                  endDate = end;
                }),
                selectedDayPredicate: (day) => false,
                rangeStartDay: startDate,
                rangeEndDay: endDate,
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: submitFullRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continuar', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
