import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum AccentColorOption {
  blue(Colors.blue),
  green(Colors.green),
  purple(Colors.purple),
  orange(Colors.deepOrange),
  pink(Colors.pinkAccent);

  const AccentColorOption(this.color);

  final Color color;
}

class AccentColorOptionAdapter extends TypeAdapter<AccentColorOption> {
  @override
  final int typeId = 3;

  @override
  AccentColorOption read(BinaryReader reader) {
    final value = reader.readInt();
    return AccentColorOption.values[value];
  }

  @override
  void write(BinaryWriter writer, AccentColorOption obj) {
    writer.writeInt(obj.index);
  }
}

class AppSettings extends HiveObject {
  AppSettings({
    required this.themeMode,
    required this.accentColor,
    required this.notificationsEnabled,
  });

  ThemeMode themeMode;
  AccentColorOption accentColor;
  bool notificationsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AccentColorOption? accentColor,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 4;

  @override
  ThemeMode read(BinaryReader reader) {
    final value = reader.readInt();
    return ThemeMode.values[value];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 5;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppSettings(
      themeMode: fields[0] as ThemeMode,
      accentColor: fields[1] as AccentColorOption,
      notificationsEnabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.accentColor)
      ..writeByte(2)
      ..write(obj.notificationsEnabled);
  }
}
