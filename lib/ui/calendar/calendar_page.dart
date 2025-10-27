import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/task.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../tasks/task_editor.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Календарь'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'День'),
              Tab(text: 'Неделя'),
              Tab(text: 'Месяц'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DayView(),
            _WeekView(),
            _MonthView(),
          ],
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasksForSelectedDay;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tasks.length,
        itemBuilder: (context, index) => TaskCard(
          task: tasks[index],
          onTap: () => _openEditor(context, tasks[index]),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Task task) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => TaskEditorSheet(task: task),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final start = provider.focusedDay
        .subtract(Duration(days: provider.focusedDay.weekday - 1));
    final weeklyTasks = provider.tasksForWeek(start);
    final dateFormatter = DateFormat.EEEE('ru_RU');
    final dayFormatter = DateFormat.MMMMd('ru_RU');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = start.add(Duration(days: index));
        final tasks = weeklyTasks
            .where((task) => _isSameDay(task.startTime, day))
            .toList();
        return Card(
          child: ExpansionTile(
            title: Text(dayFormatter.format(day)),
            subtitle: Text(dateFormatter.format(day)),
            children: tasks.isEmpty
                ? [
                    const ListTile(
                      title: Text('Нет задач'),
                    ),
                  ]
                : tasks
                    .map((task) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TaskCard(
                            task: task,
                            onTap: () => _openEditor(context, task),
                          ),
                        ))
                    .toList(),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> _openEditor(BuildContext context, Task task) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => TaskEditorSheet(task: task),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView();

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            TableCalendar<Task>(
              locale: 'ru_RU',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: provider.focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, provider.selectedDay),
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.all,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              onDaySelected: (selectedDay, focusedDay) {
                provider.onDaySelected(selectedDay, focusedDay);
              },
              onPageChanged: provider.onPageChanged,
              eventLoader: (day) => provider.tasksForDay(day),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: provider.tasksForSelectedDay.length,
                itemBuilder: (context, index) {
                  final task = provider.tasksForSelectedDay[index];
                  return TaskCard(
                    task: task,
                    onTap: () => _openEditor(context, task),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditor(BuildContext context, Task task) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => TaskEditorSheet(task: task),
    );
  }
}
