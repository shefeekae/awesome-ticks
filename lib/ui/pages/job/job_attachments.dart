import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:files_viewer/files_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../../core/blocs/attachments/attachments_controller_bloc.dart';
import '../../../core/blocs/internet/bloc/internet_available_bloc.dart';
import '../../../core/models/hive db/list_jobs_model.dart';
import '../../../core/schemas/jobs_schemas.dart';
import '../../../core/services/file_services.dart';
import '../../../core/services/jobs/jobs_no_internet_services.dart';
import '../../../core/services/jobs/jobs_services.dart';
import 'package:path/path.dart' as path;
import '../../../utils/themes/colors.dart';
import '../../shared/widgets/loading_widget.dart';
import 'package:collection/collection.dart';

// ignore: must_be_immutable
class JobAttachmentsScreen extends StatefulWidget {
  final int jobId;
  final String jobDomain;
  final String? serviceRequestNumber;

  const JobAttachmentsScreen({
    required this.jobDomain,
    required this.jobId,
    required this.serviceRequestNumber,
    super.key,
  });

  @override
  State<JobAttachmentsScreen> createState() => _JobAttachmentsScreenState();
}

class _JobAttachmentsScreenState extends State<JobAttachmentsScreen> {
  double spacing = 5.sp;

  List<Map> tabBarList = [
    {
      "title": "All",
      "key": "",
    },
    {
      "title": "Before",
      "key": "__before",
    },
    {
      "title": "After",
      "key": "__after",
    },
  ];

  late AttachmentsControllerBloc attachmentsControllerBloc;

  int currentTabIndex = 0;

  @override
  void initState() {
    attachmentsControllerBloc =
        BlocProvider.of<AttachmentsControllerBloc>(context);

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // appBar: AppBar(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.c,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            JobsServices().showAttachmentDialogPicker(context,
                attachingFilePath:
                    getAttachmentFilePath(tabBarList[currentTabIndex]['key']),
                attachmentsControllerBloc: attachmentsControllerBloc,
                attachmentCategoryKey: tabBarList[currentTabIndex]['key']);
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            TabBar(
                padding:
                    EdgeInsets.symmetric(vertical: 5.sp, horizontal: 10.sp),
                labelPadding:
                    EdgeInsets.symmetric(vertical: 5.sp, horizontal: 10.sp),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: List.generate(tabBarList.length, (index) {
                  String title = tabBarList[index]['title'];

                  return Text(
                    title,
                    style: TextStyle(
                      color: kBlack,
                    ),
                  );
                })),
            Expanded(
              child: TabBarView(
                children: List.generate(
                  tabBarList.length,
                  (index) {
                    return Builder(
                      builder: (context) {
                        currentTabIndex = index;

                        // List filteredList = attachmentsControllerBloc
                        //     .state.allData
                        //     .where((element) {
                        //   return element['path'].toString().contains(key);
                        // }).toList();

                        // attachmentsControllerBloc.add(
                        //     UpdateFilteredData(filteredData: filteredList));

                        return buildAttachments();
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // // ===============================================================================================================================
  // // GEt Attachment file path

  String getAttachmentFilePath(String key) {
    switch (key) {
      case "":
        return "jobs/${widget.jobDomain}/${widget.jobId}";

      case "__before":
      case "__after":
        return "jobs/${widget.jobDomain}/${widget.jobId}/$key";

      // case "after":
      //   return "jobs/${widget.jobDomain}/${widget.jobId}/after";

      default:
        return "";
    }
  }

  // ==========================================================================================================================
  Widget buildAttachments() {
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        if (!state.isInternetAvailable) {
          return ValueListenableBuilder(
            valueListenable: syncdbgetBox().listenable(),
            builder: (context, box, _) {
              String attachmentCategoryKey = tabBarList[currentTabIndex]['key'];

              String attachingFilePath =
                  getAttachmentFilePath(attachmentCategoryKey);

              // var splitedList = attachingFilePath.split("/");

              // int jobId = int.parse(splitedList[2]);

              // var list = box.values
              //     .where(
              //       (element) =>
              //           element.graphqlMethod ==
              //               JobsSchemas.addJobCommentWithAttachment &&
              //           element.payload.containsKey('attachmentData'),
              //     )
              //     .toList();

              // List filteredList = list.map((e) {
              //   var data = e.payload['attachmentData'];

              //   var commentData =
              //       e.payload['data']?['data']?['comment']?['comment'];

              //   if (commentData != null) {
              //     data?['commentData'] = commentData;
              //   }

              //   return data;
              // }).where((element) {
              //   int pathJobId =
              //       int.parse(element['path'].toString().split("/")[2]);

              //   return element['path']
              //           .toString()
              //           .contains(attachmentCategoryKey) &&
              //       pathJobId == jobId;
              // }).toList();

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
                      return element.commentTime == commentData['commentTime'];
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

              return buildGridViewBuilder(
                filteredList,
                noInternet: true,
              );
            },
          );
        }

        return BlocBuilder<AttachmentsControllerBloc,
            AttachmentsControllerState>(
          builder: (context, state) {
            bool isLoading = state.isLoading;

            if (isLoading) {
              return GridView.builder(
                padding: EdgeInsets.all(spacing),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 2,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: 2.sp,
                ),
                itemBuilder: (context, index) {
                  return ShimmerLoadingContainerWidget(
                    height: 0,
                  );
                },
              );
            }

            List filteredList =
                attachmentsControllerBloc.state.allData.where((element) {
              return element['path']
                  .toString()
                  .contains(tabBarList[currentTabIndex]['key']);
            }).toList();

            attachmentsControllerBloc.state.filteredData = filteredList;

            List attachments = state.filteredData;

            if (attachments.isEmpty) {
              return const Center(
                child: Text(
                  "No attachments found",
                ),
              );
            }

            return buildGridViewBuilder(
              attachments,
            );
          },
        );
      },
    );
  }

  // ====================================================================================================================
  // BuildGridView builder

  Widget buildGridViewBuilder(
    List<dynamic> attachments, {
    bool noInternet = false,
  }) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        if (!noInternet) {
          // String attachmentCategoryKey = tabBarList[currentTabIndex]['key'];

          // print(attachmentCategoryKey);

          await JobsServices().addJobAttachmentsToBlocState(
            jobAttachmentFilePath: getAttachmentFilePath(""),
            serviceRequestAttachmentFilePath: widget.serviceRequestNumber ==
                    null
                ? null
                : "serviceRequests/${widget.jobDomain}/${widget.serviceRequestNumber}",
            attachmentCategoryKey: "",
          );
        }
      },
      child: GridView.builder(
        itemCount: attachments.length,
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 2,
          mainAxisSpacing: spacing,
          crossAxisSpacing: 2.sp,
        ),
        itemBuilder: (context, index) {
          // Map<String, dynamic> map = attachments[index];

          Map map = attachments[index];

          String extension = map['fileName'].split('.').last;
          String fileName = path.basename(map['fileName']);

          File originalFile = File(fileName);
          // String originalFileName = fileName;
          String originalFileMimeType = '';

          bool commentAvailable = noInternet
              ? map['commentAvailable']
              : map['path'].toString().contains('/comments');

          return Bounce(
            duration: const Duration(milliseconds: 100),
            onPressed: () async {
              // if (map["thumbnail"] == true) {
              //   originalFile = File(map['originalFileName']);

              //   var result = await GraphqlServices().performQuery(
              //       query: JobsSchemas.getFileForPreview,
              //       variables: {
              //         "fileName": map['originalFileName'],
              //         "filePath": map['originalFilePath'],
              //       });

              //   var data = result.data ?? {};

              //   if (data.isEmpty) {
              //     return;
              //   }

              //   await FileServices()
              //       .convertToFile(
              //     base64Encoded: data["getFileForPreview"]["data"],
              //     fileName: data["getFileForPreview"]["fileName"],
              //   )
              //       .then((val) {
              //     originalFile = val;
              //     // originalFileName = data["getFileForPreview"]["fileName"];
              //   });

              //   originalFileMimeType =
              //       map['originalFileMimeType'].toString().split('/').first;
              // }

              // if (originalFileMimeType == 'video') {
              //   print(originalFile.path);

              //   if (!context.mounted) return;
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) {
              //         return VideoPlayerScreen(
              //           file: originalFile,
              //         );
              //       },
              //     ),
              //   );
              // } else if (originalFileMimeType == 'audio') {
              //   print(originalFile.path);

              //   if (!context.mounted) return;
              //   FileServices().showAudioPlayerBottomSheet(
              //     context,
              //     originalFile.path,
              //   );
              // } else {
              // Only images
              List<dynamic> imageAttachments = attachments.where(
                (element) {
                  return element['thumbnail'] != true;
                },
              ).toList();

              // Assuming `index` is the index in the original `attachments` list
// Find the corresponding index in `imageAttachments` list
              int initialIndexInImageAttachments = attachments
                  .indexWhere((element) => element == attachments[index]);

              print(originalFile.path);

              bool? changed =
                  await Navigator.of(context).push<bool?>(MaterialPageRoute(
                builder: (context) => FilesViewerWithSwipeScreen(
                  items: attachments,
                  initilaIndex: initialIndexInImageAttachments,
                  internetAvailable: !noInternet,
                  noInternetCommentSaving:
                      (fileDataModel, comment, isReplyComment) {
                    var commentData = fileDataModel.commentData?.toJson() ?? {};

                    if (isReplyComment) {
                      JobsNoInternetServices()
                          .addingAttachmentWithCommentsReplies(
                        context: context,
                        jobId: widget.jobId,
                        commentData: commentData,
                        replyComment: comment,
                      );
                      return;
                    }

                    String attachmentCategoryKey =
                        tabBarList[currentTabIndex]['key'];

                    JobsNoInternetServices().addingCommentWithJobAttachment(
                      context: context,
                      jobId: widget.jobId,
                      comment: comment,
                      fileName: fileName,
                      base64EncodeData: fileDataModel.base64Encoded,
                      attachingFilePath: attachmentCategoryKey.isEmpty
                          ? "jobs/${widget.jobDomain}/${widget.jobId}"
                          : "jobs/${widget.jobDomain}/${widget.jobId}/$attachmentCategoryKey",
                      attachedFileData: {
                        "filePath": fileDataModel.filePath,
                        "fileName": fileDataModel.fileName,
                        "id": fileDataModel.dateTime,
                      },
                      commentData: commentData,
                      attachmentCategoryKey: attachmentCategoryKey,
                      allAttachmentsFilePath:
                          "jobs/${widget.jobDomain}/${widget.jobId}",
                    );
                  },
                ),
              ));

              if (changed ?? false) {
                JobsServices().addJobAttachmentsToBlocState(
                  jobAttachmentFilePath:
                      "jobs/${widget.jobDomain}/${widget.jobId}",
                  attachmentCategoryKey: "",
                  serviceRequestAttachmentFilePath: widget
                              .serviceRequestNumber ==
                          null
                      ? null
                      : "serviceRequests/${widget.jobDomain}/${widget.serviceRequestNumber}",
                );
              }
              // }
            },
            child: Builder(builder: (context) {
              String filePath = map['path'];

              if (extension == "jpeg" ||
                  extension == "png" ||
                  extension == "jpg") {
                // String fileName = file.path.split(".").last;

                return buildImageContainerWidget(
                  context,
                  map['data'],
                  map: map,
                  fileName: fileName,
                  isCommentAvailable: commentAvailable,
                  filePath: map['path'],
                  index: index,
                );
              }

              if ([
                'mp4',
                'mkv',
                'mov',
                'avi',
                'webm',
                'wmv',
              ].contains(extension)) {}

              bool isBefore = filePath.contains("__before");

              bool isAfter = filePath.contains("__after");

              String text = !isAfter && !isBefore
                  ? ""
                  : isBefore
                      ? "Before"
                      : "After";

              return buildPdfandFileWidget(
                context: context,
                data: map['data'],
                extension: extension,
                fileName: fileName,
                isCommentAvailable: commentAvailable,
                text: text,
              );
            }),
          );
        },
      ),
    );
  }

  // ===================================================================================
  Widget buildImageContainerWidget(
    BuildContext context,
    String data, {
    required Map<dynamic, dynamic> map,
    required String fileName,
    required bool isCommentAvailable,
    required String filePath,
    required int index,
  }) {
    Uint8List decodedbytes = base64Decode(data);

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        image: DecorationImage(
          image: MemoryImage(decodedbytes),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(5.sp),
      ),
      child: Builder(builder: (context) {
        // if (!isCommentAvailable) {
        //   return const SizedBox();
        // }
        bool isBefore = filePath.contains("__before");

        bool isAfter = filePath.contains("__after");

        String text = !isAfter && !isBefore
            ? ""
            : isBefore
                ? "Before"
                : "After";

        if (text.isEmpty && !isCommentAvailable) {
          return const SizedBox();
        }

        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: text.isNotEmpty,
                  child: Builder(builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: text == "Before"
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: text == "Before"
                              ? ThemeServices().getPrimaryFgColor(context)
                              : ThemeServices().getSecondaryFgColor(context),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  width: 5.sp,
                ),
                Visibility(
                  visible: isCommentAvailable,
                  child: Container(
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
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ===========================================================================
  //

  Widget buildPdfandFileWidget({
    required String data,
    required BuildContext context,
    required String extension,
    required String fileName,
    required bool isCommentAvailable,
    required String text,
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

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: kWhite,
            // image: DecorationImage(
            //   image: FileImage(file),
            // ),
            borderRadius: BorderRadius.circular(5.sp),
          ),
          child: Center(
            child: Image.asset(
              getFileTypeImagePath(extension),
            ),
            // child: Icon(
            //   isPdf ? FontAwesomeIcons.filePdf : FontAwesomeIcons.file,
            //   size: 30.sp,
            // ),
          ),
        ),
        GestureDetector(onTap: () async {
          File file = await FileServices()
              .convertToFile(base64Encoded: data, fileName: fileName);

          if (context.mounted) {
            FileServices().shareImage(filePath: file.path);
          }
        }, child: Builder(builder: (context) {
          if (text.isEmpty && !isCommentAvailable) {
            return const SizedBox();
          }

          return Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: text.isNotEmpty,
                    child: Builder(builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: text == "Before"
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: text == "Before"
                                ? ThemeServices().getPrimaryFgColor(context)
                                : ThemeServices().getSecondaryFgColor(context),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: 5.sp,
                  ),
                  Visibility(
                    visible: isCommentAvailable,
                    child: Container(
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
                  ),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }
}
