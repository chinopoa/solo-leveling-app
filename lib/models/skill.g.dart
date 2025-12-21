// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillAdapter extends TypeAdapter<Skill> {
  @override
  final int typeId = 17;

  @override
  Skill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Skill(
      id: fields[0] as String?,
      name: fields[1] as String,
      category: fields[2] as String,
      rank: fields[3] as String,
      currentXp: fields[4] as int,
      xpToNextRank: fields[5] as int,
      relatedStat: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      lastProgressAt: fields[8] as DateTime?,
      iconEmoji: fields[9] as String?,
      totalXpEarned: fields[10] as int,
      description: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Skill obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.currentXp)
      ..writeByte(5)
      ..write(obj.xpToNextRank)
      ..writeByte(6)
      ..write(obj.relatedStat)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastProgressAt)
      ..writeByte(9)
      ..write(obj.iconEmoji)
      ..writeByte(10)
      ..write(obj.totalXpEarned)
      ..writeByte(11)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
