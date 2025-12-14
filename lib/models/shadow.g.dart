// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shadow.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShadowAdapter extends TypeAdapter<Shadow> {
  @override
  final int typeId = 6;

  @override
  Shadow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shadow(
      id: fields[0] as String?,
      name: fields[1] as String,
      originalDungeonName: fields[2] as String,
      rank: fields[3] as String,
      type: fields[4] as String,
      extractedAt: fields[5] as DateTime?,
      powerLevel: fields[6] as int,
      passiveBonus: fields[7] as String?,
      passiveBonusAmount: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Shadow obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.originalDungeonName)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.extractedAt)
      ..writeByte(6)
      ..write(obj.powerLevel)
      ..writeByte(7)
      ..write(obj.passiveBonus)
      ..writeByte(8)
      ..write(obj.passiveBonusAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShadowArmyAdapter extends TypeAdapter<ShadowArmy> {
  @override
  final int typeId = 7;

  @override
  ShadowArmy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShadowArmy(
      shadowIds: (fields[0] as List?)?.cast<String>(),
      totalPower: fields[1] as int,
      maxCapacity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShadowArmy obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.shadowIds)
      ..writeByte(1)
      ..write(obj.totalPower)
      ..writeByte(2)
      ..write(obj.maxCapacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowArmyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
