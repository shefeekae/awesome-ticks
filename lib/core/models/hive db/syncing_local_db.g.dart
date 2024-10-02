// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syncing_local_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncingLocalDbAdapter extends TypeAdapter<SyncingLocalDb> {
  @override
  final int typeId = 12;

  @override
  SyncingLocalDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncingLocalDb(
      payload: (fields[0] as Map).cast<String, dynamic>(),
      generatedTime: fields[1] as int,
      graphqlMethod: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SyncingLocalDb obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.generatedTime)
      ..writeByte(2)
      ..write(obj.graphqlMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncingLocalDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
