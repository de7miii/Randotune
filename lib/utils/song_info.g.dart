// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongInfoLocalAdapter extends TypeAdapter<SongInfoLocal> {
  @override
  final int typeId = 1;

  @override
  SongInfoLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongInfoLocal(
      albumId: fields[0] as String,
      artistId: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      title: fields[4] as String,
      displayName: fields[5] as String,
      composer: fields[6] as String,
      year: fields[7] as String,
      track: fields[8] as String,
      duration: fields[9] as String,
      bookmark: fields[10] as String,
      filePath: fields[11] as String,
      fileSize: fields[12] as String,
      albumArtwork: fields[13] as String,
      isMusic: fields[14] as bool,
      isPodcast: fields[15] as bool,
      isNotification: fields[16] as bool,
      isRingtone: fields[17] as bool,
      isAlarm: fields[18] as bool,
      id: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SongInfoLocal obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.albumId)
      ..writeByte(1)
      ..write(obj.artistId)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.displayName)
      ..writeByte(6)
      ..write(obj.composer)
      ..writeByte(7)
      ..write(obj.year)
      ..writeByte(8)
      ..write(obj.track)
      ..writeByte(9)
      ..write(obj.duration)
      ..writeByte(10)
      ..write(obj.bookmark)
      ..writeByte(11)
      ..write(obj.filePath)
      ..writeByte(12)
      ..write(obj.fileSize)
      ..writeByte(13)
      ..write(obj.albumArtwork)
      ..writeByte(14)
      ..write(obj.isMusic)
      ..writeByte(15)
      ..write(obj.isPodcast)
      ..writeByte(16)
      ..write(obj.isNotification)
      ..writeByte(17)
      ..write(obj.isRingtone)
      ..writeByte(18)
      ..write(obj.isAlarm)
      ..writeByte(19)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongInfoLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
