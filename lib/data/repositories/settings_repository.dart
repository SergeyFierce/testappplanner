import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._box);

  final Box<AppSettings> _box;

  AppSettings get settings =>
      _box.values.isNotEmpty ? _box.values.first : _defaultSettings;

  AppSettings get _defaultSettings => AppSettings(
        themeMode: ThemeMode.system,
        accentColor: AccentColorOption.blue,
        notificationsEnabled: true,
      );

  Future<void> ensureInitialized() async {
    if (_box.values.isEmpty) {
      await _box.add(_defaultSettings);
    }
  }

  Future<void> save(AppSettings settings) async {
    if (_box.values.isEmpty) {
      await _box.add(settings);
    } else {
      await _box.putAt(0, settings);
    }
  }
}
