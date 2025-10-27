import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_editor.dart';

enum TaskFilter { all, active, completed }

extension TaskFilterX on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'Все';
      case TaskFilter.active:
        return 'Активные';
      case TaskFilter.completed:
        return 'Завершенные';
    }
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = _filteredTasks(provider.tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          PopupMenuButton<TaskFilter>(
            initialValue: _filter,
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => TaskFilter.values
                .map(
                  (filter) => PopupMenuItem(
                    value: filter,
                    child: Text(filter.label),
                  ),
                )
                .toList(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => _openEditor(context, task: task),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_task),
        label: const Text('Новая задача'),
      ),
    );
  }

  List<Task> _filteredTasks(List<Task> tasks) {
    switch (_filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.active:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
    }
  }

  Future<void> _openEditor(BuildContext context, {Task? task}) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => TaskEditorSheet(task: task),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Theme.of(context).hintColor),
          const SizedBox(height: 12),
          const Text('Добавьте свою первую задачу'),
        ],
      ),
    );
  }
}
