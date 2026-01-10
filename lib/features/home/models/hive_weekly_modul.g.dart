

part of 'hive_weekly_modul.dart';





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
      isLectureCompleted: fields[2] as bool,
      isTaskCompleted: fields[4] as bool,
      importance: fields[3] as int,
      sortOrder: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyModule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.weekStart)
      ..writeByte(1)
      ..write(obj.module)
      ..writeByte(2)
      ..write(obj.isLectureCompleted)
      ..writeByte(3)
      ..write(obj.importance)
      ..writeByte(4)
      ..write(obj.isTaskCompleted)
      ..writeByte(5)
      ..write(obj.sortOrder);
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
