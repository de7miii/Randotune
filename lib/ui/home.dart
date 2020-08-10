import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_music_player/ui/album_page.dart';
import 'package:random_music_player/ui/widgets/album_list_item.dart';
import 'package:random_music_player/utils/app_theme.dart';
import 'package:random_music_player/utils/search.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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
  Box songsBox = Hive.box('songs');
  Box albumsBox = Hive.box('albums');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                'Randotune',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Theme.of(context).accentColor),
              ),
              floating: true,
              pinned: false,
              snap: true,
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    showSearch(
                            context: context,
                            delegate: Search(
                                allAlbums: Provider.of<MusicFinder>(context,
                                            listen: false)
                                        .allAlbums
                                        .isEmpty
                                    ? albumsBox
                                        .get('allAlbums', defaultValue: [])
                                    : Provider.of<MusicFinder>(context,
                                            listen: false)
                                        .allAlbums))
                        .then((value) {
                          if(value == null){
                            AudioService.connect();
                          }});
                  },
                  icon: Icon(Icons.search),
                )
              ],
            ),
          ];
        },
        body: SafeArea(
          top: false,
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.18,
                      child: !value.isLoading || value.allSongs.isNotEmpty
                          ? value.musicPlayer
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _loadMedia() {
    AudioService.connect();
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: false);
    if ((songsBox.isOpen && albumsBox.isOpen) &&
        (songsBox.containsKey('allSongs') &&
            albumsBox.containsKey('allAlbums'))) {
      print('boxes are open');
      musicModel.allSongs = List.castFrom(songsBox.get('allSongs'));
      musicModel.allAlbums = List.castFrom(albumsBox.get('allAlbums'));
    } else {
      musicModel
        ..findAllSongs()
        ..findAllAlbums();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('home page init state');
    Permission.storage.status.then((value) {
      if (value.isGranted) {
        _loadMedia();
      } else {
        Permission.storage.request().then((status) {
          if (status.isGranted) {
            _loadMedia();
          } else if (status.isDenied) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Media Storage Permission Required'),
                    content: Text(
                        'For the app to work it requires media storage permission to fetch your music library. Please consider granting this permission.'),
                    actions: <Widget>[
                      RaisedButton(
                          child: Text('Request Permission'),
                          onPressed: () {
                            Permission.storage.request().then((value) {
                              if (value.isGranted) {
                                _loadMedia();
                              } else if (value.isPermanentlyDenied) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            'Permission Permanently Denied'),
                                        content: Text(
                                            'To use the app grant the storage permission from the permission settings.'),
                                        actions: <Widget>[
                                          RaisedButton(
                                            child: Text('Open Settings'),
                                            onPressed: () {
                                              openAppSettings()
                                                  .then((value) => null)
                                                  .isGranted
                                                  .then((value) {
                                                if (value) {
                                                  _loadMedia();
                                                } else {
                                                  AudioService.disconnect();
                                                  SystemNavigator.pop();
                                                }
                                              });
                                            },
                                          ),
                                          RaisedButton(
                                            child: Text('Close App'),
                                            onPressed: () {
                                              AudioService.disconnect();
                                              SystemNavigator.pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              } else {
                                AudioService.disconnect();
                                SystemNavigator.pop();
                              }
                            });
                          }),
                      RaisedButton(
                        child: Text('Close App'),
                        onPressed: () {
                          AudioService.disconnect();
                          SystemNavigator.pop();
                        },
                      ),
                    ],
                  );
                });
          } else if (status.isPermanentlyDenied) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Permission is Permanently Denied'),
                    content: Text(
                        'To use the app grant the storage permission from the permission settings.'),
                    actions: <Widget>[
                      RaisedButton(
                        child: Text('Open Settings'),
                        onPressed: () {
                          openAppSettings()
                              .then((value) {})
                              .isGranted
                              .then((value) {
                            if (value) {
                              _loadMedia();
                            } else {
                              AudioService.disconnect();
                              SystemNavigator.pop();
                            }
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text('Close App'),
                        onPressed: () {
                          AudioService.disconnect();
                          SystemNavigator.pop();
                        },
                      ),
                    ],
                  );
                });
          }
        }, onError: (err) {
          print(err);
        });
      }
    });
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
