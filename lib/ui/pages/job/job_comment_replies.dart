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
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/skelton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:collection/collection.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import '../../../utils/themes/colors.dart';

class JobCommentRepliesScreen extends StatefulWidget {
  JobCommentRepliesScreen(
      {required this.jobId,
      required this.jobDomain,
      required this.comment,
      this.replyId,
      super.key});

  final GetAllComments comment;
  final int jobId;
  final String jobDomain;
  final int? replyId;

  @override
  State<JobCommentRepliesScreen> createState() =>
      _JobCommentRepliesScreenState();
}

class _JobCommentRepliesScreenState extends State<JobCommentRepliesScreen> {
  final TextEditingController commentController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _scrollController = ScrollController();
  late final AnimationController _animationController;

  UserDataSingleton userData = UserDataSingleton();

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     var syncBox = syncdbgetBox();

      //     for (var element in syncBox.values) {
      //       print(element.payload);
      //       print("========");
      //     }
      //   },
      // ),
      appBar: const GradientAppBar(
        title: "Replies",
      ),
      // AppBar(
      //   title: const Text("Replies"),
      // ),
      body: Column(
        children: [
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

              return StatefulBuilder(builder: (context, setState) {
                return FutureBuilder(
                  future: GraphqlServices().performQuery(
                      query: JobsSchemas.getCommentReplyQuery,
                      variables: {
                        "commentId": widget.comment.id,
                      }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildLoadingWidget();
                    }

                    var result = snapshot.data!;

                    if (result.hasException) {
                      return GraphqlServices().handlingGraphqlExceptions(
                        result: result,
                        context: context,
                        setState: setState,
                      );
                    }

                    CommentReply commentReply =
                        CommentReply.fromJson(result.data!);

                    List<GetCommentReply> replies =
                        commentReply.getCommentReply ?? [];

                    return buildRepliesbuilder(replies);
                  },
                );
              });
            }),
          ),
          buildTextfieldwithSendWidget(context),
          SizedBox(
            height: 10.sp,
          ),
        ],
      ),
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

        JobComments? jobComment = jobDetailsDb.jobComments!.singleWhereOrNull(
          (element) {
            return element.commentTime == widget.comment.commentTime;
            //     &&
            // element.commentBy == widget.comment.commentBy;
          },
        );

        if (jobComment == null) {
          return const Center(
            child: Text("Comments not found"),
          );
        }
        // print("Comment");
        // print(jobComment.comment);

        var commentReplies = jobComment.replies ?? [];

        var replies = commentReplies
            .map((e) => GetCommentReply.fromJson(e.toJson()))
            .toList();

        return buildRepliesbuilder(
          replies,
        );
      },
    );
  }

  Widget buildRepliesbuilder(List<GetCommentReply> replies) {
    ItemScrollController itemScrollController = ItemScrollController();
    int repliedIndex = 0;

    if (widget.replyId != null) {
      repliedIndex = replies.indexWhere(
        (element) => element.id == widget.replyId,
      );

      if (repliedIndex != -1) {
        Future.delayed(
          const Duration(seconds: 0),
          () {
            itemScrollController.scrollTo(
              index: repliedIndex,
              duration: const Duration(milliseconds: 500),
            );
          },
        );
      }
    }

    return ScrollablePositionedList.builder(
      itemCount: replies.length,
      itemScrollController: itemScrollController,
      // padding: EdgeInsets.symmetric(horizontal: 5.sp),
      itemBuilder: (context, index) {
        GetCommentReply reply = replies[index];

        if (widget.replyId != null &&
            repliedIndex != -1 &&
            index == repliedIndex) {
          return buildListTile(
            name: reply.commentBy ?? "N/A",
            comment: reply.comment ?? "N/A",
            formatedDateTime: reply.commentTime == null
                ? "N/A"
                : timeago.format(
                    DateTime.fromMillisecondsSinceEpoch(reply.commentTime!),
                  ),
            highlight: true,
          );
        }

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

  Row buildTextfieldwithSendWidget(BuildContext context) {
    return Row(
      children: [
        Form(
          key: formKey,
          child: BuildCommentTextfield(
            controller: commentController,
            hintText: "Enter reply comment",
          ),
        ),
        IconButton(
          onPressed: () async {
            bool isValid = formKey.currentState!.validate();

            if (isValid) {
              Box<JobDetailsDb> jobBox = jobDetailsDbgetBox();
              Box<SyncingLocalDb> syncBox = syncdbgetBox();

              bool hasInternet =
                  await InterNetServices().checkInternetConnectivity();

              if (!hasInternet) {
                // syncBox

                JobDetailsDb? jobDetailsDb = jobBox.values
                    .singleWhere((element) => element.id == widget.jobId);

                JobComments? selectedComment =
                    jobDetailsDb.jobComments?.singleWhereOrNull(
                  (element) =>
                      element.comment == widget.comment.comment &&
                      element.commentTime == widget.comment.commentTime &&
                      element.commentBy == widget.comment.commentBy,
                );

                // print("Selected comment text is ${selectedComment?.comment}");

                if (selectedComment == null) {
                  // ignore: use_build_context_synchronously
                  buildSnackBar(
                      context: context, value: "Something went wrong");

                  return;
                }

                var replies = selectedComment.replies ?? [];

                String userName = userData.userName;

                String domain = userData.domain;

                replies.add(
                  Replies(
                    comment: commentController.text.trim(),
                    commentBy: "$userName@$domain",
                    commentTime: DateTime.now().millisecondsSinceEpoch,
                  ),
                );

                // jobBox.values.toList()
                //     .indexWhere((element) =>
                //         element.id == widget.jobId);

                int index = jobBox.values.toList().indexOf(jobDetailsDb);

                jobBox.putAt(index, jobDetailsDb);

                if (selectedComment.id != null) {
                  // buildSnackBar(context: context, value: "Comment Id not null");
                  syncBox.add(
                    SyncingLocalDb(
                      payload: {
                        "data": {
                          "comment": {
                            "id": selectedComment.id,
                          },
                          "jobId": widget.jobId,
                          "reply": {
                            "comment": commentController.text.trim(),
                          }
                        }
                      },
                      generatedTime: DateTime.now().millisecondsSinceEpoch,
                      graphqlMethod: JobsSchemas.addCommentReplyMutation,
                    ),
                  );

                  commentController.clear();
                  return;
                }

                for (var element in syncBox.values) {
                  // element./

                  if (element.graphqlMethod ==
                      JobsSchemas.addJobCommentMutation) {
                    String replyId = element.payload['replyId'];

                    if ("${selectedComment.commentBy}/${selectedComment.commentTime}" ==
                        replyId) {
                      Map<String, dynamic> payload = element.payload;

                      if (payload['repliesPayload'] == null) {
                        payload['repliesPayload'] = [
                          {
                            "data": {
                              "comment": {
                                "id": widget.comment.id,
                              },
                              "jobId": widget.jobId,
                              "reply": {
                                "comment": commentController.text.trim(),
                              }
                            }
                          },
                        ];
                      } else {
                        payload['repliesPayload'].add(
                          {
                            "data": {
                              "comment": {
                                // "id": widget.comment.id,
                              },
                              "jobId": widget.jobId,
                              "reply": {
                                "comment": commentController.text.trim(),
                              }
                            }
                          },
                        );
                      }

                      //  pay

                      int index = syncBox.values.toList().indexOf(element);

                      syncBox.putAt(
                        index,
                        SyncingLocalDb(
                          payload: payload,
                          generatedTime: element.generatedTime,
                          graphqlMethod: element.graphqlMethod,
                        ),
                      );
                    }

                    // String comment =
                    //     data['comment']['comment'];
                  }
                }

                commentController.clear();

                return;
              }

              // ignore: use_build_context_synchronously
              var result = await GraphqlServices().performMutation(
                context: context,
                query: JobsSchemas.addCommentReplyMutation,
                variables: {
                  "data": {
                    "comment": {
                      "id": widget.comment.id,
                    },
                    "jobId": widget.jobId,
                    "reply": {
                      "comment": commentController.text.trim(),
                    }
                  }
                },
              );

              commentController.clear();

              if (result.hasException) {
                // ignore: use_build_context_synchronously
                buildSnackBar(
                  context: context,
                  value: "Something went wrong",
                );
                return;
              }

              setState(() {});
            }
          },
          icon: const Icon(
            Icons.send,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  ListTile buildListTile({
    required String name,
    required String comment,
    required String formatedDateTime,
    bool highlight = false,
  }) {
    String letter = shortLetterConverter(name);

    return ListTile(
      contentPadding: EdgeInsets.only(left: 15.sp, right: 5.sp),
      tileColor: highlight
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.25)
          : null,
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
