import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:sizer/sizer.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  final dynamic Function(String?) onSave;

  const TrimmerView(this.file, {Key? key, required this.onSave})
      : super(key: key);
  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  int videoTimeLimit = 60;

  @override
  void initState() {
    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      videoTimeLimit = data?["fileConfiguration"]?["videoTimeLimit"] ?? 60;
    }

    super.initState();

    _loadVideo();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  _saveVideo() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: widget.onSave
      // onSave: (outputPath) {
      //   setState(() {
      //     _progressVisibility = false;
      //   });
      //   debugPrint('OUTPUT PATH: $outputPath');
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(
      //       builder: (context) => SelectedFileScreen(),
      //     ),
      //   );
      // }
      ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            TextButton(
                onPressed: _progressVisibility ? null : () => _saveVideo(),
                child: const Text("Save"))
          ],
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_MM_SS,
                      maxVideoLength: Duration(seconds: videoTimeLimit),
                      editorProperties: TrimEditorProperties(
                        borderPaintColor: Colors.yellow,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.yellow.shade800,
                      ),
                      areaProperties: TrimAreaProperties.edgeBlur(
                        thumbnailQuality: 10,
                      ),
                      showDuration: true,
                      onChangeStart: (value) => _startValue = value,
                      onChangeEnd: (value) => _endValue = value,
                      onChangePlaybackState: (value) =>
                          setState(() => _isPlaying = value),
                    ),
                  ),
                ),

                // ElevatedButton(
                //   onPressed: _progressVisibility ? null : () => _saveVideo(),
                //   child: const Text("SAVE"),
                // ),
                Expanded(
                  child: Stack(
                    children: [
                      VideoViewer(trimmer: _trimmer),
                      Center(
                        child: TextButton(
                          child: _isPlaying
                              ? Icon(
                                  Icons.pause_rounded,
                                  size: 50.sp,
                                )
                              : Icon(
                                  Icons.play_arrow_rounded,
                                  size: 50.sp,
                                ),
                          onPressed: () async {
                            bool playbackState =
                                await _trimmer.videoPlaybackControl(
                              startValue: _startValue,
                              endValue: _endValue,
                            );
                            setState(() => _isPlaying = playbackState);
                          },
                        ),
                      ),
                      Visibility(
                        visible: _progressVisibility,
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
