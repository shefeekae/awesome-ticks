// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_reasons_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReasonsDbAdapter extends TypeAdapter<ReasonsDb> {
  @override
  final int typeId = 11;

  @override
  ReasonsDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReasonsDb(
      identifier: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReasonsDb obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasonsDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
