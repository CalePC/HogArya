import 'package:flutter/material.dart';
import 'package:hogarya/domain/entities/job_task_selection.dart';

class AddJobProfileController extends ChangeNotifier {
  List<String> cuidadosTasks = [];
  List<String> hogarTasks = [];

  final Map<String, bool> addedCuidados = {};
  final Map<String, bool> addedHogar = {};

  void initFromEditing(Map<String, dynamic> request) {
    cuidadosTasks = List<String>.from(request['tasks']['cuidados']);
    hogarTasks = List<String>.from(request['tasks']['hogar']);

    for (var task in cuidadosTasks) {
      addedCuidados[task] = true;
    }
    for (var task in hogarTasks) {
      addedHogar[task] = true;
    }
    notifyListeners();
  }

  void toggleTask(String category, String task) {
    if (category == 'Cuidados') {
      if (addedCuidados[task] == true) {
        cuidadosTasks.remove(task);
        addedCuidados[task] = false;
      } else {
        cuidadosTasks.add(task);
        addedCuidados[task] = true;
      }
    } else {
      if (addedHogar[task] == true) {
        hogarTasks.remove(task);
        addedHogar[task] = false;
      } else {
        hogarTasks.add(task);
        addedHogar[task] = true;
      }
    }
    notifyListeners();
  }

  JobTaskSelection getSelectedTasks() {
    return JobTaskSelection(cuidados: cuidadosTasks, hogar: hogarTasks);
  }
}
