import 'package:flutter/material.dart';

import 'calendar/calendar_page.dart';
import 'reports/report_page.dart';
import 'settings/settings_page.dart';
import 'tasks/task_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    CalendarPage(),
    TaskListPage(),
    ReportPage(),
    SettingsPage(),
  ];

  final _navItems = const [
    NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Календарь'),
    NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Задачи'),
    NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Отчеты'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Настройки'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: _navItems,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
