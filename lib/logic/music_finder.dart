import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:random_music_player/ui/widgets/music_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/utils/album_info.dart';
import 'package:random_music_player/utils/artist_info.dart';
import 'package:random_music_player/utils/song_info.dart';

class MusicFinder with ChangeNotifier {
  final FlutterAudioQuery aq = FlutterAudioQuery();
  final musicPlayer = MusicPlayer();
  Box songsBox = Hive.box('songs'),
      albumsBox = Hive.box('albums'),
      artistsBox = Hive.box('artists');

  List<SongInfoLocal> _allSongs = [];
  List<AlbumInfoLocal> _allAlbums = [];
  List<ArtistInfoLocal> _allArtists = [];
  List<SongInfoLocal> _selectedAlbumSongs = [];
  List<AlbumInfoLocal> _selectedArtistAlbums = [];
  List<AlbumInfoLocal> _displayedAlbums = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isLoopSong = false;
  bool _isFilteredByArtist = false;
  AlbumInfoLocal _selectedAlbum;
  SongInfoLocal _currentlyPlaying;
  ArtistInfoLocal _selectedArtist;
  int _currentSongPosition = 0;
  int _currentSongDuration = 0;

  List<SongInfoLocal> get allSongs => _allSongs;
  List<AlbumInfoLocal> get allAlbums => _allAlbums;
  List<ArtistInfoLocal> get allArtists => _allArtists;
  List<SongInfoLocal> get selectedAlbumSongs => _selectedAlbumSongs;
  List<AlbumInfoLocal> get selectedArtistAlbums => _selectedArtistAlbums;
  List<AlbumInfoLocal> get displayedAlbums => _displayedAlbums;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isLoopSong => _isLoopSong;
  bool get isFilteredByArtist => _isFilteredByArtist;
  AlbumInfoLocal get selectedAlbum => _selectedAlbum;
  SongInfoLocal get currentlyPlaying => _currentlyPlaying;
  ArtistInfoLocal get selectedArtist => _selectedArtist;
  int get currentSongPosition => _currentSongPosition;
  int get currentSongDuration => _currentSongDuration;

  set selectedAlbumSongs(List<SongInfoLocal> albumSongs) {
    assert(albumSongs != null);
    _selectedAlbumSongs = albumSongs;
    notifyListeners();
  }

  set selectedAlbum(AlbumInfoLocal newAlbum) {
    assert(newAlbum != null);
    _selectedAlbum = newAlbum;
    notifyListeners();
  }

  set selectedArtistAlbums(List<AlbumInfoLocal> selectedArtistAlbums) {
    assert(selectedArtistAlbums != null);
    _selectedArtistAlbums = selectedArtistAlbums;
    notifyListeners();
  }

  set displayedAlbums(List<AlbumInfoLocal> albums) {
    assert(albums != null);
    _displayedAlbums = albums;
    notifyListeners();
  }

  set selectedArtist(ArtistInfoLocal artist) {
    // assert(artist != null);
    _selectedArtist = artist;
    notifyListeners();
  }

  set isPlaying(bool state) {
    assert(state != null);
    _isPlaying = state;
    notifyListeners();
  }

  set isLoopSong(bool state) {
    assert(state != null);
    _isLoopSong = state;
//    notifyListeners();
  }

  set isFilteredByArtist(bool state) {
    assert(state != null);
    _isFilteredByArtist = state;
    notifyListeners();
  }

  set currentlyPlaying(SongInfoLocal newSong) {
    assert(newSong != null);
    _currentlyPlaying = newSong;
    print("Currently Playing: ${newSong.title}");
    notifyListeners();
  }

  set currentSongPosition(int newPos) {
    assert(newPos != null);
    _currentSongPosition = newPos;
    notifyListeners();
  }

  set currentSongDuration(int newDur) {
    assert(newDur != null);
    _currentSongDuration = newDur;
    notifyListeners();
  }

  set allSongs(List<SongInfoLocal> allSongs) {
    assert(allSongs != null);
    _allSongs = allSongs;
    _isLoading = false;
    notifyListeners();
  }

  set allAlbums(List<AlbumInfoLocal> allAlbums) {
    assert(allAlbums != null);
    _allAlbums = allAlbums;
    _isLoading = false;
    notifyListeners();
  }

  set allArtists(List<ArtistInfoLocal> allArtists) {
    assert(allArtists != null);
    _allArtists = allArtists;
    _isLoading = false;
    notifyListeners();
  }

  findAllSongs(
      {SongSortType sortType = SongSortType.SMALLER_TRACK_NUMBER}) async {
    _isLoading = true;
    notifyListeners();
    aq.getSongs(sortType: sortType).then((songsList) {
      _allSongs = songsList
          .map((e) => SongInfoLocal.fromSongInfo(e))
          .toList()
          .where((element) => element.isMusic == true)
          .toList();
      _isLoading = false;
      print('songs are loaded');
      notifyListeners();
      if (songsBox?.isOpen ?? false) {
        print('songs box is open');
        if (!songsBox.containsKey('allSongs')) {
          songsBox.put('allSongs', _allSongs);
          print('songs put in box');
        }
      }
    }, onError: (err) {
      print(err);
    });
  }

  findAllAlbums({AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    _isLoading = true;
    notifyListeners();
    aq.getAlbums(sortType: sortType).then((albumList) {
      _allAlbums =
          albumList.map((e) => AlbumInfoLocal.fromAlbumInfo(e)).toList();
      _isLoading = false;
      print('albums loaded');
      notifyListeners();
      if (albumsBox?.isOpen ?? false) {
        print('albums box is open');
        if (!albumsBox.containsKey('allAlbums')) {
          albumsBox.put('allAlbums', _allAlbums);
          print('albums put in box');
        }
      }
    }, onError: (err) {
      print(err);
    });
  }

  findAlbumSongs({@required AlbumInfoLocal album}) async {
    assert(album != null);
    selectedAlbum = album;
    _isLoading = true;
    notifyListeners();
    if (allSongs?.isNotEmpty ?? false) {
      _selectedAlbumSongs =
          allSongs.where((element) => element.albumId == album.id).toList();
      _isLoading = false;
      notifyListeners();
    } else {
      aq
          .getSongsFromAlbum(
              albumId: album.id, sortType: SongSortType.SMALLER_TRACK_NUMBER)
          .then(
        (songsList) {
          print(songsList);
          _selectedAlbumSongs =
              songsList.map((e) => SongInfoLocal.fromSongInfo(e)).toList();
          _isLoading = false;
          notifyListeners();
        },
        onError: (err) => print(err),
      );
    }
  }

  findAllArtists({ArtistSortType sortType = ArtistSortType.DEFAULT}) async {
    _isLoading = true;
    notifyListeners();
    aq.getArtists(sortType: sortType).then((artistsList) {
      _allArtists =
          artistsList.map((e) => ArtistInfoLocal.fromArtistInfo(e)).toList();
      _isLoading = false;
      notifyListeners();
      if (artistsBox?.isOpen ?? false) {
        print('artists box is open');
        if (!artistsBox.containsKey('allArtists')) {
          artistsBox.put('allArtists', _allArtists);
          print('artists put in box');
        }
      }
    }, onError: (err) {
      print(err);
    });
  }

  findArtistAlbums({@required ArtistInfoLocal artist}) {
    _isLoading = true;
    notifyListeners();
    if (allAlbums?.isNotEmpty ?? false) {
      _selectedArtistAlbums =
          allAlbums.where((element) => element.artist == artist.name).toList();
      _isLoading = false;
      notifyListeners();
    } else {
      aq.getAlbumsFromArtist(artist: artist.name).then((albums) {
        _selectedArtistAlbums =
            albums.map((e) => AlbumInfoLocal.fromAlbumInfo(e)).toList();
        _isLoading = false;
        notifyListeners();
      }, onError: (err) {
        print(err);
      });
    }
  }
}
