import 'package:hive/hive.dart';

import '../models/recurrence_rule.dart';
import '../models/task.dart';
import '../models/task_priority.dart';

class TaskRepository {
  TaskRepository(this._box);

  final Box<Task> _box;

  List<Task> getAllTasks() {
    final tasks = _box.values.toList();
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    return tasks;
  }

  Stream<List<Task>> watchAll() => _box.watch().map((_) => getAllTasks());

  Task? getById(String id) => _box.get(id);

  Future<Task> addTask({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    TaskPriority priority = TaskPriority.normal,
    RecurrenceRule recurrence = RecurrenceRule.none,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndDate,
    int reminderMinutesBefore = 30,
    String? groupId,
  }) async {
    final task = Task.create(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      priority: priority,
      recurrence: recurrence,
      recurrenceInterval: recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate,
      reminderMinutesBefore: reminderMinutesBefore,
      groupId: groupId,
    );
    await _box.put(task.id, task);
    return task;
  }

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await task.save();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  Future<void> toggleCompletion(Task task, bool isCompleted) async {
    task
      ..isCompleted = isCompleted
      ..completedAt = isCompleted ? DateTime.now() : null
      ..updatedAt = DateTime.now();
    await task.save();
  }

  Future<Task?> completeAndScheduleNext(Task task) async {
    await toggleCompletion(task, true);
    if (task.recurrence == RecurrenceRule.none) {
      return null;
    }
    final nextDate = _nextOccurrence(task);
    if (nextDate == null) {
      return null;
    }
    return addTask(
      title: task.title,
      description: task.description,
      startTime: nextDate,
      endTime: task.endTime != null
          ? nextDate.add(task.endTime!.difference(task.startTime))
          : null,
      priority: task.priority,
      recurrence: task.recurrence,
      recurrenceInterval: task.recurrenceInterval,
      recurrenceEndDate: task.recurrenceEndDate,
      reminderMinutesBefore: task.reminderMinutesBefore,
      groupId: task.groupId ?? task.id,
    );
  }

  List<Task> tasksForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return getAllTasks()
        .where((task) => task.startTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            task.startTime.isBefore(end))
        .toList();
  }

  List<Task> tasksForWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return getAllTasks()
        .where((task) => !task.startTime.isBefore(start) && task.startTime.isBefore(end))
        .toList();
  }

  List<Task> tasksForMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return getAllTasks()
        .where((task) => !task.startTime.isBefore(start) && task.startTime.isBefore(end))
        .toList();
  }

  DateTime? _nextOccurrence(Task task) {
    final base = task.startTime;
    final interval = task.recurrence.baseInterval * task.recurrenceInterval;
    if (interval == Duration.zero) {
      return null;
    }
    DateTime next;
    if (task.recurrence == RecurrenceRule.monthly) {
      next = DateTime(base.year, base.month + task.recurrenceInterval, base.day,
          base.hour, base.minute);
    } else {
      next = base.add(interval);
    }
    if (task.recurrenceEndDate != null &&
        next.isAfter(task.recurrenceEndDate!)) {
      return null;
    }
    return next;
  }
}
