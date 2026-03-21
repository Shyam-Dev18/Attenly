// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableEntryAdapter extends TypeAdapter<TimetableEntry> {
  @override
  final int typeId = 2;

  @override
  TimetableEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableEntry()
      ..id = fields[0] as String
      ..subjectId = fields[1] as String
      ..weekday = fields[2] as int
      ..startTime = fields[3] as String
      ..endTime = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, TimetableEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.weekday)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
