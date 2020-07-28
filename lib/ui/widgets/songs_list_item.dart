import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/background_music_handler.dart';
import 'package:random_music_player/logic/music_finder.dart';

class SongsListItem extends StatefulWidget {
  final SongInfo songInfo;

  SongsListItem({this.songInfo});

  @override
  _SongsListItemState createState() => _SongsListItemState();
}

class _SongsListItemState extends State<SongsListItem> {
  final String placeholderUrl =
      'https://via.placeholder.com/1080x1080?text=Album+Art';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(widget.songInfo.filePath);
        play(context);
      },
      child: ListTile(
        leading: widget.songInfo.track != null &&
            int.parse(widget.songInfo.track) is int &&
            int.parse(widget.songInfo.track) > 0
            ? Text(
          widget.songInfo.track.length == 4
              ? int.parse(widget.songInfo.track) > 1009
              ? widget.songInfo.track.substring(2)
              : widget.songInfo.track.substring(3)
              : widget.songInfo.track,
          style: Theme
              .of(context)
              .textTheme
              .bodyText1,
        )
            : null,
        title: Text(widget.songInfo.title),
        subtitle: Text(widget.songInfo.artist),
        trailing: Consumer<MusicFinder>(
          builder:(context, value, child) => Icon(
            value.isPlaying && widget.songInfo.id == value.currentlyPlaying.id
                ? Icons.pause
                : Icons.play_arrow,
            size: 26.0,
          ),
        ),
      ),
    );
  }

  play(BuildContext context) async {
    if (AudioService.running) {
      AudioService.playMediaItem(MediaItem(
          id: widget.songInfo.filePath, album: widget.songInfo.album, title: widget.songInfo.title));
      _handleCustomEvents();
    } else {
      await start(context);
      play(context);
    }
  }

  start(BuildContext context) =>
      AudioService.start(
          backgroundTaskEntrypoint: _entryPoint,
          params: {
            'allSongs': Provider.of<MusicFinder>(context, listen: false).allSongs.map((e) => e.filePath).toList()
          },
          androidNotificationChannelName: 'Random Music Player',
          androidNotificationColor: Theme
              .of(context)
              .primaryColor
              .value,
          androidNotificationClickStartsActivity: true);

  _handleCustomEvents() {
    MusicFinder model = Provider.of<MusicFinder>(context, listen: false);
    AudioService.customEventStream.listen((event) {
      if (event is String) {
        var currentSong = model.allSongs
            .where((element) => element.filePath == event)
            .reduce((value, element) => element);
        model.currentlyPlaying = currentSong;
        model.currentSongDuration =
            int.parse(currentSong.duration);
      } else if (event is int) {
        model.currentSongPosition = event;
        model.isPlaying = true;
      }
    });
  }
}
  _entryPoint() => AudioServiceBackground.run(() => BackgroundMusicHandler());