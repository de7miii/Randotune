import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_music_player/ui/widgets/songs_list_item.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicFinder(),
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.indigo.shade600,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Random Player'),
          ),
          body: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PermissionStatus permissionStatus;
  double gridBottomPadding = 84.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Consumer<MusicFinder>(
          builder: (context, value, child) {
            return Stack(
              children: <Widget>[
                !value.isLoading
                    ? GridView.builder(
                        padding: EdgeInsets.only(bottom: 84.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          var curSong = value.allSongs[index];
                          return SongsListItem(
                            songInfo: curSong,
                            musicModel: value,
                          );
                        },
                        itemCount: value.allSongs.length,
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
                DraggableScrollableSheet(
                  initialChildSize: 0.12,
                  maxChildSize: 0.2,
                  minChildSize: 0.12,
                  expand: true,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.174,
                        decoration: BoxDecoration(
                            color: Colors.deepOrange.shade900.withAlpha(220),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0))),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
//                                    IconButton(
//                                      onPressed: () {
//                                        value.seek(duration: -1000);
//                                      },
//                                      icon: Icon(Icons.fast_rewind),
//                                      color: Colors.black,
//                                      iconSize: 36.0,
//                                    ),
//                                    SizedBox(
//                                      width: 10.0,
//                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (value.isPlaying &&
                                            value.currentlyPlaying != null) {
                                          value.pauseSong();
                                          value.isPlaying = false;
                                        } else if (!value.isPlaying &&
                                            value.currentlyPlaying != null) {
                                          value.resumeSong();
                                          value.isPlaying = true;
                                        } else if (!value.isPlaying &&
                                            value.currentlyPlaying == null) {
                                          value.currentlyPlaying =
                                              value.allSongs[Random.secure()
                                                  .nextInt(
                                                      value.allSongs.length)];
                                          value
                                              .playSong(value.currentlyPlaying);
                                          value.isPlaying = true;
                                        }
                                      },
                                      icon: !value.isPlaying
                                          ? Icon(Icons.play_arrow)
                                          : Icon(Icons.pause),
                                      color: Colors.black,
                                      iconSize: 56.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        value.currentlyPlaying =
                                        value.allSongs[Random.secure()
                                            .nextInt(
                                            value.allSongs.length)];
                                        value
                                            .playSong(value.currentlyPlaying);
                                        value.isPlaying = true;
                                      },
                                      icon: Icon(Icons.fast_forward),
                                      color: Colors.black,
                                      iconSize: 36.0,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                value.currentlyPlaying != null
                                    ? Text(
                                        value.currentlyPlaying.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      )
                                    : Text(''),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Permission.storage.request().then((status) {
      permissionStatus = status;
      if (status.isGranted) {
        Provider.of<MusicFinder>(context, listen: false).findAllSongs();
        Provider.of<MusicFinder>(context, listen: false).findAllAlbums();
        Provider.of<MusicFinder>(context, listen: false).findAllArtists();
      }
    }, onError: (err) {
      print(err);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (permissionStatus.isGranted) {
      Provider.of<MusicFinder>(context, listen: false).findAllArtists();
      Provider.of<MusicFinder>(context, listen: false).findAllAlbums();
      Provider.of<MusicFinder>(context, listen: false).findAllSongs();
    }
  }
}
