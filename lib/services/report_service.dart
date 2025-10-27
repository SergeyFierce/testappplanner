import 'package:intl/intl.dart';

import '../data/models/performance_snapshot.dart';
import '../data/models/task.dart';

class ReportService {
  List<PerformanceSnapshot> buildSnapshots(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(today.year, today.month);

    return [
      _snapshotForRange(tasks, today, today.add(const Duration(days: 1)),
          'Сегодня'),
      _snapshotForRange(tasks, weekStart, weekStart.add(const Duration(days: 7)),
          'Эта неделя'),
      _snapshotForRange(tasks, monthStart,
          DateTime(monthStart.year, monthStart.month + 1), 'Этот месяц'),
      _snapshotForRange(tasks, today.subtract(const Duration(days: 30)),
          today.add(const Duration(days: 1)), '30 дней'),
    ];
  }

  PerformanceSnapshot _snapshotForRange(
    List<Task> tasks,
    DateTime start,
    DateTime end,
    String label,
  ) {
    final filtered = tasks
        .where((task) => !task.startTime.isBefore(start) && task.startTime.isBefore(end))
        .toList();
    final completed = filtered.where((task) => task.isCompleted).length;
    final focusHours = filtered.fold<double>(0, (total, task) {
      final duration = task.endTime != null
          ? task.endTime!.difference(task.startTime)
          : const Duration(hours: 1);
      return total + duration.inMinutes / 60.0;
    });
    final rate = filtered.isEmpty ? 0 : completed / filtered.length;
    return PerformanceSnapshot(
      periodLabel: label,
      totalTasks: filtered.length,
      completedTasks: completed,
      completionRate: double.parse(rate.toStringAsFixed(2)),
      focusTimeHours: double.parse(focusHours.toStringAsFixed(1)),
    );
  }

  String formatCompletionRate(double value) {
    final percentage = NumberFormat.percentPattern('ru_RU');
    return percentage.format(value);
  }

  String formatHours(double hours) {
    return '${hours.toStringAsFixed(1)} ч';
  }
}
