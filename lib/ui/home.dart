import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:instabug_flutter/BugReporting.dart';
import 'package:instabug_flutter/CrashReporting.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_music_player/ui/album_page.dart';
import 'package:random_music_player/ui/widgets/album_list_item.dart';
import 'package:random_music_player/ui/widgets/artsit_list_item.dart';
import 'package:random_music_player/utils/app_theme.dart';
import 'package:random_music_player/utils/environment_config.dart';
import 'package:random_music_player/utils/search.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:random_music_player/utils/strings.dart';

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
          '/': (context) => AudioServiceWidget(
                  child: ShowCaseWidget(
                builder: Builder(builder: (context) => HomePage()),
                onFinish: () {
                  Hive.box('prefs').put('displayFeatures', false);
                  print(
                      'displayFeatures after showcase finished: ${Hive.box('prefs').get('displayFeatures')}');
                  if (Hive.box('prefs').get('isFirstRun')) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('What\'s New in This Update'),
                            content: Column(
                              children: [
                                Text(feature_1),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(feature_2),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(feature_3),
                              ],
                            ),
                            actions: [
                              RaisedButton(
                                onPressed: () {
                                  Hive.box('prefs').put('isFirstRun', false);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Dismiss'),
                              )
                            ],
                          );
                        });
                  }
                },
              )),
          '/album_page': (context) => AudioServiceWidget(
                  child: ShowCaseWidget(
                builder: Builder(builder: (context) => AlbumPage()),
              ))
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
  Box artistsBox = Hive.box('artists');
  Box prefsBox = Hive.box('prefs');
  Color bgColor = Colors.transparent;
  int _selectedIndex;
  int _previousIndex;
  bool displayFeatures = false;
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();
  GlobalKey _five = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // if (prefsBox?.isOpen ?? false) {
    //   if (prefsBox.containsKey('displayFeatures')) {
    //     displayFeatures = prefsBox.get('displayFeatures');
    //     ShowCaseWidget.of(context)
    //         .startShowCase([_one, _two, _three, _four, _five]);
    //   }
    // }
    //
    // if (displayFeatures) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) =>
    //       ShowCaseWidget.of(context)
    //           .startShowCase([_one, _two, _three, _four, _five]));
    // }

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
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
              floating: false,
              pinned: true,
              snap: false,
              actions: <Widget>[
                Showcase(
                  key: _four,
                  description: 'Search for a specific album in your library.',
                  child: IconButton(
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
                        if (value == null) {
                          AudioService.connect();
                        }
                      });
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                Showcase(
                  key: _five,
                  description: 'Report bugs, or request new features.',
                  child: FlatButton(
                    child: Text(
                      'Report a Bug',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Instabug.show();
                    },
                  ),
                ),
              ],
            ),
          ];
        },
        body: SafeArea(
          top: false,
          child: Consumer<MusicFinder>(
            builder: (context, value, child) {
              return Column(children: [
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: Showcase(
                    key: _three,
                    description: 'Filter albums by artist.',
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _previousIndex = _selectedIndex;
                              _selectedIndex = index;
                              _selectedIndex == _previousIndex
                                  ? value.isFilteredByArtist = false
                                  : value.isFilteredByArtist = true;
                              _selectedIndex == _previousIndex
                                  ? value.selectedArtist = null
                                  : value.selectedArtist =
                                      value.allArtists[index];
                              _selectedIndex == _previousIndex
                                  ? bgColor = Theme.of(context).primaryColor
                                  : bgColor = Colors.transparent;
                            });
                            if (value.isFilteredByArtist) {
                              value.findArtistAlbums(
                                  artist: value.selectedArtist);
                              setState(() {
                                value.displayedAlbums =
                                    value.selectedArtistAlbums;
                              });
                            } else {
                              setState(() {
                                value.displayedAlbums = value.allAlbums;
                                _previousIndex = null;
                                _selectedIndex = null;
                              });
                            }
                          },
                          child: ArtistListItem(
                            artistInfo: value.allArtists[index],
                            bgColor: _selectedIndex != null &&
                                    _selectedIndex == index
                                ? bgColor
                                : Theme.of(context).primaryColor,
                          ),
                        );
                      },
                      itemCount: value.allArtists.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
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
                                    Provider.of<MusicFinder>(context,
                                            listen: false)
                                        .findAlbumSongs(
                                            album:
                                                value.displayedAlbums[index]);
                                    Navigator.pushNamed(context, '/album_page')
                                        .then((ret) {
                                      print('popped back to home');
                                      Future.delayed(
                                          Duration(milliseconds: 500), () {
                                        if (!AudioService.connected) {
                                          AudioService.connect();
                                        }
                                      });
                                    });
                                  },
                                  child: AlbumListItem(
                                    albumInfo: value.displayedAlbums[index],
                                  ),
                                );
                              },
                              itemCount: value.displayedAlbums.length,
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.18,
                          child: !value.isLoading
                              ? Showcase(
                                  key: _two,
                                  description: 'Here is your Players Controls',
                                  child: value.musicPlayer)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  void _loadMedia() {
    AudioService.connect();
    MusicFinder musicModel = Provider.of<MusicFinder>(context, listen: false);
    if ((songsBox.isOpen && albumsBox.isOpen && artistsBox.isOpen) &&
        (songsBox.containsKey('allSongs') &&
            albumsBox.containsKey('allAlbums') &&
            artistsBox.containsKey('allArtists'))) {
      print('boxes are open');
      musicModel.allSongs = List.castFrom(songsBox.get('allSongs'));
      musicModel.allAlbums = List.castFrom(albumsBox.get('allAlbums'));
      musicModel.allArtists = List.castFrom(artistsBox.get('allArtists'));
      musicModel.displayedAlbums = musicModel.allAlbums;
    } else {
      musicModel
        ..findAllSongs()
        ..findAllAlbums()
        ..findAllArtists();
    }

    if (prefsBox?.isOpen ?? false) {
      if (!prefsBox.containsKey('displayFeatures')) {
        prefsBox.put('displayFeatures', true);
        displayFeatures = prefsBox.get('displayFeatures');
        print('displayFeatures: $displayFeatures');
        ShowCaseWidget.of(context).startShowCase([_two, _three, _four, _five]);
      } else {
        displayFeatures = prefsBox.get('displayFeatures');
        if (displayFeatures) {
          ShowCaseWidget.of(context)
              .startShowCase([_two, _three, _four, _five]);
        }
      }
    }
  }

  void initInstaBug() {
    Instabug.setWelcomeMessageMode(WelcomeMessageMode.disabled);
    BugReporting.setEnabled(true);
    BugReporting.setReportTypes([ReportType.bug, ReportType.feedback]);
    BugReporting.setInvocationOptions([InvocationOption.emailFieldHidden]);
    CrashReporting.setEnabled(true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) {
      Instabug.start(EnvironmentConfig.IB_TOKEN, [InvocationEvent.none]);
    }
    initInstaBug();
    if (!prefsBox.containsKey('isFirstRun')) {
      prefsBox.put('isFirstRun', true);
    }
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
    Instabug.setPrimaryColor(Theme.of(context).primaryColor);
    if (AudioService.connected) {
      if (AudioService.running) {
        if (AudioService.playbackState.playing) {
          AudioService.currentMediaItemStream.listen((event) {
            if (event?.id != musicModel.currentlyPlaying?.id) {
              musicModel.currentlyPlaying = musicModel.allSongs.firstWhere(
                  (element) =>
                      element?.id == AudioService.currentMediaItem?.id);
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
