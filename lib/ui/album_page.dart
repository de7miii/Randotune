import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:random_music_player/ui/widgets/songs_list_item.dart';

import 'widgets/music_player.dart';

class AlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: true);
    return Scaffold(
            appBar: AppBar(
              title: Text(musicModel.selectedAlbum.title),
            ),
            body: Stack(
              children: <Widget>[
                !musicModel.isLoading
                    ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 112.0),
                  itemBuilder: (context, index) {
                    return SongsListItem(songInfo: musicModel.selectedAlbumSongs[index]);
                  },
                  itemCount: int.parse(musicModel.selectedAlbum.numberOfSongs),
                )
                    : Center(
                  child: CircularProgressIndicator(),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.2,
                  maxChildSize: 0.2,
                  minChildSize: 0.2,
                  builder: (context, scrollController) {
                    return musicModel.musicPlayer;
                  },
                ),
              ],
            ),
          );
  }
}
