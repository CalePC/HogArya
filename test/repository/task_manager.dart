class TaskManager {

  final List<String> cuidados;
  final List<String> hogar;


  final Map<String, bool> addedCuidados;
  final Map<String, bool> addedHogar;

  TaskManager({Map<String, dynamic>? editingRequest})
      : cuidados = List<String>.from(
    editingRequest?['tasks']?['cuidados'] ?? const [],
  ),
        hogar = List<String>.from(
          editingRequest?['tasks']?['hogar'] ?? const [],
        ),
        addedCuidados = {},
        addedHogar = {} {

    for (final t in cuidados) {
      addedCuidados[t] = true;
    }
    for (final t in hogar) {
      addedHogar[t] = true;
    }
  }


  void addTask(String category, String task) {
    if (category == 'Cuidados') {
      cuidados.add(task);
      addedCuidados[task] = true;
    } else {
      hogar.add(task);
      addedHogar[task] = true;
    }
  }

  Map<String, List<String>> buildTasksMap() => {
    'cuidados': List.unmodifiable(cuidados),
    'hogar': List.unmodifiable(hogar),
  };
}


