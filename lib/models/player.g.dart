// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      name: fields[0] as String,
      level: fields[1] as int,
      currentXp: fields[2] as int,
      xpToNextLevel: fields[3] as int,
      jobClass: fields[4] as String,
      title: fields[5] as String,
      rank: fields[6] as String,
      currentHp: fields[7] as int,
      maxHp: fields[8] as int,
      currentMp: fields[9] as int,
      maxMp: fields[10] as int,
      fatigue: fields[11] as int,
      gold: fields[12] as int,
      dailyStreak: fields[13] as int,
      lastDailyCompletion: fields[14] as DateTime?,
      unlockedTitles: (fields[15] as List?)?.cast<String>(),
      stats: fields[16] as PlayerStats?,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.currentXp)
      ..writeByte(3)
      ..write(obj.xpToNextLevel)
      ..writeByte(4)
      ..write(obj.jobClass)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.rank)
      ..writeByte(7)
      ..write(obj.currentHp)
      ..writeByte(8)
      ..write(obj.maxHp)
      ..writeByte(9)
      ..write(obj.currentMp)
      ..writeByte(10)
      ..write(obj.maxMp)
      ..writeByte(11)
      ..write(obj.fatigue)
      ..writeByte(12)
      ..write(obj.gold)
      ..writeByte(13)
      ..write(obj.dailyStreak)
      ..writeByte(14)
      ..write(obj.lastDailyCompletion)
      ..writeByte(15)
      ..write(obj.unlockedTitles)
      ..writeByte(16)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
