// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PRHistoryEntryAdapter extends TypeAdapter<PRHistoryEntry> {
  @override
  final int typeId = 18;

  @override
  PRHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PRHistoryEntry(
      value: fields[0] as double,
      date: fields[1] as DateTime,
      note: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PRHistoryEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PRHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersonalRecordAdapter extends TypeAdapter<PersonalRecord> {
  @override
  final int typeId = 19;

  @override
  PersonalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalRecord(
      id: fields[0] as String?,
      name: fields[1] as String,
      category: fields[2] as String,
      currentValue: fields[3] as double,
      unit: fields[4] as String,
      achievedAt: fields[5] as DateTime?,
      history: (fields[6] as List?)?.cast<PRHistoryEntry>(),
      relatedQuestType: fields[7] as String?,
      isAutoTracked: fields[8] as bool,
      iconEmoji: fields[9] as String?,
      previousValue: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.currentValue)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.achievedAt)
      ..writeByte(6)
      ..write(obj.history)
      ..writeByte(7)
      ..write(obj.relatedQuestType)
      ..writeByte(8)
      ..write(obj.isAutoTracked)
      ..writeByte(9)
      ..write(obj.iconEmoji)
      ..writeByte(10)
      ..write(obj.previousValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
