import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'ui/home.dart';

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final settings = settingsProvider.settings;
        return MaterialApp(
          title: 'Планировщик дня',
          theme: AppTheme.light(settings.accentColor),
          darkTheme: AppTheme.dark(settings.accentColor),
          themeMode: settings.themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
        );
      },
    );
  }
}
