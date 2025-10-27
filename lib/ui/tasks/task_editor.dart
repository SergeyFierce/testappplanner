import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/recurrence_rule.dart';
import '../../data/models/task.dart';
import '../../data/models/task_priority.dart';
import '../../providers/task_provider.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({this.task, super.key});

  final Task? task;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  TaskPriority _priority = TaskPriority.normal;
  RecurrenceRule _recurrence = RecurrenceRule.none;
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  int _reminderMinutes = 30;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    final initialDate = task?.startTime ?? DateTime.now();
    _startDate = DateTime(initialDate.year, initialDate.month, initialDate.day);
    _startTime = TimeOfDay.fromDateTime(initialDate);
    if (task?.endTime != null) {
      _endDate = DateTime(task!.endTime!.year, task.endTime!.month, task.endTime!.day);
      _endTime = TimeOfDay.fromDateTime(task.endTime!);
    }
    _priority = task?.priority ?? TaskPriority.normal;
    _recurrence = task?.recurrence ?? RecurrenceRule.none;
    _recurrenceInterval = task?.recurrenceInterval ?? 1;
    _recurrenceEndDate = task?.recurrenceEndDate;
    _reminderMinutes = task?.reminderMinutesBefore ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat.yMMMMd('ru_RU');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.task == null ? 'Новая задача' : 'Редактирование задачи',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Дата начала',
                      value: dateFormatter.format(_startDate),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Время начала',
                      value: _startTime.format(context),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) {
                          setState(() => _startTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Дата окончания',
                      value:
                          _endDate != null ? dateFormatter.format(_endDate!) : 'Не указано',
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _endDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Время окончания',
                      value: _endTime != null ? _endTime!.format(context) : 'Не указано',
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? _startTime,
                        );
                        if (picked != null) {
                          setState(() => _endTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Приоритет',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RecurrenceRule>(
                value: _recurrence,
                decoration: const InputDecoration(
                  labelText: 'Повтор',
                  border: OutlineInputBorder(),
                ),
                items: RecurrenceRule.values
                    .map((rule) => DropdownMenuItem(
                          value: rule,
                          child: Text(rule.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recurrence = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              if (_recurrence != RecurrenceRule.none) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Интервал',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _recurrenceInterval.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            _recurrenceInterval = parsed;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: 'Дата окончания повтора',
                        value: _recurrenceEndDate != null
                            ? dateFormatter.format(_recurrenceEndDate!)
                            : 'Не указано',
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _recurrenceEndDate ?? _startDate,
                            firstDate: _startDate,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _recurrenceEndDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<int>(
                value: _reminderMinutes,
                decoration: const InputDecoration(
                  labelText: 'Напоминание',
                  border: OutlineInputBorder(),
                ),
                items: const [5, 10, 15, 30, 60, 120]
                    .map((minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text('За $minutes мин.'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reminderMinutes = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(widget.task == null ? 'Создать' : 'Сохранить'),
              ),
              if (widget.task != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить задачу?'),
                        content: const Text('Это действие нельзя будет отменить.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      await context.read<TaskProvider>().deleteTask(widget.task!);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Удалить задачу'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  DateTime _composeDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<TaskProvider>();
    final start = _composeDateTime(_startDate, _startTime);
    DateTime? end;
    if (_endDate != null && _endTime != null) {
      end = _composeDateTime(_endDate!, _endTime!);
    }
    if (end != null && end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Окончание не может быть раньше начала')),
      );
      return;
    }

    if (widget.task == null) {
      await provider.createTask(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: start,
        endTime: end,
        priority: _priority,
        recurrence: _recurrence,
        recurrenceInterval: _recurrenceInterval,
        recurrenceEndDate: _recurrenceEndDate,
        reminderMinutesBefore: _reminderMinutes,
      );
    } else {
      final updated = widget.task!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: start,
        endTime: end,
        priority: _priority,
        recurrence: _recurrence,
        recurrenceInterval: _recurrenceInterval,
        recurrenceEndDate: _recurrenceEndDate,
        reminderMinutesBefore: _reminderMinutes,
      );
      await provider.updateTask(updated);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
