import 'package:audio_service/audio_service.dart';

final playCtrl = MediaControl(label: 'Play',
    action: MediaAction.play,
    androidIcon: 'drawable/ic_play_arrow');
final pauseCtrl = MediaControl(label: 'Pause',
    action: MediaAction.pause,
    androidIcon: 'drawable/ic_pause');
final skipToNextCtrl = MediaControl(label: 'Skip To Next',
    action: MediaAction.skipToNext,
    androidIcon: 'drawable/ic_skip_next');
final skipToPrevCtrl = MediaControl(label: 'Skip To Previous',
    action: MediaAction.skipToPrevious,
    androidIcon: 'drawable/ic_skip_previous');