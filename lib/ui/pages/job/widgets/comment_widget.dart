import 'dart:io';

import 'package:awesometicks/core/models/job_comments_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
// import 'package:awesometicks/ui/pages/job/widgets/checklist_commen_replies.dart';
import 'package:awesometicks/ui/shared/functions/short_letter_converter.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_tutorials/screens/video_player/video_player_screen.dart';
import '../../../../utils/themes/colors.dart';
import '../job_comment_replies.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'checklist_commen_replies.dart';
import 'image_view.dart';

// import 'image_view.dart';

class CommentWidget extends StatelessWidget {
  CommentWidget({
    super.key,
    this.isReplyScreen = false,
    this.isChecklistComment = false,
    this.checklistId,
    required this.comment,
    required this.jobId,
    required this.jobDomain,
    this.highlight = false,
  });

  bool isReplyScreen;
  GetAllComments comment;
  int jobId;
  String jobDomain;
  bool isChecklistComment;
  int? checklistId;
  bool highlight;

  @override
  Widget build(BuildContext context) {
    // print("Job comment Id : ${comment.id}");
    // print("Job Domain : ${jobDomain}");

    return Container(
      decoration: BoxDecoration(
        color: highlight ? null : kWhite,
        borderRadius: BorderRadius.circular(3.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.sp),
      margin: EdgeInsets.symmetric(horizontal: 3.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildListTile(
            userName: comment.commentBy ?? "N/A",
            comment: comment.comment ?? "N/A",
            formatedDateTime: comment.commentTime == null
                ? "N/A"
                : timeago.format(
                    DateTime.fromMillisecondsSinceEpoch(comment.commentTime!),
                  ),
          ),
          buildAttachemntsAndReplies(),
        ],
      ),
    );
  }

  // ================================================================================================
  // Show hide button.

  Widget buildAttachemntsAndReplies() {
    bool show = false;

    return FutureBuilder(
      future: InterNetServices().checkInternetConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }

        bool hasInternet = snapshot.data!;

        // if (!hasInternet) {
        //   return const SizedBox();
        // }

        return StatefulBuilder(builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: hasInternet,
                    child: TextButton(
                      onPressed: () {
                        setState(
                          () {
                            show = !show;
                          },
                        );
                      },
                      child:
                          Text(show ? "Hide Attachments" : "Show Attachments"),
                    ),
                  ),
                  Visibility(
                    visible: !isReplyScreen,
                    child: TextButton(
                      onPressed: () {
                        if (isChecklistComment) {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(5),
                              ),
                            ),
                            builder: (context) {
                              return ChecklistCommentRepliesWidget(
                                comment: comment,
                                jobId: jobId,
                                jobDomain: jobDomain,
                                checklistId: checklistId!,
                              );
                            },
                          );

                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => JobCommentRepliesScreen(
                              comment: comment,
                              jobId: jobId,
                              jobDomain: jobDomain,
                            ),
                          ),
                        );
                      },
                      child: const Text("Replies"),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: show,
                child: Builder(builder: (context) {
                  double cardHeightWidth = 50.sp;

                  return StatefulBuilder(builder: (context, setState) {
                    return FutureBuilder(
                      future: GraphqlServices().performQuery(
                        query: JobsSchemas.getAllFilesFromSamePath,
                        variables: {
                          "traverseFiles": true,
                          "filePath": isChecklistComment
                              ? "jobs/$jobDomain/$jobId/checklist/$checklistId/comments/${comment.id}"
                              : "jobs/$jobDomain/$jobId/comments/${comment.id}",
                        },
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: LoadingIosAndroidWidget(),
                          );
                        }

                        // print("Variables : ${{
                        //   "filePath":
                        //       "/jobs/$jobDomain/$jobId/comments/${comment.id}",
                        // }}");

                        if (snapshot.data?.hasException ?? false) {
                          return GraphqlServices().handlingGraphqlExceptions(
                            result: snapshot.data!,
                            context: context,
                            // refetch: refetch,
                            setState: setState,
                          );
                        }

                        var result = snapshot.data;

                        List results = result?.data?['getAllFilesFromSamePath']
                                ['data'] ??
                            [];

                        return SizedBox(
                          height: cardHeightWidth,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              Map map = results[index];

                              bool isThumbnail = map['thumbnail'] ?? false;

                              return FutureBuilder(
                                future: FileServices().convertToFile(
                                    base64Encoded: map['data'],
                                    fileName: map['fileName']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const LoadingIosAndroidWidget();
                                  }

                                  File file = snapshot.data!;
                                  String fileName = map['fileName'];

                                  String extension = file.path.split('.').last;


                                  // TODO:- check this is necessery if not remove
                                  if (extension != "jpeg" &&
                                      extension != "png") {
                                    return Container(
                                      height: cardHeightWidth,
                                      width: cardHeightWidth,
                                      decoration: BoxDecoration(
                                        color: fwhite,
                                        borderRadius:
                                            BorderRadius.circular(5.sp),
                                      ),
                                      child: const Icon(Icons.description),
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      onAttachmentTap(
                                        context: context,
                                        file: file,
                                        fileName: fileName,
                                        isThumbnail: isThumbnail,
                                        map: map,
                                      );
                                    },
                                    child: Container(
                                      height: cardHeightWidth,
                                      width: cardHeightWidth,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.sp),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(file),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: 10.sp,
                              );
                            },
                            itemCount: results.length,
                          ),
                        );
                      },
                    );
                  });
                }),
              ),
              SizedBox(
                height: 5.sp,
              )
            ],
          );
        });
      },
    );
  }

  /// onTap of attached files
  Future<void> onAttachmentTap({
    required BuildContext context,
    required File file,
    required String fileName,
    required bool isThumbnail,
    required Map map,
  }) async {
    File originalFile = file;
    String originalFileName = fileName;
    String originalFileMimeType = '';

    if (isThumbnail) {
      var result = await GraphqlServices()
          .performQuery(query: JobsSchemas.getFileForPreview, variables: {
        "fileName": map['originalFileName'],
        "filePath": map['originalFilePath'],
      });

      var data = result.data ?? {};

      if (data.isEmpty) {
        return;
      }

      await FileServices()
          .convertToFile(
        base64Encoded: data["getFileForPreview"]["data"],
        fileName: data["getFileForPreview"]["fileName"],
      )
          .then((val) {
        originalFile = val;
        originalFileName = data["getFileForPreview"]["fileName"];
      });

      originalFileMimeType =
          map['originalFileMimeType'].toString().split('/').first;
    }

    if (originalFileMimeType == 'video') {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return VideoPlayerScreen(
              file: originalFile,
            );
          },
        ),
      );
    } else if (originalFileMimeType == 'audio') {
      if (!context.mounted) return;
      FileServices().showAudioPlayerBottomSheet(
        context,
        originalFile.path,
      );
    } else {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageViewer(
            file: originalFile,
            fileName: originalFileName,
          ),
        ),
      );
    }
  }

  //

  Widget buildListTile({
    required String userName,
    required String comment,
    required String formatedDateTime,
  }) {
    // String a = userName.contains("@")
    //     ? "${userName.split("@")[0][0].toUpperCase()}${userName.split("@")[1][1].toUpperCase()}"
    //     : userName.contains(" ")
    //         ? "${userName.split(" ")[0][0].toLowerCase()}${userName.split(" ")[1].toLowerCase()}"
    //         : "${userName[0].toUpperCase()}${userName[1] ? userName[0].toUpperCase() : "" }";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          child: Text(
            shortLetterConverter(userName),
          ),
        ),
        SizedBox(
          width: 10.sp,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10.sp,
              ),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.black38,
                ),
              ),
              SizedBox(
                height: 5.sp,
              ),
              Text(
                comment,
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatedDateTime,
          style: TextStyle(
            fontSize: 8.sp,
            color: Colors.black38,
          ),
        ),
      ],
    );

    // return ListTile(
    //   contentPadding: EdgeInsets.zero,
    //   minVerticalPadding: 0,
    //   leading: const CircleAvatar(),
    //   // titleTextStyle: TextStyle(fontSize: 10),
    //   // subtitleTextStyle: TextStyle(fontSize: 10.sp),

    //   title: Text(
    //     userName,
    //     style: TextStyle(fontSize: 10.sp),
    //   ),
    //   subtitle: Text(
    //     comment,
    //     style: TextStyle(
    //       fontSize: 11.sp,
    //     ),
    //   ),
    //   trailing: Text(
    //     formatedDateTime,
    //     style: TextStyle(
    //       fontSize: 8.sp,
    //     ),
    //   ),
    // );
  }
}
