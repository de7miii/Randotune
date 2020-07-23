import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:random_music_player/logic/music_finder.dart';

class AlbumListItem extends StatelessWidget {
  final AlbumInfo albumInfo;
  final MusicFinder musicModel;
  final String placeholderUrl =
      'https://via.placeholder.com/1080x1080?text=Album+Art';

  AlbumListItem({this.albumInfo, @required this.musicModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        musicModel.selectedAlbum = albumInfo;
        musicModel.findAlbumSongs(albumId: albumInfo.id);
        Navigator.of(context).pushNamed('/album_page');
      },
      child: Card(
        shadowColor: Colors.blueGrey.shade900,
        elevation: 2,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        borderOnForeground: true,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            albumInfo.albumArt != null
                ? Image.file(
              File(albumInfo.albumArt),
            )
                : Image.network(placeholderUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.indigo.shade900.withAlpha(255),
                  Colors.indigo.shade700.withAlpha(155),
                  Colors.indigo.withAlpha(90),
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                child: Text(
                  albumInfo.title,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).accentColor, letterSpacing: 1.0, fontSize: 12.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
