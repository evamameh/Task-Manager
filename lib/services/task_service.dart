import '../models/task.dart';

class TaskService {
  final List<Task> _tasks = [];

  List<Task> get allTasks => List.unmodifiable(_tasks);

  void addTask(Task task) {
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }
    _tasks.add(task);
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
  }

  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw StateError('Task not found: \$id');
    _tasks[index] = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );
  }

  List<Task> getByStatus({required bool completed}) =>
      _tasks.where((t) => t.isCompleted == completed).toList();

  List<Task> sortByPriority() {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted;
  }

  List<Task> sortByDueDate() {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  Map<String, int> get statistics => {
    'total': _tasks.length,
    'completed': _tasks.where((t) => t.isCompleted).length,
    'overdue': _tasks.where((t) => t.isOverdue).length,
  };
}
