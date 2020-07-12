import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:random_music_player/logic/music_finder.dart';

class SongsListItem extends StatelessWidget {
  final SongInfo songInfo;
  final MusicFinder musicModel;
  final String placeholderUrl =
      'https://via.placeholder.com/1080x1080?text=Album+Art';

  SongsListItem({this.songInfo, this.musicModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(songInfo.filePath);
        musicModel.currentlyPlaying = songInfo;
        musicModel.playSong(songInfo);
      },
      child: Card(
        shadowColor: Colors.blueGrey.shade900,
        elevation: 6,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        borderOnForeground: true,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            songInfo.albumArtwork != null
                ? Image.file(
                    File(songInfo.albumArtwork),
                  )
                : Image.network(placeholderUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.indigo.withAlpha(100),
                  Colors.indigo.withAlpha(80),
                  Colors.indigo.withAlpha(30),
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  songInfo.title,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
