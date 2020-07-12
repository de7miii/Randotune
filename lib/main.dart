import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:random_music_player/ui/home.dart';
import 'package:storage_path/storage_path.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

final AudioPlayer ap = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
final FlutterAudioQuery aq = FlutterAudioQuery();

void main() => runApp(MyApp());

playLocalSong() async {
  var response = await StoragePath.audioPath;
  var audioPath = jsonDecode(response);
  var localPath = audioPath[0]['files'][0]['path'];
  var artists = await aq.getSongs(sortType: SongSortType.DISPLAY_NAME);
  print(artists.length);
  print(artists);
//  artists.forEach((element) {print(element);});
  localPath = artists[1].filePath;
//  print(audioPath);
//  print(localPath);
  await ap.play(localPath, isLocal: true);
}

pauseLocalSong() async {
  await ap.pause();
}