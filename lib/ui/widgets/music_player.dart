import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_music_player/logic/music_finder.dart';

class MusicPlayer extends StatefulWidget {
  final MusicFinder musicModel;

  MusicPlayer({@required this.musicModel});

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: widget.musicModel.currentlyPlaying != null &&
                  widget.musicModel.currentlyPlaying.albumArtwork != null
              ? Image.file(
                  File(widget.musicModel.currentlyPlaying.albumArtwork),
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.175,
          decoration: BoxDecoration(
              color: widget.musicModel.currentlyPlaying == null ||
                      widget.musicModel.currentlyPlaying.albumArtwork == null
                  ? Colors.indigo.shade900.withAlpha(240)
                  : null,
              gradient: widget.musicModel.currentlyPlaying != null &&
                      widget.musicModel.currentlyPlaying.albumArtwork != null
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
                                widget.musicModel.getPlayingSongPosition();
                                if (widget.musicModel.currentSongPosition == 0 ||
                                    widget.musicModel.currentSongPosition <
                                        5000.0) {
                                  print(widget.musicModel.currentSongPosition);
                                  widget.musicModel.currentlyPlaying =
                                      widget.musicModel.allSongs[Random.secure()
                                          .nextInt(
                                              widget.musicModel.allSongs.length)];
                                  widget.musicModel.playSong(
                                      widget.musicModel.currentlyPlaying);
                                  widget.musicModel.isPlaying = true;
                                } else {
                                  print(widget.musicModel.currentSongPosition);
                                  widget.musicModel.seek(duration: 0);
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
                                if (widget.musicModel.isPlaying &&
                                    widget.musicModel.currentlyPlaying != null) {
                                  setState(() {
                                    widget.musicModel.pauseSong();
                                    widget.musicModel.isPlaying = false;
                                  });
                                } else if (!widget.musicModel.isPlaying &&
                                    widget.musicModel.currentlyPlaying != null) {
                                  setState(() {
                                    widget.musicModel.resumeSong();
                                    widget.musicModel.isPlaying = true;
                                  });
                                } else if (!widget.musicModel.isPlaying &&
                                    widget.musicModel.currentlyPlaying == null) {
                                  setState(() {
                                    widget.musicModel.currentlyPlaying = widget
                                            .musicModel.allSongs[
                                        Random.secure().nextInt(
                                            widget.musicModel.allSongs.length)];
                                    widget.musicModel.playSong(
                                        widget.musicModel.currentlyPlaying);
                                    widget.musicModel.isPlaying = true;
                                  });
                                }
                              },
                              icon: !widget.musicModel.isPlaying
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
                                widget.musicModel.currentlyPlaying =
                                    widget.musicModel.allSongs[Random.secure()
                                        .nextInt(
                                            widget.musicModel.allSongs.length)];
                                widget.musicModel
                                    .playSong(widget.musicModel.currentlyPlaying);
                                widget.musicModel.isPlaying = true;
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
                        child: widget.musicModel.currentlyPlaying != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 4.0, right: 4.0),
                                child: Text(
                                  "${widget.musicModel.currentlyPlaying.title} - ${widget.musicModel.currentlyPlaying.artist}",
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
                      )
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
                            widget.musicModel.currentSongPosition ~/ 1000 <= 59
                                ? "0:${widget.musicModel.currentSongPosition ~/ 1000}"
                                : (widget.musicModel.currentSongPosition ~/
                                        1000 /
                                        60)
                                    .toStringAsPrecision(3)
                                    .replaceAll('.', ':'),
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
                          value: widget.musicModel.currentSongPosition >=
                                  widget.musicModel.currentSongDuration
                              ? 0.0
                              : widget.musicModel.currentSongPosition / 1000,
                          min: 0.0,
                          max: widget.musicModel.currentSongDuration / 1000,
                          onChanged: (newVal) {
                            widget.musicModel.seek(duration: newVal.toInt());
                            setState(() {
                              widget.musicModel.currentSongPosition =
                                  newVal * 1000;
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
                                (widget.musicModel.currentSongDuration ~/
                                        1000 /
                                        60)
                                    .toStringAsPrecision(3)
                                    .replaceAll('.', ':'),
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
}
