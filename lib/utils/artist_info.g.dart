// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtistInfoLocalAdapter extends TypeAdapter<ArtistInfoLocal> {
  @override
  final int typeId = 3;

  @override
  ArtistInfoLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtistInfoLocal(
      id: fields[0] as String,
      name: fields[1] as String,
      artistArtPath: fields[2] as String,
      numberOfAlbums: fields[3] as String,
      numberOfTracks: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ArtistInfoLocal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.artistArtPath)
      ..writeByte(3)
      ..write(obj.numberOfAlbums)
      ..writeByte(4)
      ..write(obj.numberOfTracks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistInfoLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
