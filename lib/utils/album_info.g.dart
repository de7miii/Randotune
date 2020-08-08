// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumInfoLocalAdapter extends TypeAdapter<AlbumInfoLocal> {
  @override
  final int typeId = 2;

  @override
  AlbumInfoLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlbumInfoLocal(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[3] as String,
      albumArt: fields[2] as String,
      numberOfSongs: fields[6] as String,
      firstYear: fields[4] as String,
      lastYear: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AlbumInfoLocal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.albumArt)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.firstYear)
      ..writeByte(5)
      ..write(obj.lastYear)
      ..writeByte(6)
      ..write(obj.numberOfSongs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumInfoLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
