// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopItemAdapter extends TypeAdapter<ShopItem> {
  @override
  final int typeId = 8;

  @override
  ShopItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopItem(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as int,
      category: fields[4] as String,
      effect: fields[5] as String?,
      isUserDefined: fields[6] as bool,
      iconEmoji: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShopItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.effect)
      ..writeByte(6)
      ..write(obj.isUserDefined)
      ..writeByte(7)
      ..write(obj.iconEmoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryAdapter extends TypeAdapter<Inventory> {
  @override
  final int typeId = 9;

  @override
  Inventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inventory(
      items: (fields[0] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Inventory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
