
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';

part 'song_info.g.dart';

@HiveType(typeId : 1)
class SongInfoLocal extends HiveObject{

  @HiveField(0)
  String albumId;
  @HiveField(1)
  String artistId;
  @HiveField(2)
  String artist;
  @HiveField(3)
  String album;
  @HiveField(4)
  String title;
  @HiveField(5)
  String displayName;
  @HiveField(6)
  String composer;
  @HiveField(7)
  String year;
  @HiveField(8)
  String track;
  @HiveField(9)
  String duration;
  @HiveField(10)
  String bookmark;
  @HiveField(11)
  String filePath;
  @HiveField(12)
  String fileSize;
  @HiveField(13)
  String albumArtwork;
  @HiveField(14)
  bool isMusic;
  @HiveField(15)
  bool isPodcast;
  @HiveField(16)
  bool isNotification;
  @HiveField(17)
  bool isRingtone;
  @HiveField(18)
  bool isAlarm;
  @HiveField(19)
  String id;


  SongInfoLocal(
      {this.albumId,
      this.artistId,
      this.artist,
      this.album,
      this.title,
      this.displayName,
      this.composer,
      this.year,
      this.track,
      this.duration,
      this.bookmark,
      this.filePath,
      this.fileSize,
      this.albumArtwork,
      this.isMusic,
      this.isPodcast,
      this.isNotification,
      this.isRingtone,
      this.isAlarm,
      this.id});

  factory SongInfoLocal.fromSongInfo(SongInfo songInfo) =>
      SongInfoLocal(id: songInfo.id, album: songInfo.album, albumArtwork: songInfo.albumArtwork, albumId: songInfo.albumId, title: songInfo.title,
      isAlarm: songInfo.isAlarm, isRingtone: songInfo.isRingtone, isNotification: songInfo.isNotification, isPodcast: songInfo.isPodcast,
      isMusic: songInfo.isMusic, filePath: songInfo.filePath, fileSize: songInfo.fileSize, bookmark: songInfo.bookmark, duration: songInfo.duration,
      track: songInfo.track, year: songInfo.year, composer: songInfo.composer, displayName: songInfo.displayName, artist: songInfo.artist, artistId: songInfo.artistId);
}
