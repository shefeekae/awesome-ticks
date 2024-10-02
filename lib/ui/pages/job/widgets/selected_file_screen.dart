import 'dart:convert';
import 'dart:io';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_no_internet_services.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:files_viewer/core/models/file_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:video_tutorials/screens/video_player/video_player_screen.dart';
import '../../../../core/blocs/attachments/attachments_controller_bloc.dart';
import '../../../../core/services/jobs/jobs_services.dart';
import '../../../../core/services/theme_services.dart';
import 'package:path/path.dart' as path;
import '../../../../utils/themes/colors.dart';

class SelectedFileScreen extends StatefulWidget {
  const SelectedFileScreen({
    super.key,
    required this.file,
    required this.attachingFilePath,
    required this.attachmentCategoryKey,
    required this.allAttachmentFilePath,
    this.fileAlreadyAttached = false,
    this.networkFilePath,
    this.attachedFileData,
    this.videoThumbnail,
  });

  final File file;
  final String attachingFilePath;
  final String attachmentCategoryKey;
  final String allAttachmentFilePath;
  final String? networkFilePath;
  final bool fileAlreadyAttached;
  final Map<String, dynamic>? attachedFileData;
  final File? videoThumbnail;

  @override
  State<SelectedFileScreen> createState() => _SelectedFileScreenState();
}

class _SelectedFileScreenState extends State<SelectedFileScreen> {
  late AttachmentsControllerBloc attachmentsControllerBloc;

  ValueNotifier<bool> attachmentLoadingNotifier = ValueNotifier<bool>(false);

  late ValueNotifier<File> selectedAttachmentNotifier;

  final TextEditingController commentTextController = TextEditingController();

  @override
  void initState() {
    attachmentsControllerBloc =
        BlocProvider.of<AttachmentsControllerBloc>(context);

    selectedAttachmentNotifier = ValueNotifier<File>(widget.file);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: path.basename(widget.file.path),
        // backgroundColor: Colors.transparent,
        actions: [
          ValueListenableBuilder(
              valueListenable: selectedAttachmentNotifier,
              builder: (context, attachedFile, child) {
                FileType fileType = FileServices()
                    .getFileType(path.extension(attachedFile.path));

                if (fileType == FileType.image) {
                  return IconButton(
                    onPressed: () async {
                      await FileServices().navigateToImageEditor(
                        context: context,
                        file: attachedFile,
                      );
                    },
                    icon: const Icon(Icons.edit),
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: selectedAttachmentNotifier,
          builder: (context, file, child) {
            return Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // const Spacer(),
                Expanded(
                  child: Center(
                    child: _buildFileViewWidget(
                      file,
                      widget.videoThumbnail,
                    ),
                  ),
                ),
                // const Spacer(),
                buildTextfieldWithSendButton(file),
                KeyboardVisibilityBuilder(builder: (
                  context,
                  isVisible,
                ) {
                  return SizedBox(
                    height: isVisible ? 0 : 20.sp,
                  );
                }),
              ],
            );
          }),
    );
  }

  Widget _buildFileViewWidget(File file, File? videoThumbnail) {
    switch (file.path.split('.').last.toLowerCase()) {
      case 'mp4':
      case 'mkv':
      case 'mov':
      case 'avi':
      case 'webm':
      case 'wmv':
        return Stack(
          children: [
            if (videoThumbnail != null)
              Center(child: Image.file(videoThumbnail)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return VideoPlayerScreen(file: file);
                    },
                  ),
                );
              },
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 50.0,
                ),
              ),
            ),
          ],
        );

      case 'mp3':
      case 'm4a':
      case 'wav':
      case 'ogg':
        return Stack(
          children: [
            Center(
              child: Container(
                // height: 300.sp,
                // width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/audio-file-thumbnail.png'))),
              ),
            ),
            // Icon(
            //   Icons.audio_file,
            //   size: 50.0,
            // ),
            Center(
              child: GestureDetector(
                onTap: () {
                  FileServices().showAudioPlayerBottomSheet(
                    context,
                    file.path,
                  );
                },
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 50.0,
                ),
              ),
            ),
          ],
        );

      default:
        return Image.file(
          file,
          fit: BoxFit.contain,
          height: 70.h,
        );
    }
  }

  // ===========================================================================
  // Displaying the comment field with send button.

  Padding buildTextfieldWithSendButton(File selectedFile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SizedBox(
              height: 30.sp,
              child: buildCommentTextfield(),
            ),
          ),
          SizedBox(
            width: 5.sp,
          ),
          MutationWidget(
            options: GrapghQlClientServices().getMutateOptions(
              document: widget.fileAlreadyAttached
                  ? JobsSchemas.addJobCommentToAttachment
                  : JobsSchemas.addJobCommentWithAttachment,
              context: context,
              onCompleted: (data) async {
                if (data != null) {
                  await JobsServices().addJobAttachmentsToBlocState(
                    jobAttachmentFilePath: widget.allAttachmentFilePath,
                    attachmentCategoryKey: widget.attachmentCategoryKey,
                  );

                  attachmentLoadingNotifier.value = false;

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } else {
                  attachmentLoadingNotifier.value = false;
                }
              },
            ),
            builder: (runMutation, result) {
              return ValueListenableBuilder<bool>(
                  valueListenable: attachmentLoadingNotifier,
                  builder: (context, loading, _) {
                    bool isLoading = loading;

                    return CircleAvatar(
                      radius: 15.sp,
                      child: IconButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                UserDataSingleton userData =
                                    UserDataSingleton();

                                var list = widget.attachingFilePath.split("/");

                                int? jobId = int.tryParse(list[2]);

                                print("jobId: $jobId");

                                if (jobId == null) {
                                  return;
                                }

                                attachmentLoadingNotifier.value = true;

                                bool hasInternet = await InterNetServices()
                                    .checkInternetConnectivity();

                                print("hasInternet: $hasInternet");

                                int commentTime =
                                    DateTime.now().millisecondsSinceEpoch;

                                var payload = {
                                  "data": {
                                    "comment": commentTextController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : {
                                            "comment": {
                                              "comment": commentTextController
                                                  .text
                                                  .trim(),
                                              "commentBy":
                                                  "${userData.userName}@${userData.domain}",
                                              "commentTime": commentTime,
                                            },
                                            "jobId": jobId,
                                          },
                                    "filePath": widget.allAttachmentFilePath,
                                    "subPath": widget
                                            .attachmentCategoryKey.isEmpty
                                        ? ""
                                        : "/${widget.attachmentCategoryKey}",
                                  }
                                };

                                if (!hasInternet) {
                                  var byteData =
                                      await selectedFile.readAsBytes();

                                  if (context.mounted) {
                                    JobsNoInternetServices()
                                        .addingAttachmentWithComment(
                                      context: context,
                                      jobId: jobId,
                                      comment:
                                          commentTextController.text.trim(),
                                      fileName: path.basename(widget.file.path),
                                      base64EncodeData: base64Encode(byteData),
                                      attachingFilePath:
                                          widget.attachingFilePath,
                                      attachmentCategoryKey:
                                          widget.attachmentCategoryKey,
                                      allAttachmentsFilePath:
                                          widget.allAttachmentFilePath,
                                    );
                                  }

                                  return;
                                }

                                var attachmentsUploadData = await JobsServices()
                                    .convertToFileUploadData(
                                  selectedFile,
                                );

                                payload['data']
                                    ?['attachments'] = [attachmentsUploadData];

                                runMutation(payload);
                              },
                        icon: isLoading
                            ? CircularProgressIndicator.adaptive(
                                backgroundColor:
                                    ThemeServices().getPrimaryFgColor(context),
                              )
                            : Icon(
                                Icons.send,
                                size: 12.sp,
                              ),
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  TextField buildCommentTextfield() {
    return TextField(
      controller: commentTextController,
      decoration: InputDecoration(
        // fillColor: Colors.black12,
        hintText: "Enter a comment (Optional)",
        fillColor: kWhite,
        enabledBorder: const OutlineInputBorder(
          // borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        border: const OutlineInputBorder(
          // borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        // enabledBorder: InputBorder.none,
        // border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 5.sp),
      ),
      // style: TextStyle(fontSize: 25),
    );
  }
}
