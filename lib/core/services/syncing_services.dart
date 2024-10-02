import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/blocs/sync%20progress/sync_progress_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import '../../main.dart';

class SyncingServices {
  showingSyncProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
            title: const Text("Syncing.."),
            // actions: [
            //   IconButton(
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //       },
            //       icon: Icon(Icons.done))
            // ],
            content: BlocBuilder<SyncProgressBloc, SyncProgressState>(
              builder: (_, state) {
                int progressValue = state.progress;
                int total = state.total;

                double percentage =
                    progressValue == 0 ? 0 : progressValue / total * 100;

                String text = progressValue == 0
                    ? ""
                    : "${percentage.round()}% syncing completed.";

                Color accentColor = Theme.of(context).colorScheme.secondary;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Lottie.network(
                        "https://assets6.lottiefiles.com/packages/lf20_h2iwbavc.json",
                        height: 25.h,
                        repeat: true,
                        // width: 80.w,
                      ),
                    ),
                    Row(
                      children: [
                        Builder(builder: (context) {
                          return Expanded(
                            child: LinearProgressIndicator(
                              value: progressValue / total,
                              backgroundColor: Colors.black26,
                              color: accentColor,
                              minHeight: 5,
                            ),
                          );
                        }),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Text("${state.progress}/${state.total}")
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text(
                          text,
                        ),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Ok",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                );
              },
            ));
      },
    );
  }

  static bool syncCalled = false;

  // ===========================

  void listenForInternet(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      BuildContext context = MyApp.navigatorKey.currentState!.overlay!.context;


      InternetAvailableBloc internetAvailableBloc =
          BlocProvider.of<InternetAvailableBloc>(context);

      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        if (!syncCalled) {
          syncCalled = true;

          internetAvailableBloc.add(ChangeInternetAvailablity(available: true));

          // UserAuthService().handlingAccessTokenExpiredOrNotStates();

          Box<SyncingLocalDb> box = syncdbgetBox();

          List<SyncingLocalDb> items = box.values.toList();

          if (items.isEmpty) {
            syncCalled = false;
            return;
          }

          syncToCloud(
            context: context,
          );

          showingSyncProgressDialog(context);
        }
      } else if (connectivityResult == ConnectivityResult.none) {
        internetAvailableBloc.add(ChangeInternetAvailablity(available: false));
        // TimerServices().cancelTimer();
      }
    });
  }

// ====================================================================================
// SYNC TO CLOUD.

  void syncToCloud({
    required BuildContext context,
  }) async {
    try {
      var box = syncdbgetBox();
      List<SyncingLocalDb> items = box.values.toList();

      items.sort(
        (a, b) => a.generatedTime.compareTo(b.generatedTime),
      );

      var syncProgressBloc = BlocProvider.of<SyncProgressBloc>(context);

      syncProgressBloc.add(ChangeTotalCountEvent(total: items.length));

      int success = 0;

      for (var element in items) {
        // bool isQuery = element.graphqlMethod.contains("query");

        if (element.graphqlMethod == JobsSchemas.addJobCommentMutation) {
          File? attachedFile;

          Map<dynamic, dynamic> data = element.payload['data'];

          if (element.payload['fileData'] != null) {
            try {
              final tempDir = await getTemporaryDirectory();
              File file = await File('${tempDir.path}/image.png').create();
              Uint8List bytes = element.payload["fileData"]['attachedFiile'];
              file.writeAsBytesSync(bytes);

              attachedFile = file;
            } catch (e) {
              // TODO
            }
          }

          // ignore: use_build_context_synchronously
          int? id = await JobsServices().addCommentToJob(
            context: context,
            jobId: data['jobId'],
            comment: data['comment']['comment'],
            attachedFile: attachedFile,
            jobDomain: data['jobDomain'],
          );

          if (id == null) {
            continue;
          } else {
            List repliesPayload = element.payload['repliesPayload'] ?? [];

            for (var elem in repliesPayload) {
              elem['data']['comment']['id'] = id;

              Map a = elem;

              Map<String, dynamic> variables =
                  a.map((key, value) => MapEntry(key.toString(), value));

              var result = await GraphqlServices().performMutation(
                context: context,
                query: JobsSchemas.addCommentReplyMutation,
                variables: variables,
              );

              if (result.hasException) {
                continue;
              } else {
                // repliesPayload.remove(elem);

                // element.payload['repliesPayload'] = [];
                // box.putAt(
                //     box.values.toList().indexOf(element),
                //     SyncingLocalDb(
                //       payload: element.payload,
                //       generatedTime: DateTime.now().millisecondsSinceEpoch,
                //       graphqlMethod: JobsSchemas.addCheckListCommentReply,
                //     ));
              }
            }

            success = success + 1;

            deleteElement(box, element);
            continue;
          }
        } else if (element.graphqlMethod == JobsSchemas.addChecklistComment) {
          File? attachedFile;

          Map<dynamic, dynamic> payloadData = element.payload['data'];
          Map<String, dynamic> data =
              payloadData.map((key, value) => MapEntry(key.toString(), value));

          String filePath = "";

          if (element.payload['fileData'] != null) {
            try {
              final tempDir = await getTemporaryDirectory();
              File file = await File('${tempDir.path}/image.png').create();
              Uint8List bytes = element.payload["fileData"]['attachedFiile'];
              file.writeAsBytesSync(bytes);
              filePath = element.payload["fileData"]['filePath'];
              attachedFile = file;
            } catch (e) {
              // TODO
            }
          }

          // ignore: use_build_context_synchronously
          var result = await GraphqlServices().performMutation(
            context: context,
            query: element.graphqlMethod,
            variables: data,
          );

          if (result.hasException) {
            continue;
          }

          Map<String, dynamic>? map = result.data!['addCheckListComment'];

          int? id = map?['id'];

          List repliesPayload = element.payload['repliesPayload'] ?? [];

          for (var elem in repliesPayload) {
            elem['checkListReply']['comment']['id'] = id;

            Map a = elem;

            Map<String, dynamic> variables =
                a.map((key, value) => MapEntry(key.toString(), value));

            // ignore: use_build_context_synchronously
            var result = await GraphqlServices().performMutation(
              context: context,
              query: JobsSchemas.addCheckListCommentReply,
              variables: variables,
            );

            if (result.hasException) {
              continue;
            } else {
              // repliesPayload.remove(elem);

              // element.payload['repliesPayload'] = [];
              // box.putAt(
              //     box.values.toList().indexOf(element),
              //     SyncingLocalDb(
              //       payload: element.payload,
              //       generatedTime: DateTime.now().millisecondsSinceEpoch,
              //       graphqlMethod: JobsSchemas.addCheckListCommentReply,
              //     ));
            }
          }

          // deleteElement(box, element);

          // if (id == null) {
          //   // ignore: use_build_context_synchronously
          //   buildSnackBar(context: context, value: "Something went wrong !!");
          //   return;
          // }

          if (attachedFile != null) {
            // ignore: use_build_context_synchronously
            JobsServices().attachFiles(
              context: context,
              attachedFile: attachedFile,
              // id: id,
              // jobId: widget.jobId,
              filePath: "$filePath$id",
            );
          }

          success = success + 1;
          deleteElement(box, element);
          continue;
        } else if (element.graphqlMethod ==
            JobsSchemas.addJobCommentWithAttachment) {
          Map a = element.payload['data'];

          Map<String, dynamic> variables =
              a.map((key, value) => MapEntry(key.toString(), value));

          String base64Encoded = element.payload['attachmentData']['data'];

          // for (var element in list) {
          var file = await FileServices().convertToFile(
            base64Encoded: base64Encoded,
            fileName: element.payload['attachmentData']['fileName'],
          );

          var fileUploadData =
              await JobsServices().convertToFileUploadData(file);

          // variables['data']['attachments'] = [fileUploadData];

          if (context.mounted) {
            // ignore: use_build_context_synchronously
            var result = await GraphqlServices().performMutation(
              context: context,
              query: element.graphqlMethod,
              variables: {
                "data": {
                  "comment": variables['data']['comment'],
                  "filePath": variables['data']['filePath'],
                  "subPath": variables['data']['subPath'],
                  "attachments": [
                    fileUploadData,
                  ]
                }
              },
            );

            if (result.hasException) {
              continue;
            }

            int? id =
                result.data?["addJobCommentWithAttachment"]?["comment"]?["id"];

            List repliesPayload = element.payload['repliesPayload'] ?? [];

            if (id != null) {
              for (var elem in repliesPayload) {
                elem['data']['comment']['id'] = id;

                Map a = elem;

                Map<String, dynamic> variables =
                    a.map((key, value) => MapEntry(key.toString(), value));

                // ignore: use_build_context_synchronously
                var result = await GraphqlServices().performMutation(
                  context: context,
                  query: JobsSchemas.addCommentReplyMutation,
                  variables: variables,
                );

                if (result.hasException) {
                  continue;
                } else {
                  // repliesPayload.remove(elem);

                  // element.payload['repliesPayload'] = [];
                  // box.putAt(
                  //     box.values.toList().indexOf(element),
                  //     SyncingLocalDb(
                  //       payload: element.payload,
                  //       generatedTime: DateTime.now().millisecondsSinceEpoch,
                  //       graphqlMethod: JobsSchemas.addCheckListCommentReply,
                  //     ));
                }
              }
            }

            // int index = box.values.toList().indexOf(element);

            // box.deleteAt(index);

            success = success + 1;
            deleteElement(box, element);

            continue;
          }
        } else if (element.graphqlMethod == JobsSchemas.jobCompleteMutation) {
          Map a = element.payload['data'];

          Map<String, dynamic> variables =
              a.map((key, value) => MapEntry(key.toString(), value));

          if (context.mounted) {
            // ignore: use_build_context_synchronously
            var result = await GraphqlServices().performMutation(
              context: context,
              query: element.graphqlMethod,
              variables: variables,
            );

            if (result.hasException) {
              continue;
            }

            var signatures = element.payload['signatures'];

            var technicianData = signatures?['technician'];
            var clientData = signatures?['client'];

            if (technicianData != null) {
              // ignore: use_build_context_synchronously
              await uploadFileData(
                filePath: technicianData['filePath'],
                base64Encoded: technicianData['data'],
                context: context,
              );
            }

            if (clientData != null) {
              // ignore: use_build_context_synchronously
              await uploadFileData(
                filePath: clientData['filePath'],
                base64Encoded: clientData['data'],
                context: context,
              );
            }

            // int index = box.values.toList().indexOf(element);

            // box.deleteAt(index);

            success = success + 1;
            deleteElement(box, element);

            continue;
          }
        }

        // ignore: use_build_context_synchronously
        var result = await GraphqlServices().performMutation(
          query: element.graphqlMethod,
          variables: element.payload,
          context: context,
        );

        if (result.hasException) {
          continue;
        }
        // int index = box.values.toList().indexOf(element);

        // box.deleteAt(index);

        success = success + 1;
        deleteElement(box, element);
      }

      // var syncBox = syncdbgetBox();

      // print("Sync progress VAlues length ${}");

      syncCalled = false;

      syncProgressBloc.add(ChangeSyncProgressEvent(
        progress: success,
      ));
    } catch (e) {}

    // ignore: use_build_context_synchronously
    // Navigator.of(context).pop();
  }

  void deleteElement(Box<SyncingLocalDb> box, SyncingLocalDb element) {
    int index = box.values
        .toList()
        .indexWhere((ele) => ele.generatedTime == element.generatedTime);

    box.deleteAt(index);
  }

  uploadFileData({
    required String filePath,
    required String base64Encoded,
    required BuildContext context,
  }) async {
    var attachedFile = await FileServices()
        .convertToFile(base64Encoded: base64Encoded, fileName: "signature.png");

    if (context.mounted) {
      await JobsServices().attachFiles(
        attachedFile: attachedFile,
        filePath: filePath,
        context: context,
      );
    }
  }
}
