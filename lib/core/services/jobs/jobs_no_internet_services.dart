import 'package:flutter/cupertino.dart';
import 'package:secure_storage/secure_storage.dart';
import '../../../ui/shared/widgets/custom_snackbar.dart';
import '../../models/hive db/list_jobs_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import '../../models/hive db/syncing_local_db.dart';
import '../../schemas/jobs_schemas.dart';

class JobsNoInternetServices {
// ========================
// Adding comment to Local db

  void addingCommentWithJobAttachment({
    required BuildContext context,
    required int jobId,
    required String comment,
    required String fileName,
    required String base64EncodeData,
    required String attachingFilePath,
    required Map<String, dynamic>? attachedFileData,
    required String attachmentCategoryKey,
    required String allAttachmentsFilePath,
    required Map<String, dynamic> commentData,
  }) {
    UserDataSingleton userData = UserDataSingleton();

    var jobsList = jobDetailsDbgetBox().values.toList();

    JobDetailsDb? jobDetailsDb =
        jobsList.singleWhereOrNull((element) => element.id == jobId);

    if (jobDetailsDb == null) {
      // ignore: use_build_context_synchronously
      buildSnackBar(
        context: context,
        value: "Something went wrong!",
      );

      return;
    }

    DateTime now = DateTime.now();

    int commentTime = now.millisecondsSinceEpoch;

    if (comment.trim().isNotEmpty) {
      jobDetailsDb.jobComments!.add(
        JobComments(
          comment: comment,
          commentBy: "${userData.userName}@${userData.domain}",
          commentTime: commentData['commentTime'],
        ),
      );
    }

    var box = syncdbgetBox();

    int index = box.values.toList().indexWhere(
          (element) => element.generatedTime == attachedFileData?['id'],
        );

    if (index != -1) {
      box.putAt(
        index,
        SyncingLocalDb(
          payload: {
            "replyId":
                "${userData.userName}@${userData.domain}/${commentData["commentTime"]}",
            "attachmentData": {
              "id": commentTime,
              "commentAvailable": comment.isNotEmpty,
              "path": attachingFilePath,
              "fileName": fileName,
              "data": base64EncodeData,
              "uploadedTime": now.toIso8601String(),
            },
            "data": {
              "data": {
                "comment": {
                  "comment": {
                    "comment": commentData['comment'],
                    "commentTime": commentData['commentTime'],
                    "commentBy": commentData['commentBy'],
                  },
                
                  "jobId": jobId,
                },
                "filePath": allAttachmentsFilePath,
                "subPath": attachmentCategoryKey.isEmpty
                    ? ""
                    : "/$attachmentCategoryKey",
              }
            },
          },
          generatedTime: commentTime,
          graphqlMethod: JobsSchemas.addJobCommentWithAttachment,
        ),
      );
    }

    // if (context.mounted) {
    //   Navigator.of(context).pop();
    // }
  }

// //  ==============================================================================================
// // Adding attachment to local db. If comment is available comment also saving to local db.

  void addingAttachmentWithComment({
    required BuildContext context,
    required int jobId,
    required String comment,
    required String fileName,
    required String base64EncodeData,
    required String attachingFilePath,
    required String attachmentCategoryKey,
    required String allAttachmentsFilePath,

    // required Map<String, dynamic> payload,
  }) {
    UserDataSingleton userData = UserDataSingleton();

    var jobsList = jobDetailsDbgetBox().values.toList();

    JobDetailsDb? jobDetailsDb =
        jobsList.singleWhereOrNull((element) => element.id == jobId);

    if (jobDetailsDb == null) {
      // ignore: use_build_context_synchronously
      buildSnackBar(
        context: context,
        value: "Something went wrong!",
      );

      return;
    }

    DateTime now = DateTime.now();

    int commentTime = now.millisecondsSinceEpoch;

    if (comment.trim().isNotEmpty) {
      jobDetailsDb.jobComments!.add(
        JobComments(
          comment: comment.trim(),
          commentBy: "${userData.userName}@${userData.domain}",
          commentTime: commentTime,
        ),
      );
    }

    var box = syncdbgetBox();

    box.add(
      SyncingLocalDb(
        payload: {
          "replyId": "${userData.userName}@${userData.domain}/$commentTime",
          "attachmentData": {
            "id": commentTime,
            "commentAvailable": comment.trim().isNotEmpty,
            "path": attachingFilePath,
            "fileName": fileName,
            "data": base64EncodeData,
            "uploadedTime": now.toIso8601String(),
          },
          "data": {
            "data": {
              "comment": comment.isEmpty
                  ? null
                  : {
                      "comment": {
                        "comment": comment,
                        "commentBy": "${userData.userName}@${userData.domain}",
                        "commentTime": commentTime,
                      },
                      "jobId": jobId,
                    },
              "filePath": allAttachmentsFilePath,
              "subPath": attachmentCategoryKey.isEmpty
                  ? ""
                  : "/$attachmentCategoryKey",
            }
          },
        },
        generatedTime: commentTime,
        graphqlMethod: JobsSchemas.addJobCommentWithAttachment,
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    return;
  }

//  ====================
//  Adding replies to local db. attachment against comment replies

  void addingAttachmentWithCommentsReplies({
    required BuildContext context,
    required int jobId,
    required Map<String, dynamic>? commentData,
    required String replyComment,
  }) {
    var jobBox = jobDetailsDbgetBox();

    var jobDetailsDb =
        jobBox.values.singleWhere((element) => element.id == jobId);

    var selectedComment = jobDetailsDb.jobComments?.singleWhereOrNull(
      (element) =>
          element.comment == commentData?['comment'] &&
          element.commentTime == commentData?['commentTime'] &&
          element.commentBy == commentData?['commentBy'],
    );

    if (selectedComment == null) {
      // ignore: use_build_context_synchronously
      buildSnackBar(context: context, value: "Something went wrong");

      return;
    }

    var replies = selectedComment.replies ?? [];

    DateTime now = DateTime.now();

    UserDataSingleton userData = UserDataSingleton();

    String userName = userData.userName;

    String domain = userData.domain;

    replies.add(
      Replies(
        comment: replyComment,
        commentBy: "$userName@$domain",
        commentTime: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    int index = jobBox.values.toList().indexOf(jobDetailsDb);

    int? commentIndex = jobDetailsDb.jobComments
        ?.indexWhere((element) => element == selectedComment);

    if (commentIndex != null) {
      jobDetailsDb.jobComments?[commentIndex].replies = replies;
    }

    jobBox.putAt(index, jobDetailsDb);

    var syncBox = syncdbgetBox();

    if (selectedComment.id != null) {
      syncBox.add(
        SyncingLocalDb(
          payload: {
            "data": {
              "comment": {
                "id": selectedComment.id,
              },
              "jobId": jobId,
              "reply": {
                "comment": replyComment.trim(),
              }
            }
          },
          generatedTime: now.millisecondsSinceEpoch,
          graphqlMethod: JobsSchemas.addCommentReplyMutation,
        ),
      );

      return;
    }

    for (var element in syncBox.values) {
      if (element.graphqlMethod == JobsSchemas.addJobCommentWithAttachment) {
        String replyId = element.payload['replyId'];

        if ("${selectedComment.commentBy}/${selectedComment.commentTime}" ==
            replyId) {
          Map<String, dynamic> payload = element.payload;


          if (payload['repliesPayload'] == null) {
            payload['repliesPayload'] = [
              {
                "data": {
                  "comment": {},
                  "jobId": jobId,
                  "reply": {
                    "comment": replyComment.trim(),
                  }
                }
              },
            ];
          } else {
            payload['repliesPayload'].add(
              {
                "data": {
                  "comment": {},
                  "jobId": jobId,
                  "reply": {
                    "comment": replyComment.trim(),
                  }
                }
              },
            );
          }

          int index = syncBox.values.toList().indexOf(element);

          payload['data']['data']['comment']['comment'].remove("replies");

          syncBox.putAt(
            index,
            SyncingLocalDb(
              payload: payload,
              generatedTime: element.generatedTime,
              graphqlMethod: element.graphqlMethod,
            ),
          );
        }
      }
    }
  }
}
