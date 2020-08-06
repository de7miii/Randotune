import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';

part 'album_info.g.dart';

@HiveType(typeId: 2)
class AlbumInfoLocal extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String albumArt;
  @HiveField(3)
  String artist;
  @HiveField(4)
  String firstYear;
  @HiveField(5)
  String lastYear;
  @HiveField(6)
  String numberOfSongs;

  AlbumInfoLocal(
      {this.id,
      this.title,
      this.artist,
      this.albumArt,
      this.numberOfSongs,
      this.firstYear,
      this.lastYear});

  factory AlbumInfoLocal.fromAlbumInfo(AlbumInfo albumInfo) => AlbumInfoLocal(
      id: albumInfo.id,
      title: albumInfo.title,
      artist: albumInfo.artist,
      albumArt: albumInfo.albumArt,
      numberOfSongs: albumInfo.numberOfSongs,
      firstYear: albumInfo.firstYear,
      lastYear: albumInfo.lastYear);
}
