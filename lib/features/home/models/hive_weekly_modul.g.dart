// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_weekly_modul.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyModuleAdapter extends TypeAdapter<WeeklyModule> {
  @override
  final int typeId = 2;

  @override
  WeeklyModule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyModule(
      weekStart: fields[0] as DateTime,
      module: fields[1] as Module,
      isCompleted: fields[2] as bool,
      importance: fields[3] as Importance,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyModule obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weekStart)
      ..writeByte(1)
      ..write(obj.module)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.importance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyModuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
