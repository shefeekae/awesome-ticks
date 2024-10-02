import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/job_comments_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:awesometicks/ui/pages/job/widgets/attachment_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../../core/models/checklist_comments_model.dart';
import '../../shared/widgets/skelton_loader.dart';
import 'package:collection/collection.dart';

class JobChecklistCommentsScreen extends StatefulWidget {
  const JobChecklistCommentsScreen({
    required this.jobId,
    required this.jobDomain,
    required this.checklistId,
    super.key,
  });

  final int jobId;
  final String jobDomain;
  final int checklistId;

  @override
  State<JobChecklistCommentsScreen> createState() =>
      _JobChecklistCommentsScreenState();
}

class _JobChecklistCommentsScreenState
    extends State<JobChecklistCommentsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController commentController = TextEditingController();

  JobDetailsDb? jobDetailsDb;
  List<JobComments> jobComments = [];

  UserDataSingleton userData = UserDataSingleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
              // future: Connectivity().checkConnectivity(),
              builder: (context, state) {
                bool notAvailable = state.isInternetAvailable;

                if (!notAvailable) {
                  return ValueListenableBuilder(
                    valueListenable: jobDetailsDbgetBox().listenable(),
                    builder: (context, box, child) {
                      var jobsList = box.values.toList();

                      JobDetailsDb? jobDetailsDb = jobsList.singleWhereOrNull(
                          (element) => element.id == widget.jobId);

                      if (jobDetailsDb == null) {
                        return const Center(
                          child: Text("Checklist Comment not found"),
                        );
                      }

                      ChecklistDb? checklistDb =
                          jobDetailsDb.checklistDb?.singleWhereOrNull(
                        (element) => element.id == widget.checklistId,
                      );

                      var checklistComments = checklistDb?.comments ?? [];

                      // var comments = checklistComments
                      //     .map((e) =>
                      //         ListCheckListComments
                      //             .fromJson(
                      //                 e.toJson()))
                      //     .toList();

                      // for (var element in checklistComments[0].replies!) {
                      //   print(element.comment);
                      // }
                      // print("-----------------");
                      // print(checklistComments[0].replies?.length);

                      List<GetAllComments> allComments = checklistComments
                          .map((e) => GetAllComments.fromJson(e.toJson()))
                          .toList();

                      return buildCommentsBuilder(allComments);
                    },
                  );
                }

                return FutureBuilder(
                  future: GraphqlServices().performQuery(
                    query: JobsSchemas.checklistCommentsQuery,
                    variables: {
                      "checklistId": widget.checklistId,
                    },
                  ),
                  builder: (result, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Expanded(
                        child: ListView.separated(
                          itemCount: 10,
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: 10.sp,
                            );
                          },
                          itemBuilder: (context, index) {
                            return buildSkeleton(context);
                          },
                        ),
                      );
                    }

                    var result = snapshot.data;

                    if (result!.hasException) {
                      return Expanded(
                        child: GraphqlServices().handlingGraphqlExceptions(
                          result: result,
                          context: context,
                          setState: setState,
                        ),
                      );
                    }

                    var data = CheckListComments.fromJson(result.data!);

                    var comments = data.listCheckListComments ?? [];

                    if (comments.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: Text("No comments"),
                        ),
                      );
                    }

                    comments.sort(
                      (a, b) => b.commentTime!.compareTo(a.commentTime!),
                    );

                    List<GetAllComments> allComments = comments
                        .map((e) => GetAllComments.fromJson(e.toJson()))
                        .toList();

                    return buildCommentsBuilder(allComments);
                  },
                );
              },
            ),
            buildChecklistCommentAttachmentAndTextfield(
              context,
              jobId: widget.jobId,
              jobDomain: widget.jobDomain,
              checklistId: widget.checklistId,
              setState: setState,
            ),
            SizedBox(
              height: 18.sp,
            )
          ],
        ),
      ),
    );
  }

  Expanded buildCommentsBuilder(List<GetAllComments> allComments) {
    allComments.sort(
      (a, b) => b.commentTime!.compareTo(a.commentTime!),
    );

    return Expanded(
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 4.sp,
          ),
          itemBuilder: (context, index) {
            return CommentWidget(
              checklistId: widget.checklistId,
              isChecklistComment: true,
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

  //   bool isAndroid = Platform.isAndroid;

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
  //           child: Row(
  //             children: [
  //               IconButton(
  //                 onPressed: () {
  //                   PlatformServices().showDialogWithDialogActions(
  //                     context,
  //                     title: "Attach Images",
  //                     list: [
  //                       DialogActionModel(
  //                         child: const Text(
  //                           "Take Photo",
  //                         ),
  //                         onPressed: () async {
  //                           Navigator.of(context).pop();

  //                           var file = await FileServices().pickImage(
  //                             context,
  //                             isCamera: true,
  //                           );

  //                           if (file != null) {
  //                             setState(
  //                               () {
  //                                 attachedFile = file;
  //                               },
  //                             );
  //                           }
  //                         },
  //                       ),
  //                       DialogActionModel(
  //                         child: const Text("Choose Image"),
  //                         onPressed: () async {
  //                           Navigator.of(context).pop();

  //                           var file = await FileServices().pickImage(
  //                             context,
  //                           );

  //                           if (file != null) {
  //                             setState(
  //                               () {
  //                                 attachedFile = file;
  //                               },
  //                             );
  //                           }
  //                         },
  //                       ),
  //                       DialogActionModel(
  //                         child: const Text("Cancel"),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                       )
  //                       // DialogActionModel(
  //                       //   child: const Text(
  //                       //     "Take Photo",
  //                       //   ),
  //                       //   onPressed: () async {
  //                       //     Navigator.of(context).pop();
  //                       //     PermissionStatus permissionStatus =
  //                       //         await Permission.camera.status;

  //                       //     print(permissionStatus);

  //                       //     if (permissionStatus.isPermanentlyDenied) {
  //                       //       openAppSettings();
  //                       //       // Permission.camera.request();
  //                       //     } else if (permissionStatus.isDenied) {
  //                       //       PermissionStatus permissionStatus =
  //                       //           await Permission.camera.request();

  //                       //       print("PERMISSION STATUS DENIED");

  //                       //       if (permissionStatus.isGranted) {
  //                       //         // ignore: use_build_context_synchronously
  //                       //         var file = await FileServices()
  //                       //             .getImages(context, isCamera: true);
  //                       //         if (file != null) {
  //                       //           // var file = files[0];

  //                       //           refreshState(
  //                       //             () {
  //                       //               attachedFile = file;
  //                       //             },
  //                       //           );
  //                       //         }
  //                       //       }
  //                       //     } else {
  //                       //       // ignore: use_build_context_synchronously

  //                       //       // ignore: use_build_context_synchronously
  //                       //       var file = await FileServices()
  //                       //           .getImages(context, isCamera: true);
  //                       //       if (file != null) {
  //                       //         // var file = files[0];

  //                       //         refreshState(
  //                       //           () {
  //                       //             attachedFile = file;
  //                       //           },
  //                       //         );
  //                       //       }
  //                       //     }
  //                       //   },
  //                       // ),
  //                       // DialogActionModel(
  //                       //   child: Text("Take Video"),
  //                       //   onPressed: () async {
  //                       //     Navigator.of(context).pop();

  //                       //     PermissionStatus permissionStatus =
  //                       //         await Permission.camera.status;

  //                       //     print(permissionStatus);

  //                       //     if (permissionStatus.isPermanentlyDenied) {
  //                       //       // PermissionStatus permissionStatus =
  //                       //       //     await Permission.photos.request();
  //                       //       openAppSettings();
  //                       //       // print(permissionStatus);

  //                       //       // Permission.camera.request();
  //                       //     } else if (permissionStatus.isDenied) {
  //                       //       PermissionStatus permissionStatus =
  //                       //           await Permission.camera.request();

  //                       //       if (permissionStatus.isGranted) {
  //                       //         var file =
  //                       //             // ignore: use_build_context_synchronously
  //                       //             await JobsServices().getVideo(
  //                       //           context,
  //                       //           isCamera: true,
  //                       //         );

  //                       //         if (file != null) {
  //                       //           refreshState(
  //                       //             () {
  //                       //               attachedFile = file;
  //                       //             },
  //                       //           );
  //                       //         }
  //                       //       }
  //                       //     } else {
  //                       //       // ignore: use_build_context_synchronously

  //                       //       // ignore: use_build_context_synchronously
  //                       //       var file = await JobsServices().getVideo(
  //                       //         context,
  //                       //         isCamera: true,
  //                       //       );

  //                       //       if (file != null) {
  //                       //         // var file = files[0];

  //                       //         refreshState(
  //                       //           () {
  //                       //             attachedFile = file;
  //                       //           },
  //                       //         );
  //                       //       }
  //                       //     }
  //                       //   },
  //                       // ),
  //                       // DialogActionModel(
  //                       //   child: const Text("Choose Image"),
  //                       //   onPressed: () async {
  //                       //     Navigator.of(context).pop();

  //                       //     PermissionStatus permissionStatus = isAndroid
  //                       //         ? await Permission.storage.request()
  //                       //         : await Permission.photos.request();

  //                       //     print(permissionStatus);

  //                       //     if (permissionStatus.isPermanentlyDenied) {
  //                       //       // PermissionStatus permissionStatus =
  //                       //       //     await Permission.photos.request();
  //                       //       openAppSettings();
  //                       //       // print(permissionStatus);

  //                       //       // Permission.camera.request();
  //                       //     } else if (permissionStatus.isDenied) {
  //                       //       PermissionStatus permissionStatus = isAndroid
  //                       //           ? await Permission.storage.status
  //                       //           : await Permission.photos.status;

  //                       //       print("PERMISSION STATUS DENIED");

  //                       //       if (permissionStatus.isGranted) {
  //                       //         var file =
  //                       //             // ignore: use_build_context_synchronously
  //                       //             await FileServices().getImages(
  //                       //           context,
  //                       //         );

  //                       //         if (file != null) {
  //                       //           refreshState(
  //                       //             () {
  //                       //               attachedFile = file;
  //                       //             },
  //                       //           );
  //                       //         }
  //                       //       }
  //                       //     } else {
  //                       //       // ignore: use_build_context_synchronously

  //                       //       // ignore: use_build_context_synchronously
  //                       //       var file = await FileServices().getImages(
  //                       //         context,
  //                       //       );

  //                       //       if (file != null) {
  //                       //         // var file = files[0];

  //                       //         refreshState(
  //                       //           () {
  //                       //             attachedFile = file;
  //                       //           },
  //                       //         );
  //                       //       }
  //                       //     }
  //                       //   },
  //                       // ),
  //                       // DialogActionModel(
  //                       //   child: const Text("Choose Video"),
  //                       //   onPressed: () async {
  //                       //     Navigator.of(context).pop();

  //                       //     PermissionStatus permissionStatus = isAndroid
  //                       //         ? await Permission.storage.status
  //                       //         : await Permission.photos.status;

  //                       //     print(permissionStatus);

  //                       //     if (permissionStatus.isPermanentlyDenied) {
  //                       //       // PermissionStatus permissionStatus =
  //                       //       //     await Permission.photos.request();
  //                       //       openAppSettings();
  //                       //       // print(permissionStatus);

  //                       //       // Permission.camera.request();
  //                       //     } else if (permissionStatus.isDenied) {
  //                       //       PermissionStatus permissionStatus = isAndroid
  //                       //           ? await Permission.storage.request()
  //                       //           : await Permission.videos.request();

  //                       //       if (permissionStatus.isGranted) {
  //                       //         var file =
  //                       //             // ignore: use_build_context_synchronously
  //                       //             await JobsServices().getVideo(
  //                       //           context,
  //                       //         );

  //                       //         if (file != null) {
  //                       //           refreshState(
  //                       //             () {
  //                       //               attachedFile = file;
  //                       //             },
  //                       //           );
  //                       //         }
  //                       //       }
  //                       //     } else {
  //                       //       // ignore: use_build_context_synchronously

  //                       //       // ignore: use_build_context_synchronously
  //                       //       var file = await JobsServices().getVideo(
  //                       //         context,
  //                       //       );

  //                       //       if (file != null) {
  //                       //         // var file = files[0];

  //                       //         refreshState(
  //                       //           () {
  //                       //             attachedFile = file;
  //                       //           },
  //                       //         );
  //                       //       }
  //                       //     }
  //                       //   },
  //                       // ),
  //                       // DialogActionModel(
  //                       //   child: const Text("Cancel"),
  //                       //   onPressed: () {
  //                       //     Navigator.of(context).pop();
  //                       //   },
  //                       // )
  //                     ],
  //                   );
  //                 },
  //                 icon: const Icon(
  //                   Icons.attachment,
  //                 ),
  //               ),
  //               Form(
  //                 key: formKey,
  //                 child: BuildCommentTextfield(
  //                   controller: commentController,
  //                   hintText: "Enter comment",
  //                 ),
  //               ),
  //               IconButton(
  //                 onPressed: () async {
  //                   bool isValid = formKey.currentState!.validate();
  //                   if (isValid) {
  //                     int nowMilliseconds =
  //                         DateTime.now().millisecondsSinceEpoch;

  //                     bool internetAvailable =
  //                         await InterNetServices().checkInternetConnectivity();

  //                     if (!internetAvailable) {
  //                       var jobsList = jobDetailsDbgetBox().values.toList();

  //                       JobDetailsDb? jobDetailsDb = jobsList.singleWhereOrNull(
  //                           (element) => element.id == widget.jobId);

  //                       if (jobDetailsDb == null) {
  //                         // ignore: use_build_context_synchronously
  //                         buildSnackBar(
  //                           context: context,
  //                           value: "Something went wrong!",
  //                         );
  //                         print("JOB DETAILS DB CALLED NULL VALUE");
  //                         return;
  //                       }

  //                       String userName = userData.userName;

  //                       String domain = userData.domain;

  //                       jobDetailsDb.jobComments!.add(
  //                         JobComments(
  //                           comment: commentController.text.trim(),
  //                           commentBy: "$userName@$domain",
  //                           commentTime: nowMilliseconds,
  //                           replies: [],
  //                         ),
  //                       );

  //                       int index = jobDetailsDbgetBox()
  //                           .values
  //                           .toList()
  //                           .indexOf(jobDetailsDb);

  //                       jobDetailsDbgetBox().putAt(index, jobDetailsDb);

  //                       var syncBox = syncdbgetBox();

  //                       // int nowMilliseconds =
  //                       //     DateTime.now().millisecondsSinceEpoch;

  //                       print("Now Milliseconds $nowMilliseconds");

  //                       var payload = {
  //                         "replyId": "$userName@$domain/$nowMilliseconds",
  //                         "data": {
  //                           "comment": {
  //                             "comment": commentController.text.trim()
  //                           },
  //                           "jobId": widget.jobId,
  //                           "jobDomain": widget.jobDomain,
  //                         }
  //                       };

  //                       if (attachedFile != null) {
  //                         Uint8List uint8List = attachedFile!.readAsBytesSync();

  //                         payload['fileData'] = {
  //                           "attachedFiile": uint8List,
  //                           // "filePath": "/jobs/${widget.jobId}/comments/",
  //                         };

  //                         refreshState(() {
  //                           attachedFile = null;
  //                         });
  //                       }

  //                       print("Now Milliseconds $nowMilliseconds");

  //                       syncBox.add(
  //                         SyncingLocalDb(
  //                           payload: payload,
  //                           generatedTime: nowMilliseconds,
  //                           graphqlMethod: JobsSchemas.addJobCommentMutation,
  //                         ),
  //                       );

  //                       // if (attachedFile != null) {
  //                       //   syncBox.add(
  //                       //     SyncingLocalDb(
  //                       //       payload: {
  //                       //         "attachedFiile": uint8List,
  //                       //         "filePath": "/jobs/${widget.jobId}/comments/",
  //                       //       },
  //                       //       generatedTime:
  //                       //           DateTime.now().millisecondsSinceEpoch,
  //                       //       graphqlMethod:
  //                       //           JobsSchemas.uploadMultipleFilesMutation,
  //                       //     ),
  //                       //   );
  //                       // }

  //                       commentController.clear();
  //                       // ignore: use_build_context_synchronously
  //                       FocusScope.of(context).unfocus();

  //                       return;
  //                     }

  //                     // ignore: use_build_context_synchronously
  //                     int? id = await JobsServices().addCommentToJob(
  //                       jobId: widget.jobId,
  //                       comment: commentController.text.trim(),
  //                       attachedFile: attachedFile,
  //                       jobDomain: widget.jobDomain,
  //                       context: context,
  //                     );

  //                     if (id != null) {
  //                       setState(
  //                         () {},
  //                       );
  //                     } else {
  //                       // ignore: use_build_context_synchronously
  //                       buildSnackBar(
  //                         context: context,
  //                         value: "Something went wrong!",
  //                       );
  //                     }

  //                     attachedFile = null;
  //                     commentController.clear();
  //                   }
  //                 },
  //                 icon: Icon(
  //                   Icons.send,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }

  // ==========================================================================================================
  AppBar buildAppbar() {
    return AppBar(
      title: Text("Checklist Comments "),
    );
  }
}
