// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSetAdapter extends TypeAdapter<WorkoutSet> {
  @override
  final int typeId = 24;

  @override
  WorkoutSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSet(
      id: fields[0] as String?,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      weight: fields[3] as double,
      reps: fields[4] as int,
      isPR: fields[5] as bool,
      timestamp: fields[6] as DateTime?,
      note: fields[7] as String?,
      setNumber: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSet obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.reps)
      ..writeByte(5)
      ..write(obj.isPR)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.setNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
