import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';

part 'artist_info.g.dart';

@HiveType(typeId: 3)
class ArtistInfoLocal extends HiveObject{

  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String artistArtPath;
  @HiveField(3)
  String numberOfAlbums;
  @HiveField(4)
  String numberOfTracks;

  ArtistInfoLocal(
      {this.id,
        this.name,
        this.artistArtPath,
        this.numberOfAlbums,
        this.numberOfTracks});

  factory ArtistInfoLocal.fromArtistInfo(ArtistInfo artistInfo) => ArtistInfoLocal(
      id: artistInfo.id,
      name: artistInfo.name,
      artistArtPath: artistInfo.artistArtPath,
      numberOfAlbums: artistInfo.numberOfAlbums,
      numberOfTracks: artistInfo.numberOfTracks);
}