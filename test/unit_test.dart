import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';

void main() {
  late TaskService service;
  late DateTime now;
  late Task baseTask;
  late Task pastDueActiveTask;
  late Task futureActiveTask;
  late Task completedPastTask;
  late Task highPriorityTask;
  late Task mediumPriorityTask;
  late Task lowPriorityTask;

  setUp(() {
    service = TaskService();
    now = DateTime.now();

    baseTask = Task(
      id: 'base',
      title: 'Base task',
      dueDate: now.add(const Duration(days: 2)),
    );

    pastDueActiveTask = Task(
      id: 'past-active',
      title: 'Past active',
      priority: Priority.low,
      dueDate: now.subtract(const Duration(days: 1)),
    );

    futureActiveTask = Task(
      id: 'future-active',
      title: 'Future active',
      priority: Priority.medium,
      dueDate: now.add(const Duration(days: 3)),
    );

    completedPastTask = Task(
      id: 'completed-past',
      title: 'Completed past',
      priority: Priority.high,
      dueDate: now.subtract(const Duration(days: 2)),
      isCompleted: true,
    );

    highPriorityTask = Task(
      id: 'high',
      title: 'High priority',
      priority: Priority.high,
      dueDate: now.add(const Duration(days: 5)),
    );

    mediumPriorityTask = Task(
      id: 'medium',
      title: 'Medium priority',
      priority: Priority.medium,
      dueDate: now.add(const Duration(days: 2)),
    );

    lowPriorityTask = Task(
      id: 'low',
      title: 'Low priority',
      priority: Priority.low,
      dueDate: now.add(const Duration(days: 7)),
    );
  });

  group('Task Model — Constructor & Properties', () {
    test('stores required id, title, and dueDate values', () {
      final dueDate = now.add(const Duration(days: 10));
      final task = Task(id: 't-1', title: 'Write tests', dueDate: dueDate);

      expect(task.id, equals('t-1'));
      expect(task.title, equals('Write tests'));
      expect(task.dueDate, equals(dueDate));
    });

    test('uses an empty description by default', () {
      final task = Task(id: 't-2', title: 'Read docs', dueDate: now);

      expect(task.description, isEmpty);
    });

    test('uses medium priority and incomplete status by default', () {
      final task = Task(id: 't-3', title: 'Review code', dueDate: now);

      expect(task.priority, equals(Priority.medium));
      expect(task.isCompleted, isFalse);
    });

    test('stores the provided priority value', () {
      final task = Task(
        id: 't-4',
        title: 'Ship feature',
        priority: Priority.high,
        dueDate: now,
      );

      expect(task.priority, equals(Priority.high));
    });
  });

  group('Task Model — copyWith()', () {
    test('updates only the provided field during a partial update', () {
      final updated = baseTask.copyWith(title: 'Updated task');

      expect(updated.title, equals('Updated task'));
      expect(updated.id, equals(baseTask.id));
      expect(updated.description, equals(baseTask.description));
      expect(updated.priority, equals(baseTask.priority));
      expect(updated.dueDate, equals(baseTask.dueDate));
      expect(updated.isCompleted, equals(baseTask.isCompleted));
    });

    test('updates every provided field during a full update', () {
      final updated = baseTask.copyWith(
        id: 'new-id',
        title: 'New title',
        description: 'New description',
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 9)),
        isCompleted: true,
      );

      expect(updated.id, equals('new-id'));
      expect(updated.title, equals('New title'));
      expect(updated.description, equals('New description'));
      expect(updated.priority, equals(Priority.high));
      expect(updated.dueDate, equals(now.add(const Duration(days: 9))));
      expect(updated.isCompleted, isTrue);
    });

    test('leaves the original task unchanged after copyWith is called', () {
      final updated = baseTask.copyWith(title: 'Changed');

      expect(baseTask.title, equals('Base task'));
      expect(updated, isNot(same(baseTask)));
    });
  });

  group('Task Model — isOverdue getter', () {
    test(
      'returns true when task is incomplete and due date is in the past',
      () {
        expect(pastDueActiveTask.isOverdue, isTrue);
      },
    );

    test('returns false when due date is in the future', () {
      expect(futureActiveTask.isOverdue, isFalse);
    });

    test('returns false when a past-due task is already completed', () {
      expect(completedPastTask.isOverdue, isFalse);
    });
  });

  group('Task Model — toJson() / fromJson()', () {
    test('preserves task values through a serialization round-trip', () {
      final original = Task(
        id: 'round-trip',
        title: 'Serialize me',
        description: 'Round-trip description',
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 4)),
        isCompleted: true,
      );

      final restored = Task.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.description, equals(original.description));
      expect(restored.priority, equals(original.priority));
      expect(restored.dueDate, equals(original.dueDate));
      expect(restored.isCompleted, equals(original.isCompleted));
    });

    test('stores priority as an int index and dueDate as an ISO string', () {
      final json = highPriorityTask.toJson();

      expect(json['priority'], equals(Priority.high.index));
      expect(json['priority'], isA<int>());
      expect(
        json['dueDate'],
        equals(highPriorityTask.dueDate.toIso8601String()),
      );
      expect(json['dueDate'], isA<String>());
    });

    test('maps the priority index back to the correct enum value', () {
      final restored = Task.fromJson({
        'id': 'json-task',
        'title': 'Mapped task',
        'priority': Priority.low.index,
        'dueDate': now.toIso8601String(),
      });

      expect(restored.priority, equals(Priority.low));
      expect(restored.description, isEmpty);
      expect(restored.isCompleted, isFalse);
    });
  });

  group('TaskService — addTask()', () {
    test('adds a task to the service on the happy path', () {
      service.addTask(baseTask);

      expect(service.allTasks, contains(baseTask));
      expect(service.allTasks, hasLength(1));
    });

    test('throws ArgumentError when the title is empty after trimming', () {
      final invalidTask = Task(id: 'invalid', title: '   ', dueDate: now);

      expect(() => service.addTask(invalidTask), throwsA(isA<ArgumentError>()));
    });

    test('allows duplicate task IDs to be added', () {
      service.addTask(baseTask);
      service.addTask(baseTask.copyWith(title: 'Same id, different title'));

      expect(service.allTasks, hasLength(2));
    });
  });

  group('TaskService — deleteTask()', () {
    test('removes an existing task by id', () {
      service.addTask(baseTask);
      service.addTask(futureActiveTask);

      service.deleteTask(baseTask.id);

      expect(
        service.allTasks.map((task) => task.id),
        isNot(contains(baseTask.id)),
      );
      expect(service.allTasks, hasLength(1));
    });

    test('does nothing when deleting a non-existent id', () {
      service.addTask(baseTask);

      expect(() => service.deleteTask('missing-id'), returnsNormally);
      expect(service.allTasks, hasLength(1));
    });
  });

  group('TaskService — toggleComplete()', () {
    test('changes an active task from false to true', () {
      service.addTask(futureActiveTask);

      service.toggleComplete(futureActiveTask.id);

      expect(service.allTasks.single.isCompleted, isTrue);
    });

    test('changes a completed task from true to false', () {
      service.addTask(completedPastTask);

      service.toggleComplete(completedPastTask.id);

      expect(service.allTasks.single.isCompleted, isFalse);
    });

    test('throws StateError when toggling an unknown id', () {
      expect(
        () => service.toggleComplete('unknown-id'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('TaskService — getByStatus()', () {
    test('returns only active tasks when completed is false', () {
      service.addTask(futureActiveTask);
      service.addTask(completedPastTask);
      service.addTask(pastDueActiveTask);

      final activeTasks = service.getByStatus(completed: false);

      expect(activeTasks.every((task) => task.isCompleted == false), isTrue);
      expect(activeTasks, hasLength(2));
    });

    test('returns only completed tasks when completed is true', () {
      service.addTask(futureActiveTask);
      service.addTask(completedPastTask);
      service.addTask(pastDueActiveTask);

      final completedTasks = service.getByStatus(completed: true);

      expect(completedTasks.every((task) => task.isCompleted), isTrue);
      expect(completedTasks, hasLength(1));
    });
  });

  group('TaskService — sortByPriority()', () {
    test('returns tasks from highest priority to lowest priority', () {
      service.addTask(lowPriorityTask);
      service.addTask(highPriorityTask);
      service.addTask(mediumPriorityTask);

      final sorted = service.sortByPriority();

      expect(
        sorted.map((task) => task.priority),
        orderedEquals([Priority.high, Priority.medium, Priority.low]),
      );
    });

    test('does not change the original task order stored in the service', () {
      service.addTask(lowPriorityTask);
      service.addTask(highPriorityTask);
      service.addTask(mediumPriorityTask);

      service.sortByPriority();

      expect(
        service.allTasks.map((task) => task.id),
        orderedEquals(['low', 'high', 'medium']),
      );
    });
  });

  group('TaskService — sortByDueDate()', () {
    test('returns tasks from earliest due date to latest due date', () {
      service.addTask(lowPriorityTask);
      service.addTask(highPriorityTask);
      service.addTask(mediumPriorityTask);

      final sorted = service.sortByDueDate();

      expect(
        sorted.map((task) => task.id),
        orderedEquals(['medium', 'high', 'low']),
      );
    });

    test('does not change the original task order stored in the service', () {
      service.addTask(lowPriorityTask);
      service.addTask(highPriorityTask);
      service.addTask(mediumPriorityTask);

      service.sortByDueDate();

      expect(
        service.allTasks.map((task) => task.id),
        orderedEquals(['low', 'high', 'medium']),
      );
    });
  });

  group('TaskService — statistics getter', () {
    test('returns zero counts when the service has no tasks', () {
      expect(
        service.statistics,
        equals({'total': 0, 'completed': 0, 'overdue': 0}),
      );
    });

    test('returns accurate total and completed counts for mixed tasks', () {
      service.addTask(futureActiveTask);
      service.addTask(completedPastTask);
      service.addTask(lowPriorityTask);

      final stats = service.statistics;

      expect(stats['total'], equals(3));
      expect(stats['completed'], equals(1));
    });

    test('counts only incomplete past-due tasks as overdue', () {
      service.addTask(pastDueActiveTask);
      service.addTask(completedPastTask);
      service.addTask(futureActiveTask);

      expect(service.statistics['overdue'], equals(1));
    });
  });
}
