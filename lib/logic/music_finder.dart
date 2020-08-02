import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:random_music_player/ui/widgets/music_player.dart';

class MusicFinder with ChangeNotifier {
  final FlutterAudioQuery aq = FlutterAudioQuery();
  final musicPlayer = MusicPlayer();

  List<SongInfo> _allSongs = [];
  List<AlbumInfo> _allAlbums = [];
  List<ArtistInfo> _allArtists = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isUiActive = true;
  AlbumInfo _selectedAlbum;
  List<SongInfo> _selectedAlbumSongs = [];
  SongInfo _currentlyPlaying;
  int _currentSongPosition = 0;
  int _currentSongDuration = 0;

  List<SongInfo> get allSongs => _allSongs;
  List<AlbumInfo> get allAlbums => _allAlbums;
  List<ArtistInfo> get allArtists => _allArtists;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isUiActive => _isUiActive;
  AlbumInfo get selectedAlbum => _selectedAlbum;
  List<SongInfo> get selectedAlbumSongs => _selectedAlbumSongs;
  SongInfo get currentlyPlaying => _currentlyPlaying;
  int get currentSongPosition => _currentSongPosition;
  int get currentSongDuration => _currentSongDuration;

  set selectedAlbumSongs(List<SongInfo> albumSongs) {
    assert(albumSongs != null);
    _selectedAlbumSongs = albumSongs;
    notifyListeners();
  }

  set selectedAlbum(AlbumInfo newAlbum) {
    assert(newAlbum != null);
    _selectedAlbum = newAlbum;
    notifyListeners();
  }

  set isPlaying(bool state) {
    assert(state != null);
    _isPlaying = state;
    notifyListeners();
  }

  set isUiActive(bool state) {
    assert(state != null);
    _isUiActive = state;
    notifyListeners();
  }

  set currentlyPlaying(SongInfo newSong) {
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

  findAllSongs({SongSortType sortType = SongSortType.DISPLAY_NAME}) {
    _isLoading = true;
    aq.getSongs(sortType: sortType).then((songsList) {
      _allSongs = songsList;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print(err);
    });
  }

  findAllAlbums({AlbumSortType sortType = AlbumSortType.DEFAULT}) {
    _isLoading = true;
    aq.getAlbums(sortType: sortType).then((albumList) {
      _allAlbums = albumList;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print(err);
    });
  }

  findAlbumSongs({@required AlbumInfo album}) {
    assert(album != null);
    selectedAlbum = album;
    _isLoading = true;
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
          _selectedAlbumSongs = songsList;
          _isLoading = false;
          notifyListeners();
        },
        onError: (err) => print(err),
      );
    }
  }

  findAllArtists({ArtistSortType sortType = ArtistSortType.DEFAULT}) {
    aq.getArtists(sortType: sortType).then((artistsList) {
      _allArtists = artistsList;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print(err);
    });
  }

  handleCustomEvents() {
    AudioService.customEventStream.asBroadcastStream().listen((event) {
      if (event is String) {
        var currentSong = allSongs
            .where((element) => element.filePath == event)
            .reduce((value, element) => element);
        currentlyPlaying = currentSong;
        currentSongDuration = int.parse(currentSong.duration);
      } else if (event is int) {
        if (event == -1) {
//          AudioService.skipToNext();
          print('song completed');
        } else {
          print(event);
          currentSongPosition = event;
        }
      }
    }, cancelOnError: true);
  }
}
