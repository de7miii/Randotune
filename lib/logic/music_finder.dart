
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:random_music_player/ui/widgets/music_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/utils/album_info.dart';
import 'package:random_music_player/utils/song_info.dart';

class MusicFinder with ChangeNotifier {
  final FlutterAudioQuery aq = FlutterAudioQuery();
  final musicPlayer = MusicPlayer();
  Box songsBox = Hive.box('songs'), albumsBox = Hive.box('albums');

  List<SongInfoLocal> _allSongs = [];
  List<AlbumInfoLocal> _allAlbums = [];
  List<ArtistInfo> _allArtists = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isUiActive = true;
  AlbumInfoLocal _selectedAlbum;
  List<SongInfoLocal> _selectedAlbumSongs = [];
  SongInfoLocal _currentlyPlaying;
  int _currentSongPosition = 0;
  int _currentSongDuration = 0;

  List<SongInfoLocal> get allSongs => _allSongs;
  List<AlbumInfoLocal> get allAlbums => _allAlbums;
  List<ArtistInfo> get allArtists => _allArtists;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isUiActive => _isUiActive;
  AlbumInfoLocal get selectedAlbum => _selectedAlbum;
  List<SongInfoLocal> get selectedAlbumSongs => _selectedAlbumSongs;
  SongInfoLocal get currentlyPlaying => _currentlyPlaying;
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

  set allSongs(List<SongInfoLocal> allSongs){
    assert(allSongs != null);
    _allSongs = allSongs;
    _isLoading = false;
    notifyListeners();
  }

  set allAlbums(List<AlbumInfoLocal> allAlbums){
    assert(allAlbums != null);
    _allAlbums = allAlbums;
    _isLoading = false;
    notifyListeners();
  }

  findAllSongs({SongSortType sortType = SongSortType.SMALLER_TRACK_NUMBER}) async {
    _isLoading = true;
    notifyListeners();
    aq.getSongs(sortType: sortType).then((songsList) {
      _allSongs = songsList.map((e) => SongInfoLocal.fromSongInfo(e)).toList().where((element) => element.isMusic == true).toList();
      _isLoading = false;
      print('songs are loaded');
      notifyListeners();
      if(songsBox?.isOpen ?? false){
        print('songs box is open');
        if(!songsBox.containsKey('allSongs')){
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
      _allAlbums = albumList.map((e) => AlbumInfoLocal.fromAlbumInfo(e)).toList();
      _isLoading = false;
      print('albums loaded');
      notifyListeners();
      if(albumsBox?.isOpen ?? false){
        print('albums box is open');
        if(!albumsBox.containsKey('allAlbums')){
          albumsBox.put('allAlbums', allAlbums);
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
          _selectedAlbumSongs = songsList.map((e) => SongInfoLocal.fromSongInfo(e)).toList();
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
      _allArtists = artistsList;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print(err);
    });
  }

  initHive() async {
    var path = await getApplicationDocumentsDirectory();
    await Hive.initFlutter();
    Hive.init(path.path);
    Hive.registerAdapter(SongInfoLocalAdapter());
    Hive.registerAdapter(AlbumInfoLocalAdapter());
    await openHiveBoxes();
  }

  openHiveBoxes() async {
    songsBox = await Hive.openBox('songs');
    albumsBox = await Hive.openBox('albums');
  }
}
