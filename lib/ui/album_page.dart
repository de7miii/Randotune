import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:random_music_player/ui/widgets/songs_list_item.dart';

class AlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: true);
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        physics: BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false,
              pinned: true,
              snap: false,
              expandedHeight: 250.0,
              stretch: true,
              stretchTriggerOffset: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle
                  ],
                  title: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      musicModel.selectedAlbum.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      musicModel.selectedAlbum.albumArt != null
                          ? Image.file(
                              File(musicModel.selectedAlbum.albumArt),
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/images/vinyl_album.png'),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).primaryColor.withAlpha(220),
                                Theme.of(context).primaryColor.withAlpha(150),
                                Theme.of(context).primaryColor.withAlpha(100),
                              ]),
                        ),
                      ),
                    ],
                  )),
            ),
          ];
        },
        body: SafeArea(
          top: false,
          child: Stack(
            children: <Widget>[
              !musicModel.isLoading
                  ? ListView.builder(
                      padding: EdgeInsets.only(bottom: 115.0),
                      itemBuilder: (context, index) {
                        return SongsListItem(
                            songInfo: musicModel.selectedAlbumSongs[index]);
                      },
                      itemCount:
                          int.parse(musicModel.selectedAlbum.numberOfSongs),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  child: !musicModel.isLoading || musicModel.allSongs.isNotEmpty ? musicModel.musicPlayer : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
