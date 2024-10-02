import 'dart:convert';
import 'dart:typed_data';
import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/jobs/jobs_no_internet_services.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:files_viewer/files_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/blocs/attachments/attachments_controller_bloc.dart';
import '../../../../core/models/hive db/list_jobs_model.dart';
import '../../../../core/services/jobs/jobs_services.dart';
import '../../../../core/services/theme_services.dart';
import '../../../../utils/themes/colors.dart';
import 'details_card.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';

class BeforeAfterAttachmentsWidget extends StatelessWidget {
  const BeforeAfterAttachmentsWidget({
    super.key,
    required this.attachmentsControllerBloc,
    required this.title,
    required this.attachmentCategoryKey,
    required this.attachingFilePath,
    required this.serviceRequestNumber,
  });

  final AttachmentsControllerBloc attachmentsControllerBloc;
  final String title;
  final String attachmentCategoryKey;
  final String attachingFilePath;
  final String? serviceRequestNumber;

  @override
  Widget build(BuildContext context) {
    return BuildDetailsCard(
      title: title,
      // value: job?.jobNumber ?? "N/A",
      children: [
        SizedBox(
          height: 50.sp,
          child: BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
              builder: (context, state) {
            if (!state.isInternetAvailable) {
              return ValueListenableBuilder(
                valueListenable: syncdbgetBox().listenable(),
                builder: (context, box, _) {
                  var splitedList = attachingFilePath.split("/");

                  int jobId = int.parse(splitedList[2]);

                  JobDetailsDb? jobDetailsDb = jobDetailsDbgetBox()
                      .values
                      .singleWhereOrNull((element) => element.id == jobId);

                  var list = box.values
                      .where(
                        (element) =>
                            element.graphqlMethod ==
                                JobsSchemas.addJobCommentWithAttachment &&
                            element.payload.containsKey('attachmentData'),
                      )
                      .toList();

                  List filteredList = list.map((e) {
                    var data = e.payload['attachmentData'];

                    Map<dynamic, dynamic>? commentData =
                        e.payload['data']?['data']?['comment']?['comment'];

                    if (commentData != null) {
                      JobComments? jobComment =
                          jobDetailsDb?.jobComments?.singleWhereOrNull(
                        (element) {
                          return element.commentTime ==
                              commentData['commentTime'];
                        },
                      );

                      data?['commentData'] = commentData;

                      if (jobComment != null) {
                        List<Replies> replies = jobComment.replies ?? [];

                        data['commentData']['replies'] = replies
                            .map((e) => {
                                  "comment": e.comment,
                                  "commentBy": e.commentBy,
                                  "commentTime": e.commentTime,
                                })
                            .toList();
                      }
                    }

                    return data;
                  }).where((element) {
                    int pathJobId =
                        int.parse(element['path'].toString().split("/")[2]);

                    return element['path']
                            .toString()
                            .contains(attachmentCategoryKey) &&
                        pathJobId == jobId;
                  }).toList();

                  return buildListviewBuilder(
                    filteredList,
                    noInternet: true,
                  );
                },
              );
            }

            return BlocBuilder<AttachmentsControllerBloc,
                AttachmentsControllerState>(
              builder: (context, state) {
                // List<String> attachmentsPath = [
                //   "https://media-cdn.tripadvisor.com/media/photo-s/06/e3/fa/91/rosemead-guest-house.jpg",
                // ];

                if (state.isLoading) {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ShimmerLoadingContainerWidget(
                        height: 50.sp,
                        width: 50.sp,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 5.sp,
                      );
                    },
                    itemCount: 5,
                  );
                }

                List filteredList =
                    attachmentsControllerBloc.state.allData.where((element) {
                  return element['path']
                      .toString()
                      .contains(attachmentCategoryKey);
                }).toList();

                return buildListviewBuilder(filteredList);
              },
            );
          }),
        )
      ],
      // value: job?.id != null ? job!.id.toString() : "N/A",
    );
  }

  // ============================================================================================

  ListView buildListviewBuilder(
    List<dynamic> filteredList, {
    bool noInternet = false,
  }) {
    return ListView.separated(
      itemCount: filteredList.length + 1,
      scrollDirection: Axis.horizontal,
      separatorBuilder: (context, index) {
        return SizedBox(
          width: 5.sp,
        );
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildAddButton(context);
        }

        var map = filteredList[index - 1];

        String extension = map['fileName'].split('.').last;
        String fileName = path.basename(map['fileName']);

        return Bounce(
          duration: const Duration(milliseconds: 100),
          onPressed: () async {
            var list = attachingFilePath.split("/");

            String jobDomain = list[1];

            int jobId = int.parse(list[2]);

          bool? changed =  await Navigator.of(context).push<bool?>(MaterialPageRoute(
              builder: (context) => FilesViewerWithSwipeScreen(
                items: filteredList,
                initilaIndex: index - 1,
                internetAvailable: !noInternet,
                noInternetCommentSaving:
                    (fileDataModel, comment, isReplyComment) {
                  var commentData = fileDataModel.commentData?.toJson() ?? {};

                  if (isReplyComment) {
                    JobsNoInternetServices()
                        .addingAttachmentWithCommentsReplies(
                      context: context,
                      jobId: jobId,
                      commentData: commentData,
                      replyComment: comment,
                    );
                    return;
                  }

                  JobsNoInternetServices().addingCommentWithJobAttachment(
                    context: context,
                    jobId: jobId,
                    comment: comment,
                    fileName: fileName,
                    base64EncodeData: fileDataModel.base64Encoded,
                    attachingFilePath: attachingFilePath,
                    attachedFileData: {
                      "filePath": fileDataModel.filePath,
                      "fileName": fileDataModel.fileName,
                      "id": fileDataModel.dateTime,
                    },
                    commentData: commentData,
                    attachmentCategoryKey: attachmentCategoryKey,
                    allAttachmentsFilePath: "jobs/$jobDomain/$jobId",
                  );
                },
              ),
            ));

            if (changed ?? false) {
  JobsServices().addJobAttachmentsToBlocState(
    jobAttachmentFilePath: "jobs/$jobDomain/$jobId",
    attachmentCategoryKey: "",
    serviceRequestAttachmentFilePath: serviceRequestNumber == null
        ? null
        : "serviceRequests/$jobDomain/$serviceRequestNumber",
  );
}
          },
          child: Builder(
            builder: (context) {
              String filePath = map['path'];

              bool commentAvailable = noInternet
                  ? map['commentAvailable']
                  : filePath.contains('/comments');

              if (extension == "jpeg" ||
                  extension == "png" ||
                  extension == "jpg") {
                Uint8List decodedbytes = base64Decode(map['data']);

                return Container(
                  decoration: BoxDecoration(
                    color: fwhite,
                    borderRadius: BorderRadius.circular(7),
                    image: DecorationImage(
                      image: MemoryImage(decodedbytes),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 50.sp,
                  child: Builder(builder: (context) {
                    if (!commentAvailable) {
                      return const SizedBox();
                    }

                    return Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Icon(
                          Icons.comment,
                          color: ThemeServices().getPrimaryFgColor(context),
                          size: 12.sp,
                        ),
                      ),
                    );
                  }),
                );
              }

              return buildPdfandFileWidget(
                context: context,
                extension: extension,
                fileName: fileName,
                commentAvailable: commentAvailable,
              );
            },
          ),
        );
      },
    );
  }

  // ======================================================================================================

  GestureDetector buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        JobsServices().showAttachmentDialogPicker(
          context,
          attachingFilePath: attachingFilePath,
          attachmentsControllerBloc: attachmentsControllerBloc,
          attachmentCategoryKey: attachmentCategoryKey,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: fwhite,
          borderRadius: BorderRadius.circular(7),
        ),
        width: 50.sp,
        child: Center(
          child: Icon(
            Icons.add,
            size: 25.sp,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  //

  Widget buildPdfandFileWidget({
    required BuildContext context,
    required String extension,
    required String fileName,
    required bool commentAvailable,
  }) {
    String getFileTypeImagePath(String key) {
      switch (key) {
        case "pdf":
          return "assets/images/pdf.png";

        case "xls":
          return "assets/images/xls.png";

        default:
          return "assets/images/unknown-file.png";
      }
    }

    return Container(
      width: 50.sp,
      decoration: BoxDecoration(
        color: fwhite,
        image: DecorationImage(
          image: AssetImage(
            getFileTypeImagePath(extension),
          ),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(5.sp),
      ),
      child: Builder(
        builder: (context) {
          if (!commentAvailable) {
            return const SizedBox();
          }

          return Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                Icons.comment,
                color: ThemeServices().getPrimaryFgColor(context),
                size: 12.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}
