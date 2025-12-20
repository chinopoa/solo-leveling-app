// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 15;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      frequency: fields[3] as String,
      targetPerPeriod: fields[4] as int,
      currentStreak: fields[5] as int,
      longestStreak: fields[6] as int,
      completionDates: (fields[7] as List?)?.cast<String>(),
      relatedStat: fields[8] as String?,
      relatedSkillId: fields[9] as String?,
      createdAt: fields[10] as DateTime?,
      isEnabled: fields[11] as bool,
      iconEmoji: fields[12] as String?,
      xpPerCompletion: fields[13] as int,
      customDays: (fields[14] as List?)?.cast<int>(),
      isDefault: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.targetPerPeriod)
      ..writeByte(5)
      ..write(obj.currentStreak)
      ..writeByte(6)
      ..write(obj.longestStreak)
      ..writeByte(7)
      ..write(obj.completionDates)
      ..writeByte(8)
      ..write(obj.relatedStat)
      ..writeByte(9)
      ..write(obj.relatedSkillId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.isEnabled)
      ..writeByte(12)
      ..write(obj.iconEmoji)
      ..writeByte(13)
      ..write(obj.xpPerCompletion)
      ..writeByte(14)
      ..write(obj.customDays)
      ..writeByte(15)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
