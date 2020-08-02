import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:random_music_player/utils/media_controls.dart';
import '../utils/audio_playback_helpers.dart';

class BackgroundMusicHandler extends BackgroundAudioTask {
  AudioPlayer audioPlayer;
  List<dynamic> allSongs = [];
  Duration position;

  @override
  void onStart(Map<String, dynamic> params) {
    print('onStart');
    audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    allSongs = params['allSongs'];
    super.onStart(params);
  }

  @override
  void onPlay() async {
    print('onPlay');
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
      dynamic song = allSongs[Random.secure().nextInt(allSongs.length)];
      AudioServiceBackground.sendCustomEvent(song[1]);
      int res = await playSong(song[1], audioPlayer);
      if (res == 1) {
        audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
          if(event == AudioPlayerState.COMPLETED){
            AudioServiceBackground.sendCustomEvent(-1);
            print(event);
          }
        });
        audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
          AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
        });
        AudioServiceBackground.setState(
            controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
            processingState: AudioProcessingState.ready,
            playing: true);
        AudioServiceBackground.setMediaItem(MediaItem(
            id: song[0],
            album: song[2],
            title: song[3],
            artist: song[4],
            artUri: song[5]));
      }
    }
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
    print('onPlayMediaItem');
    AudioServiceBackground.sendCustomEvent(mediaItem.id);
    int res = await playSong(mediaItem.id, audioPlayer);
    if (res == 1) {
      print(audioPlayer.state);
      audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
        if(event == AudioPlayerState.COMPLETED){
          AudioServiceBackground.sendCustomEvent(-1);
          print(event);
        }
      });
      audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
    }
    AudioServiceBackground.setState(
        controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.ready,
        playing: true);
    AudioServiceBackground.setMediaItem(mediaItem);
  }

  @override
  void onSkipToPrevious() async {
    print('OnSkipToPrevious');
    dynamic song = allSongs[Random.secure().nextInt(allSongs.length)];
    AudioServiceBackground.sendCustomEvent(song[1]);
    int res = await playSong(song[1], audioPlayer);
    if (res == 1) {
      AudioServiceBackground.setState(
          controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
      print(audioPlayer.state);
      audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
        if(event == AudioPlayerState.COMPLETED){
          AudioServiceBackground.sendCustomEvent(-1);
          print(event);
        }
      });
      audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
      AudioServiceBackground.setMediaItem(MediaItem(
          id: song[0],
          album: song[2],
          title: song[3],
          artist: song[4],
          artUri: song[5]));
    }
  }

  @override
  void onSkipToNext() async {
    print('onSkipToNext');
    dynamic song = allSongs[Random.secure().nextInt(allSongs.length)];
    AudioServiceBackground.sendCustomEvent(song[1]);
    int res = await playSong(song[1], audioPlayer);
    if (res == 1) {
      AudioServiceBackground.setState(
          controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
      print(audioPlayer.state);
      audioPlayer.onPlayerStateChanged.asBroadcastStream().listen((event) {
        if(event == AudioPlayerState.COMPLETED){
          AudioServiceBackground.sendCustomEvent(-1);
          print(event);
        }
      });
      audioPlayer.onAudioPositionChanged.asBroadcastStream().listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
      AudioServiceBackground.setMediaItem(MediaItem(
          id: song[0],
          album: song[2],
          title: song[3],
          artist: song[4],
          artUri: song[5]));
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
    audioPlayer.dispose();
    await super.onStop();
  }


  @override
  void onClose() async {
    onStop();
  }

  @override
  void onAudioFocusLost(AudioInterruption interruption) {
    switch(interruption){
      case AudioInterruption.pause:
        // TODO: Handle this case.
        break;
      case AudioInterruption.temporaryPause:
        // TODO: Handle this case.
        break;
      case AudioInterruption.temporaryDuck:
        // TODO: Handle this case.
        break;
      case AudioInterruption.unknownPause:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void onAudioFocusGained(AudioInterruption interruption) {
    switch(interruption){
      case AudioInterruption.pause:
        // TODO: Handle this case.
        break;
      case AudioInterruption.temporaryPause:
        // TODO: Handle this case.
        break;
      case AudioInterruption.temporaryDuck:
        // TODO: Handle this case.
        break;
      case AudioInterruption.unknownPause:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void onTaskRemoved() {
    onStop();
    super.onTaskRemoved();
  }
}
