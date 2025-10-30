// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockModelAdapter extends TypeAdapter<BlockModel> {
  @override
  final int typeId = 2;

  @override
  BlockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlockModel(
      type: fields[0] as String,
      text: fields[1] as String,
      checked: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BlockModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.checked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
