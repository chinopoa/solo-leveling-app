// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyWeightEntryAdapter extends TypeAdapter<BodyWeightEntry> {
  @override
  final int typeId = 26;

  @override
  BodyWeightEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyWeightEntry(
      id: fields[0] as String?,
      weight: fields[1] as double,
      date: fields[2] as DateTime?,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyWeightEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyWeightEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
