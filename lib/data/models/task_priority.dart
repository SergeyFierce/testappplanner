import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum TaskPriority { low, normal, high, urgent }

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 0;

  @override
  TaskPriority read(BinaryReader reader) {
    final value = reader.readInt();
    return TaskPriority.values[value];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeInt(obj.index);
  }
}

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Низкий';
      case TaskPriority.normal:
        return 'Средний';
      case TaskPriority.high:
        return 'Высокий';
      case TaskPriority.urgent:
        return 'Срочный';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.normal:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
}
