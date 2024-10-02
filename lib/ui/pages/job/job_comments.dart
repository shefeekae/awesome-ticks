import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/models/job_comments_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/ui/pages/job/widgets/video_trimmer_screen.dart';
import 'package:files_viewer/core/models/file_data_model.dart';
import 'package:files_viewer/screens/image_editor_screen.dart';
import 'package:awesometicks/ui/shared/models/file_selector_model.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_widget.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import 'package:sizer/sizer.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../core/services/jobs/jobs_services.dart';
import '../../shared/widgets/skelton_loader.dart';
import 'package:collection/collection.dart';
import 'job_comment_replies.dart';
import 'package:path/path.dart' as path;

// ignore: must_be_immutable
class JobCommentsScreen extends StatefulWidget {
  JobCommentsScreen({
    required this.jobId,
    required this.jobDomain,
    required this.commentId,
    required this.replyId,
    super.key,
  });

  final int jobId;
  final String jobDomain;

  int? commentId;
  int? replyId;

  @override
  State<JobCommentsScreen> createState() => _JobCommentsScreenState();
}

class _JobCommentsScreenState extends State<JobCommentsScreen> {
  // final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // final TextEditingController commentController = TextEditingController();

  JobDetailsDb? jobDetailsDb;
  List<JobComments> jobComments = [];

  // ValueNotifier sendButtonNotifier = ValueNotifier<bool>(false);
  // ValueNotifier commentAddedLodingNotifier = ValueNotifier<bool>(false);

  final UserDataSingleton userData = UserDataSingleton();

  Future<QueryResult<dynamic>?> Function()? listCommentsRefetch;

  Future<void> _startScrolling({required GetAllComments comment}) async {
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        // _animationController.forward();
        if (widget.replyId != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JobCommentRepliesScreen(
                comment: comment,
                jobId: widget.jobId,
                jobDomain: widget.jobDomain,
                replyId: widget.replyId,
              ),
            ),
          );
        }

        widget.commentId = null;
        widget.replyId = null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
          builder: (context, state) {
            bool notAvailable = state.isInternetAvailable;

            if (!notAvailable) {
              return ValueListenableBuilder(
                valueListenable: jobDetailsDbgetBox().listenable(),
                builder: (context, box, child) {
                  var jobsList = box.values.toList();

                  jobDetailsDb = jobsList.singleWhereOrNull(
                      (element) => element.id == widget.jobId);

                  if (jobDetailsDb == null) {
                    return const Expanded(
                      child: Center(
                        child: Text("Job comments not found"),
                      ),
                    );
                  }

                  jobComments = jobDetailsDb!.jobComments ?? [];

                  if (jobComments.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text("No comments"),
                      ),
                    );
                  }

                  List<GetAllComments> allComments = jobComments
                      .map(
                        (e) => GetAllComments(
                          comment: e.comment,
                          commentBy: e.commentBy,
                          commentTime: e.commentTime,
                        ),
                      )
                      .toList();

                  return buildCommentsBuilder(allComments);
                },
              );
            }

            return QueryWidget(
              options: GraphqlServices().getQueryOptions(
                query: JobsSchemas.jobCommentsQuery,
                variables: {
                  "jobId": widget.jobId,
                },
              ),
              builder: (result, {fetchMore, refetch}) {
                listCommentsRefetch = refetch;
                if (result.isLoading) {
                  return Expanded(
                    child: ListView.separated(
                      // controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(5.sp),
                      itemCount: 10,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 5.sp,
                        );
                      },
                      itemBuilder: (context, index) {
                        return buildSkeleton(context);
                      },
                    ),
                  );
                }

                if (result.hasException) {
                  return Expanded(
                    child: GraphqlServices().handlingGraphqlExceptions(
                      result: result,
                      context: context,
                      refetch: refetch,
                    ),
                  );
                }

                AllJobComments jobComments =
                    AllJobComments.fromJson(result.data!);

                List<GetAllComments> allComments =
                    jobComments.getAllComments ?? [];

                if (allComments.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("No comments"),
                    ),
                  );
                }

                return buildCommentsBuilder(allComments);
              },
            );
          },
        ),
        PermissionChecking(
            featureGroup: "jobManagement",
            feature: "job",
            permission: "addComment",
            child: CommentTextfieldWithAttachment(
              jobId: widget.jobId,
              jobDomain: widget.jobDomain,
              refreshState: () {
                listCommentsRefetch?.call();
              },
            )),
        KeyboardVisibilityBuilder(builder: (context, visible) {
          if (visible) {
            return const SizedBox();
          }
          return SizedBox(
            height: 15.sp,
          );
        })
      ],
    );
    // );
  }

  // ==========================================================================================================
  // List of comments.

  Expanded buildCommentsBuilder(List<GetAllComments> allComments) {
    allComments.sort(
      (a, b) => b.commentTime!.compareTo(a.commentTime!),
    );

    ItemScrollController itemScrollController = ItemScrollController();
    int commentedIndex = -1;

    if (widget.commentId != null) {
      commentedIndex = allComments.indexWhere(
        (element) => element.id == widget.commentId,
      );

      GetAllComments comment = allComments.singleWhere(
        (element) => element.id == widget.commentId,
      );

      if (commentedIndex != -1) {
        Future.delayed(
          const Duration(seconds: 0),
          () {
            itemScrollController.scrollTo(
              index: commentedIndex,
              duration: const Duration(milliseconds: 500),
            );
            _startScrolling(comment: comment);
          },
        );
      }
    }

    Color color = Theme.of(context).colorScheme.secondary.withOpacity(0.25);

    return Expanded(
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          setState(() {});
          widget.commentId = null;
          widget.replyId = null;
          listCommentsRefetch?.call();
        },
        child: ScrollablePositionedList.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemScrollController: itemScrollController,
          // padding: EdgeInsets.all(5.sp),

          separatorBuilder: (context, index) {
            if (widget.commentId != null && commentedIndex != -1) {
              if (commentedIndex == index || commentedIndex - 1 == index) {
                return Container(
                  height: 5.sp,
                  color: color,
                );
              }
            }

            return SizedBox(
              height: 5.sp,
            );
          },
          itemBuilder: (context, index) {
            bool jobcommentNotification = commentedIndex != -1 &&
                commentedIndex == index &&
                widget.commentId != null;

            if (jobcommentNotification) {
              return Container(
                color: color,
                child: CommentWidget(
                  comment: allComments[index],
                  jobId: widget.jobId,
                  jobDomain: widget.jobDomain,
                  highlight: true,
                ),
              );
              // return FadeTransition(
              //   opacity: _animationController,
              //   child: CommentWidget(
              //     comment: allComments[index],
              //     jobId: widget.jobId,
              //     jobDomain: widget.jobDomain,
              //   ),
              // );
            }

            return CommentWidget(
              comment: allComments[index],
              jobId: widget.jobId,
              jobDomain: widget.jobDomain,
            );
          },
          itemCount: allComments.length,
        ),
      ),
    );
  }

  // ========================================================================================
  // buildAttachmentAndTextfield

  // Widget buildAttachmentAndTextfield(BuildContext context) {
  //   File? attachedFile;

  //   // bool isAndroid = Platform.isAndroid;

  //   return StatefulBuilder(builder: (context, refreshState) {
  //     bool hide = attachedFile == null;

  //     return Column(
  //       children: [
  //         Stack(
  //           children: [
  //             AnimatedContainer(
  //               duration: const Duration(milliseconds: 500),
  //               height: hide ? 0 : 20.h,
  //               width: hide ? 0 : 20.h,
  //               decoration: const BoxDecoration(
  //                 color: kWhite,
  //               ),
  //               child: hide ? const SizedBox() : Image.file(attachedFile!),
  //             ),
  //             Positioned(
  //               top: 5.sp, // Adjust the top position as needed
  //               right: 5.sp, // Adjust the right position as needed
  //               child: GestureDetector(
  //                 onTap: () {
  //                   refreshState(
  //                     () {
  //                       attachedFile = null;
  //                     },
  //                   );
  //                 },
  //                 child: Icon(
  //                   Icons.cancel,
  //                   color: Colors.red.shade700,
  //                   size: 24,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         Container(
  //           color: kWhite,
  //           child: ValueListenableBuilder(
  //               valueListenable: commentAddedLodingNotifier,
  //               builder: (context, value, _) {
  //                 if (value) {
  //                   return Center(
  //                     child: Padding(
  //                       padding: EdgeInsets.all(10.sp),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           LoadingIosAndroidWidget(
  //                             radius: 8.sp,
  //                           ),
  //                           SizedBox(
  //                             width: 5.sp,
  //                           ),
  //                           const Text("Comment adding"),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 }

  //                 return Row(
  //                   children: [
  //                     IconButton(
  //                       onPressed: () {
  //                         PlatformServices().showDialogWithDialogActions(
  //                           context,
  //                           title: "Attach Images",
  //                           list: [
  //                             DialogActionModel(
  //                               child: const Text(
  //                                 "Take Photo",
  //                               ),
  //                               onPressed: () async {
  //                                 Navigator.of(context).pop();

  //                                 var file = await FileServices().pickImage(
  //                                   context,
  //                                   isCamera: true,
  //                                 );

  //                                 if (file != null) {
  //                                   refreshState(
  //                                     () {
  //                                       attachedFile = file;
  //                                     },
  //                                   );
  //                                 }
  //                               },
  //                             ),
  //                             DialogActionModel(
  //                               child: const Text("Choose Image"),
  //                               onPressed: () async {
  //                                 Navigator.of(context).pop();

  //                                 var file = await FileServices().pickImage(
  //                                   context,
  //                                 );

  //                                 if (file != null) {
  //                                   refreshState(
  //                                     () {
  //                                       attachedFile = file;
  //                                     },
  //                                   );
  //                                 }
  //                               },
  //                             ),
  //                             DialogActionModel(
  //                               child: const Text("Cancel"),
  //                               onPressed: () {
  //                                 Navigator.of(context).pop();
  //                               },
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                       icon: const Icon(
  //                         Icons.attachment,
  //                         // color: Colors.red,
  //                       ),
  //                     ),
  //                     Form(
  //                       key: formKey,
  //                       child: BuildCommentTextfield(
  //                         onChanged: (value) {
  //                           sendButtonNotifier.value = value.trim().isNotEmpty;
  //                         },
  //                         controller: commentController,
  //                         hintText: "Enter comment",
  //                       ),
  //                     ),
  //                     ValueListenableBuilder(
  //                       valueListenable: sendButtonNotifier,
  //                       builder: (ctx, value, _) => IconButton(
  //                         onPressed: value
  //                             ? () async {
  //                                 bool isValid =
  //                                     formKey.currentState!.validate();
  //                                 if (isValid) {
  //                                   commentAddedLodingNotifier.value = true;

  //                                   int nowMilliseconds =
  //                                       DateTime.now().millisecondsSinceEpoch;

  //                                   bool internetAvailable =
  //                                       await InterNetServices()
  //                                           .checkInternetConnectivity();

  //                                   if (!internetAvailable) {
  //                                     var jobsList =
  //                                         jobDetailsDbgetBox().values.toList();

  //                                     JobDetailsDb? jobDetailsDb = jobsList
  //                                         .singleWhereOrNull((element) =>
  //                                             element.id == widget.jobId);

  //                                     if (jobDetailsDb == null) {
  //                                       // ignore: use_build_context_synchronously
  //                                       buildSnackBar(
  //                                         context: context,
  //                                         value: "Something went wrong!",
  //                                       );

  //                                       commentAddedLodingNotifier.value =
  //                                           false;

  //                                       return;
  //                                     }

  //                                     String userName = userData.userName;

  //                                     String domain = userData.domain;

  //                                     jobDetailsDb.jobComments!.add(
  //                                       JobComments(
  //                                         comment:
  //                                             commentController.text.trim(),
  //                                         commentBy: "$userName@$domain",
  //                                         commentTime: nowMilliseconds,
  //                                         replies: [],
  //                                       ),
  //                                     );

  //                                     int index = jobDetailsDbgetBox()
  //                                         .values
  //                                         .toList()
  //                                         .indexOf(jobDetailsDb);

  //                                     jobDetailsDbgetBox()
  //                                         .putAt(index, jobDetailsDb);

  //                                     var syncBox = syncdbgetBox();

  //                                     var payload = {
  //                                       "replyId":
  //                                           "$userName@$domain/$nowMilliseconds",
  //                                       "data": {
  //                                         "comment": {
  //                                           "comment":
  //                                               commentController.text.trim()
  //                                         },
  //                                         "jobId": widget.jobId,
  //                                         "jobDomain": widget.jobDomain,
  //                                       }
  //                                     };

  //                                     if (attachedFile != null) {
  //                                       Uint8List uint8List =
  //                                           attachedFile!.readAsBytesSync();

  //                                       payload['fileData'] = {
  //                                         "attachedFiile": uint8List,
  //                                         // "filePath": "/jobs/${widget.jobId}/comments/",
  //                                       };

  //                                       refreshState(() {
  //                                         attachedFile = null;
  //                                       });
  //                                     }

  //                                     syncBox.add(
  //                                       SyncingLocalDb(
  //                                         payload: payload,
  //                                         generatedTime: nowMilliseconds,
  //                                         graphqlMethod:
  //                                             JobsSchemas.addJobCommentMutation,
  //                                       ),
  //                                     );

  //                                     // if (attachedFile != null) {
  //                                     //   syncBox.add(
  //                                     //     SyncingLocalDb(
  //                                     //       payload: {
  //                                     //         "attachedFiile": uint8List,
  //                                     //         "filePath": "/jobs/${widget.jobId}/comments/",
  //                                     //       },
  //                                     //       generatedTime:
  //                                     //           DateTime.now().millisecondsSinceEpoch,
  //                                     //       graphqlMethod:
  //                                     //           JobsSchemas.uploadMultipleFilesMutation,
  //                                     //     ),
  //                                     //   );
  //                                     // }

  //                                     commentController.clear();
  //                                     sendButtonNotifier.value = false;

  //                                     commentAddedLodingNotifier.value = false;
  //                                     // ignore: use_build_context_synchronously
  //                                     FocusScope.of(context).unfocus();

  //                                     return;
  //                                   }

  //                                   int? id =
  //                                       // ignore: use_build_context_synchronously
  //                                       await JobsServices().addCommentToJob(
  //                                     context: context,
  //                                     jobId: widget.jobId,
  //                                     comment: commentController.text.trim(),
  //                                     attachedFile: attachedFile,
  //                                     jobDomain: widget.jobDomain,
  //                                   );

  //                                   if (id != null) {
  //                                     setState(
  //                                       () {},
  //                                     );
  //                                   } else {
  //                                     // ignore: use_build_context_synchronously
  //                                     buildSnackBar(
  //                                       context: context,
  //                                       value: "Something went wrong!",
  //                                     );
  //                                     commentAddedLodingNotifier.value = false;
  //                                   }

  //                                   attachedFile = null;
  //                                   commentController.clear();
  //                                   sendButtonNotifier.value = false;
  //                                   commentAddedLodingNotifier.value = false;
  //                                 }
  //                               }
  //                             : null,
  //                         icon: const Icon(
  //                           Icons.send,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 );
  //               }),
  //         ),
  //       ],
  //     );
  //   });
  // }

  // ==========================================================================================================
  AppBar buildAppbar() {
    return AppBar(
      title: const Text("Job Comments "),
    );
  }
}

class CommentTextfieldWithAttachment extends StatefulWidget {
  final int jobId;
  final String jobDomain;
  final VoidCallback refreshState;

  const CommentTextfieldWithAttachment({
    super.key,
    required this.jobId,
    required this.jobDomain,
    required this.refreshState,
  });

  @override
  State<CommentTextfieldWithAttachment> createState() =>
      _CommentTextfieldWithAttachmentState();
}

class _CommentTextfieldWithAttachmentState
    extends State<CommentTextfieldWithAttachment> {
  late final ValueNotifier<File?> attachedFileNotifier;

  final ValueNotifier commentAddedLodingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier sendButtonNotifier = ValueNotifier<bool>(false);

  final TextEditingController commentController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final UserDataSingleton userData = UserDataSingleton();

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
    return ValueListenableBuilder(
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
                color: kWhite,
                child: ValueListenableBuilder(
                    valueListenable: commentAddedLodingNotifier,
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
                                const Text("Comment adding"),
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
                              // color: Colors.red,
                            ),
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
                          ValueListenableBuilder(
                            valueListenable: sendButtonNotifier,
                            builder: (ctx, value, _) => IconButton(
                              onPressed: value
                                  ? () async {
                                      bool isValid =
                                          formKey.currentState!.validate();
                                      if (isValid) {
                                        commentAddedLodingNotifier.value = true;

                                        int nowMilliseconds = DateTime.now()
                                            .millisecondsSinceEpoch;

                                        bool internetAvailable =
                                            await InterNetServices()
                                                .checkInternetConnectivity();

                                        if (!internetAvailable) {
                                          var jobsList = jobDetailsDbgetBox()
                                              .values
                                              .toList();

                                          JobDetailsDb? jobDetailsDb = jobsList
                                              .singleWhereOrNull((element) =>
                                                  element.id == widget.jobId);

                                          if (jobDetailsDb == null) {
                                            // ignore: use_build_context_synchronously
                                            buildSnackBar(
                                              context: context,
                                              value: "Something went wrong!",
                                            );

                                            commentAddedLodingNotifier.value =
                                                false;

                                            return;
                                          }

                                          String userName = userData.userName;

                                          String domain = userData.domain;

                                          jobDetailsDb.jobComments!.add(
                                            JobComments(
                                              comment:
                                                  commentController.text.trim(),
                                              commentBy: "$userName@$domain",
                                              commentTime: nowMilliseconds,
                                              replies: [],
                                            ),
                                          );

                                          int index = jobDetailsDbgetBox()
                                              .values
                                              .toList()
                                              .indexOf(jobDetailsDb);

                                          jobDetailsDbgetBox()
                                              .putAt(index, jobDetailsDb);

                                          var syncBox = syncdbgetBox();

                                          var payload = {
                                            "replyId":
                                                "$userName@$domain/$nowMilliseconds",
                                            "data": {
                                              "comment": {
                                                "comment": commentController
                                                    .text
                                                    .trim()
                                              },
                                              "jobId": widget.jobId,
                                              "jobDomain": widget.jobDomain,
                                            }
                                          };

                                          if (attachedFile != null) {
                                            Uint8List uint8List =
                                                attachedFile.readAsBytesSync();

                                            payload['fileData'] = {
                                              "attachedFiile": uint8List,
                                              // "filePath": "/jobs/${widget.jobId}/comments/",
                                            };

                                            attachedFileNotifier.value = null;
                                          }

                                          syncBox.add(
                                            SyncingLocalDb(
                                              payload: payload,
                                              generatedTime: nowMilliseconds,
                                              graphqlMethod: JobsSchemas
                                                  .addJobCommentMutation,
                                            ),
                                          );

                                          commentController.clear();
                                          sendButtonNotifier.value = false;

                                          commentAddedLodingNotifier.value =
                                              false;
                                          // ignore: use_build_context_synchronously
                                          FocusScope.of(context).unfocus();

                                          return;
                                        }

                                        int? id =
                                            // ignore: use_build_context_synchronously
                                            await JobsServices()
                                                .addCommentToJob(
                                          context: context,
                                          jobId: widget.jobId,
                                          comment:
                                              commentController.text.trim(),
                                          attachedFile: attachedFile,
                                          jobDomain: widget.jobDomain,
                                        );

                                        if (id != null) {
                                          widget.refreshState.call();
                                        } else {
                                          // ignore: use_build_context_synchronously
                                          buildSnackBar(
                                            context: context,
                                            value: "Something went wrong!",
                                          );
                                          commentAddedLodingNotifier.value =
                                              false;
                                        }

                                        attachedFileNotifier.value = null;

                                        commentController.clear();
                                        sendButtonNotifier.value = false;
                                        commentAddedLodingNotifier.value =
                                            false;
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
