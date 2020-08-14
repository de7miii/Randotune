import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/background_music_handler.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:random_music_player/utils/song_info.dart';

class SongsListItem extends StatefulWidget {
  final SongInfoLocal songInfo;

  SongsListItem({this.songInfo});

  @override
  _SongsListItemState createState() => _SongsListItemState();
}

class _SongsListItemState extends State<SongsListItem> {
  File vinylImage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Provider.of<MusicFinder>(context, listen: false)
            .allSongs
            .isNotEmpty) {
          playMediaItem(context);
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Please wait while your songs being loaded.'),
            duration: Duration(seconds: 2),
          ));
        }
      },
      child: ListTile(
        leading: widget.songInfo.track != null &&
                int.parse(widget.songInfo.track) is int &&
                int.parse(widget.songInfo.track) > 0
            ? Text(
                widget.songInfo.track.length == 4
                    ? int.parse(widget.songInfo.track) > 1009 &&
                                int.parse(widget.songInfo.track) < 2000 ||
                            int.parse(widget.songInfo.track) > 2009 &&
                                int.parse(widget.songInfo.track) < 3000 ||
                            int.parse(widget.songInfo.track) > 3009 &&
                                int.parse(widget.songInfo.track) < 4000
                        ? widget.songInfo.track.substring(2)
                        : widget.songInfo.track.substring(3)
                    : widget.songInfo.track,
                style: Theme.of(context).textTheme.bodyText1,
              )
            : null,
        title: Text(widget.songInfo.title),
        subtitle: Text(widget.songInfo.artist),
        trailing: Consumer<MusicFinder>(
          builder: (context, value, child) => Icon(
            value.isPlaying && widget.songInfo.id == value.currentlyPlaying?.id
                ? Icons.pause
                : Icons.play_arrow,
            size: 26.0,
          ),
        ),
      ),
    );
  }

  playMediaItem(BuildContext context) async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
    if (AudioService.running) {
      var artUri = widget.songInfo.albumArtwork != null
          ? File(widget.songInfo.albumArtwork).uri.toString()
          : vinylImage.uri.toString();
      await AudioService.playMediaItem(MediaItem(
          id: widget.songInfo.id,
          genre: widget.songInfo.filePath,
          album: widget.songInfo.album,
          title: widget.songInfo.title,
          artist: widget.songInfo.artist,
          artUri: artUri));
    } else {
      await start(context);
      playMediaItem(context);
    }
  }

  start(BuildContext context) => AudioService.start(
      backgroundTaskEntrypoint: _entryPoint,
      params: {
        'allSongs': Provider.of<MusicFinder>(context, listen: false)
            .allSongs
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

  _loadAssetImage() async {
    var byteData = await rootBundle.load('assets/images/vinyl_album.png');
    final file = File("${(await getTemporaryDirectory()).path}/vinyl_album.png");
    vinylImage = await file.writeAsBytes(byteData.buffer.asUint8List());
  }

  @override
  void initState() {
    super.initState();
    _loadAssetImage();
  }
}

_entryPoint() => AudioServiceBackground.run(() => BackgroundMusicHandler());
