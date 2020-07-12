import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class MusicFinder with ChangeNotifier {
  final FlutterAudioQuery aq = FlutterAudioQuery();

  List<SongInfo> _allSongs = [];
  List<AlbumInfo> _allAlbums = [];
  List<ArtistInfo> _allArtists = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  SongInfo _playing;
  AudioPlayer _audioPlayer = AudioPlayer();
  double _currentSongDuration = 0.0;
  double _currentSongPosition = 0.0;
  SongInfo _upNext;

  List<SongInfo> get allSongs => _allSongs;
  List<AlbumInfo> get allAlbums => _allAlbums;
  List<ArtistInfo> get allArtists => _allArtists;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  SongInfo get currentlyPlaying => _playing;
  AudioPlayer get audioPlayer => _audioPlayer;
  double get currentSongDuration => _currentSongDuration;
  double get currentSongPosition => _currentSongPosition;
  SongInfo get upNext => _upNext;

  set isPlaying(bool newVal) {
    assert(newVal != null);
    _isPlaying = newVal;
    notifyListeners();
  }

  set currentlyPlaying(SongInfo newSong) {
    assert(newSong != null);
    _playing = newSong;
    currentSongDuration = double.parse(newSong.duration);
    isPlaying = true;
    notifyListeners();
  }

  set upNext(SongInfo newSong){
    assert(newSong != null);
    _upNext = newSong;
    notifyListeners();
  }

  set currentSongPosition(double newPos) {
    assert(newPos != null);
    _currentSongPosition = newPos;
    notifyListeners();
  }

  set currentSongDuration(double newDur) {
    assert(newDur != null);
    _currentSongDuration = newDur;
    notifyListeners();
  }

  fetchSongs({SongSortType sortType = SongSortType.DISPLAY_NAME}) async {
    _allSongs = await aq.getSongs(sortType: sortType);
    notifyListeners();
  }

  fetchAlbums({AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    _allAlbums = await aq.getAlbums(sortType: sortType);
    notifyListeners();
  }

  fetchArtists({ArtistSortType sortType = ArtistSortType.DEFAULT}) async {
    _allArtists = await aq.getArtists(sortType: sortType);
    notifyListeners();
  }

  findAllSongs({SongSortType sortType = SongSortType.DISPLAY_NAME}) {
    aq.getSongs(sortType: sortType).then((songsList) {
      _allSongs = songsList;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print(err);
    });
  }

  findAllAlbums({AlbumSortType sortType = AlbumSortType.DEFAULT}) {
    aq.getAlbums(sortType: sortType).then((albumList) {
      _allAlbums = albumList;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print(err);
    });
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

  playSong(SongInfo song) async {
    assert(song != null);
    assert(audioPlayer != null);
    audioPlayer.setReleaseMode(ReleaseMode.STOP);
    int res = await audioPlayer.play(song.filePath, isLocal: true);
    if (res == 1) {
      getPlayingSongPosition();
      print("Playing: ${song.title}");
    }
    audioPlayer.onAudioPositionChanged.listen((event) {
      if ((currentSongDuration - event.inMilliseconds < 10000 && upNext == null) || (upNext == currentlyPlaying && currentSongDuration - event.inMilliseconds < 10000)){
        // TODO: fix loop when song is finished.
        upNext = allSongs[Random.secure().nextInt(allSongs.length)];
        print("Up next: ${upNext.title}");
      }
    });
    audioPlayer.onPlayerCompletion.listen((event) {
        print('song finished');
        Future.delayed(Duration(seconds: 5));
        currentSongPosition = 0.0;
        currentlyPlaying = upNext;
        notifyListeners();
        playSong(currentlyPlaying);
    });
  }

  pauseSong() async {
    assert(audioPlayer != null);
    await audioPlayer.pause();
  }

  resumeSong() async {
    assert(audioPlayer != null);
    await audioPlayer.resume();
  }

  seek({@required int duration}) async {
    assert(audioPlayer != null);
    assert(duration != null);
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      if (duration == 0) {
        await audioPlayer.seek(Duration(seconds: 0));
      } else {
        await audioPlayer.seek(Duration(seconds: duration));
      }
    }
  }

  getPlayingSongPosition() async {
    assert(audioPlayer != null);
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.onAudioPositionChanged.listen((event) {
        currentSongPosition = event.inMilliseconds.toDouble();
        notifyListeners();
      });
    }
  }
}
