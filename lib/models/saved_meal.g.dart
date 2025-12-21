// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_meal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedMealItemAdapter extends TypeAdapter<SavedMealItem> {
  @override
  final int typeId = 20;

  @override
  SavedMealItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMealItem(
      name: fields[0] as String,
      servingSize: fields[1] as double,
      servings: fields[2] as double,
      calories: fields[3] as double,
      protein: fields[4] as double,
      carbs: fields[5] as double,
      fat: fields[6] as double,
      fiber: fields[7] as double,
      sugar: fields[8] as double,
      sodium: fields[9] as double,
      barcode: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedMealItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.servingSize)
      ..writeByte(2)
      ..write(obj.servings)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.carbs)
      ..writeByte(6)
      ..write(obj.fat)
      ..writeByte(7)
      ..write(obj.fiber)
      ..writeByte(8)
      ..write(obj.sugar)
      ..writeByte(9)
      ..write(obj.sodium)
      ..writeByte(10)
      ..write(obj.barcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMealItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedMealAdapter extends TypeAdapter<SavedMeal> {
  @override
  final int typeId = 21;

  @override
  SavedMeal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMeal(
      id: fields[0] as String,
      name: fields[1] as String,
      items: (fields[2] as List).cast<SavedMealItem>(),
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedMeal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
