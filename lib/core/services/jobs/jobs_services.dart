import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesometicks/core/blocs/attachments/attachments_controller_bloc.dart';
// import 'package:awesometicks/core/blocs/filter/filter_selection/filter_selection_bloc.dart';
// import 'package:awesometicks/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:awesometicks/core/blocs/pagination%20controller/pagination_controller_bloc.dart';
import 'package:awesometicks/core/models/assets/asset_info_model.dart';
import 'package:awesometicks/core/models/hive%20db/job_reasons_model.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/schemas/assets_schemas.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/file_services.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/launcher_services.dart';
import 'package:awesometicks/core/services/mime_types.dart';
import 'package:awesometicks/core/services/notifications/notification_controller.dart';
import 'package:awesometicks/main.dart';
import 'package:awesometicks/ui/pages/job/widgets/video_trimmer_screen.dart';
import 'package:awesometicks/ui/shared/models/file_selector_model.dart';
import 'package:files_viewer/core/models/file_data_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:sizer/sizer.dart';
import 'package:video_compress/video_compress.dart';
// import '../models/filter_model.dart';
// import '../models/filter_value_model.dart';
import '../../../ui/pages/job/widgets/selected_file_screen.dart';
import '../../../ui/shared/widgets/custom_snackbar.dart';
import '../../models/hive db/syncing_local_db.dart';
import '../../models/listalljobsmodel.dart';
import 'package:firebase_config/services/notifications/notification_services.dart';
import 'package:app_filter_form/app_filter_form.dart';
import 'package:intl/intl.dart';
import '../platform_services.dart';

class JobsServices {
// jobsStatusListAll

  static final List<String> initialStatusList = [
    "SCHEDULED",
    "RESCHEDULED",
    "INPROGRESS",
    "WAITINGFORPARTS",
    "NOACCESS",
    "HELD",
    "TRANSFERRED_TO_VENDOR",
    "COMPLETED",
  ];

  UserDataSingleton userData = UserDataSingleton();

// =============================================================================
// Update checklist.

  Future<bool> updateChecklist({
    required int jobId,
    required List<Checklist> list,
    required BuildContext context,
  }) async {
    List<Map<String, dynamic>> checklists = [];

    for (var element in list) {
      checklists.add(element.toJson());
    }

    var result = await GraphqlServices().performMutation(
      context: context,
      query: JobsSchemas.updateCheckListMutation,
      variables: {
        "checkListData": {
          "checklists": checklists,
          "jobId": jobId,
        }
      },
    );

    if (result.hasException) {
      return false;
    }

    if (result.data?['updateCheckList'] == null) {
      return false;
    }

    return true;
  }

// -------------------------------------------------
// AttachFiles

  Future<bool> attachFiles({
    required File attachedFile,
    // required int id,
    // required int jobId,
    required String filePath,
    required BuildContext context,
  }) async {
    var byteData = await attachedFile.readAsBytes();

    // var documentary = await getApplicationDocumentsDirectory();

    String fileName = path.basename(attachedFile.path);
    String extension = attachedFile.path.split('.').last;

    String mimeType = MimeTypes.getMimeType(extension);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      byteData,
      filename: fileName,
      contentType: MediaType(mimeType.split('/').first, extension),
    );

    // ignore: use_build_context_synchronously
    var result = await GraphqlServices().performMutation(
      context: context,
      operationName: "uploadMultipleFiles",
      query: JobsSchemas.uploadMultipleFilesMutation,
      variables: {
        "data": [
          {
            "file": multipartFile,
            "name": fileName,
            "filePath": filePath,
            // "filePath": "/jobs/$jobId/checklist/comments/$id",
          },
        ],
      },
    );

    if (result.hasException) {
      return false;
    }

    return true;
  }

//

  // ================================================================================
  // Pagination list jobs.

  void listAlljobsWithPagination({
    required PayloadManagementBloc payloadManagementBloc,
    required PaginationControllerBloc paginationControllerBloc,
    // required List<String> status,
  }) async {
    Map<String, dynamic> data = payloadManagementBloc.state.payload;

    int page = paginationControllerBloc.state.currentPage + 1;

    late Map<String, dynamic> variables;

    // data['status'] = status;

    // if (status.isEmpty) {
    variables = {
      "queryParam": {
        "page": page,
        "size": 10,
        "sort": "jobStartTime,desc",
      },
      "data": {
        "domain": userData.domain,
        "hasInTeam": true,
        ...data,
      },
    };

    var result = await GraphqlServices().performQuery(
      query: JobsSchemas.listAllJobsQuery,
      variables: variables,
    );

    if (result.hasException) {
      return;
    }

    var listallJobs = ListAllJobsModel.fromJson(result.data!);

    var list = listallJobs.listAllJobsWithPaginationSortSearch?.items ?? [];

    var totalItems =
        listallJobs.listAllJobsWithPaginationSortSearch?.totalItems ?? 0;

    var updatedData = paginationControllerBloc.state.result + list;

    if (totalItems == updatedData.length) {
      // paginationControllerBloc.add(UpdateResultDataEvent(
      //   results: updatedData,
      // ));
      paginationControllerBloc.state.result = updatedData;
      paginationControllerBloc.add(UpdateFetchMoreEvent(isCompleted: true));
    } else {
      paginationControllerBloc.add(UpdateResultDataEvent(
        results: updatedData,
      ));
    }

    paginationControllerBloc.state.currentPage = page;
  }

  // ==================================================================================
  // Get all jobs list using for store to local db.
  //

  void listAlljobsStoreToLocalDb() async {
    StorageServices storageServices = StorageServices();

    int? syncTime = await storageServices.getSyncTime();

    DateTime now = DateTime.now();

    if (syncTime != null) {
      DateTime syncDateTime = DateTime.fromMillisecondsSinceEpoch(syncTime);

      Duration duration = now.difference(syncDateTime);

      if (duration.inMinutes < 10) {
        return;
      }
    }

    String domain = userData.domain;

    int startDate;
    int endDate;

    DateTime currentMonthStart = DateTime(now.year, now.month, 1);
    DateTime previousMonthStart =
        DateTime(currentMonthStart.year, currentMonthStart.month - 1, 1);
    DateTime nextMonthStart =
        DateTime(currentMonthStart.year, currentMonthStart.month + 1, 1);

    // Calculate the start of the month after the next month
    DateTime monthAfterNextStart =
        DateTime(nextMonthStart.year, nextMonthStart.month + 1, 1);

    // Calculate the end of the next month
    DateTime nextMonthEnd =
        monthAfterNextStart.subtract(const Duration(days: 1));

    startDate = previousMonthStart.millisecondsSinceEpoch;
    endDate = nextMonthEnd.millisecondsSinceEpoch;

    Map<String, dynamic> variables = {
      "data": {
        "domain": domain,
        "startDate": startDate,
        "endDate": endDate,
        "hasInTeam": true,
      },
      "queryParam": {
        "page": -1,
        "size": 0,
      }
    };

    if (syncTime != null) {
      variables['data']['lastSyncTime'] = syncTime;
    }

    var result = await GraphqlServices().performQuery(
      query: JobsSchemas.listAllJobsWithDetailsForSync,
      variables: variables,
    );

    if (result.hasException) {
      return;
    }

    List items = result.data?["listAllJobsWithDetailsForSync"]['items'] ?? [];

    if (items.isEmpty) {
      return;
    }

    Box<JobDetailsDb> box = jobDetailsDbgetBox();

    await box.clear();

    storageServices.storeSyncTime(now.millisecondsSinceEpoch);

    for (var element in items) {
      JobDetailsDb jobDetailsDb = JobDetailsDb.fromJson(element);

      box.add(jobDetailsDb);
    }

    // DateTime currentDate = DateTime.now();

    // AwesomeNotifications().cancelNotificationsByChannelKey(
    //   NotificationController.notifyMeChannelKey,
    // );

    final List<JobDetailsDb> allJobs = box.values.toList();

    // Define the suffixes for different notification types
    const int startNotificationSuffix = 1;
    const int endNotificationSuffix = 2;

    List<JobDetailsDb> futureScheduledJobs = allJobs.where((element) {
      return DateTime.fromMillisecondsSinceEpoch(element.jobStartTime!)
              .isAfter(now) &&
          element.status == "SCHEDULED";
    }).toList();

    List<JobDetailsDb> futureCompletedJobs = allJobs.where((element) {
      return DateTime.fromMillisecondsSinceEpoch(element.expectedEndTime!)
              .isAfter(now) &&
          element.status == "SCHEDULED";
    }).toList();

    List<JobDetailsDb> alreadyCompletedJobs = allJobs.where((element) {
      return DateTime.fromMillisecondsSinceEpoch(element.expectedEndTime!)
              .isAfter(now) &&
          element.status == "COMPLETED";
    }).toList();

    // Cancel notifications for completed jobs
    for (var element in alreadyCompletedJobs) {
      final completedNotificationId =
          (element.id ?? -1) * 10 + endNotificationSuffix;

      NotificationService().cancelScheduledNotfication(completedNotificationId);
    }

    for (var element in futureScheduledJobs) {
      // Generate unique ID for the scheduled notification
      final startNotificationId =
          (element.id ?? -1) * 10 + startNotificationSuffix;

      DateTime notifyTime =
          DateTime.fromMillisecondsSinceEpoch(element.jobStartTime!)
              .subtract(const Duration(minutes: 10));

      NotificationService().scheduleNotifyNotification(
        identifier: startNotificationId,
        notifyTime: notifyTime,
        jobName: element.jobName ?? "",
        channelKey: NotificationController.notifyMeChannelKey,
        isCompleteNotification: false,
        payload: {
          "jobId": element.id.toString(),
          "updateItemType": "JOB",
        },
      );
    }

    for (var element in futureCompletedJobs) {
      // Generate unique ID for the completed notification
      final endNotificationId = (element.id ?? -1) * 10 + endNotificationSuffix;

      DateTime notifyTime =
          DateTime.fromMillisecondsSinceEpoch(element.expectedEndTime!)
              .subtract(const Duration(minutes: 10));

      NotificationService().scheduleNotifyNotification(
        identifier: endNotificationId,
        notifyTime: notifyTime,
        jobName: element.jobName ?? "",
        channelKey: NotificationController.notifyMeChannelKey,
        isCompleteNotification: true,
        payload: {
          "jobId": element.id.toString(),
          "updateItemType": "JOB",
        },
      );
    }

    // }
  }

  // =======================================================================================
  // STORE JOb CAncllation REASONS TO LOCAL DB. Used for when the user offline.
  // Cancel job

  void storeReasonsToLocalDb() async {
    String domain = userData.domain;

    Box<ReasonsDb> box = ReasonsDb.getBox();

    var result = await GraphqlServices().performQuery(
      query: JobsSchemas.canecellationQuery,
      variables: {
        "domain": domain,
      },
    );

    if (result.hasException) {
      return;
    }

    box.clear();

    List items = result.data!['listServiceCancelationReason']['items'];

    for (var element in items) {
      box.add(
        ReasonsDb(
          identifier: element['identifier'],
          name: element['name'],
        ),
      );
    }
  }

// ================================================================================================================
// Parts to store local db.

  void storePartsToLocalDb() async {
    String domain = userData.domain;

    var result = await GraphqlServices().performQuery(
      query: JobsSchemas.listofPartsQuery,
      variables: {
        "queryParam": {"page": -1, "size": 0, "sort": "name,asc"},
        "body": {
          "domain": domain,
          "status": "ACTIVE",
          "name": "",
        }
      },
    );

    if (result.hasException) {
      return;
    }

    var box = partsDbgetBox();

    await box.clear();

    for (var element in result.data!['listAllServiceParts']['items']) {
      // box.add(Parts.fromJson(json))
      partsStoreTolLocalDb(element);
    }
  }

// ============================================================================
//  Add a comment against job.

  Future<int?> addCommentToJob({
    required int jobId,
    required String comment,
    required String jobDomain,
    required File? attachedFile,
    required BuildContext context,
    String? attachingCategoryKey,
  }) async {
    var result = await GraphqlServices().performMutation(
      context: context,
      query: JobsSchemas.addJobCommentMutation,
      variables: {
        "data": {
          "comment": {"comment": comment},
          "jobId": jobId,
        }
      },
    );

    if (result.hasException) {
      return null;
    }

    int commentId = result.data?["addJobComment"]['id'];

    if (attachedFile != null) {
      // ignore: use_build_context_synchronously
      await JobsServices().attachFiles(
        context: context,
        attachedFile: attachedFile,
        filePath: attachingCategoryKey == null
            ? "/jobs/$jobDomain/$jobId/comments/$commentId"
            : "/jobs/$jobDomain/$jobId/comments/$commentId/$attachingCategoryKey",
      );
      return commentId;
    }

    return commentId;
  }

// -------------------------------------------------
// AttachFiles

  Future<dynamic> convertToFileUploadData(
    File attachedFile,
  ) async {
    var byteData = await attachedFile.readAsBytes();

    // var documentary = await getApplicationDocumentsDirectory();

    String fileName = path.basename(attachedFile.path);
    String extension = attachedFile.path.split('.').last;

    String mimeType = MimeTypes.getMimeType(extension);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      byteData,
      filename: fileName,
      contentType: MediaType(mimeType.split('/').first, extension),
    );

    return {
      "file": multipartFile,
      "name": fileName,
    };
  }

  void updateChecklistToLocalDb({
    required List<Checklist> checkLists,
    required int jobId,
  }) {
    var box = jobDetailsDbgetBox();

    var now = DateTime.now();

    var syncingBox = syncdbgetBox();

    var list = box.values.toList();

    int index = list.indexWhere((element) => element.id == jobId);

    if (index != -1) {
      JobDetailsDb? jobDetailsDb = box.getAt(index);

      if (jobDetailsDb != null) {
        jobDetailsDb.checklistDb = checkLists
            .map(
              (element) => ChecklistDb(
                checkable: element.checkable,
                id: element.id,
                executionIndex: element.executionIndex,
                checked: element.checked,
                choiceType: element.choiceType,
                choices: element.choices,
                item: element.item,
                description: element.description,
                selectedChoice: element.selectedChoice,
              ),
            )
            .toList();

        box.putAt(index, jobDetailsDb);

        bool alreadyAdded = syncingBox.values.any(
          (element) =>
              element.graphqlMethod == JobsSchemas.updateCheckListMutation &&
              element.payload['checkListData']['jobId'] == jobId,
        );

        if (!alreadyAdded) {
          syncingBox.add(SyncingLocalDb(
            payload: {
              "checkListData": {
                "checklists": checkLists.map((e) => e.toJson()).toList(),
                "jobId": jobId,
              }
            },
            generatedTime: now.millisecondsSinceEpoch,
            graphqlMethod: JobsSchemas.updateCheckListMutation,
          ));
        } else {
          int index = syncingBox.values.toList().indexWhere(
                (element) =>
                    element.graphqlMethod ==
                        JobsSchemas.updateCheckListMutation &&
                    element.payload['checkListData']['jobId'] == jobId,
              );

          syncingBox.putAt(
            index,
            SyncingLocalDb(
              payload: {
                "checkListData": {
                  "checklists": checkLists.map((e) => e.toJson()).toList(),
                  "jobId": jobId,
                }
              },
              generatedTime: now.millisecondsSinceEpoch,
              graphqlMethod: JobsSchemas.updateCheckListMutation,
            ),
          );
        }
      }
    }

    // jobDetailsDb.checklistDb = checkLists.map((element) => ChecklistDb.fromJson(element.toJson())).toList();
  }

  static int retries = 0;

  Future<List> getAttachmentsData(String jobAttachmentFilePath) async {
    var jobAttachmentResult = await GraphqlServices().performQuery(
      query: JobsSchemas.getAllFilesFromSamePath,
      variables: {
        "filePath": jobAttachmentFilePath,
        "traverseFiles": true,
      },
    );

    if (jobAttachmentResult.hasException) {
      while (retries < 3) {
        retries++;
        return getAttachmentsData(jobAttachmentFilePath);
      }
      // return [];
    }
    retries = 0;

    return jobAttachmentResult.data?['getAllFilesFromSamePath']['data'] ?? [];
  }

  // ======================================================================================================================================
  // ============================================================

  Future<List> getJobAttachmentsAndServiceRequestAttachments({
    required String jobAttachmentFilePath,
    String? serviceRequestAttachmentFilePath,
    bool showHiddenFolder = false,
  }) async {
    List attachmentsData = [];

    var jobAttachmentResult = await GraphqlServices().performQuery(
      query: JobsSchemas.getAllFilesFromSamePath,
      variables: {
        "filePath": jobAttachmentFilePath,
        "traverseFiles": true,
        "showHiddenFolder": showHiddenFolder,
      },
    );

    String? exceptionMessage = jobAttachmentResult
        .exception?.linkException?.originalException
        .toString();

    // if (exceptionMessage ==null) {

    // }

    if (jobAttachmentResult.hasException) {
      if (exceptionMessage != null &&
              exceptionMessage == "Connection reset by peer" ||
          exceptionMessage ==
              "Connection closed before full header was received") {
        while (retries < 3) {
          retries++;

          return getJobAttachmentsAndServiceRequestAttachments(
            jobAttachmentFilePath: jobAttachmentFilePath,
            serviceRequestAttachmentFilePath: serviceRequestAttachmentFilePath,
          );
        }
      }
    }

    retries = 0;

    attachmentsData =
        jobAttachmentResult.data?['getAllFilesFromSamePath']?['data'] ?? [];

    if (serviceRequestAttachmentFilePath == null) {
      return attachmentsData;
    }

    var serviceAttachmentResult = await GraphqlServices().performQuery(
      query: JobsSchemas.getAllFilesFromSamePath,
      variables: {
        "filePath": serviceRequestAttachmentFilePath,
        "traverseFiles": false,
        "showHiddenFolder": showHiddenFolder,
      },
    );

    String? errorMessage = jobAttachmentResult
        .exception?.linkException?.originalException
        .toString();

    if (serviceAttachmentResult.hasException) {
      if (errorMessage != null && errorMessage == "Connection reset by peer" ||
          errorMessage == "Connection closed before full header was received") {
        while (retries < 3) {
          retries++;

          return getJobAttachmentsAndServiceRequestAttachments(
            jobAttachmentFilePath: jobAttachmentFilePath,
            serviceRequestAttachmentFilePath: serviceRequestAttachmentFilePath,
          );
        }
      }
    }
    retries = 0;

    attachmentsData.addAll(
        serviceAttachmentResult.data?['getAllFilesFromSamePath']['data'] ?? []);

    attachmentsData.removeWhere(
      (element) => element['data'] == null,
    );
    return attachmentsData;
  }

// ============================================================================================================

//  =============================================================================================

  Future<void> openJobCard(
    int jobId, {
    required String fileType,
    required BuildContext context,
  }) async {
    BuildContext myAppContext = MyApp.navigatorKey.currentState!.context;

    String query = '''
query jobCardReport(\$data: JobCardReportInput) {
  jobCardReport(data: \$data)
}
''';

    showAdaptiveDialog(
      context: myAppContext,
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

    var result = await GraphqlServices().performQuery(query: query, variables: {
      "data": {
        "reportTitle": "Breakdown Job Card",
        "app": "Nectar Assets",
        "brand": userData.domain,
        "client": "Nectar",
        "reportDate": DateTime.now().millisecondsSinceEpoch,
        "jobId": jobId,
        "reportType": fileType,
      }
    });

    if (result.hasException) {
      // if (context.mounted) {
      buildSnackBar(
        context: myAppContext,
        value: "Something went wrong. Please try again",
      );

      Navigator.of(myAppContext).pop();
      // }
      return;
    }

    String? data = result.data?['jobCardReport']?['data'];
    String? fileName = result.data?['jobCardReport']?['fileName'];

    if (data == null) {
      // if (context.mounted) {
      buildSnackBar(
        context: myAppContext,
        value: "File not found",
      );
      // Navigator.of(context).pop();
      MyApp.navigatorKey.currentState?.pop();

      // }

      return;
    }

    Uint8List decodedbytes = base64Decode(data);

    final directory = await getApplicationDocumentsDirectory();

    File file =
        await File("${directory.path}/$fileName.${getFileExtension(fileType)}")
            .writeAsBytes(decodedbytes);

    // if (context.mounted) {
    if (!file.existsSync()) {
      buildSnackBar(
        context: myAppContext,
        value: "File not found",
      );
      return;
    }

    FileServices().openFile(file, context);

    // Navigator.of(context).pop();
    MyApp.navigatorKey.currentState?.pop();
    // }
  }

//  ================================================
// Get file Extension

  String getFileExtension(String type) {
    switch (type) {
      case "PDF":
        return "pdf";

      case "EXCEL":
        return "xlsx";

      default:
        return "";
    }
  }

  // =====================================================================================================

  addJobAttachmentsToBlocState({
    required String jobAttachmentFilePath,
    required String attachmentCategoryKey,
    String? serviceRequestAttachmentFilePath,
  }) async {
    List attachmentsData = [];

    AttachmentsControllerBloc attachmentsControllerBloc =
        BlocProvider.of(MyApp.navigatorKey.currentContext!);

    attachmentsControllerBloc.add(ChangeLoadingDataEvent(isLoading: true));

    attachmentsData = await getJobAttachmentsAndServiceRequestAttachments(
      jobAttachmentFilePath: jobAttachmentFilePath,
      serviceRequestAttachmentFilePath: serviceRequestAttachmentFilePath,
    );

    attachmentsControllerBloc.add(
      AddAttachmentsListData(
        allData: attachmentsData,
        filteredData: attachmentsData,
      ),
    );
  }

 showAttachmentDialogPicker(
    BuildContext context, {
    required String attachingFilePath,
    required AttachmentsControllerBloc attachmentsControllerBloc,
    required String attachmentCategoryKey,
  }) {
    bool enableAudioVideo = false;

    String? appThemeData = SharedPrefrencesServices().getData(key: "appTheme");

    if (appThemeData != null) {
      var data = jsonDecode(appThemeData);

      enableAudioVideo =
          data?["fileConfiguration"]?["enableAudioVideo"] ?? false;
    }

    List<FileSelectorModel> attachmentSelectorList = [
      FileSelectorModel(
        title: 'Photo',
        icon: 'camera',
        onTap: () async {
          accessCamera(
            context,
            attachingFilePath: attachingFilePath,
            attachmentCategoryKey: attachmentCategoryKey,
          );
        },
      ),
      if (enableAudioVideo)
        FileSelectorModel(
          title: 'Video',
          icon: 'video',
          onTap: () {
            accessVideo(
              context,
              attachingFilePath: attachingFilePath,
              attachmentCategoryKey: attachmentCategoryKey,
            );
          },
        ),
      FileSelectorModel(
        title: 'Gallery',
        icon: 'gallery',
        onTap: () {
          accessGallery(
            context,
            attachingFilePath: attachingFilePath,
            attachmentCategoryKey: attachmentCategoryKey,
          );
        },
      ),
      if (enableAudioVideo)
        FileSelectorModel(
          title: 'Audio',
          icon: 'audio',
          onTap: () {
            accessAudio(
              context,
              attachingFilePath: attachingFilePath,
              attachmentCategoryKey: attachmentCategoryKey,
            );
          },
        ),
    ];

    FileServices().showAttachmentBottomSheet(
      context,
      attachmentSelectorList: attachmentSelectorList,
    );
  }

  Future<void> accessCamera(
    BuildContext context, {
    required String attachingFilePath,
    required String attachmentCategoryKey,
  }) async {
    Navigator.of(context).pop();

    var file = await FileServices().pickImage(
      context,
      isCamera: true,
    );

    if (file != null) {
      if (!context.mounted) return;
      navigateToSelectedFileScreen(
        context,
        attachingFilePath: attachingFilePath,
        attachmentCategoryKey: attachmentCategoryKey,
        file: file,
      );
    }
  }

  Future<void> accessGallery(
    BuildContext context, {
    required String attachingFilePath,
    required String attachmentCategoryKey,
  }) async {
    //To pop the bottom sheet
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

    File? file = await FileServices().pickImage(context, isCamera: false);

    if (file == null) {
      if (!context.mounted) return;

      // To pop the loader
      Navigator.of(context).pop();
    }

    if (file != null) {
      if (!context.mounted) return;

      // To pop the loader
      Navigator.of(context).pop();

      navigateToSelectedFileScreen(
        context,
        attachingFilePath: attachingFilePath,
        attachmentCategoryKey: attachmentCategoryKey,
        file: file,
      );
    }
  }

  Future<void> accessVideo(
    BuildContext context, {
    required String attachingFilePath,
    required String attachmentCategoryKey,
  }) async {
    Navigator.pop(context);

    var file = await FileServices().getVideo(
      context,
      isCamera: true,
    );

    if (file != null) {
      if (!context.mounted) return;
      navigateToSelectedFileScreen(
        context,
        attachingFilePath: attachingFilePath,
        attachmentCategoryKey: attachmentCategoryKey,
        file: file,
        openImageEditer: false,
      );
    }
  }

  Future<void> accessAudio(
    BuildContext context, {
    required String attachingFilePath,
    required String attachmentCategoryKey,
  }) async {
    var path = await FileServices().showAudioRecorderPopup(context);

    if (path != null) {
      if (!context.mounted) return;
      navigateToSelectedFileScreen(
        context,
        attachingFilePath: attachingFilePath,
        attachmentCategoryKey: attachmentCategoryKey,
        file: File(path),
        openImageEditer: false,
      );
    }
  }

 /// navigate to selected file screen
  void navigateToSelectedFileScreen(
    BuildContext context, {
    required String attachingFilePath,
    required String attachmentCategoryKey,
    required File file,
    bool openImageEditer = true,
  }) async {
    var list = attachingFilePath.split("/");

    String jobDomain = list[1];

    int jobId = int.parse(list[2]);

    FileType fileType = FileServices().getFileType(path.extension(file.path));

    if (openImageEditer && fileType == FileType.image) {
      File? selectedFile = await FileServices().navigateToImageEditor(
        context: context,
        file: file,
      );

      if (selectedFile != null) {
        if (!context.mounted) return;
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) {
              return SelectedFileScreen(
                file: selectedFile,
                allAttachmentFilePath: "jobs/$jobDomain/$jobId",
                attachmentCategoryKey: attachmentCategoryKey,
                attachingFilePath: attachingFilePath,
              );
            },
          ),
        );
      }
    } else if (fileType == FileType.video) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return TrimmerView(
            file,
            onSave: (path) async {
              //          setState(() {
              //   _progressVisibility = false;
              // });

              final thumbnailFile = await VideoCompress.getFileThumbnail(path!,
                  quality: 50, // default(100)
                  position: -1 // default(-1)
                  );

              debugPrint('OUTPUT PATH: $path');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SelectedFileScreen(
                    file: File(path),
                    allAttachmentFilePath: "jobs/$jobDomain/$jobId",
                    attachmentCategoryKey: attachmentCategoryKey,
                    attachingFilePath: attachingFilePath,
                    videoThumbnail: thumbnailFile,
                  ),
                ),
              );
            },
          );
        },
      ));
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) {
            return SelectedFileScreen(
              file: file,
              allAttachmentFilePath: "jobs/$jobDomain/$jobId",
              attachmentCategoryKey: attachmentCategoryKey,
              attachingFilePath: attachingFilePath,
            );
          },
        ),
      );
    }
  }

  launchGoogleMap({
    required BuildContext context,
    required String? location,
    required String? assetType,
    required String? assetIdentifier,
    required String? domain,
  }) async {
    String? data = SharedPrefrencesServices().getData(key: "appTheme");

    DateTime now = DateTime.now();

    int startDateEpoch = 0;

    int endDateEpoch = 0;

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
                  "Loading, please wait...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
    );

    if (data != null) {
      var jsonDecoded = jsonDecode(data);

      Map<String, dynamic>? notCommunicatingTimeStamp =
          jsonDecoded['assetCommunicationStatus']['notCommunicating'];

      int start = notCommunicatingTimeStamp?['start'] ?? 0;
      int end = notCommunicatingTimeStamp?['end'] ?? 0;

      startDateEpoch = start == 0
          ? 0
          : now.subtract(Duration(minutes: start)).millisecondsSinceEpoch;

      endDateEpoch = end == 0
          ? 0
          : now.subtract(Duration(minutes: end)).millisecondsSinceEpoch;
    }

    var result = await GraphqlServices()
        .performQuery(query: AssetSchema.findAssetSchema, variables: {
      "domain": domain,
      "identifier": assetIdentifier,
      "type": assetType,
    });

    if (result.hasException || result.data == null) {
      if (!context.mounted) return;

      //Pop the loader
      Navigator.of(context).pop();
      buildSnackBar(context: context, value: "Something went wrong");
      return;
    }

    //Pop the loader
    Navigator.of(context).pop();

    AssetInfoModel assetInfoModel = AssetInfoModel.fromJson(result.data ?? {});

    int? assetDataTimeEpoch = assetInfoModel.findAsset?.assetLatest?.dataTime;

    DateTime assetDataTime =
        DateTime.fromMillisecondsSinceEpoch(assetDataTimeEpoch ?? 0);

    DateTime notCommunicatingStartTime =
        DateTime.fromMillisecondsSinceEpoch(startDateEpoch);
    DateTime notCommunicatingEndTime =
        DateTime.fromMillisecondsSinceEpoch(endDateEpoch);

    String formattedAssetDataTime =
        DateFormat("dd-MMM-yyyy").add_jm().format(assetDataTime);

    if (assetDataTime.isAfter(notCommunicatingStartTime) &&
        assetDataTime.isBefore(notCommunicatingEndTime)) {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text("Alert"),
          content: Column(
            children: [
              Text(
                  "This asset has not been communicating since $formattedAssetDataTime"),
              TextButton(
                onPressed: () {
                  LauncherServices().openGoogleMaps(context, location);
                },
                child: const Text("Open Google map"),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"))
          ],
        ),
      );
    } else {
      if (!context.mounted) return;

      LauncherServices().openGoogleMaps(context, location);
    }
  }

  
}
