// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestAdapter extends TypeAdapter<Quest> {
  @override
  final int typeId = 2;

  @override
  Quest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quest(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      xpReward: fields[3] as int,
      goldReward: fields[4] as int,
      questType: fields[5] as String,
      difficulty: fields[6] as String,
      status: fields[7] as String,
      createdAt: fields[8] as DateTime?,
      deadline: fields[9] as DateTime?,
      completedAt: fields[10] as DateTime?,
      statBonus: fields[11] as String?,
      statBonusAmount: fields[12] as int,
      isRepeatable: fields[13] as bool,
      targetCount: fields[14] as int,
      currentCount: fields[15] as int,
      parentDungeonId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Quest obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.xpReward)
      ..writeByte(4)
      ..write(obj.goldReward)
      ..writeByte(5)
      ..write(obj.questType)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.deadline)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.statBonus)
      ..writeByte(12)
      ..write(obj.statBonusAmount)
      ..writeByte(13)
      ..write(obj.isRepeatable)
      ..writeByte(14)
      ..write(obj.targetCount)
      ..writeByte(15)
      ..write(obj.currentCount)
      ..writeByte(16)
      ..write(obj.parentDungeonId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
