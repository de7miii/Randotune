import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:random_music_player/utils/media_controls.dart';
import '../utils/audio_playback_helpers.dart';

class BackgroundMusicHandler extends BackgroundAudioTask {
  AudioPlayer audioPlayer;
  List<dynamic> allSongs = [];
  Duration position;
  List<MediaItem> _queue = [];
  bool isLoopSong = false;

  @override
  void onStart(Map<String, dynamic> params) {
    print('onStart');
    audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    isLoopSong ? audioPlayer.setReleaseMode(ReleaseMode.LOOP) : audioPlayer.setReleaseMode(ReleaseMode.STOP);
    allSongs = params['allSongs'];
    super.onStart(params);
  }

  MediaItem getRandomSong(List<MediaItem> queue) {
    queue.shuffle(Random.secure());
    return queue[Random.secure().nextInt(queue.length)];
  }

  @override
  Future<dynamic> onCustomAction(String name, dynamic arguments) async {
    if(name == 'isLoopSong'){
      isLoopSong = arguments;
      isLoopSong ? audioPlayer.setReleaseMode(ReleaseMode.LOOP) : audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
  }

  MediaItem getMediaItemFromSong(dynamic song) => MediaItem(
      id: song[0], // song id
      genre: song[1], // filePath
      album: song[2], // album name
      title: song[3], // song title
      artist: song[4], // artist name
      artUri: song[5]); // album artwork

  List<MediaItem> generateQueue(List<dynamic> allSongs) {
    List<MediaItem> queue = [];
    if (allSongs != null && allSongs.isNotEmpty) {
      allSongs
        ..shuffle(Random.secure())
        ..forEach((element) {
          if (queue.length < allSongs.length) {
            queue.add(getMediaItemFromSong(element));
          }
        });
    }
    assert(queue.isNotEmpty);
    return queue;
  }

  @override
  void onPlay() async {
    isLoopSong ? audioPlayer.setReleaseMode(ReleaseMode.LOOP) : audioPlayer.setReleaseMode(ReleaseMode.STOP);
    print('onPlay');
    if (_queue.isEmpty) {
      if (audioPlayer.state == AudioPlayerState.PAUSED) {
        resumeSong(audioPlayer);
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.ready,
            playing: true);
      } else {
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.connecting,
            playing: false);
        _queue = generateQueue(allSongs);
        MediaItem song = getRandomSong(_queue);
        AudioServiceBackground.sendCustomEvent(song.genre);
        int res = await playSong(song.genre, audioPlayer);
        if (res == 1) {
          audioPlayer.onAudioPositionChanged
              .asBroadcastStream()
              .listen((event) {
            AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
          });
          AudioServiceBackground.setState(
              controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
              processingState: AudioProcessingState.ready,
              playing: true);
          AudioServiceBackground.setMediaItem(song);
        }
      }
    } else {
      if (audioPlayer.state == AudioPlayerState.PAUSED) {
        resumeSong(audioPlayer);
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.ready,
            playing: true);
      } else {
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.connecting,
            playing: false);
        MediaItem song = getRandomSong(_queue);
        AudioServiceBackground.sendCustomEvent(song.genre);
        int res = await playSong(song.genre, audioPlayer);
        if (res == 1) {
          audioPlayer.onAudioPositionChanged
              .asBroadcastStream()
              .listen((event) {
            AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
          });
          AudioServiceBackground.setState(
              controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
              processingState: AudioProcessingState.ready,
              playing: true);
          AudioServiceBackground.setMediaItem(song);
        }
      }
    }
    audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
      if (event == AudioPlayerState.COMPLETED) {
        AudioServiceBackground.sendCustomEvent(-1);
        print(event);
        skipToNextAndPrevious();
      }
    });
  }

  @override
  void onPause() async {
    print('onPause 1');
    int res = await pauseSong(audioPlayer);
    if (res == 1) {
      print('onPause 2');
      print(audioPlayer.state);
    }
    AudioServiceBackground.setState(
        controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.ready,
        playing: false);
    print('onPause 3');
  }

  @override
  void onPlayMediaItem(MediaItem mediaItem) async {
    isLoopSong ? audioPlayer.setReleaseMode(ReleaseMode.LOOP) : audioPlayer.setReleaseMode(ReleaseMode.STOP);
    print('onPlayMediaItem');
    AudioServiceBackground.sendCustomEvent(mediaItem.genre);
    int res = await playSong(mediaItem.genre, audioPlayer);
    if (res == 1) {
      print(audioPlayer.state);
      audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
    }
    AudioServiceBackground.setState(
        controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.ready,
        playing: true);
    AudioServiceBackground.setMediaItem(mediaItem);
    audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
      if (event == AudioPlayerState.COMPLETED) {
        AudioServiceBackground.sendCustomEvent(-1);
        print(event);
        skipToNextAndPrevious();
      }
    });
  }

  @override
  void onSkipToPrevious() async {
    isLoopSong = false;
    print('OnSkipToPrevious');
    audioPlayer.getCurrentPosition().then((value)  {
      if(value == 0 || value < 5000){
        skipToNextAndPrevious();
      }else {
        onSeekTo(Duration(seconds: 0));
      }
    });
    audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
      if (event == AudioPlayerState.COMPLETED) {
        AudioServiceBackground.sendCustomEvent(-1);
        print(event);
        skipToNextAndPrevious();
      }
    });
  }

  @override
  void onSkipToNext() async {
    isLoopSong = false;
    print('onSkipToNext');
    skipToNextAndPrevious();
    audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
      if (event == AudioPlayerState.COMPLETED) {
        AudioServiceBackground.sendCustomEvent(-1);
        print(event);
        skipToNextAndPrevious();
      }
    });
  }

  skipToNextAndPrevious() async {
    if (_queue.isEmpty) {
      _queue = generateQueue(allSongs);
      MediaItem song = getRandomSong(_queue);
      AudioServiceBackground.sendCustomEvent(song.genre);
      int res = await playSong(song.genre, audioPlayer);
      if (res == 1) {
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.ready,
            playing: true);
        print(audioPlayer.state);
        audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
          AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
        });
        AudioServiceBackground.setMediaItem(song);
      }
    } else {
      MediaItem song = getRandomSong(_queue);
      AudioServiceBackground.sendCustomEvent(song.genre);
      int res = await playSong(song.genre, audioPlayer);
      if (res == 1) {
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.ready,
            playing: true);
        audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
          AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
        });
        AudioServiceBackground.setMediaItem(song);
      }
    }
  }

  @override
  void onSeekTo(Duration position) {
    print('onSeekTo');
    seek(audioPlayer, duration: position.inSeconds);
  }

  @override
  Future<void> onStop() async {
    print('onStop');
    await audioPlayer.stop();
    audioPlayer.dispose();
    await super.onStop();
  }

  @override
  void onClose() async {
    onStop();
  }

  @override
  void onAudioFocusLost(AudioInterruption interruption) {
    switch (interruption) {
      case AudioInterruption.pause:
        onPause();
        break;
      case AudioInterruption.temporaryPause:
        onPause();
        break;
      case AudioInterruption.temporaryDuck:
        audioPlayer.setVolume(0.5);
        break;
      case AudioInterruption.unknownPause:
        onPause();
        break;
    }
  }

  @override
  void onAudioFocusGained(AudioInterruption interruption) {
    switch (interruption) {
      case AudioInterruption.pause:
        onPlay();
        break;
      case AudioInterruption.temporaryPause:
        onPlay();
        break;
      case AudioInterruption.temporaryDuck:
        audioPlayer.setVolume(1.0);
        break;
      case AudioInterruption.unknownPause:
        onPlay();
        break;
    }
  }

  var lastClick = 0;
  var currentClick = DateTime.now().millisecondsSinceEpoch;

  @override
  void onClick(MediaButton button) {
    if(button == MediaButton.media) {
      lastClick = currentClick;
      currentClick = DateTime
          .now()
          .millisecondsSinceEpoch;
      if (currentClick - lastClick < 500) {
        print('double click');
        skipToNextAndPrevious();
      } else {
        print('single media click');
        if (audioPlayer.state == AudioPlayerState.PLAYING) {
          audioPlayer.pause();
          AudioServiceBackground.setState(
              controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
              processingState: AudioProcessingState.ready,
              playing: false);
        } else if (audioPlayer.state == AudioPlayerState.PAUSED) {
          audioPlayer.resume();
          AudioServiceBackground.setState(
              controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
              processingState: AudioProcessingState.ready,
              playing: true);
        }
      }
    }
//    switch (button) {
//      case MediaButton.media:
//        print('media');
//        if (audioPlayer.state == AudioPlayerState.PLAYING) {
//          audioPlayer.pause();
//          AudioServiceBackground.setState(
//              controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
//              processingState: AudioProcessingState.ready,
//              playing: false);
//        } else if (audioPlayer.state == AudioPlayerState.PAUSED) {
//          audioPlayer.resume();
//          AudioServiceBackground.setState(
//              controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
//              processingState: AudioProcessingState.ready,
//              playing: true);
//        }
//        break;
//      case MediaButton.next:
//        print('next');
//        skipToNextAndPrevious();
//        break;
//      case MediaButton.previous:
//        print('previous');
//        skipToNextAndPrevious();
//        break;
//    }
  }

  @override
  void onAudioBecomingNoisy() {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.pause();
      AudioServiceBackground.setState(
          controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: false);
    }
    super.onAudioBecomingNoisy();
  }

  @override
  void onTaskRemoved() {
    onStop();
    super.onTaskRemoved();
  }
}
