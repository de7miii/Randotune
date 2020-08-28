import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/background_music_handler.dart';
import 'package:random_music_player/logic/music_finder.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key key}) : super(key: key);

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  MusicFinder musicModel;
  File vinylImage;
  AnimationController _animController;
  var loopButtonBgColor;
  @override
  Widget build(BuildContext context) {
    musicModel = Provider.of<MusicFinder>(context, listen: false);
    return Consumer<MusicFinder>(builder: (context, value, child) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            child: value.currentlyPlaying != null &&
                    value.currentlyPlaying.albumArtwork != null
                ? Image.file(
                    File(value.currentlyPlaying.albumArtwork),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  )
                : value.currentlyPlaying != null &&
                        value.currentlyPlaying.albumArtwork == null
                    ? Image.asset(
                        'assets/images/vinyl_album.png',
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      )
                    : null,
          ),
          Container(
            decoration: BoxDecoration(
                color: value.currentlyPlaying == null ||
                        value.currentlyPlaying.albumArtwork == null
                    ? Theme.of(context).primaryColor.withAlpha(240)
                    : null,
                gradient: value.currentlyPlaying != null &&
                        value.currentlyPlaying.albumArtwork != null
                    ? LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                            Theme.of(context).primaryColor.withAlpha(185),
                            Theme.of(context).primaryColor.withAlpha(185),
                            Theme.of(context).primaryColor.withAlpha(240),
                          ])
                    : null,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0))),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  if (value.allSongs.isNotEmpty) {
                                    if (value.currentSongPosition == 0 ||
                                        value.currentSongPosition < 5000.0) {
                                      skipToPrevious();
                                    } else {
                                      seek(0);
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.skip_previous,
                                  color: Theme.of(context).accentColor,
                                ),
                                color: Colors.black,
                                iconSize: 36.0,
                                padding: EdgeInsets.zero,
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (value.allSongs.isNotEmpty) {
                                    if (value.isPlaying) {
                                      pause();
                                      _animController.reverse();
                                    } else {
                                      play();
                                      _animController.forward();
                                    }
                                  }
                                },
                                icon: AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: _animController,
                                    color: Theme.of(context).accentColor),
                                iconSize: 48.0,
                                padding: EdgeInsets.zero,
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (value.allSongs.isNotEmpty) {
                                    skipToNext();
                                  }
                                },
                                icon: Icon(
                                  Icons.skip_next,
                                  color: Theme.of(context).accentColor,
                                ),
                                color: Colors.black,
                                iconSize: 36.0,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: value.currentlyPlaying != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4.0, right: 4.0),
                                  child: Text(
                                    "${value.currentlyPlaying.title} - ${value.currentlyPlaying.artist}",
                                    maxLines: 3,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: 14.0),
                                  ),
                                )
                              : Text(''),
                        ),
                        Expanded(
                          child: CircleAvatar(
                            backgroundColor: loopButtonBgColor,
                            radius: 20.0,
                            child: IconButton(
                              icon: Icon(Icons.loop),
                              iconSize: 26.0,
                              color: Theme.of(context).accentColor,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                value.isLoopSong
                                    ? value.isLoopSong = false
                                    : value.isLoopSong = true;
                                AudioService.customAction(
                                    'isLoopSong', value.isLoopSong);
                                Hive.box('prefs')
                                    .put('isLoopSong', value.isLoopSong);
                                setState(() {
                                  value.isLoopSong
                                      ? loopButtonBgColor =
                                          Colors.white.withAlpha(100)
                                      : loopButtonBgColor = Colors.transparent;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 4.0,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "${((value.currentSongPosition ~/ 1000) % 3600) ~/ 60}:${(value.currentSongPosition ~/ 1000) % 60}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: Theme.of(context).accentColor),
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          flex: 8,
                          child: Slider.adaptive(
                            value: value.currentSongPosition >=
                                    value.currentSongDuration
                                ? 0.0
                                : value.currentSongPosition / 1000,
                            min: 0.0,
                            max: value.currentSongDuration / 1000,
                            onChanged: (newVal) {
                              seek(newVal.toInt());
                              setState(() {
                                value.currentSongPosition =
                                    (newVal.toInt() * 1000);
                              });
                            },
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  "${((value.currentSongDuration ~/ 1000) % 3600) ~/ 60}:${(value.currentSongDuration ~/ 1000) % 60}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          color: Theme.of(context).accentColor),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  seek(int duration) async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    if (AudioService.running) {
      AudioService.seekTo(Duration(seconds: duration));
    } else {
      await start();
      seek(duration);
    }
  }

  skipToPrevious() async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    if (AudioService.running) {
      AudioService.skipToPrevious();
    } else {
      await start();
      skipToPrevious();
    }
  }

  skipToNext() async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    if (AudioService.running) {
      AudioService.skipToNext();
    } else {
      await start();
      skipToNext();
    }
  }

  pause() async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    if (AudioService.running) {
      await AudioService.pause();
    } else {
      await start();
      pause();
    }
  }

  play() async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    if (AudioService.running) {
      await AudioService.play();
    } else {
      await start();
      play();
    }
  }

  start() => AudioService.start(
      backgroundTaskEntrypoint: _entryPoint,
      params: {
        'allSongs': musicModel.allSongs
            .map((e) => [
                  e.id,
                  e.filePath,
                  e.album,
                  e.title,
                  e.artist,
                  e.albumArtwork != null
                      ? File(e.albumArtwork).uri.toString()
                      : vinylImage.uri.toString()
                ])
            .toList()
      },
      androidNotificationChannelName: 'Random Music Player',
      androidNotificationColor: Theme.of(context).primaryColor.value,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'drawable/ic_notification',
      androidNotificationClickStartsActivity: true);

  _handleCustomEvents() async {
    AudioService.customEventStream.listen((event) {
      if (event is String) {
        var currentSong = musicModel.allSongs
            .where((element) => element.filePath == event)
            .reduce((value, element) => element);
        musicModel.currentlyPlaying = currentSong;
        musicModel.currentSongDuration = int.parse(currentSong.duration);
      } else if (event is int) {
        if (event == -1) {
          print('song completed');
        } else {
          musicModel.currentSongPosition = event;
        }
      }
    });
  }

  _loadAssetImage() async {
    var byteData = await rootBundle.load('assets/images/vinyl_album.png');
    final file =
        File("${(await getTemporaryDirectory()).path}/vinyl_album.png");
    vinylImage = await file.writeAsBytes(byteData.buffer.asUint8List());
  }

  @override
  void initState() {
    super.initState();
    print('music player init state');
    _handleCustomEvents();
    _loadAssetImage();
    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    if (!AudioService.connected) {
      AudioService.connect();
    }
    AudioService.playbackStateStream.listen((event) {
      if (!AudioService.connected) {
        AudioService.connect();
      }
      print(event.playing);
      if (event.playing) {
        musicModel.isPlaying = true;
        _animController.forward();
      } else {
        musicModel.isPlaying = false;
        _animController.reverse();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('music player did change dependencies');
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: false);
    AudioService.currentMediaItemStream.listen((event) {
      if (musicModel.currentlyPlaying == null) {
        if (musicModel.allSongs.isEmpty) {
          musicModel.allSongs =
              List.castFrom(Hive.box('songs').get('allSongs'));
        }
        if (musicModel.allSongs.any((element) => element?.id == event?.id)) {
          musicModel.currentlyPlaying = musicModel.allSongs
              .firstWhere((element) => element?.id == event?.id);
          print(musicModel.currentlyPlaying);
          musicModel.currentSongDuration =
              int.parse(musicModel.currentlyPlaying.duration);
        }
      }
      if (event?.id != musicModel.currentlyPlaying?.id ||
          event?.title != musicModel.currentlyPlaying?.title) {
        if (musicModel.allSongs.isEmpty) {
          musicModel.allSongs =
              List.castFrom(Hive.box('songs').get('allSongs'));
        }
        if (musicModel.allSongs.any((element) => element?.id == event?.id)) {
          musicModel.currentlyPlaying = musicModel.allSongs.firstWhere(
              (element) => element?.id == AudioService?.currentMediaItem?.id);
          musicModel.currentSongDuration =
              int.parse(musicModel.currentlyPlaying.duration);
          print(musicModel.currentlyPlaying);
        }
      }
    });
    print('isLoopSong = ${musicModel.isLoopSong}');
    musicModel.isLoopSong =
        Hive.box('prefs').get('isLoopSong', defaultValue: false);
    print('isLoopSong = ${musicModel.isLoopSong}');
    AudioService.customAction(
        'isLoopSong', musicModel.isLoopSong);
    if(mounted) {
      setState(() {
        musicModel.isLoopSong
            ? loopButtonBgColor = Colors.white.withAlpha(100)
            : loopButtonBgColor = Colors.transparent;
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    print('music player deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    print('music player dispose');
    if(!AudioService.connected) {
      _animController.dispose();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    print('music player reassemble');
  }

  @override
  void didUpdateWidget(MusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('music player did update widget');
  }
}

_entryPoint() => AudioServiceBackground.run(() => BackgroundMusicHandler());
