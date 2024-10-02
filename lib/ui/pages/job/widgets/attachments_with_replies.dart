import 'dart:io';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_no_internet_services.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/image_view.dart';
import 'package:awesometicks/ui/shared/functions/short_letter_converter.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/model/login_response_model.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/services/graphql_services.dart';
import '../../../../core/services/platform_services.dart';
import 'package:collection/collection.dart';

import '../../../shared/widgets/custom_snackbar.dart';

class AttachmentsWithReplies extends StatelessWidget {
  AttachmentsWithReplies({
    super.key,
    required this.file,
    required this.commentId,
    required this.isChecklistComment,
    required this.jobId,
    required this.checklistId,
    this.commentData,
  });

  final File file;
  final int commentId;
  final bool isChecklistComment;
  final int jobId;
  final int? checklistId;

  // This variable using only when the internet is off
  final Map<String, dynamic>? commentData;

  final TextEditingController replyTextController = TextEditingController();
  late StateSetter refreshState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GradientAppBar(
          title: "",
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.sp,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ImageViewer(
                      file: file,
                      fileName: file.path,
                    );
                  },
                ));
              },
              child: Image.file(
                file,
                height: 20.h,
                width: double.infinity,
              ),
            ),
            buildCommentWidget(context),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Replies",
                style: TextStyle(
                  fontSize: 15.sp,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
                  builder: (context, state) {
                if (!state.isInternetAvailable) {
                  return ValueListenableBuilder(
                    valueListenable: jobDetailsDbgetBox().listenable(),
                    builder: (context, box, child) {
                      JobDetailsDb? jobDetailsDb = box.values
                          .singleWhereOrNull((element) => element.id == jobId);

                      if (jobDetailsDb == null) {
                        return const Center(
                          child: Text(
                            "No Replies yet",
                          ),
                        );
                      }

                      JobComments? jobComment =
                          jobDetailsDb.jobComments!.singleWhereOrNull(
                        (element) {
                          return element.commentTime ==
                              commentData?['commentTime'];
                        },
                      );

                      if (jobComment == null) {
                        return const Center(
                          child: Text("Comments not found"),
                        );
                      }

                      var commentReplies = jobComment.replies ?? [];

                      if (commentReplies.isEmpty) {
                        return const Center(
                          child: Text("No replies yet"),
                        );
                      }

                      return ListView.builder(
                        itemCount: commentReplies.length,
                        itemBuilder: (context, index) {
                          var reply = commentReplies[index];

                          var data = {
                            "comment": reply.comment,
                            "commentBy": reply.commentBy,
                            "commentTime": reply.commentTime,
                          };

                          return buildListTile(data);
                        },
                      );
                    },
                  );
                }

                return StatefulBuilder(builder: (context, setState) {
                  refreshState = setState;
                  return FutureBuilder(
                    future: GraphqlServices().performQuery(
                      query: isChecklistComment
                          ? JobsSchemas.cheklictRepliesCommentsQuery
                          : JobsSchemas.getCommentReplyQuery,
                      variables: {
                        "commentId": commentId,
                      },
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return BuildShimmerLoadingWidget(
                          height: 30.sp,
                        );
                      }

                      var result = snapshot.data!;

                      if (result.hasException) {
                        return GraphqlServices().handlingGraphqlExceptions(
                          result: result,
                          context: context,
                          setState: setState,
                        );
                      }

                      List replies = [];
                      if (isChecklistComment) {
                        replies = result.data!['listCheckListReplies'];
                      } else {
                        replies = result.data?['getCommentReply'] ?? [];
                      }

                      if (replies.isEmpty) {
                        return const Center(
                          child: Text("No replies yet"),
                        );
                      }

                      return ListView.builder(
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          var reply = replies[index];

                          var data = {
                            "comment": reply['comment'],
                            "commentBy": reply['commentBy'],
                            "commentTime": reply['commentTime'],
                          };

                          return buildListTile(data);
                        },
                      );
                    },
                  );
                });
              }),
            ),
            Row(
              children: [
                SizedBox(
                  width: 5.sp,
                ),
                BuildCommentTextfield(
                  controller: replyTextController,
                  hintText: "Enter reply comment",
                ),
                MutationWidget(
                  options: GrapghQlClientServices().getMutateOptions(
                    document: isChecklistComment
                        ? JobsSchemas.addCheckListCommentReply
                        : JobsSchemas.addCommentReplyMutation,
                    context: context,
                    onCompleted: (data) {
                      if (data == null) {
                        return;
                      }

                      refreshState(
                        () {},
                      );

                      replyTextController.clear();
                    },
                  ),
                  builder: (runMutation, result) {
                    bool isLoading = result?.isLoading ?? false;

                    return IconButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (replyTextController.text.trim().isEmpty) {
                                PlatformServices().showPlatformAlertDialog(
                                  context,
                                  title: "Alert!",
                                  message: "Please add comment",
                                );
                                return;
                              }

                              bool hasInternet = await InterNetServices()
                                  .checkInternetConnectivity();

                              if (!hasInternet) {
                                // ignore: use_build_context_synchronously
                                JobsNoInternetServices()
                                    .addingAttachmentWithCommentsReplies(
                                  context: context,
                                  jobId: jobId,
                                  commentData: commentData,
                                  replyComment: replyTextController.text.trim(),
                                );

                                return;

                                // var jobBox = jobDetailsDbgetBox();

                                // JobDetailsDb? jobDetailsDb = jobBox.values
                                //     .singleWhere(
                                //         (element) => element.id == jobId);

                                // JobComments? selectedComment =
                                //     jobDetailsDb.jobComments?.singleWhereOrNull(
                                //   (element) {
                                //     return element.comment ==
                                //             commentData?['comment'] &&
                                //         element.commentTime ==
                                //             commentData?['commentTime'] &&
                                //         element.commentBy ==
                                //             commentData?['commentBy'];
                                //   },
                                // );

                                // if (selectedComment == null) {
                                //   // ignore: use_build_context_synchronously
                                //   buildSnackBar(
                                //       context: context,
                                //       value: "Selected comment null");

                                //   return;
                                // }

                                // var replies = selectedComment.replies ?? [];

                                // UserDataSingleton userData =
                                //     UserDataSingleton();

                                // String userName = userData.userName;

                                // String domain = userData.domain;

                                // replies.add(
                                //   Replies(
                                //     comment: replyTextController.text.trim(),
                                //     commentBy: "$userName@$domain",
                                //     commentTime:
                                //         DateTime.now().millisecondsSinceEpoch,
                                //   ),
                                // );

                                // int index = jobBox.values
                                //     .toList()
                                //     .indexOf(jobDetailsDb);

                                // jobBox.putAt(index, jobDetailsDb);

                                // var syncBox = syncdbgetBox();

                                // if (selectedComment.id != null) {
                                //   syncBox.add(
                                //     SyncingLocalDb(
                                //       payload: {
                                //         "data": {
                                //           "comment": {
                                //             "id": selectedComment.id,
                                //           },
                                //           "jobId": jobId,
                                //           "reply": {
                                //             "comment":
                                //                 replyTextController.text.trim(),
                                //           }
                                //         }
                                //       },
                                //       generatedTime:
                                //           DateTime.now().millisecondsSinceEpoch,
                                //       graphqlMethod:
                                //           JobsSchemas.addCommentReplyMutation,
                                //     ),
                                //   );

                                //   replyTextController.clear();
                                //   return;
                                // }

                                // for (var element in syncBox.values) {
                                //   // element./

                                //   if (element.graphqlMethod ==
                                //       JobsSchemas.addJobCommentWithAttachment) {
                                //     String replyId = element.payload['replyId'];

                                //     // print(
                                //     //     "=======================================================");
                                //     // print(
                                //     //     "Reply Id $replyId -- ${selectedComment?.commentBy}/${selectedComment?.commentTime}");
                                //     // print(
                                //     //     "=======================================================");

                                //     if ("${selectedComment.commentBy}/${selectedComment.commentTime}" ==
                                //         replyId) {
                                //       Map<String, dynamic> payload =
                                //           element.payload;

                                //       if (payload['repliesPayload'] == null) {
                                //         payload['repliesPayload'] = [
                                //           {
                                //             "data": {
                                //               "comment": {
                                //                 // "id": 10,
                                //               },
                                //               "jobId": jobId,
                                //               "reply": {
                                //                 "comment": replyTextController
                                //                     .text
                                //                     .trim(),
                                //               }
                                //             }
                                //           },
                                //         ];
                                //       } else {
                                //         payload['repliesPayload'].add(
                                //           {
                                //             "data": {
                                //               "comment": {
                                //                 // "id": widget.comment.id,
                                //               },
                                //               "jobId": jobId,
                                //               "reply": {
                                //                 "comment": replyTextController
                                //                     .text
                                //                     .trim(),
                                //               }
                                //             }
                                //           },
                                //         );
                                //       }

                                //       //  pay

                                //       int index = syncBox.values
                                //           .toList()
                                //           .indexOf(element);

                                //       syncBox.putAt(
                                //         index,
                                //         SyncingLocalDb(
                                //           payload: payload,
                                //           generatedTime: element.generatedTime,
                                //           graphqlMethod: element.graphqlMethod,
                                //         ),
                                //       );
                                //     }

                                //     // String comment =
                                //     //     data['comment']['comment'];
                                //   }
                                // }

                                // print("Success");

                                // replyTextController.clear();

                                // return;
                              }

                              if (isChecklistComment) {
                                runMutation(
                                  {
                                    "checkListReply": {
                                      "checklistId": checklistId,
                                      "comment": {
                                        "id": commentId,
                                      },
                                      "jobId": jobId,
                                      "reply": {
                                        "comment":
                                            replyTextController.text.trim(),
                                      }
                                    }
                                  },
                                );
                                return;
                              }

                              runMutation({
                                "data": {
                                  "comment": {
                                    "id": commentId,
                                  },
                                  "jobId": jobId,
                                  "reply": {
                                    "comment": replyTextController.text.trim(),
                                  }
                                },
                              });
                            },
                      icon: isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : const Icon(Icons.send),
                    );
                  },
                )
              ],
            ),
            KeyboardVisibilityBuilder(builder: (
              context,
              isVisible,
            ) {
              return SizedBox(
                height: isVisible ? 0 : 20.sp,
              );
            }),
          ],
        ));
  }

  // ==================================================================================

  Widget buildCommentWidget(BuildContext context) {
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        if (!state.isInternetAvailable) {
          if (commentData == null) {
            return const Center(
              child: Text("Comment Not found"),
            );
          }

          return buildListTile(
            commentData ?? {},
          );
        }

        return QueryWidget(
          options: GrapghQlClientServices().getQueryOptions(
            document: isChecklistComment
                ? JobsSchemas.findChecklistJobComment
                : JobsSchemas.findJobComment,
            variables: {
              "commentId": commentId,
            },
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return Padding(
                padding: EdgeInsets.only(top: 3.sp),
                child: ShimmerLoadingContainerWidget(height: 40.sp),
              );
            }

            if (result.hasException) {
              return GrapghQlClientServices().handlingGraphqlExceptions(
                result: result,
                context: context,
                refetch: refetch,
              );
            }

            print(result.data);

            return buildListTile(
              result.data?[isChecklistComment
                      ? "findJobChecklistComment"
                      : "findJobComment"] ??
                  {},
            );
          },
        );
      },
    );
  }

  Widget buildListTile(Map data) {
    return Builder(builder: (context) {
      return ListTile(
        contentPadding: EdgeInsets.only(left: 15.sp, right: 5.sp),
        minVerticalPadding: 0,
        leading: CircleAvatar(
          child: Text(shortLetterConverter(data['commentBy'] ?? "N/A")),
        ),
        title: Text(
          data['commentBy'] ?? "N/A",
          style: TextStyle(
            fontSize: 10.sp,
          ),
        ),
        subtitle: Text(
          data["comment"] ?? "N/A",
          style: TextStyle(
            fontSize: 11.sp,
          ),
        ),
        trailing: Text(
          data['commentTime'] == null
              ? "N/A"
              : timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(data['commentTime']!),
                ),
          style: TextStyle(
            fontSize: 8.sp,
          ),
        ),
      );
    });
  }
}
