import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required SettingsRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService {
    _load();
  }

  final SettingsRepository _repository;
  final NotificationService _notificationService;

  AppSettings? _settings;
  bool _loading = true;

  AppSettings get settings => _settings ?? _repository.settings;
  bool get loading => _loading;

  Future<void> _load() async {
    await _repository.ensureInitialized();
    _settings = _repository.settings;
    await _notificationService.initialize(
      notificationsEnabled: _settings?.notificationsEnabled ?? true,
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final updated = settings.copyWith(themeMode: mode);
    _settings = updated;
    await _repository.save(updated);
    notifyListeners();
  }

  Future<void> updateAccentColor(AccentColorOption option) async {
    final updated = settings.copyWith(accentColor: option);
    _settings = updated;
    await _repository.save(updated);
    notifyListeners();
  }

  Future<void> updateNotifications(bool enabled) async {
    final updated = settings.copyWith(notificationsEnabled: enabled);
    _settings = updated;
    await _repository.save(updated);
    if (enabled) {
      await _notificationService.initialize(notificationsEnabled: true);
    }
    notifyListeners();
  }
}
