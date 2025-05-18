import 'package:hogarya/data/datasources/assigned_tasks_service.dart';

class AssignedTasksController {
  final AssignedTasksService _service = AssignedTasksService();

  Future<List<Map<String, dynamic>>> fetchTasksForHelper(String helperId) {
    return _service.getTasksForHelper(helperId);
  }
}
