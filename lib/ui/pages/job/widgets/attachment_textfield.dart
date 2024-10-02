// ========================================================================================
// buildAttachmentAndTextfield

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/ui/pages/job/widgets/video_trimmer_screen.dart';
import 'package:awesometicks/ui/shared/models/file_selector_model.dart';
import 'package:files_viewer/files_viewer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/models/hive db/list_jobs_model.dart';
import '../../../../core/models/hive db/syncing_local_db.dart';
import '../../../../core/schemas/jobs_schemas.dart';
import '../../../../core/services/internet_services.dart';
import '../../../../core/services/jobs/jobs_services.dart';
import '../../../../utils/themes/colors.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'comment_textfield.dart';
import 'package:path/path.dart' as path;

import 'package:collection/collection.dart';

Widget buildChecklistCommentAttachmentAndTextfield(
  BuildContext context, {
  required int jobId,
  required String jobDomain,
  required int checklistId,
  required Function(void Function()) setState,
}) {
  return ChecklistCommentAttachmentTextfield(
    jobId: jobId,
    jobDomain: jobDomain,
    checklistId: checklistId,
    refreshState: setState,
  );

  // return StatefulBuilder(builder: (context, refreshState) {
  //   bool hide = attachedFile == null;

  //   return Column(
  //     children: [
  //       Stack(
  //         children: [
  //           AnimatedContainer(
  //             duration: const Duration(milliseconds: 500),
  //             height: hide ? 0 : 20.h,
  //             width: hide ? 0 : 20.h,
  //             decoration: const BoxDecoration(
  //               color: kWhite,
  //             ),
  //             child: hide ? const SizedBox() : Image.file(attachedFile!),
  //           ),
  //           Positioned(
  //             top: 5.sp, // Adjust the top position as needed
  //             right: 5.sp, // Adjust the right position as needed
  //             child: GestureDetector(
  //               onTap: () {
  //                 refreshState(
  //                   () {
  //                     attachedFile = null;
  //                   },
  //                 );
  //               },
  //               child: Icon(
  //                 Icons.cancel,
  //                 color: Colors.red.shade700,
  //                 size: 24,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       Container(
  //         height: 38.sp,
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(8.sp),
  //             color: kWhite,
  //             border: Border.all(color: Colors.grey.shade300)),
  //         child: ValueListenableBuilder(
  //             valueListenable: commentAddingLoadingNotifier,
  //             builder: (context, value, _) {
  //               if (value) {
  //                 return Center(
  //                   child: Padding(
  //                     padding: EdgeInsets.all(10.sp),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         LoadingIosAndroidWidget(
  //                           radius: 8.sp,
  //                         ),
  //                         SizedBox(
  //                           width: 5.sp,
  //                         ),
  //                         const Text("Posting comment"),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               }

  //               return Row(
  //                 children: [
  //                   IconButton(
  //                     onPressed: () {
  //                       PlatformServices().showDialogWithDialogActions(
  //                         context,
  //                         title: "Attach Images",
  //                         list: [
  //                           DialogActionModel(
  //                             child: const Text(
  //                               "Take Photo",
  //                             ),
  //                             onPressed: () async {
  //                               Navigator.of(context).pop();

  //                               var file = await FileServices().pickImage(
  //                                 context,
  //                                 isCamera: true,
  //                               );

  //                               if (file != null) {
  //                                 refreshState(
  //                                   () {
  //                                     attachedFile = file;
  //                                   },
  //                                 );
  //                               }
  //                             },
  //                           ),
  //                           DialogActionModel(
  //                             child: const Text("Choose Image"),
  //                             onPressed: () async {
  //                               Navigator.of(context).pop();

  //                               var file = await FileServices().pickImage(
  //                                 context,
  //                               );

  //                               if (file != null) {
  //                                 refreshState(
  //                                   () {
  //                                     attachedFile = file;
  //                                   },
  //                                 );
  //                               }
  //                             },
  //                           ),
  //                           DialogActionModel(
  //                             child: const Text("Cancel"),
  //                             onPressed: () {
  //                               Navigator.of(context).pop();
  //                             },
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                     icon: const Icon(
  //                       Icons.attachment,
  //                     ),
  //                   ),
  //                   VerticalDivider(
  //                     width: 1.sp,
  //                     // thickness: 1,
  //                     color: Colors.grey,
  //                   ),
  //                   Form(
  //                     key: formKey,
  //                     child: BuildCommentTextfield(
  //                       onChanged: (value) {
  //                         sendButtonNotifier.value = value.trim().isNotEmpty;
  //                       },
  //                       controller: commentController,
  //                       hintText: "Enter comment",
  //                     ),
  //                   ),
  //                   VerticalDivider(
  //                     width: 1.sp,
  //                     // thickness: 1,
  //                     color: Colors.grey,
  //                   ),
  //                   ValueListenableBuilder(
  //                     valueListenable: sendButtonNotifier,
  //                     builder: (context, value, child) => IconButton(
  //                       onPressed: value
  //                           ? () async {
  //                               bool valid = formKey.currentState!.validate();

  //                               if (valid) {
  //                                 bool hasInternet = await InterNetServices()
  //                                     .checkInternetConnectivity();

  //                                 commentAddingLoadingNotifier.value = true;

  //                                 if (!hasInternet) {
  //                                   var syncBox = Hive.box<SyncingLocalDb>(
  //                                       SyncingLocalDb.boxName);
  //                                   var jobBox = jobDetailsDbgetBox();

  //                                   // syncdbgetBox();
  //                                   // var jobBox =

  //                                   JobDetailsDb? jobDetailsDb = jobBox.values
  //                                       .singleWhere(
  //                                           (element) => element.id == jobId);

  //                                   ChecklistDb? checklistDb = jobDetailsDb
  //                                       .checklistDb
  //                                       ?.singleWhereOrNull((element) =>
  //                                           element.id == checklistId);

  //                                   var checklistComments =
  //                                       checklistDb?.comments ?? [];

  //                                   String userName = userData.userName;

  //                                   String domain = userData.domain;

  //                                   checklistComments.add(
  //                                     Comments(
  //                                       comment: commentController.text.trim(),
  //                                       commentBy: "$userName@$domain",
  //                                       commentTime: now.millisecondsSinceEpoch,
  //                                       replies: [],
  //                                     ),
  //                                   );

  //                                   Map<String, dynamic> payload = {
  //                                     "replyId":
  //                                         "$userName@$domain/${now.millisecondsSinceEpoch}",
  //                                     "data": {
  //                                       "checkListComment": {
  //                                         "checklistId": checklistId,
  //                                         "comment": {
  //                                           "comment":
  //                                               commentController.text.trim(),
  //                                         },
  //                                         "jobId": jobId,
  //                                       }
  //                                     }
  //                                   };

  //                                   if (attachedFile != null) {
  //                                     Uint8List uint8List =
  //                                         attachedFile!.readAsBytesSync();

  //                                     payload['fileData'] = {
  //                                       "attachedFiile": uint8List,
  //                                       "filePath":
  //                                           "/jobs/$jobDomain/$jobId/checklist/$checklistId/comments/",
  //                                       // "/jobs/${widget.jobId}/checklist/comments/",
  //                                     };

  //                                     setState(() {});
  //                                     attachedFile = null;
  //                                   }

  //                                   syncBox.add(
  //                                     SyncingLocalDb(
  //                                       payload: payload,
  //                                       generatedTime: DateTime.now()
  //                                           .millisecondsSinceEpoch,
  //                                       graphqlMethod:
  //                                           JobsSchemas.addChecklistComment,
  //                                     ),
  //                                   );

  //                                   commentController.clear();
  //                                   sendButtonNotifier.value = false;
  //                                   commentAddingLoadingNotifier.value = false;

  //                                   setState(() {});

  //                                   return;
  //                                 }

  //                                 var result =
  //                                     // ignore: use_build_context_synchronously
  //                                     await GraphqlServices().performMutation(
  //                                   context: context,
  //                                   query: JobsSchemas.addChecklistComment,
  //                                   variables: {
  //                                     "checkListComment": {
  //                                       "checklistId": checklistId,
  //                                       "comment": {
  //                                         "comment":
  //                                             commentController.text.trim(),
  //                                       },
  //                                       "jobId": jobId
  //                                     }
  //                                   },
  //                                 );

  //                                 if (result.hasException) {
  //                                   // ignore: use_build_context_synchronously
  //                                   buildSnackBar(
  //                                       context: context,
  //                                       value: "Something went wrong !!");
  //                                   commentAddingLoadingNotifier.value = false;

  //                                   return;
  //                                 }

  //                                 // print(result.data);

  //                                 Map<String, dynamic>? map =
  //                                     result.data!['addCheckListComment'];

  //                                 int? id = map?['id'];

  //                                 if (id == null) {
  //                                   // ignore: use_build_context_synchronously
  //                                   buildSnackBar(
  //                                       context: context,
  //                                       value: "Something went wrong !!");
  //                                   return;
  //                                 }

  //                                 if (attachedFile != null) {
  //                                   // ignore: use_build_context_synchronously
  //                                   await JobsServices().attachFiles(
  //                                       context: context,
  //                                       attachedFile: attachedFile!,
  //                                       filePath:
  //                                           "/jobs/$jobDomain/$jobId/checklist/$checklistId/comments/$id");
  //                                 }

  //                                 commentController.clear();

  //                                 sendButtonNotifier.value = false;
  //                                 commentAddingLoadingNotifier.value = false;

  //                                 attachedFile = null;

  //                                 setState(() {});
  //                               }
  //                             }
  //                           : null,
  //                       icon: const Icon(
  //                         Icons.send,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             }),
  //       ),
  //     ],
  //   );
  // });
}

class ChecklistCommentAttachmentTextfield extends StatefulWidget {
  final int jobId;
  final String jobDomain;
  final int checklistId;
  final Function(void Function()) refreshState;

  const ChecklistCommentAttachmentTextfield({
    super.key,
    required this.jobId,
    required this.jobDomain,
    required this.checklistId,
    required this.refreshState,
  });

  @override
  State<ChecklistCommentAttachmentTextfield> createState() =>
      _ChecklistCommentAttachmentTextfieldState();
}

class _ChecklistCommentAttachmentTextfieldState
    extends State<ChecklistCommentAttachmentTextfield> {
  // bool isAndroid = Platform.isAndroid;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController commentController = TextEditingController();

  final DateTime now = DateTime.now();

  final ValueNotifier sendButtonNotifier = ValueNotifier(false);

  final ValueNotifier commentAddingLoadingNotifier = ValueNotifier(false);

  final UserDataSingleton userData = UserDataSingleton();

  late final ValueNotifier<File?> attachedFileNotifier;

  List<FileSelectorModel> attachmentSelectorList = [];

  @override
  void initState() {
    bool enableAudioVideo = false;

    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      enableAudioVideo =
          data?["fileConfiguration"]?["enableAudioVideo"] ?? false;
    }
    attachedFileNotifier = ValueNotifier<File?>(null);
    attachmentSelectorList = [
      FileSelectorModel(
        title: 'Photo',
        icon: 'camera',
        onTap: () async {
          accessCamera();
        },
      ),
      if (enableAudioVideo)
        FileSelectorModel(
          title: 'Video',
          icon: 'video',
          onTap: () {
            accessVideo();
          },
        ),
      FileSelectorModel(
        title: 'Gallery',
        icon: 'gallery',
        onTap: () {
          accessGallery();
        },
      ),
      if (enableAudioVideo)
        FileSelectorModel(
          title: 'Audio',
          icon: 'audio',
          onTap: () {
            accessAudio();
          },
        ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<File?>(
        valueListenable: attachedFileNotifier,
        builder: (context, attachedFile, _) {
          bool hide = attachedFile == null;

          return Column(
            children: [
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: hide ? 0 : 20.h,
                    width: hide ? 0 : 20.h,
                    decoration: const BoxDecoration(
                      color: kWhite,
                    ),
                    child: buildThumNail(attachedFile),
                  ),
                  Positioned(
                    top: 5.sp, // Adjust the top position as needed
                    right: 5.sp, // Adjust the right position as needed
                    child: GestureDetector(
                      onTap: () {
                        attachedFileNotifier.value = null;
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 38.sp,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    color: kWhite,
                    border: Border.all(color: Colors.grey.shade300)),
                child: ValueListenableBuilder(
                    valueListenable: commentAddingLoadingNotifier,
                    builder: (context, value, _) {
                      if (value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingIosAndroidWidget(
                                  radius: 8.sp,
                                ),
                                SizedBox(
                                  width: 5.sp,
                                ),
                                const Text("Posting comment"),
                              ],
                            ),
                          ),
                        );
                      }

                      return Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              FileServices().showAttachmentBottomSheet(
                                context,
                                attachmentSelectorList: attachmentSelectorList,
                              );
                            },
                            icon: const Icon(
                              Icons.attachment,
                            ),
                          ),
                          VerticalDivider(
                            width: 1.sp,
                            // thickness: 1,
                            color: Colors.grey,
                          ),
                          Form(
                            key: formKey,
                            child: BuildCommentTextfield(
                              onChanged: (value) {
                                sendButtonNotifier.value =
                                    value.trim().isNotEmpty;
                              },
                              controller: commentController,
                              hintText: "Enter comment",
                            ),
                          ),
                          VerticalDivider(
                            width: 1.sp,
                            // thickness: 1,
                            color: Colors.grey,
                          ),
                          ValueListenableBuilder(
                            valueListenable: sendButtonNotifier,
                            builder: (context, value, child) => IconButton(
                              onPressed: value
                                  ? () async {
                                      bool valid =
                                          formKey.currentState!.validate();

                                      if (valid) {
                                        bool hasInternet =
                                            await InterNetServices()
                                                .checkInternetConnectivity();

                                        commentAddingLoadingNotifier.value =
                                            true;

                                        if (!hasInternet) {
                                          var syncBox =
                                              Hive.box<SyncingLocalDb>(
                                                  SyncingLocalDb.boxName);
                                          var jobBox = jobDetailsDbgetBox();

                                          // syncdbgetBox();
                                          // var jobBox =

                                          JobDetailsDb? jobDetailsDb = jobBox
                                              .values
                                              .singleWhere((element) =>
                                                  element.id == widget.jobId);

                                          ChecklistDb? checklistDb =
                                              jobDetailsDb.checklistDb
                                                  ?.singleWhereOrNull(
                                                      (element) =>
                                                          element.id ==
                                                          widget.checklistId);

                                          int? checklistIndex = jobDetailsDb
                                              .checklistDb
                                              ?.indexWhere((element) =>
                                                  element.id ==
                                                  widget.checklistId);

                                          var checklistComments =
                                              checklistDb?.comments ?? [];

                                          String userName = userData.userName;

                                          String domain = userData.domain;

                                          checklistComments.add(
                                            Comments(
                                              comment:
                                                  commentController.text.trim(),
                                              commentBy: "$userName@$domain",
                                              commentTime:
                                                  now.millisecondsSinceEpoch,
                                              replies: [],
                                            ),
                                          );

                                          if (checklistIndex != null) {
                                            jobDetailsDb
                                                .checklistDb?[checklistIndex]
                                                .comments = checklistComments;

                                            int jobIndex = jobBox.values
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.id == widget.jobId);

                                            jobBox.putAt(
                                                jobIndex, jobDetailsDb);
                                          }

                                          Map<String, dynamic> payload = {
                                            "replyId":
                                                "$userName@$domain/${now.millisecondsSinceEpoch}",
                                            "data": {
                                              "checkListComment": {
                                                "checklistId":
                                                    widget.checklistId,
                                                "comment": {
                                                  "comment": commentController
                                                      .text
                                                      .trim(),
                                                },
                                                "jobId": widget.jobId,
                                              }
                                            }
                                          };

                                          if (attachedFile != null) {
                                            Uint8List uint8List =
                                                attachedFile.readAsBytesSync();

                                            payload['fileData'] = {
                                              "attachedFiile": uint8List,
                                              "filePath":
                                                  "/jobs/${widget.jobDomain}/${widget.jobId}/checklist/${widget.checklistId}/comments/",
                                              // "/jobs/${widget.jobId}/checklist/comments/",
                                            };

                                            widget.refreshState(() {});
                                            attachedFileNotifier.value = null;
                                          }

                                          syncBox.add(
                                            SyncingLocalDb(
                                              payload: payload,
                                              generatedTime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              graphqlMethod: JobsSchemas
                                                  .addChecklistComment,
                                            ),
                                          );

                                          commentController.clear();
                                          sendButtonNotifier.value = false;
                                          commentAddingLoadingNotifier.value =
                                              false;

                                          widget.refreshState(() {});

                                          return;
                                        }

                                        var result =
                                            // ignore: use_build_context_synchronously
                                            await GraphqlServices()
                                                .performMutation(
                                          context: context,
                                          query:
                                              JobsSchemas.addChecklistComment,
                                          variables: {
                                            "checkListComment": {
                                              "checklistId": widget.checklistId,
                                              "comment": {
                                                "comment": commentController
                                                    .text
                                                    .trim(),
                                              },
                                              "jobId": widget.jobId
                                            }
                                          },
                                        );

                                        if (result.hasException) {
                                          // ignore: use_build_context_synchronously
                                          buildSnackBar(
                                              context: context,
                                              value: "Something went wrong !!");
                                          commentAddingLoadingNotifier.value =
                                              false;

                                          return;
                                        }

                                        // print(result.data);

                                        Map<String, dynamic>? map =
                                            result.data!['addCheckListComment'];

                                        int? id = map?['id'];

                                        if (id == null) {
                                          // ignore: use_build_context_synchronously
                                          buildSnackBar(
                                              context: context,
                                              value: "Something went wrong !!");
                                          return;
                                        }

                                        if (attachedFile != null) {
                                          // ignore: use_build_context_synchronously
                                          await JobsServices().attachFiles(
                                              context: context,
                                              attachedFile: attachedFile,
                                              filePath:
                                                  "/jobs/${widget.jobDomain}/${widget.jobId}/checklist/${widget.checklistId}/comments/$id");
                                        }

                                        commentController.clear();

                                        sendButtonNotifier.value = false;

                                        commentAddingLoadingNotifier.value =
                                            false;

                                        attachedFileNotifier.value = null;

                                        widget.refreshState(() {});
                                      }
                                    }
                                  : null,
                              icon: const Icon(
                                Icons.send,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          );
        });
  }

  Widget buildThumNail(File? attachedFile) {
    if (attachedFile == null) {
      return const SizedBox.shrink();
    }

    // Get the file extension and convert it to lowercase
    String type = attachedFile.path.split('.').last.toLowerCase();
    const double thumbnailHeight = 100.0;
    const double thumbnailWidth = 50.0;

    // Define the container for the thumbnail
    Widget thumbnail;

    // Determine the type of file and create the appropriate thumbnail widget
    switch (type) {
      case 'mp4':
      case 'mkv':
      case 'mov':
      case 'avi':
      case 'webm':
      case 'wmv':
        thumbnail = const Icon(Icons.video_file);
        break;
      case 'mp3':
      case 'm4a':
      case 'wav':
      case 'ogg':
        thumbnail = const Icon(Icons.audio_file);
        break;
      case 'jpeg':
      case 'jpg':
      case 'png':
      case 'gif':
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageEditorWidget(
                  file: attachedFile,
                  onImageEditingComplete: (bytes) async {
                    attachedFileNotifier.value =
                        await FileServices().convertToFile(
                      base64Encoded: base64Encode(bytes),
                      fileName: path.basename(attachedFile.path),
                    );
                  },
                ),
              ),
            );
          },
          child: Image.file(attachedFile),
        );
      default:
        return const SizedBox.shrink();
    }

    return Container(
      height: thumbnailHeight,
      width: thumbnailWidth,
      color: Colors.black,
      alignment: Alignment.center,
      child: thumbnail,
    );
  }

  Future<void> accessCamera() async {
    Navigator.of(context).pop();

    var file = await FileServices().pickImage(
      context,
      isCamera: true,
    );

    if (file != null) {
      if (!mounted) return;
      attachedFileNotifier.value = await FileServices().navigateToImageEditor(
        context: context,
        file: file,
      );
    }
  }

  Future<void> accessGallery() async {
    print("Access Gallery called");

    Navigator.of(context).pop();

    showAdaptiveDialog(
      context: context,
      builder: (context) => Dialog(

          // insetPadding: EdgeInsets.symmetric(horizontal: 10.sp),
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.sp, horizontal: 5.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator.adaptive(),
                SizedBox(
                  width: 5.sp,
                ),
                const Text(
                  "File is loading, please wait...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
    );

    var file = await FileServices().pickImage(
      context,
    );

    if (file == null) {
      if (!context.mounted) return;

      // To pop the loader
      Navigator.of(context).pop();
    }

    if (file != null) {
      if (!mounted) return;

      // To pop the loader
      Navigator.of(context).pop();

      FileType fileType = FileServices().getFileType(path.extension(file.path));

      if (fileType == FileType.image) {
        attachedFileNotifier.value = await FileServices().navigateToImageEditor(
          context: context,
          file: file,
        );
      } else if (fileType == FileType.video) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return TrimmerView(
              file,
              onSave: (path) {
                Navigator.pop(context);

                if (path != null) {
                  attachedFileNotifier.value = File(path);
                }
              },
            );
          },
        ));
      } else {
        attachedFileNotifier.value = file;
      }
    }
  }

  Future<void> accessVideo() async {
    Navigator.pop(context);

    var file = await FileServices().getVideo(
      context,
      isCamera: true,
    );

    if (file != null) {
      attachedFileNotifier.value = file;
    }
  }

  Future<void> accessAudio() async {
    var path = await FileServices().showAudioRecorderPopup(context);

    if (path != null) {
      attachedFileNotifier.value = File(path);
    }
  }
}
