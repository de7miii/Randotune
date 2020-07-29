import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/background_music_handler.dart';
import 'package:random_music_player/logic/music_finder.dart';

class MusicPlayer extends StatefulWidget {
  MusicPlayer();

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  MusicFinder musicModel;
  @override
  Widget build(BuildContext context) {
    musicModel = Provider.of<MusicFinder>(context, listen: true);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: musicModel.currentlyPlaying != null &&
                  musicModel.currentlyPlaying.albumArtwork != null
              ? Image.file(
                  File(musicModel.currentlyPlaying.albumArtwork),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.175,
          decoration: BoxDecoration(
              color: musicModel.currentlyPlaying == null ||
                      musicModel.currentlyPlaying.albumArtwork == null
                  ? Colors.indigo.shade900.withAlpha(240)
                  : null,
              gradient: musicModel.currentlyPlaying != null &&
                      musicModel.currentlyPlaying.albumArtwork != null
                  ? LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                          Colors.indigo.shade900.withAlpha(255),
                          Colors.indigo.shade700.withAlpha(155),
                          Colors.indigo.withAlpha(125),
                        ])
                  : null,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0))),
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
                                AudioService.playbackStateStream
                                    .listen((event) {
                                  if (event.playing) {
                                    musicModel.isPlaying = true;
                                  } else {
                                    musicModel.isPlaying = false;
                                  }
                                });
                                if (musicModel.currentSongPosition == 0 ||
                                    musicModel.currentSongPosition < 5000.0) {
                                  print(musicModel.currentSongPosition);
                                  skipToPrevious();
                                } else {
                                  print(musicModel.currentSongPosition);
                                  seek(0);
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
                                AudioService.playbackStateStream
                                    .listen((event) {
                                  print(event.playing);
                                  if (event.playing) {
                                    musicModel.isPlaying = true;
                                  } else {
                                    musicModel.isPlaying = false;
                                  }
                                });
                                if (musicModel.isPlaying) {
                                  pause();
                                } else {
                                  play();
                                }
                              },
                              icon: !musicModel.isPlaying
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
                                AudioService.playbackStateStream
                                    .listen((event) {
                                  if (event.playing) {
                                    musicModel.isPlaying = true;
                                  } else {
                                    musicModel.isPlaying = false;
                                  }
                                });
                                skipToNext();
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
                        child: musicModel.currentlyPlaying != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 4.0, right: 4.0),
                                child: Text(
                                  "${musicModel.currentlyPlaying.title} - ${musicModel.currentlyPlaying.artist}",
                                  maxLines: 3,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          color: Theme.of(context).accentColor,
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
                            "${((musicModel.currentSongPosition ~/ 1000) % 3600) ~/ 60}:${(musicModel.currentSongPosition ~/ 1000) % 60}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        flex: 8,
                        child: Slider.adaptive(
                          value: max(
                                  0.0,
                                  min(musicModel.currentSongPosition,
                                      musicModel.currentSongDuration)) /
                              1000,
                          min: 0.0,
                          max: musicModel.currentSongDuration / 1000,
                          onChanged: (newVal) {
                            seek(newVal.toInt());
                            setState(() {
                              musicModel.currentSongPosition =
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
                                "${((musicModel.currentSongDuration ~/ 1000) % 3600) ~/ 60}:${(musicModel.currentSongDuration ~/ 1000) % 60}",
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
  }

  seek(int duration) => AudioService.seekTo(Duration(seconds: duration));

  skipToPrevious() async {
    AudioService.skipToPrevious();
  }

  skipToNext() async {
    AudioService.skipToNext();
  }

  pause() => AudioService.pause();

  play() async {
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
      androidNotificationClickStartsActivity: true);

  _handleCustomEvents() {
    AudioService.customEventStream.listen((event) {
      if (event is String) {
        var currentSong = musicModel.allSongs
            .where((element) => element.filePath == event)
            .reduce((value, element) => element);
        musicModel.currentlyPlaying = currentSong;
        musicModel.currentSongDuration = int.parse(currentSong.duration);
      } else if (event is int) {
        print(event);
        if(event == -1){
          play();
        }else {
          musicModel.currentSongPosition = event;
          musicModel.isPlaying = true;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _handleCustomEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

_entryPoint() => AudioServiceBackground.run(() => BackgroundMusicHandler());
