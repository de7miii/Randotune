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
          primaryColor: Colors.indigo,
          primaryColorDark: Colors.indigo.shade800,
          primaryColorLight: Colors.indigo.shade200,
          accentColor: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          sliderTheme: SliderThemeData(
              activeTrackColor: Theme.of(context).primaryColorDark,
              inactiveTrackColor: Theme.of(context).primaryColorLight,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              thumbColor: Theme.of(context).primaryColorDark,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
              trackHeight: 2.0),
        ),
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
                        padding: EdgeInsets.only(bottom: 144.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          return SongsListItem(
                            songInfo: value.allSongs[index],
                            musicModel: value,
                          );
                        },
                        itemCount: value.allSongs.length,
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
                DraggableScrollableSheet(
                  initialChildSize: 0.2,
                  maxChildSize: 0.2,
                  minChildSize: 0.2,
                  builder: (context, scrollController) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.174,
                      decoration: BoxDecoration(
                          color: Colors.blueGrey.shade900.withAlpha(240),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0))),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 8.0),
                                      child: IconButton(
                                        onPressed: () {
                                          value.getPlayingSongPosition();
                                          if (value.currentSongPosition == 0 ||
                                              value.currentSongPosition < 5000.0) {
                                            print(value.currentSongPosition);
                                            value.currentlyPlaying =
                                                value.allSongs[Random.secure()
                                                    .nextInt(
                                                        value.allSongs.length)];
                                            value.playSong(
                                                value.currentlyPlaying);
                                            value.isPlaying = true;
                                          } else {
                                            print(value.currentSongPosition);
                                            value.seek(
                                                duration: 0);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.skip_previous,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        color: Colors.black,
                                        iconSize: 36.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
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
                                          ? Icon(
                                              Icons.play_arrow,
                                              color:
                                                  Theme.of(context).accentColor,
                                            )
                                          : Icon(
                                              Icons.pause,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                      iconSize: 56.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: IconButton(
                                        onPressed: () {
                                          value.currentlyPlaying =
                                              value.allSongs[Random.secure()
                                                  .nextInt(
                                                      value.allSongs.length)];
                                          value
                                              .playSong(value.currentlyPlaying);
                                          value.isPlaying = true;
                                        },
                                        icon: Icon(Icons.skip_next, color: Theme.of(context).accentColor,),
                                        color: Colors.black,
                                        iconSize: 36.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Slider.adaptive(
                                    value: value.currentSongPosition >= value.currentSongDuration ? 0.0 : value.currentSongPosition / 1000 ,
                                    min: 0.0,
                                    max: value.currentSongDuration / 1000,
                                    onChanged: (newVal) {
                                      value.seek(duration: newVal.toInt());
                                      setState(() {
                                        value.currentSongPosition = newVal * 1000;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: value.currentlyPlaying != null
                                    ? Text(
                                        "${value.currentlyPlaying.title} - ${value.currentlyPlaying.artist}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6.copyWith(color: Theme.of(context).accentColor, fontSize: 18.0),
                                      )
                                    : Text(''),
                              ),
                            ],
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
