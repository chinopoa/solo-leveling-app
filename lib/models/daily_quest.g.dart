// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_quest.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyQuestConfigAdapter extends TypeAdapter<DailyQuestConfig> {
  @override
  final int typeId = 3;

  @override
  DailyQuestConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyQuestConfig(
      id: fields[0] as String,
      title: fields[1] as String,
      targetCount: fields[2] as int,
      statBonus: fields[3] as String,
      isEnabled: fields[4] as bool,
      order: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyQuestConfig obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetCount)
      ..writeByte(3)
      ..write(obj.statBonus)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyQuestConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyQuestProgressAdapter extends TypeAdapter<DailyQuestProgress> {
  @override
  final int typeId = 4;

  @override
  DailyQuestProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyQuestProgress(
      date: fields[0] as String,
      progress: (fields[1] as Map?)?.cast<String, int>(),
      isCompleted: fields[2] as bool,
      penaltyTriggered: fields[3] as bool,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyQuestProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.progress)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.penaltyTriggered)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyQuestProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
