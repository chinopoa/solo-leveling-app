// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExercisePRHistoryAdapter extends TypeAdapter<ExercisePRHistory> {
  @override
  final int typeId = 22;

  @override
  ExercisePRHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExercisePRHistory(
      weight: fields[0] as double,
      reps: fields[1] as int,
      achievedAt: fields[2] as DateTime,
      rank: fields[3] as String,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExercisePRHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.achievedAt)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExercisePRHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 23;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String?,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      armSubGroup: fields[3] as String?,
      iconEmoji: fields[4] as String?,
      notes: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      currentPRWeight: fields[7] as double?,
      currentPRReps: fields[8] as int?,
      rank: fields[9] as String,
      prHistory: (fields[10] as List?)?.cast<ExercisePRHistory>(),
      prCount: fields[11] as int,
      lastPerformedAt: fields[12] as DateTime?,
      lastWeight: fields[13] as double?,
      lastReps: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.armSubGroup)
      ..writeByte(4)
      ..write(obj.iconEmoji)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.currentPRWeight)
      ..writeByte(8)
      ..write(obj.currentPRReps)
      ..writeByte(9)
      ..write(obj.rank)
      ..writeByte(10)
      ..write(obj.prHistory)
      ..writeByte(11)
      ..write(obj.prCount)
      ..writeByte(12)
      ..write(obj.lastPerformedAt)
      ..writeByte(13)
      ..write(obj.lastWeight)
      ..writeByte(14)
      ..write(obj.lastReps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
