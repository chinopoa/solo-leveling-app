// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionEntryAdapter extends TypeAdapter<NutritionEntry> {
  @override
  final int typeId = 10;

  @override
  NutritionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionEntry(
      id: fields[0] as String,
      date: fields[1] as String,
      barcode: fields[2] as String?,
      productName: fields[3] as String,
      brand: fields[4] as String?,
      servingSize: fields[5] as double,
      servingsConsumed: fields[6] as double,
      calories: fields[7] as double,
      protein: fields[8] as double,
      carbs: fields[9] as double,
      fat: fields[10] as double,
      fiber: fields[11] as double,
      sugar: fields[12] as double,
      sodium: fields[13] as double,
      mealType: fields[14] as MealType,
      timestamp: fields[15] as DateTime?,
      isManualEntry: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionEntry obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.servingSize)
      ..writeByte(6)
      ..write(obj.servingsConsumed)
      ..writeByte(7)
      ..write(obj.calories)
      ..writeByte(8)
      ..write(obj.protein)
      ..writeByte(9)
      ..write(obj.carbs)
      ..writeByte(10)
      ..write(obj.fat)
      ..writeByte(11)
      ..write(obj.fiber)
      ..writeByte(12)
      ..write(obj.sugar)
      ..writeByte(13)
      ..write(obj.sodium)
      ..writeByte(14)
      ..write(obj.mealType)
      ..writeByte(15)
      ..write(obj.timestamp)
      ..writeByte(16)
      ..write(obj.isManualEntry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 12;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      case 3:
        return MealType.snack;
      default:
        return MealType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast:
        writer.writeByte(0);
        break;
      case MealType.lunch:
        writer.writeByte(1);
        break;
      case MealType.dinner:
        writer.writeByte(2);
        break;
      case MealType.snack:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
