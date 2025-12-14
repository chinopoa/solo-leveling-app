// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dungeon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DungeonAdapter extends TypeAdapter<Dungeon> {
  @override
  final int typeId = 5;

  @override
  Dungeon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dungeon(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      rank: fields[3] as String,
      questIds: (fields[4] as List?)?.cast<String>(),
      bossQuestId: fields[5] as String?,
      isCleared: fields[6] as bool,
      createdAt: fields[7] as DateTime?,
      clearedAt: fields[8] as DateTime?,
      totalXpReward: fields[9] as int,
      totalGoldReward: fields[10] as int,
      rewardItemId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Dungeon obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.questIds)
      ..writeByte(5)
      ..write(obj.bossQuestId)
      ..writeByte(6)
      ..write(obj.isCleared)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.clearedAt)
      ..writeByte(9)
      ..write(obj.totalXpReward)
      ..writeByte(10)
      ..write(obj.totalGoldReward)
      ..writeByte(11)
      ..write(obj.rewardItemId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DungeonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
