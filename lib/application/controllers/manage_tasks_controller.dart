import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTasksController extends ValueNotifier<void> {
  final String helperId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<String> assignedTasks = [];
  final List<String> taskBank = [
    'Sacar la basura',
    'Despertar a los niños',
    'Alistar los niños',
    'Preparar desayuno',
    'Alimentar a los niños',
    'Jugar con los niños',
    'Personalizada',
  ];

  ManageTasksController({required this.helperId}) : super(null);

  Future<void> loadTasks() async {
    final doc = await _db.collection('usuarios').doc(helperId).get();
    final data = doc.data();
    if (data != null && data['tareasAsignadas'] != null) {
      assignedTasks.clear();
      assignedTasks.addAll(List<String>.from(data['tareasAsignadas']));
      notifyListeners();
    }
  }

  void addTask(String task) {
    if (!assignedTasks.contains(task)) {
      assignedTasks.add(task);
      notifyListeners();
    }
  }

  void removeTask(String task) {
    assignedTasks.remove(task);
    notifyListeners();
  }

  Future<void> saveTasks() async {
    await _db.collection('usuarios').doc(helperId).update({
      'tareasAsignadas': assignedTasks,
    });
  }
}
