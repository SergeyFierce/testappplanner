import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../data/models/recurrence_rule.dart';
import '../data/models/task.dart';
import '../data/models/task_priority.dart';
import '../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({
    required TaskRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService {
    _load();
  }

  final TaskRepository _repository;
  final NotificationService _notificationService;

  final List<Task> _tasks = [];
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;

  List<Task> get tasksForSelectedDay => _repository.tasksForDay(_selectedDay);

  List<Task> tasksForWeek(DateTime date) => _repository.tasksForWeek(date);

  List<Task> tasksForMonth(DateTime date) => _repository.tasksForMonth(date);

  List<Task> tasksForDay(DateTime day) => _repository.tasksForDay(day);

  Future<void> _load() async {
    _tasks
      ..clear()
      ..addAll(_repository.getAllTasks());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    TaskPriority priority = TaskPriority.normal,
    RecurrenceRule recurrence = RecurrenceRule.none,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndDate,
    int reminderMinutesBefore = 30,
  }) async {
    final task = await _repository.addTask(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      priority: priority,
      recurrence: recurrence,
      recurrenceInterval: recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate,
      reminderMinutesBefore: reminderMinutesBefore,
    );
    await _notificationService.scheduleTaskReminder(task);
    await refresh();
    return task;
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await _notificationService.cancelReminder(task.id);
    await _notificationService.scheduleTaskReminder(task);
    await refresh();
  }

  Future<void> deleteTask(Task task) async {
    await _notificationService.cancelReminder(task.id);
    await _repository.deleteTask(task);
    await refresh();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    if (task.isCompleted) {
      await _repository.toggleCompletion(task, false);
      await _notificationService.scheduleTaskReminder(task);
    } else {
      await _notificationService.cancelReminder(task.id);
      final nextTask = await _repository.completeAndScheduleNext(task);
      if (nextTask != null) {
        await _notificationService.scheduleTaskReminder(nextTask);
      }
    }
    await refresh();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }
}
