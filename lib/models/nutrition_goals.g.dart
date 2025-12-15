// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionGoalsAdapter extends TypeAdapter<NutritionGoals> {
  @override
  final int typeId = 11;

  @override
  NutritionGoals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionGoals(
      dailyCalories: fields[0] as int,
      dailyProtein: fields[1] as int,
      dailyCarbs: fields[2] as int,
      dailyFat: fields[3] as int,
      dailyFiber: fields[4] as int,
      dailySugar: fields[5] as int,
      dailySodium: fields[6] as int,
      isEnabled: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionGoals obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dailyCalories)
      ..writeByte(1)
      ..write(obj.dailyProtein)
      ..writeByte(2)
      ..write(obj.dailyCarbs)
      ..writeByte(3)
      ..write(obj.dailyFat)
      ..writeByte(4)
      ..write(obj.dailyFiber)
      ..writeByte(5)
      ..write(obj.dailySugar)
      ..writeByte(6)
      ..write(obj.dailySodium)
      ..writeByte(7)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionGoalsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
