import 'dart:io';
import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/background_music_handler.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_music_player/ui/album_page.dart';
import 'package:random_music_player/ui/widgets/album_list_item.dart';
import 'package:random_music_player/ui/widgets/music_player.dart';
import 'package:tuple/tuple.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicFinder(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.indigo,
          primaryColorDark: Colors.indigo.shade800,
          primaryColorLight: Colors.indigo.shade200,
          accentColor: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          sliderTheme: SliderThemeData(
              activeTrackColor: Theme.of(context).primaryColorDark,
              inactiveTrackColor: Theme.of(context).primaryColorLight,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              thumbColor: Theme.of(context).primaryColorDark,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 8.0),
              trackHeight: 2.0),
        ),
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  PermissionStatus permissionStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RandoTron'),
        centerTitle: true,
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
                                    .findAlbumSongs(album: value.allAlbums[index]);
                                Navigator.pushNamed(context, '/album_page').then((ret) {
                                    print('popped back to home');
                                    Future.delayed(Duration(milliseconds: 500), (){
                                      if(!AudioService.connected) {
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
                      return !value.isLoading
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
    if(permissionStatus?.isGranted ?? false) {
      Provider.of<MusicFinder>(context, listen: false).findAllSongs();
      Provider.of<MusicFinder>(context, listen: false).findAllAlbums();
    } else {
      Permission.storage.request().then((status) {
        permissionStatus = status;
        if (status.isGranted) {
          Provider.of<MusicFinder>(context, listen: false).findAllSongs();
          Provider.of<MusicFinder>(context, listen: false).findAllAlbums();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    switch(state){
      case AppLifecycleState.resumed:
        print(Provider.of<MusicFinder>(context, listen: false).musicPlayer.createElement().dirty);
        if(Provider.of<MusicFinder>(context, listen: false).musicPlayer.createElement().dirty){
          Provider.of<MusicFinder>(context, listen: false).musicPlayer.createElement().markNeedsBuild();
        }
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        print('activity now is paused');
        AudioService.customEventStream.listen((event) {
          if (event is int) {
            if (event == -1) {
              print('song completed');
            }
          }
        });
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }
}