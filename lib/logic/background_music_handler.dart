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
    audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    allSongs = params['allSongs'];
    super.onStart(params);
  }

  @override
  void onPlay() async {
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
        audioPlayer.onPlayerStateChanged.listen((event) {
          if(event == AudioPlayerState.COMPLETED){
            AudioServiceBackground.sendCustomEvent(-1);
          }
        });
        audioPlayer.onAudioPositionChanged.listen((event) {
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
    int res = await pauseSong(audioPlayer);
    if (res == 1) {
      print(audioPlayer.state);
    }
    AudioServiceBackground.setState(
        controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.ready,
        playing: false);
  }

  @override
  void onPlayMediaItem(MediaItem mediaItem) async {
    AudioServiceBackground.setState(
        controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.connecting,
        playing: false);
    AudioServiceBackground.sendCustomEvent(mediaItem.id);
    int res = await playSong(mediaItem.id, audioPlayer);
    if (res == 1) {
      print(audioPlayer.state);
      audioPlayer.onAudioPositionChanged.listen((event) {
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
    dynamic song = allSongs[Random.secure().nextInt(allSongs.length)];
    AudioServiceBackground.sendCustomEvent(song[1]);
    int res = await playSong(song[1], audioPlayer);
    if (res == 1) {
      AudioServiceBackground.setState(
          controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
      audioPlayer.onAudioPositionChanged.listen((event) {
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
    dynamic song = allSongs[Random.secure().nextInt(allSongs.length)];
    AudioServiceBackground.sendCustomEvent(song[1]);
    int res = await playSong(song[1], audioPlayer);
    if (res == 1) {
      AudioServiceBackground.setState(
          controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
      audioPlayer.onAudioPositionChanged.listen((event) {
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
    seek(audioPlayer, duration: position.inSeconds);
  }

  @override
  Future<Function> onStop() {
    audioPlayer.stop();
    AudioServiceBackground.setState(
        controls: [],
        processingState: AudioProcessingState.none,
        playing: false);
    return super.onStop();
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
}
