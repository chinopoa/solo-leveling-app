// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_split.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSplitAdapter extends TypeAdapter<WorkoutSplit> {
  @override
  final int typeId = 27;

  @override
  WorkoutSplit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSplit(
      monday: (fields[0] as List?)?.cast<String>(),
      tuesday: (fields[1] as List?)?.cast<String>(),
      wednesday: (fields[2] as List?)?.cast<String>(),
      thursday: (fields[3] as List?)?.cast<String>(),
      friday: (fields[4] as List?)?.cast<String>(),
      saturday: (fields[5] as List?)?.cast<String>(),
      sunday: (fields[6] as List?)?.cast<String>(),
      name: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSplit obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.monday)
      ..writeByte(1)
      ..write(obj.tuesday)
      ..writeByte(2)
      ..write(obj.wednesday)
      ..writeByte(3)
      ..write(obj.thursday)
      ..writeByte(4)
      ..write(obj.friday)
      ..writeByte(5)
      ..write(obj.saturday)
      ..writeByte(6)
      ..write(obj.sunday)
      ..writeByte(7)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSplitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
