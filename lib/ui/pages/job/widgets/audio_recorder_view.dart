import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesometicks/ui/pages/job/functions/time_counter.dart';
import 'package:awesometicks/ui/pages/job/widgets/time_counter_widget.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:sizer/sizer.dart';

class AudioRecorderView extends StatefulWidget {
  final void Function(String path) onRecordingComplete;

  const AudioRecorderView({super.key, required this.onRecordingComplete});

  @override
  State<AudioRecorderView> createState() => _AudioRecorderViewState();
}

class _AudioRecorderViewState extends State<AudioRecorderView> {
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;

  bool isRecording = false;
  String audioPath = '';

  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  String get _durationText =>
      TimeCounterService.convertToMinutesSeconds(_duration?.toString() ?? '');

  String get _positionText =>
      TimeCounterService.convertToMinutesSeconds(_position?.toString() ?? '');

  late ValueNotifier<String> elapsedTimeNotifier;

  late TimeCounterService timeCounterService;

  int audioTimeLimit = 180;

  @override
  void initState() {
    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      audioTimeLimit = data?["fileConfiguration"]?["audioTimeLimit"] ?? 180;
    }

    elapsedTimeNotifier = ValueNotifier<String>("0:00");

    timeCounterService =
        TimeCounterService(elapsedTimeNotifier: elapsedTimeNotifier);

    audioRecord = AudioRecorder();
    audioPlayer = AudioPlayer();
    Future.delayed(Duration.zero, () {
      startRecording();
    });

    _initiliazeTempPlayer();
    super.initState();
  }

  void _initiliazeTempPlayer() {
    _playerState = audioPlayer.state;
    audioPlayer.getDuration().then((value) {
      setState(() {
        _duration = value;
      });
    });
    audioPlayer.getCurrentPosition().then((value) {
      setState(() {
        _position = value;
      });
    });
    _initStreams();
  }

  void _initStreams() {
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = audioPlayer.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    try {
      // Source urlSource = UrlSource(audioPath);

      DeviceFileSource fileSource = DeviceFileSource(audioPath);
      await audioPlayer.play(fileSource);
      setState(() => _playerState = PlayerState.playing);
    } catch (e) {
      if (!mounted) return;
      buildSnackBar(
        context: context,
        value: 'Error Play Recording $e',
      );
    }
  }

  Future<void> _pause() async {
    await audioPlayer.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await audioPlayer.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return ValueListenableBuilder(
        valueListenable: elapsedTimeNotifier,
        builder: (context, value, child) {
          int timeLimit = convertStringtoSeconds(value);

          if (timeLimit == audioTimeLimit) {
            stopRecording();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording) ...[
                Lottie.asset(
                  'assets/lotties/audio_record.json',
                  height: 70.sp,
                  width: 70.sp,
                ),
                TimeCounter(elapsedTimeNotifier: elapsedTimeNotifier),
                // const Text('Recording in progress...'),
                SizedBox(height: 20.sp),
                ElevatedButton(
                  onPressed: stopRecording,
                  child: const Text('Stop Recording'),
                ),
              ],
              if (!isRecording && audioPath.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // if (!_isPlaying)
                          Visibility(
                            visible: !_isPlaying,
                            child: IconButton(
                              key: const Key('temp_play_button'),
                              onPressed: _isPlaying ? null : _play,
                              iconSize: 24.sp,
                              icon: const Icon(Icons.play_arrow_rounded),
                              color: color,
                            ),
                          ),
                          // if (_isPlaying)
                          Visibility(
                            visible: _isPlaying,
                            child: IconButton(
                              key: const Key('temp_pause_button'),
                              onPressed: _isPlaying ? _pause : null,
                              iconSize: 24.sp,
                              icon: const Icon(Icons.pause_rounded),
                              color: color,
                            ),
                          ),
                          Flexible(
                            child: SliderTheme(
                              data: const SliderThemeData(
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 10),
                              ),
                              child: Slider(
                                onChanged: (value) {
                                  final duration = _duration;
                                  if (duration == null) {
                                    return;
                                  }
                                  final position =
                                      value * duration.inMilliseconds;
                                  audioPlayer.seek(
                                    Duration(milliseconds: position.round()),
                                  );
                                },
                                value: (_position != null &&
                                        _duration != null &&
                                        _position!.inMilliseconds > 0 &&
                                        _position!.inMilliseconds <
                                            _duration!.inMilliseconds)
                                    ? _position!.inMilliseconds /
                                        _duration!.inMilliseconds
                                    : 0.0,
                              ),
                            ),
                          ),
                          Text(
                            _position != null
                                ? '$_positionText / $_durationText'
                                : _duration != null
                                    ? _durationText
                                    : '0:00 / ${elapsedTimeNotifier.value}',
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (!isRecording && audioPath.isNotEmpty) ...[
                SizedBox(height: 12.sp),
                OutlinedButton(
                  onPressed: () {
                    _stop();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                SizedBox(height: 8.sp),
                ElevatedButton(
                  onPressed: () {
                    widget.onRecordingComplete(audioPath);
                    Navigator.pop(context);
                  },
                  child: const Text('Select Recording'),
                ),
              ]
            ],
          );
        });
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        final path = await _getPath();

        await audioRecord.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 48000,
            sampleRate: 22050,
            numChannels: 1,
          ),
          path: path,
        );
        setState(() {
          isRecording = true;
        });

        timeCounterService.startOrStopTimer();
      }
    } catch (e) {
      if (!mounted) return;
      buildSnackBar(
        context: context,
        value: 'Error Start Recording $e',
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });

      timeCounterService.startOrStopTimer();
    } catch (e) {
      if (!mounted) return;
      buildSnackBar(
        context: context,
        value: 'Error Stop Recording $e',
      );
    }
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(
      dir.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  int convertStringtoSeconds(String timeStr) {
    List<String> parts = timeStr.split(':');

    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);

    int totalSeconds = (minutes * 60) + seconds;

    return totalSeconds;
  }
}
