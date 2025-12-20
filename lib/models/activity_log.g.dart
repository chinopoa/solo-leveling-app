// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogAdapter extends TypeAdapter<ActivityLog> {
  @override
  final int typeId = 16;

  @override
  ActivityLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLog(
      id: fields[0] as String?,
      activityType: fields[1] as String,
      statAffected: fields[2] as String?,
      statPoints: fields[3] as int,
      timestamp: fields[4] as DateTime?,
      sourceId: fields[5] as String?,
      sourceType: fields[6] as String,
      note: fields[7] as String?,
      xpEarned: fields[8] as int,
      skillId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.activityType)
      ..writeByte(2)
      ..write(obj.statAffected)
      ..writeByte(3)
      ..write(obj.statPoints)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.sourceId)
      ..writeByte(6)
      ..write(obj.sourceType)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.xpEarned)
      ..writeByte(9)
      ..write(obj.skillId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
