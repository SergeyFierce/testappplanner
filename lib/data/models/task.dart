import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'recurrence_rule.dart';
import 'task_priority.dart';

class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.priority,
    required this.recurrence,
    this.recurrenceInterval = 1,
    this.recurrenceEndDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.reminderMinutesBefore = 30,
    this.groupId,
  });

  factory Task.create({
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    TaskPriority priority = TaskPriority.normal,
    RecurrenceRule recurrence = RecurrenceRule.none,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndDate,
    int reminderMinutesBefore = 30,
    String? groupId,
  }) {
    final now = DateTime.now();
    return Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      priority: priority,
      recurrence: recurrence,
      recurrenceInterval: recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate,
      createdAt: now,
      updatedAt: now,
      reminderMinutesBefore: reminderMinutesBefore,
      groupId: groupId,
    );
  }

  String id;
  String title;
  String? description;
  DateTime startTime;
  DateTime? endTime;
  TaskPriority priority;
  RecurrenceRule recurrence;
  int recurrenceInterval;
  DateTime? recurrenceEndDate;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? completedAt;
  int reminderMinutesBefore;
  String? groupId;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    TaskPriority? priority,
    RecurrenceRule? recurrence,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? reminderMinutesBefore,
    String? groupId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      groupId: groupId ?? this.groupId,
    );
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      priority: fields[5] as TaskPriority,
      recurrence: fields[6] as RecurrenceRule,
      recurrenceInterval: fields[7] as int,
      recurrenceEndDate: fields[8] as DateTime?,
      isCompleted: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      completedAt: fields[12] as DateTime?,
      reminderMinutesBefore: fields[13] as int,
      groupId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.recurrence)
      ..writeByte(7)
      ..write(obj.recurrenceInterval)
      ..writeByte(8)
      ..write(obj.recurrenceEndDate)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(14)
      ..write(obj.groupId);
  }
}
