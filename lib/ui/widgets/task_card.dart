import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/task.dart';
import '../../data/models/recurrence_rule.dart';
import '../../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, super.key, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat.Hm();
    final provider = context.read<TaskProvider>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => provider.toggleTaskCompletion(task),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: task.priority.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            task.priority.label,
                            style: TextStyle(color: task.priority.color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeRange(timeFormatter),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                    if ((task.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (task.recurrence != RecurrenceRule.none) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.repeat, size: 16),
                          const SizedBox(width: 6),
                          Text(task.recurrence.label),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(DateFormat formatter) {
    final start = formatter.format(task.startTime);
    if (task.endTime != null) {
      final end = formatter.format(task.endTime!);
      return '$start — $end';
    }
    return start;
  }
}
