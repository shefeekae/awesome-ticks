import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/models/comment_replies_model.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/models/job_comments_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_widget.dart';
import 'package:awesometicks/ui/shared/functions/short_letter_converter.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/ui/shared/widgets/skelton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:collection/collection.dart';

class ChecklistCommentRepliesWidget extends StatefulWidget {
  ChecklistCommentRepliesWidget(
      {required this.jobId,
      required this.jobDomain,
      required this.comment,
      required this.checklistId,
      super.key});

  final GetAllComments comment;
  final int jobId;
  final String jobDomain;
  final int checklistId;

  @override
  State<ChecklistCommentRepliesWidget> createState() =>
      _ChecklistCommentRepliesWidgetState();
}

class _ChecklistCommentRepliesWidgetState
    extends State<ChecklistCommentRepliesWidget> {
  final TextEditingController commentController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime now = DateTime.now();

  UserDataSingleton userData = UserDataSingleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 8.sp,
        ),
        CommentWidget(
          isReplyScreen: true,
          comment: widget.comment,
          jobId: widget.jobId,
          jobDomain: widget.jobDomain,
        ),
        Expanded(
          child: BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
              builder: (context, state) {
            bool internetAvailable = state.isInternetAvailable;

            if (!internetAvailable) {
              //  return ValueListenableBuilder(
              //       valueListenable: ,
              //       builder: (context, value, child) {

              //  },);

              return fetchingfromLocalDb();
            }

            return FutureBuilder(
              future: GraphqlServices().performQuery(
                  query: JobsSchemas.cheklictRepliesCommentsQuery,
                  variables: {
                    "commentId": widget.comment.id,
                  }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoadingWidget();
                }

                var result = snapshot.data!;

                // CommentReply commentReply =
                //     CommentReply.fromJson(result.data!);

                List results = result.data?['listCheckListReplies'] ?? [];

                results.sort(
                  (a, b) => b['commentTime'].compareTo(a['commentTime']),
                );

                List<GetCommentReply> replies = results
                    .map((e) => GetCommentReply(
                          comment: e['comment'],
                          commentBy: e['commentBy'],
                          commentTime: e['commentTime'],
                        ))
                    .toList();
                // commentReply.getCommentReply ?? [];

                return buildRepliesbuilder(replies);
              },
            );
          }),
        ),
        buildTextfieldwithSendWidget(context),
        SizedBox(
          height: 20.sp,
        ),
      ],
    );
  }

  ValueListenableBuilder<Box<JobDetailsDb>> fetchingfromLocalDb() {
    return ValueListenableBuilder(
      valueListenable: jobDetailsDbgetBox().listenable(),
      builder: (context, box, _) {
        JobDetailsDb? jobDetailsDb = box.values
            .singleWhereOrNull((element) => element.id == widget.jobId);

        if (jobDetailsDb == null) {
          return const Center(
            child: Text(
              "No replies yet",
            ),
          );
        }

        print(widget.comment.commentBy);
        print(widget.comment.commentTime);
        print("===========================================");

        var jobChecklist = jobDetailsDb.checklistDb!.singleWhereOrNull(
          (element) {
            // print(element.commentBy);
            // print(element.commentTime);

            return element.id == widget.checklistId;
            //     &&
            // element.commentBy == widget.comment.commentBy;
          },
        );

        if (jobChecklist == null) {
          return const Center(
            child: Text("Comments not found"),
          );
        }
        // print("Comment");
        // print(jobComment.comment);

        var checklistComment =
            jobChecklist.comments?.singleWhereOrNull((element) {
          return element.id == widget.comment.id;
        });

        List<Replies> replies = checklistComment?.replies ?? [];

        var repliesList =
            replies.map((e) => GetCommentReply.fromJson(e.toJson())).toList();

        return buildRepliesbuilder(
          repliesList,
        );
      },
    );
  }

  // ===========================================================================

  ListView buildRepliesbuilder(List<GetCommentReply> replies) {
    return ListView.builder(
      itemCount: replies.length,
      padding: EdgeInsets.symmetric(horizontal: 5.sp),
      itemBuilder: (context, index) {
        GetCommentReply reply = replies[index];

        return buildListTile(
          name: reply.commentBy ?? "N/A",
          comment: reply.comment ?? "N/A",
          formatedDateTime: reply.commentTime == null
              ? "N/A"
              : timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(reply.commentTime!),
                ),
        );
      },
    );
  }

  ListView buildLoadingWidget() {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 10.sp,
        );
      },
      itemBuilder: (context, index) {
        return buildSkeleton(context);
      },
    );
  }

  Widget buildTextfieldwithSendWidget(BuildContext context) {
    ValueNotifier sendButtonNotifier = ValueNotifier(false);
    ValueNotifier commentAddingLoadingNotifier = ValueNotifier(false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 5.sp),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.sp),
            border: Border.all(color: Colors.grey.shade300)),
        child: ValueListenableBuilder(
            valueListenable: commentAddingLoadingNotifier,
            builder: (context, loadingValue, child) {
              if (loadingValue) {
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
                        const Text("Posting reply"),
                      ],
                    ),
                  ),
                );
              }

              return Row(
                children: [
                  Form(
                    key: formKey,
                    child: BuildCommentTextfield(
                      onChanged: (value) {
                        sendButtonNotifier.value = value.trim().isNotEmpty;
                      },
                      controller: commentController,
                      hintText: "Enter reply ",
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: sendButtonNotifier,
                      builder: (context, value, child) {
                        return IconButton(
                          onPressed: value
                              ? () async {
                                  bool isValid =
                                      formKey.currentState!.validate();

                                  var syncBox = syncdbgetBox();
                                  var jobBox = jobDetailsDbgetBox();

                                  if (isValid) {
                                    commentAddingLoadingNotifier.value = true;
                                    bool hasInternet = await InterNetServices()
                                        .checkInternetConnectivity();

                                    if (!hasInternet) {
                                      // syncBox

                                      JobDetailsDb? jobDetailsDb = jobBox.values
                                          .singleWhere((element) =>
                                              element.id == widget.jobId);

                                      ChecklistDb? checklistDb = jobDetailsDb
                                          .checklistDb
                                          ?.singleWhereOrNull((element) =>
                                              element.id == widget.checklistId);

                                      var checklistComments =
                                          checklistDb?.comments ?? [];

                                      var selectedComment =
                                          checklistComments.singleWhereOrNull(
                                        (element) =>
                                            element.comment ==
                                                widget.comment.comment &&
                                            element.commentBy ==
                                                widget.comment.commentBy &&
                                            element.commentTime ==
                                                widget.comment.commentTime,
                                      );

                                      // print(selectedComment?.replies?.length);

                                      var replies =
                                          selectedComment?.replies ?? [];

                                      String userName = userData.userName;

                                      String domain = userData.domain;

                                      replies.add(
                                        Replies(
                                          comment:
                                              commentController.text.trim(),
                                          commentBy: "$userName@$domain",
                                          commentTime:
                                              now.millisecondsSinceEpoch,
                                        ),
                                      );

                                      // jobBox.values.toList()
                                      //     .indexWhere((element) =>
                                      //         element.id == widget.jobId);

                                      int index = jobBox.values
                                          .toList()
                                          .indexOf(jobDetailsDb);

                                      jobBox.putAt(index, jobDetailsDb);

                                      if (selectedComment?.id != null) {
                                        // buildSnackBar(
                                        //     context: context,
                                        //     value: "Comment Id not null");
                                        syncBox.add(SyncingLocalDb(
                                          payload: {
                                            "checkListReply": {
                                              "checklistId": widget.checklistId,
                                              "comment": {
                                                "id": selectedComment!.id,
                                              },
                                              "jobId": widget.jobId,
                                              "reply": {
                                                "comment": commentController
                                                    .text
                                                    .trim(),
                                              }
                                            }
                                          },
                                          generatedTime:
                                              now.millisecondsSinceEpoch,
                                          graphqlMethod: JobsSchemas
                                              .addCheckListCommentReply,
                                        ));

                                        commentController.clear();

                                        return;
                                      }

                                      for (var element in syncBox.values) {
                                        // element./

                                        if (element.graphqlMethod ==
                                            JobsSchemas.addChecklistComment) {
                                          print("IF CASE IS is Working");
                                          String replyId =
                                              element.payload['replyId'];

                                          print(
                                              "=======================================================");
                                          print(
                                              "Reply Id $replyId -- ${selectedComment?.commentBy}/${selectedComment?.commentTime}");
                                          print(
                                              "=======================================================");

                                          if ("${selectedComment?.commentBy}/${selectedComment?.commentTime}" ==
                                              replyId) {
                                            Map<String, dynamic> payload =
                                                element.payload;

                                            if (payload['repliesPayload'] ==
                                                null) {
                                              payload['repliesPayload'] = [
                                                {
                                                  "checkListReply": {
                                                    "checklistId":
                                                        widget.checklistId,
                                                    "comment": {
                                                      // "id": comment.id,
                                                    },
                                                    "jobId": widget.jobId,
                                                    "reply": {
                                                      "comment":
                                                          commentController.text
                                                              .trim(),
                                                    }
                                                  }
                                                },
                                              ];
                                            } else {
                                              payload['repliesPayload'].add(
                                                {
                                                  "checkListReply": {
                                                    "checklistId":
                                                        widget.checklistId,
                                                    "comment": {
                                                      // "id": comment.id,
                                                    },
                                                    "jobId": widget.jobId,
                                                    "reply": {
                                                      "comment":
                                                          commentController.text
                                                              .trim(),
                                                    }
                                                  }
                                                },
                                              );
                                            }

                                            //  pay

                                            int index = syncBox.values
                                                .toList()
                                                .indexOf(element);

                                            syncBox.putAt(
                                              index,
                                              SyncingLocalDb(
                                                payload: payload,
                                                generatedTime:
                                                    element.generatedTime,
                                                graphqlMethod:
                                                    element.graphqlMethod,
                                              ),
                                            );
                                          }

                                          // String comment =
                                          //     data['comment']['comment'];
                                        }
                                      }

                                      commentController.clear();
                                      sendButtonNotifier.value = false;
                                      commentAddingLoadingNotifier.value =
                                          false;
                                      return;
                                    }

                                    var result =
                                        // ignore: use_build_context_synchronously
                                        await GraphqlServices().performMutation(
                                      context: context,
                                      query:
                                          JobsSchemas.addCheckListCommentReply,
                                      variables: {
                                        "checkListReply": {
                                          "checklistId": widget.checklistId,
                                          "comment": {
                                            "id": widget.comment.id,
                                          },
                                          "jobId": widget.jobId,
                                          "reply": {
                                            "comment":
                                                commentController.text.trim(),
                                          }
                                        }
                                      },
                                    );

                                    if (result.hasException) {
                                      buildSnackBar(
                                          context: context,
                                          value: "Something went wrong !!");
                                      commentAddingLoadingNotifier.value =
                                          false;
                                      return;
                                    }

                                    commentController.clear();
                                    sendButtonNotifier.value = false;
                                    commentAddingLoadingNotifier.value = false;
                                    setState(() {});
                                  }
                                }
                              : null,
                          icon: const Icon(
                            Icons.send,
                          ),
                        );
                      }),
                ],
              );
            }),
      ),
    );
  }

  // ============================================================================
  ListTile buildListTile({
    required String name,
    required String comment,
    required String formatedDateTime,
  }) {
    String letter = shortLetterConverter(name);

    return ListTile(
      contentPadding: EdgeInsets.only(left: 15.sp),
      minVerticalPadding: 0,
      leading: CircleAvatar(
        child: Text(letter),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 10.sp,
        ),
      ),
      subtitle: Text(
        comment,
        style: TextStyle(
          fontSize: 11.sp,
        ),
      ),
      trailing: Text(
        formatedDateTime,
        style: TextStyle(
          fontSize: 8.sp,
        ),
      ),
    );
  }
}
