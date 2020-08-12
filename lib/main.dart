import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:instabug_flutter/CrashReporting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/ui/home.dart';
import 'package:random_music_player/utils/album_info.dart';
import 'package:random_music_player/utils/song_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var path = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();
  Hive.init(path.path);
  Hive.registerAdapter(SongInfoLocalAdapter());
  Hive.registerAdapter(AlbumInfoLocalAdapter());
  await Hive.openBox('songs');
  await Hive.openBox('albums');
  print('hive initilized and boxes are open');
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZonedGuarded<Future<void>>(() async {
    runApp(MyApp());
  }, (Object error, StackTrace stackTrace) {
    _reportError(error, stackTrace);
  });
}

bool get isInDebugMode {
  bool isDebugMode = false;
  assert(isDebugMode = true);
  return isDebugMode;
}

Future<void> _reportError(dynamic error, dynamic stackTrace) async {
  print("Caught Error: $error");
  if (isInDebugMode) {
    print(stackTrace);
  } else {
    CrashReporting.reportCrash(error, stackTrace);
  }
}