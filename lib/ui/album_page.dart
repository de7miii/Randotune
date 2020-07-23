import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:random_music_player/ui/widgets/songs_list_item.dart';

import 'widgets/music_player.dart';

class AlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicFinder>(
        builder: (BuildContext context, MusicFinder value, Widget child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(value.selectedAlbum.title),
            ),
            body: Stack(
              children: <Widget>[
                !value.isLoading
                    ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 112.0),
                  itemBuilder: (context, index) {
                    return SongsListItem(musicModel: value, songInfo: value.selectedAlbumSongs[index]);
                  },
                  itemCount: int.parse(value.selectedAlbum.numberOfSongs),
                )
                    : Center(
                  child: CircularProgressIndicator(),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.2,
                  maxChildSize: 0.2,
                  minChildSize: 0.2,
                  builder: (context, scrollController) {
                    return MusicPlayer(
                      musicModel: value,
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
  }
}
