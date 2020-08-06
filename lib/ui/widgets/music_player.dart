import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/background_music_handler.dart';
import 'package:random_music_player/logic/music_finder.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key key}) : super(key: key);

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  MusicFinder musicModel;
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
                            Theme.of(context).primaryColor.withAlpha(255),
                            Theme.of(context).primaryColor.withAlpha(170),
                            Theme.of(context).primaryColor.withAlpha(155),
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
                          flex: 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  if (value.allSongs.isNotEmpty) {
                                    if (value.currentSongPosition == 0 ||
                                        value.currentSongPosition < 5000.0) {
                                      print(value.currentSongPosition);
                                      skipToPrevious();
                                    } else {
                                      print(value.currentSongPosition);
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
                                width: 10.0,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (value.allSongs.isNotEmpty) {
                                    if (value.isPlaying) {
                                      pause();
                                    } else {
                                      play();
                                    }
                                  }
                                },
                                icon: !value.isPlaying
                                    ? Icon(
                                        Icons.play_arrow,
                                        color: Theme.of(context).accentColor,
                                      )
                                    : Icon(
                                        Icons.pause,
                                        color: Theme.of(context).accentColor,
                                      ),
                                iconSize: 48.0,
                                padding: EdgeInsets.zero,
                              ),
                              SizedBox(
                                width: 10.0,
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
                          flex: 1,
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
                      : 'https://via.placeholder.com/1080x1080?text=Album+Art'
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

  @override
  void initState() {
    super.initState();
    print('music player init state');
    _handleCustomEvents();
    AudioService.playbackStateStream.listen((event) {
      if (!AudioService.connected) {
        AudioService.connect();
        print(event.playing);
        if (event.playing) {
          musicModel.isPlaying = true;
        } else {
          musicModel.isPlaying = false;
        }
      } else {
        if (AudioService.running) {
          print(event.playing);
          if (event.playing) {
            musicModel.isPlaying = true;
          } else {
            musicModel.isPlaying = false;
          }
        }
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
        if(musicModel.allSongs.any((element) => element?.id == event?.id)) {
          musicModel.currentlyPlaying =
              musicModel.allSongs.firstWhere((element) =>
              element?.id == event?.id);
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
        if(musicModel.allSongs.any((element) => element?.id == event?.id)) {
          musicModel.currentlyPlaying = musicModel.allSongs.firstWhere(
                  (element) =>
              element?.id == AudioService?.currentMediaItem?.id);
          musicModel.currentSongDuration =
              int.parse(musicModel.currentlyPlaying.duration);
          print(musicModel.currentlyPlaying);
        }
      }
    });
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
