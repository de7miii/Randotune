import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      child: AudioServiceWidget(
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
            '/': (context) => HomePage(),
            '/album_page': (context) => AlbumPage()
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          child: Selector<MusicFinder, Tuple2<List, bool>>(
            selector: (context, model) => Tuple2(model.allAlbums, model.isLoading),
            builder: (context, value, child) {
              return Stack(
                children: <Widget>[
                  !value.item2
                      ? GridView.builder(
                          padding: EdgeInsets.only(bottom: 144.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return AlbumListItem(
                              albumInfo: value.item1[index],
                            );
                          },
                          itemCount: value.item1.length,
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.2,
                    maxChildSize: 0.2,
                    minChildSize: 0.2,
                    builder: (context, scrollController) {
                      return !value.item2 ?
                      MusicPlayer() :
                      null;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (permissionStatus.isGranted) {
      Provider.of<MusicFinder>(context, listen: false).findAllArtists();
      Provider.of<MusicFinder>(context, listen: false).findAllAlbums();
    }
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }
}
