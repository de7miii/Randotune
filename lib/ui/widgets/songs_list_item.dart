import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:random_music_player/logic/music_finder.dart';

class SongsListItem extends StatelessWidget {
  final SongInfo songInfo;
  final MusicFinder musicModel;
  final String placeholderUrl =
      'https://via.placeholder.com/1080x1080?text=Album+Art';

  SongsListItem({this.songInfo, @required this.musicModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(songInfo.filePath);
        musicModel.currentlyPlaying = songInfo;
        musicModel.playSong(musicModel.currentlyPlaying);
        musicModel.isPlaying = true;
      },
      child: ListTile(
        leading: songInfo.track != null && int.parse(songInfo.track) > 0
            ? Text(
                songInfo.track.length == 4
                    ? int.parse(songInfo.track) > 1009 ? songInfo.track.substring(2) : songInfo.track.substring(3)
                    : songInfo.track,
                style: Theme.of(context).textTheme.bodyText1,
              )
            : null,
        title: Text(songInfo.title),
        subtitle: Text(songInfo.artist),
        trailing: Icon(
          musicModel.isPlaying && musicModel.currentlyPlaying == songInfo
              ? Icons.pause
              : Icons.play_arrow,
          size: 26.0,
        ),
      ),
    );
  }
}
