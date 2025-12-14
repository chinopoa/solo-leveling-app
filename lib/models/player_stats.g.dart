// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerStatsAdapter extends TypeAdapter<PlayerStats> {
  @override
  final int typeId = 1;

  @override
  PlayerStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStats(
      strength: fields[0] as int,
      agility: fields[1] as int,
      vitality: fields[2] as int,
      intelligence: fields[3] as int,
      sense: fields[4] as int,
      availablePoints: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.strength)
      ..writeByte(1)
      ..write(obj.agility)
      ..writeByte(2)
      ..write(obj.vitality)
      ..writeByte(3)
      ..write(obj.intelligence)
      ..writeByte(4)
      ..write(obj.sense)
      ..writeByte(5)
      ..write(obj.availablePoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
