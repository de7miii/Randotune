import 'dart:io';

import 'package:flutter/material.dart';
import 'package:random_music_player/utils/artist_info.dart';

class ArtistListItem extends StatelessWidget {
  final ArtistInfoLocal artistInfo;
  final Color bgColor;

  ArtistListItem({this.artistInfo, this.bgColor = const Color(0xff1f2228)});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).accentColor,
            child: CircleAvatar(
              radius: 25,
              backgroundImage: artistInfo.artistArtPath != null
                  ? FileImage(
                      File(artistInfo.artistArtPath),
                    )
                  : AssetImage('assets/images/vinyl_album.png'),
            ),
          ),
          Container(
            color: bgColor,
            width: 50.0,
            child: Center(
              child: Text(
                artistInfo.name,
                maxLines: 1,
                style: Theme.of(context).textTheme.subtitle2.copyWith(color: Theme.of(context).accentColor, fontSize: 10.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}
