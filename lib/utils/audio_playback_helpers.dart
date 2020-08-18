
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

playSong(String songFilePath, AudioPlayer audioPlayer) async {
  assert(songFilePath != null);
  assert(audioPlayer != null);
  return await audioPlayer.play(songFilePath, isLocal: true);
}

pauseSong(AudioPlayer audioPlayer) async {
  assert(audioPlayer != null);
  return await audioPlayer.pause();
}

resumeSong(AudioPlayer audioPlayer) async {
  assert(audioPlayer != null);
  await audioPlayer.resume();
}

seek(AudioPlayer audioPlayer, {@required int duration}) async {
  assert(audioPlayer != null);
  assert(duration != null);
  if (audioPlayer.state == AudioPlayerState.PLAYING ||
      audioPlayer.state == AudioPlayerState.PAUSED) {
    if (duration == 0) {
      await audioPlayer.seek(Duration(seconds: 0));
    } else {
      await audioPlayer.seek(Duration(seconds: duration));
    }
  }
}