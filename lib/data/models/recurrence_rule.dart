import 'package:hive/hive.dart';

enum RecurrenceRule { none, daily, weekly, monthly }

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = 1;

  @override
  RecurrenceRule read(BinaryReader reader) {
    final value = reader.readInt();
    return RecurrenceRule.values[value];
  }

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) {
    writer.writeInt(obj.index);
  }
}

extension RecurrenceRuleX on RecurrenceRule {
  String get label {
    switch (this) {
      case RecurrenceRule.none:
        return 'Без повтора';
      case RecurrenceRule.daily:
        return 'Ежедневно';
      case RecurrenceRule.weekly:
        return 'Еженедельно';
      case RecurrenceRule.monthly:
        return 'Ежемесячно';
    }
  }

  Duration get baseInterval {
    switch (this) {
      case RecurrenceRule.none:
        return const Duration();
      case RecurrenceRule.daily:
        return const Duration(days: 1);
      case RecurrenceRule.weekly:
        return const Duration(days: 7);
      case RecurrenceRule.monthly:
        return const Duration(days: 30);
    }
  }
}
