import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'data/models/app_settings.dart';
import 'data/models/recurrence_rule.dart';
import 'data/models/task.dart';
import 'data/models/task_priority.dart';
import 'firebase_options.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/storage/hive_boxes.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  Hive
    ..registerAdapter(TaskPriorityAdapter())
    ..registerAdapter(RecurrenceRuleAdapter())
    ..registerAdapter(TaskAdapter())
    ..registerAdapter(AccentColorOptionAdapter())
    ..registerAdapter(ThemeModeAdapter())
    ..registerAdapter(AppSettingsAdapter());

  final taskBox = await Hive.openBox<Task>(HiveBoxes.tasks);
  final settingsBox = await Hive.openBox<AppSettings>(HiveBoxes.settings);

  final taskRepository = TaskRepository(taskBox);
  final settingsRepository = SettingsRepository(settingsBox);
  final notificationService = NotificationService.instance;

  final currentSettings = settingsRepository.settings;
  await notificationService.initialize(
    notificationsEnabled: currentSettings.notificationsEnabled,
  );

  if (currentSettings.notificationsEnabled) {
    for (final task in taskRepository.getAllTasks()) {
      await notificationService.scheduleTaskReminder(task);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            repository: settingsRepository,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            repository: taskRepository,
            notificationService: notificationService,
          ),
        ),
      ],
      child: const PlannerApp(),
    ),
  );
}
