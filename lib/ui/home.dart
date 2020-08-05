import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_music_player/ui/album_page.dart';
import 'package:random_music_player/ui/widgets/album_list_item.dart';
import 'package:random_music_player/utils/app_theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicFinder(),
      child: MaterialApp(
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => AudioServiceWidget(child: HomePage()),
          '/album_page': (context) => AudioServiceWidget(child: AlbumPage())
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  PermissionStatus permissionStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RandoTron'),
      ),
      body: Container(
        child: SafeArea(
          child: Consumer<MusicFinder>(
            builder: (context, value, child) {
              return Stack(
                children: <Widget>[
                  !value.isLoading
                      ? GridView.builder(
                          padding: EdgeInsets.only(bottom: 144.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Provider.of<MusicFinder>(context, listen: false)
                                    .findAlbumSongs(
                                        album: value.allAlbums[index]);
                                Navigator.pushNamed(context, '/album_page')
                                    .then((ret) {
                                  print('popped back to home');
                                  Future.delayed(Duration(milliseconds: 500),
                                      () {
                                    if (!AudioService.connected) {
                                      AudioService.connect();
                                    }
                                  });
                                });
                              },
                              child: AlbumListItem(
                                albumInfo: value.allAlbums[index],
                              ),
                            );
                          },
                          itemCount: value.allAlbums.length,
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.2,
                    maxChildSize: 0.2,
                    minChildSize: 0.2,
                    expand: true,
                    builder: (context, scrollController) {
                      return !value.isLoading && value.allSongs.isNotEmpty
                          ? value.musicPlayer
                          : null;
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('home page init state');
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: false);
    if (permissionStatus?.isGranted ?? false) {
      if (musicModel.allAlbums.isEmpty && musicModel.allSongs.isEmpty) {
        musicModel
          ..findAllAlbums()
          ..findAllSongs();
      }
    } else {
      Permission.storage.request().then((status) {
        permissionStatus = status;
        if (status.isGranted) {
          if (musicModel.allAlbums.isEmpty && musicModel.allSongs.isEmpty) {
            musicModel
              ..findAllAlbums()
              ..findAllSongs();
          }
        }
      }, onError: (err) {
        print(err);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('home page did change dependencies');
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: false);
    if (AudioService.connected) {
      if (AudioService.running) {
        if (AudioService.playbackState.playing) {
          AudioService.currentMediaItemStream.listen((event) {
            if (event.id != musicModel.currentlyPlaying.id) {
              musicModel.currentlyPlaying = musicModel.allSongs.firstWhere(
                  (element) => element.id == AudioService.currentMediaItem.id);
              musicModel.currentSongDuration =
                  int.parse(musicModel.currentlyPlaying.duration);
            }
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('home page did update widget');
  }

  @override
  void reassemble() {
    super.reassemble();
    print('home page reassemble');
  }

  @override
  void dispose() {
    super.dispose();
    print('home page dispose');
    AudioService.stop();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    super.deactivate();
    print('home page deactivate');
  }

  StreamSubscription sub;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: false);
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (musicModel.musicPlayer.createElement().dirty) {
          musicModel.musicPlayer.createElement().markNeedsBuild();
        }
        if (!AudioService.connected) {
          AudioService.connect();
        }
        if (AudioService.running) {
          if (AudioService.playbackState.playing) {
            AudioService.currentMediaItemStream.listen((event) {
              if (event.id != musicModel.currentlyPlaying.id) {
                musicModel.currentlyPlaying = musicModel.allSongs.firstWhere(
                    (element) =>
                        element.id == AudioService.currentMediaItem.id);
                musicModel.currentSongDuration =
                    int.parse(musicModel.currentlyPlaying.duration);
              }
            });
          }
        }
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        print('activity now is paused');
        sub = AudioService.customEventStream.listen((event) {
          if (event is int) {
            if (event == -1) {
              print('song completed');
            }
          }
        });
        break;
      case AppLifecycleState.detached:
        sub?.cancel();
        break;
    }
  }
}
