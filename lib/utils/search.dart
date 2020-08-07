import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_music_player/logic/music_finder.dart';
import 'package:random_music_player/ui/widgets/album_list_item.dart';
import 'package:random_music_player/utils/album_info.dart';

class Search extends SearchDelegate {
  final List<AlbumInfoLocal> allAlbums;
  List<AlbumInfoLocal> searchedAlbum;

  Search({this.allAlbums});

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
      ),
      textTheme: TextTheme(
        headline6: TextStyle(color: Colors.white),
      ),
    );
    assert(theme != null);
    return theme;
  }

  @override
  // TODO: implement searchFieldLabel
  String get searchFieldLabel => 'Search Albums (Album Title)';

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchedAlbum = allAlbums
        .where((element) =>
            element.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchedAlbum.isNotEmpty
        ? GridView.count(
            crossAxisCount: 2,
            children: searchedAlbum.map((element) {
              return GestureDetector(
                onTap: () {
                  Provider.of<MusicFinder>(context, listen: false)
                      .findAlbumSongs(album: element);
                  Navigator.of(context).pushNamed('/album_page');
                },
                child: AlbumListItem(
                  albumInfo: element,
                ),
              );
            }).toList(),
          )
        : Container(
            child: Center(child: Text('No Albums Matching Your Search')));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<AlbumInfoLocal> suggestedAlbums = allAlbums
        .where((element) =>
            element.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return suggestedAlbums.isNotEmpty
        ? GridView.count(
      crossAxisCount: 2,
      children: suggestedAlbums.map((element) {
        return GestureDetector(
          onTap: () {
            Provider.of<MusicFinder>(context, listen: false)
                .findAlbumSongs(album: element);
            Navigator.of(context).pushNamed('/album_page');
          },
          child: AlbumListItem(
            albumInfo: element,
          ),
        );
      }).toList(),
    )
        : Container(
        child: Center(child: Text('No Albums Matching Your Search')));
  }
}
