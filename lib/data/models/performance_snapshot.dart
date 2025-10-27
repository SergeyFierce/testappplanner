class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.periodLabel,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.focusTimeHours,
  });

  final String periodLabel;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final double focusTimeHours;
}
