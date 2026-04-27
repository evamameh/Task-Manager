import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  late Task activeTask;
  late Task completedTask;

  Widget buildTestApp({
    required Task task,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TaskTile(task: task, onToggle: onToggle, onDelete: onDelete),
      ),
    );
  }

  setUp(() {
    activeTask = Task(
      id: 'task-1',
      title: 'Write widget tests',
      description: 'Create TaskTile tests',
      priority: Priority.high,
      dueDate: DateTime(2026, 3, 20),
    );

    completedTask = Task(
      id: 'task-2',
      title: 'Submit finished task',
      description: 'Already done',
      priority: Priority.low,
      dueDate: DateTime(2026, 3, 10),
      isCompleted: true,
    );
  });

  group('TaskTile — Rendering', () {
    testWidgets('displays the task title text', (tester) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      expect(find.text('Write widget tests'), findsOneWidget);
    });

    testWidgets('shows the uppercase priority label', (tester) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('reflects incomplete state in the checkbox value', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('renders a delete icon button', (tester) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  group('TaskTile — Checkbox Interaction', () {
    testWidgets('calls onToggle when the checkbox is tapped', (tester) async {
      var wasCalled = false;

      await tester.pumpWidget(
        buildTestApp(
          task: activeTask,
          onToggle: () {
            wasCalled = true;
          },
          onDelete: () {},
        ),
      );

      await tester.tap(find.byKey(const Key('checkbox_task-1')));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('calls onToggle exactly once for one tap', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        buildTestApp(
          task: activeTask,
          onToggle: () {
            callCount++;
          },
          onDelete: () {},
        ),
      );

      await tester.tap(find.byKey(const Key('checkbox_task-1')));
      await tester.pump();

      expect(callCount, equals(1));
    });
  });

  group('TaskTile — Delete Interaction', () {
    testWidgets('calls onDelete when the delete button is tapped', (
      tester,
    ) async {
      var wasCalled = false;

      await tester.pumpWidget(
        buildTestApp(
          task: activeTask,
          onToggle: () {},
          onDelete: () {
            wasCalled = true;
          },
        ),
      );

      await tester.tap(find.byKey(const Key('delete_task-1')));
      await tester.pump();

      expect(wasCalled, isTrue);
    });

    testWidgets('calls onDelete exactly once for one tap', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        buildTestApp(
          task: activeTask,
          onToggle: () {},
          onDelete: () {
            callCount++;
          },
        ),
      );

      await tester.tap(find.byKey(const Key('delete_task-1')));
      await tester.pump();

      expect(callCount, equals(1));
    });
  });

  group('TaskTile — Completed State UI', () {
    testWidgets('shows line-through decoration when the task is completed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(task: completedTask, onToggle: () {}, onDelete: () {}),
      );

      final titleText = tester.widget<Text>(
        find.byKey(const Key('title_task-2')),
      );
      expect(titleText.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('shows no text decoration when the task is active', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      final titleText = tester.widget<Text>(
        find.byKey(const Key('title_task-1')),
      );
      expect(titleText.style?.decoration, equals(TextDecoration.none));
    });
  });

  group('TaskTile — Key Assertions', () {
    testWidgets('uses a ValueKey that matches the task id', (tester) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      expect(find.byKey(const ValueKey<String>('task-1')), findsOneWidget);
    });

    testWidgets('assigns the expected checkbox and delete keys', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(task: activeTask, onToggle: () {}, onDelete: () {}),
      );

      expect(find.byKey(const Key('checkbox_task-1')), findsOneWidget);
      expect(find.byKey(const Key('delete_task-1')), findsOneWidget);
    });
  });
}
