import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../services/report_service.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final service = ReportService();
    final snapshots = service.buildSnapshots(provider.tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчеты'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: snapshots.length,
        itemBuilder: (context, index) {
          final snapshot = snapshots[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.periodLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Всего задач',
                          value: snapshot.totalTasks.toString(),
                          icon: Icons.list_alt,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: 'Завершено',
                          value: snapshot.completedTasks.toString(),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Успеваемость',
                          value: service.formatCompletionRate(snapshot.completionRate),
                          icon: Icons.percent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: 'Фокус, ч',
                          value: service.formatHours(snapshot.focusTimeHours),
                          icon: Icons.timelapse,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: snapshot.completionRate.clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(label),
        ],
      ),
    );
  }
}
