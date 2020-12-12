import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/ui/home.dart';
import 'package:random_music_player/utils/album_info.dart';
import 'package:random_music_player/utils/artist_info.dart';
import 'package:random_music_player/utils/song_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var path = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();
  Hive.init(path.path);
  Hive.registerAdapter(SongInfoLocalAdapter());
  Hive.registerAdapter(AlbumInfoLocalAdapter());
  Hive.registerAdapter(ArtistInfoLocalAdapter());
  await Hive.openBox('songs');
  await Hive.openBox('albums');
  await Hive.openBox('prefs');
  await Hive.openBox('artists');
  print('hive initilized and boxes are open');
  runApp(MyApp());
}
