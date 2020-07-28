import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:random_music_player/utils/media_controls.dart';
import '../utils/audio_playback_helpers.dart';

class BackgroundMusicHandler extends BackgroundAudioTask {
  AudioPlayer audioPlayer = AudioPlayer();
  List<dynamic> allSongs = [];
  Duration position;

  @override
  void onStart(Map<String, dynamic> params) {
    allSongs = params['allSongs'];
    super.onStart(params);
  }

  @override
  void onPlay() async {
    if(audioPlayer.state == AudioPlayerState.PAUSED){
      resumeSong(audioPlayer);
      AudioServiceBackground.setState(controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
    }else {
      AudioServiceBackground.setState(controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.connecting,
          playing: false);
      String songFilePath = allSongs[Random.secure().nextInt(allSongs.length)];
      AudioServiceBackground.sendCustomEvent(songFilePath);
      int res = await playSong(songFilePath, audioPlayer);
      if(res == 1){
        print(audioPlayer.state);
        audioPlayer.onAudioPositionChanged.listen((event) {
          AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
        });
      }
      AudioServiceBackground.setState(controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
    }
  }

  @override
  void onPause() async {
    int res = await pauseSong(audioPlayer);
    if(res == 1){
      print(audioPlayer.state);
    }
    AudioServiceBackground.setState(controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.ready,
        playing: false);
  }


  @override
  void onPlayMediaItem(MediaItem mediaItem) async {
    AudioServiceBackground.setState(controls: [skipToPrevCtrl, playCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.connecting,
        playing: false);
    AudioServiceBackground.sendCustomEvent(mediaItem.id);
    int res = await playSong(mediaItem.id, audioPlayer);
    if(res == 1){
      print(audioPlayer.state);
      audioPlayer.onAudioPositionChanged.listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
    }
    AudioServiceBackground.setState(controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
        processingState: AudioProcessingState.ready,
        playing: true);
  }

  @override
  void onSkipToPrevious() async {
    String songFilePath = allSongs[Random.secure().nextInt(allSongs.length)];
    AudioServiceBackground.sendCustomEvent(songFilePath);
    int res = await playSong(songFilePath, audioPlayer);
    if(res == 1){
      AudioServiceBackground.setState(controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
      print(audioPlayer.state);
      audioPlayer.onAudioPositionChanged.listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
    }
  }

  @override
  void onSkipToNext() async {
    String songFilePath = allSongs[Random.secure().nextInt(allSongs.length)];
    AudioServiceBackground.sendCustomEvent(songFilePath);
    int res = await playSong(songFilePath, audioPlayer);
    if(res == 1){
      AudioServiceBackground.setState(controls: [skipToPrevCtrl, pauseCtrl, skipToNextCtrl],
          processingState: AudioProcessingState.ready,
          playing: true);
      print(audioPlayer.state);
      audioPlayer.onAudioPositionChanged.listen((event) {
        AudioServiceBackground.sendCustomEvent(event.inMilliseconds);
      });
    }
  }


  @override
  void onSeekTo(Duration position) {
    seek(audioPlayer, duration: position.inSeconds);
  }

  @override
  Future<Function> onStop() {
    audioPlayer.stop();
    AudioServiceBackground.setState(controls: [], processingState: AudioProcessingState.none, playing: false);
    return super.onStop();
  }
}