import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesometicks/main.dart';
import 'package:awesometicks/ui/pages/job/widgets/audio_player_view.dart';
import 'package:awesometicks/ui/pages/job/widgets/audio_recorder_view.dart';
import 'package:awesometicks/ui/shared/models/file_selector_model.dart';
import 'package:awesometicks/ui/shared/widgets/attachment_selector_chip.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:files_viewer/core/models/file_data_model.dart';
import 'package:files_viewer/screens/image_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:video_compress/video_compress.dart';
import '../../ui/shared/widgets/custom_snackbar.dart';
import 'package:path/path.dart' as path;
import '../schemas/jobs_schemas.dart';
import 'graphql_services.dart';

class FileServices {
// =========Share Image=============================================================================

  void shareImage({
    required String filePath,
  }) {
    Share.shareXFiles([XFile(filePath)]);
  }

// =======Download Image==============================================================================

  void downloadImagesToGallery({
    required String imagePath,
    required BuildContext context,
  }) async {
    var status = await Permission.photos.status;

    BuildContext myAppContext = MyApp.navigatorKey.currentState!.context;

    if (status == PermissionStatus.permanentlyDenied) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: myAppContext,
        builder: (context) {
          return AlertDialog(
            title: const Text("Permission is disabled"),
            content: const Text("Select Photos. Tap 'All photos'"),
            actions: [
              TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: const Text("Open app settings"))
            ],
          );
        },
      );
      return;
    }

    bool? isSuccess =
        await GallerySaver.saveImage(imagePath, albumName: "AwesomeTicks");

    if (isSuccess == null || !isSuccess) {
      // ignore: use_build_context_synchronously
      buildSnackBar(
        context: myAppContext,
        value: "Image download failed",
      );
    } else {
      // ignore: use_build_context_synchronously
      buildSnackBar(
        context: myAppContext,
        value: "Image downloaded successfully",
      );
    }
  }

// ========================================================================================================

  void openFile(File file, BuildContext context) async {
    BuildContext myAppContext = MyApp.navigatorKey.currentState!.context;

    try {
      var result = await OpenFile.open(file.path);
      // ignore: use_build_context_synchronously
      if (result.type == ResultType.noAppToOpen) {
        // ignore: use_build_context_synchronously
        buildSnackBar(
          context: myAppContext,
          value: "No APP found to open this file。",
        );
      } else if (result.type == ResultType.error) {
        // ignore: use_build_context_synchronously
        buildSnackBar(
          context: myAppContext,
          value: "Something went wrong",
        );
      } else if (result.type == ResultType.permissionDenied) {
        // ignore: use_build_context_synchronously
        buildSnackBar(
          context: myAppContext,
          value: "Permission denied",
        );
      }
    } catch (e) {
      buildSnackBar(
        context: myAppContext,
        value: "Can't open this file",
      );
      // TODO
    }
  }

// ==================================================================================
  // getAttached filesh.

  Future<File?> pickImage(
    BuildContext context, {
    bool isCamera = false,
  }) async {
    BuildContext myAppContext = MyApp.navigatorKey.currentState!.context;

    final ImagePicker picker = ImagePicker();

    bool enableAudioVideo = false;

    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      enableAudioVideo =
          data?["fileConfiguration"]?["enableAudioVideo"] ?? false;
    }

    try {
      if (!isCamera && Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        bool isAndriod13 = androidInfo.version.sdkInt >= 33;

        var status = isAndriod13
            ? await Permission.photos.request()
            : await Permission.storage.request();

        if (status.isGranted) {
          XFile? xFile;

          if (enableAudioVideo) {
            xFile = await picker.pickMedia();
          } else {
            xFile = await picker.pickImage(
              source: ImageSource.gallery,
            );
          }

          if (xFile != null) {
            FileType fileType = getFileType(path.extension(xFile.path));

            if (fileType == FileType.video) {
              try {
                MediaInfo? info = await VideoCompress.compressVideo(
                  xFile.path,
                  includeAudio: true,
                  quality: VideoQuality.Res960x540Quality,
                );

                String? compressedVideoFilePath = info?.path;

                if (compressedVideoFilePath != null) {
                  return File(compressedVideoFilePath);
                }
              } catch (e) {
                buildSnackBar(
                    context: context, value: "Error compressing video file");

                return null;
              }
            } else {
              return File(xFile.path);
            }
          }
          return null;
        } else {
          buildSnackBar(
            // ignore: use_build_context_synchronously
            context: myAppContext,
            value: "Enable Files and Media permission in settings",
            snackBarAction: SnackBarAction(
              label: "Enable",
              onPressed: () {
                openAppSettings();
              },
            ),
          );
        }

        return null;
      }
      XFile? xFile;
      if (isCamera) {
        xFile = await picker.pickImage(
          source: ImageSource.camera,
        );
      } else {
        if (enableAudioVideo) {
          xFile = await picker.pickMedia();
        } else {
          xFile = await picker.pickImage(
            source: ImageSource.gallery,
          );
        }
      }

      if (xFile != null) {
        FileType fileType = getFileType(path.extension(xFile.path));

        if (fileType == FileType.video) {
          try {
            MediaInfo? info = await VideoCompress.compressVideo(
              xFile.path,
              includeAudio: true,
              quality: VideoQuality.Res960x540Quality,
            );

            String? compressedVideoFilePath = info?.path;

            if (compressedVideoFilePath != null) {
              return File(compressedVideoFilePath);
            }
          } catch (e) {
            buildSnackBar(
                context: context, value: "Error compressing video file");
          }
        } else {
          return File(xFile.path);
        }
      }
    } catch (e) {
      if (e is PlatformException) {
        if (e.code == "photo_access_denied" ||
            e.code == "camera_access_denied") {
          String data;

          if (e.code == "camera_access_denied") {
            data = "Camera";
          } else {
            if (Platform.isIOS) {
              data = "Photos";
            } else {
              data = "Files and Media";
            }
          }

          // openAppSettings();

          buildSnackBar(
            // ignore: use_build_context_synchronously
            context: myAppContext,
            value: "Enable $data permission in settings",
            snackBarAction: SnackBarAction(
              label: "Enable",
              onPressed: () {
                openAppSettings();
              },
            ),
          );
        }
      }
    }
    return null;
  }

//  ====================================================================================================
// Get video file.

  Future<File?> getVideo(
    BuildContext context, {
    bool isCamera = false,
  }) async {
    int videoTimeLimit = 60;

    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      videoTimeLimit = data?["fileConfiguration"]?["videoTimeLimit"] ?? 60;
    }

    final ImagePicker picker = ImagePicker();

    if (isCamera) {
      XFile? xFile = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: videoTimeLimit),
      );

      if (xFile == null) {
        return null;
      }

      try {
        MediaInfo? info = await VideoCompress.compressVideo(
          xFile.path,
          includeAudio: true,
          quality: VideoQuality.Res960x540Quality,
        );

        String? compressedVideoFilePath = info?.path;

        if (compressedVideoFilePath != null) {
          return File(compressedVideoFilePath);
        }
      } catch (e) {
        buildSnackBar(context: context, value: "Error compressing video file");
      }

      // return File(xFile.path);
    }

    XFile? xFile;
    try {
      xFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: videoTimeLimit),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (xFile == null) {
      return null;
    }

    return File(xFile.path);
  }

//==========================================================================

  Future<File> convertToFile({
    required String base64Encoded,
    required String fileName,
  }) async {
    Uint8List decodedbytes = base64Decode(base64Encoded);

    //   // Write the bytes to a file
    //   File('decoded.txt').writeAsBytesSync(bytes);
    final directory = await getApplicationDocumentsDirectory();

    var extension = path.extension(fileName);

    if (extension == '.xls') {
      fileName = '${path.withoutExtension(fileName)}.xlsx';
    }

    File file =
        await File("${directory.path}/$fileName").writeAsBytes(decodedbytes);

    return file;
  }

// ==============================================================================

  Future<Map?> getOneFilePreview({
    required String jobAttachmentFilePath,
  }) async {
    var jobAttachmentResult = await GraphqlServices().performQuery(
      query: JobsSchemas.getFileForPreview,
      variables: {
        "filePath": jobAttachmentFilePath,
        "traverseFiles": true,
      },
    );

    Map? attachmentsData =
        jobAttachmentResult.data?['getFileForPreview']['data'];

    return attachmentsData;
  }

  /// show attchment bottom sheet
  void showAttachmentBottomSheet(
    BuildContext context, {
    required List<FileSelectorModel> attachmentSelectorList,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 25.0,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Attachment',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.sp),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 40,
                  runSpacing: 25,
                  children:
                      List.generate(attachmentSelectorList.length, (index) {
                    return AttachmentSelectorChip(
                      fileSelectorModel: attachmentSelectorList[index],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// function to navigate to image editor screen
  Future<File?> navigateToImageEditor({
    required BuildContext context,
    required File file,
  }) async {
    /// Create a Completer to return the result
    final Completer<File?> completer = Completer<File?>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ImageEditorWidget(
            file: file,
            onImageEditingComplete: (bytes) async {
              // /Convert the image bytes to a File
              File selectedFile = await FileServices().convertToFile(
                base64Encoded: base64Encode(bytes),
                fileName: path.basename(file.path),
              );

              /// Complete the Future with the selected file
              completer.complete(selectedFile);
            },
          );
        },
      ),
    );

    /// Return the Future from the Completer
    return completer.future;
  }

  /// show audio recorder bottom sheet
  Future<String?> showAudioRecorderPopup(BuildContext context) async {
    // /Create a Completer to return the result
    final Completer<String?> completer = Completer<String?>();

    /// Close any existing bottom sheet
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: AudioRecorderView(
            onRecordingComplete: (String path) {
              /// Complete the Future with the path of the recorded audio file
              completer.complete(path);
            },
          ),
        );
      },
    );

    /// Return the Future from the Completer
    return completer.future;
  }

  Future<void> showAudioPlayerBottomSheet(
    BuildContext context,
    String filePath,
  ) async {
    final player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);

    await player.setSource(DeviceFileSource(filePath)).whenComplete(() {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AudioPlayerView(player: player),
              ],
            ),
          );
        },
      ).whenComplete(() {
        player.stop();
      });
    });
  }

  FileType getFileType(String key) {
    switch (key) {
      case ".pdf":
        return FileType.pdf;

      case ".xls":
        return FileType.xls;

      case ".jpeg":
      case ".png":
      case ".jpg":
        return FileType.image;

      case '.mp4':
      case '.mkv':
      case '.mov':
      case '.avi':
      case '.webm':
      case '.wmv':
        return FileType.video;

      default:
        return FileType.other;
    }
  }
}
