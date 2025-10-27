import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final settings = provider.settings;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Настройки'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Тема', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Системная'), icon: Icon(Icons.phone_android)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Светлая'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Темная'), icon: Icon(Icons.dark_mode)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (value) =>
                    provider.updateThemeMode(value.first),
              ),
              const SizedBox(height: 24),
              Text('Акцентный цвет', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 12,
                children: AccentColorOption.values
                    .map(
                      (option) => ChoiceChip(
                        label: Text(option.name.toUpperCase()),
                        selected: settings.accentColor == option,
                        onSelected: (_) => provider.updateAccentColor(option),
                        selectedColor: option.color.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: settings.accentColor == option
                              ? option.color
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                value: settings.notificationsEnabled,
                title: const Text('Push-уведомления и напоминания'),
                subtitle: const Text(
                    'Используйте Firebase Cloud Messaging и локальные уведомления для напоминаний'),
                onChanged: provider.updateNotifications,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Оффлайн-режим',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Все данные задач хранятся в локальной базе Hive, что позволяет работать без подключения к сети.\nПри восстановлении интернета уведомления Firebase автоматически возобновят работу.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
