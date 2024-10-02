import 'dart:convert';
import 'package:app_filter_form/app_filter_form.dart';
import 'package:app_filter_form/core/models/filter_value_model.dart';
import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/job/job_management_bloc.dart';
import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/core/blocs/parts/bloc/parts_control_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_event.dart';
import 'package:awesometicks/core/models/hive%20db/job_reasons_model.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_action_service.dart';
import 'package:awesometicks/core/services/launcher_services.dart';
import 'package:awesometicks/core/services/platform_services.dart';
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:awesometicks/ui/pages/job/functions/time_counter.dart';
import 'package:awesometicks/ui/pages/job/widgets/action_buttons.dart';
import 'package:awesometicks/ui/pages/job/widgets/job_parts_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/job_tasks_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/start_travel_bottom_sheet.dart';
import 'package:awesometicks/ui/pages/job/widgets/start_travel_button_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/stop_travel_button.dart';
import 'package:awesometicks/ui/shared/widgets/timeline_widget.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:awesometicks/ui/pages/job/functions/format_duration.dart';
import 'package:awesometicks/ui/pages/job/job_attachments.dart';
import 'package:awesometicks/ui/pages/job/job_comments.dart';
import 'package:awesometicks/ui/pages/job/job_complete.dart';
import 'package:awesometicks/ui/pages/job/widgets/build_label_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/details_card.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:track_location/track_location.dart';
import 'package:user_permission/user_permission.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../core/blocs/attachments/attachments_controller_bloc.dart';
import '../../../core/blocs/internet/bloc/internet_available_bloc.dart';
import '../../../core/blocs/job controller/job_controller_bloc_bloc.dart';
import '../../../core/blocs/parts/parts_quantity_bloc.dart';
// import '../../../core/models/filter_value_model.dart';
import '../../shared/functions/short_letter_converter.dart';
import '../../shared/widgets/build_elvetad_button.dart';
import '../assets/details/asset_details_screen.dart';
import '../service request/details/service_details.dart';
import 'package:graphql_config/graphql_config.dart';
import 'widgets/job_card_popupmenu.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  static const String id = "/job/details";

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  TrackLocation trackLocation = TrackLocation();

  List<Map> rowButtonList = [
    {
      "title": "Tasks",
      "key": "tasks",
    },
    // {
    //   "title": "Details",
    //   "key": "details",
    // },
    {
      "title": "Notes",
      "key": "notes",
    },
    {
      "title": "Attachments",
      "key": "attachments",
    },
    {
      "title": "Parts",
      "key": "parts",
    },
    {
      "title": "Timeline",
      "key": "timeline",
    },
  ];

  List<Map> scheduledActionsList = [
    {
      "title": "Cancel",
      "key": "cancel",
    },
    {
      "title": "Start",
      "key": "start",
    },
  ];

  List<Map> startedActionsList = [
    {
      "title": "Cancel",
      "key": "cancel",
    },
    {
      "title": "Hold",
      "key": "hold",
    },
    {
      "title": "Complete",
      "key": "complete",
    },
  ];

  List<Map> holdedActionsList = [
    {
      "title": "Cancel",
      "key": "cancel",
    },
    {
      "title": "Resume",
      "key": "resume",
    },
    {
      "title": "Complete",
      "key": "complete",
    },
  ];

  List holdReasonItems = [
    {
      "name": "Held",
      "identifier": "HELD",
    },
    {
      "name": "No Access",
      "identifier": "NOACCESS",
    },
    {
      "name": "Waiting for parts",
      "identifier": "WAITINGFORPARTS",
    },
  ];

  late int jobId;

  int initialIndex = 0;

  int? commentId;
  int? replyId;
  int? checklistId;

  List<Checklist> checkLists = [];

  List<Checklist> userCheckLists = [];

  List<Checklist> assetCheckLists = [];

  ValueNotifier<int> checklistExpansionNotifier = ValueNotifier<int>(-1);

  // ValueNotifier<bool> actionButtonLoadingNotifier = ValueNotifier<bool>(false);

  ValueNotifier<String> elapsedTimeNotifier = ValueNotifier<String>("0s");

  // late StartTravelService startTravelService;

  late JobManagementBloc jobManagementBloc;
  late FilterSelectionBloc filterSelectionBloc;
  late JobDetailsModel jobDetailsModel;
  late PartsQuantityBloc partsQuantityBloc;
  late PartsControlBloc partsControlBloc;

  Box<SyncingLocalDb> syncingBox = syncdbgetBox();
  Box<JobDetailsDb> jobBox = jobDetailsDbgetBox();
  Box<ReasonsDb> reasonsBox = ReasonsDb.getBox();

  late JobControllerBlocBloc jobControllerBloc;

  ItemScrollController scrollController = ItemScrollController();

  UserDataSingleton userData = UserDataSingleton();

  late AttachmentsControllerBloc attachmentsControllerBloc;

  late TimelineUpdateBloc timelineUpdateBloc;

  late ActionButtonLoadingBloc actionButtonLoadingBloc;

  final UserPermissionServices userPermissionServices =
      UserPermissionServices();

  late TravelTimeBloc travelTimeBloc;
  late JobDetailsBloc jobDetailsBloc;

  @override
  void initState() {
    jobDetailsBloc = BlocProvider.of<JobDetailsBloc>(context);
    travelTimeBloc = BlocProvider.of<TravelTimeBloc>(context);
    jobManagementBloc = BlocProvider.of<JobManagementBloc>(context);
    filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);
    partsQuantityBloc = BlocProvider.of<PartsQuantityBloc>(context);
    partsControlBloc = BlocProvider.of<PartsControlBloc>(context);
    jobControllerBloc = BlocProvider.of<JobControllerBlocBloc>(context);
    actionButtonLoadingBloc = BlocProvider.of<ActionButtonLoadingBloc>(context);
    // startTravelService =
    //     StartTravelService(elapsedTimeNotifier: elapsedTimeNotifier);
    filterSelectionBloc.state.filterValueMap[FilterType.jobs]?.add(FilterValue(
      key: "parts",
      selectedValues: [],
      type: "",
      identifierObject: null,
    ));

    bool commentViewPermission = userPermissionServices.checkingPermission(
      featureGroup: "jobManagement",
      feature: "job",
      permission: "viewComment",
    );

    if (!commentViewPermission) {
      rowButtonList.removeWhere((element) => element['key'] == "notes");
    }

    attachmentsControllerBloc =
        BlocProvider.of<AttachmentsControllerBloc>(context);

    timelineUpdateBloc = BlocProvider.of<TimelineUpdateBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map<String, dynamic> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      int jobId = arguments['jobId'];

      InterNetServices().checkInternetConnectivity().then((value) {
        if (value) {
          jobDetailsBloc.add(
            FetchJobDetailDataEvent(
              jobId: jobId,
              isFirstTimeCall: true,
            ),
          );
        }
      });

      travelTimeBloc.add(
        TravelTimeInitialEvent(
          /// assigneeIds refers to the id of current user logged in
          payload: {
            "domains": [userData.domain],
            "assignees": [],
            "assigneeIds": [userData.userId],
            "jobIds": [arguments['jobId']],

            /// if date range not given complete job list will be returned
            // "dateRange": {
            //   "startDate": 1723454585000,
            //   "endDate": 1721308200000,
            // }
          },
        ),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    jobManagementBloc.state.completed = 0;
    filterSelectionBloc.state.filterValueMap[FilterType.jobs]
        ?.removeWhere((element) => element.key == "parts");

    // countdownController.dispose();

    elapsedTimeNotifier.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    jobId = arguments['jobId'];
    commentId = arguments['commentId'];
    checklistId = arguments['checklistId'];

    //  This condition is checking the comment is not recieved from checklist comment.
    if (commentId != null && checklistId == null) {
      int noteIndex =
          rowButtonList.indexWhere((element) => element['key'] == "notes");
      if (noteIndex != -1) {
        initialIndex = noteIndex;
      }
      replyId = arguments['replyId'];
    }

    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: DefaultTabController(
          length: rowButtonList.length,
          initialIndex: initialIndex,
          child: Scaffold(
            backgroundColor: fwhite,
            body: BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
              builder: (context, state) {
                if (!state.isInternetAvailable) {
                  return fetchingDatafromLocalDb();
                }

                return BlocBuilder<JobDetailsBloc, JobDetailsState>(
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return Column(
                        children: [
                          buildHeaderContainer(
                            jobName: "Job Details",
                            job: null,
                          ),
                          Expanded(
                            child: BuildShimmerLoadingWidget(
                              height: 10.h,
                            ),
                          ),
                        ],
                      );
                    }

                    if (state is ErroHandlingState) {
                      return Column(
                        children: [
                          buildHeaderContainer(
                            jobName: "Job Details",
                            job: null,
                          ),
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                    "Something went wrong. Please try again"),
                                TextButton.icon(
                                  onPressed: () {
                                    jobDetailsBloc.add(
                                        FetchJobDetailDataEvent(jobId: jobId));
                                  },
                                  icon: const Icon(
                                    Icons.refresh,
                                  ),
                                  label: const Text(
                                    "Retry",
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    if (state is SuccessState) {
                      jobDetailsModel = state.jobDetailsModel;

                      var job = jobDetailsModel.findJobWithId;

                      checkLists =
                          jobDetailsModel.findJobWithId?.checklist ?? [];

                      /// Filter user type checklists
                      userCheckLists = checkLists
                          .where((element) => element.type != "ASSET")
                          .toList();

                      /// Filter asset type checklists
                      assetCheckLists = checkLists
                          .where((element) => element.type == "ASSET")
                          .toList();

                      return buildHeaderWithTabbar(
                        job,
                        hasInternet: true,
                      );
                    }

                    return const SizedBox();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================================

  Column buildHeaderWithTabbar(
    FindJobWithId? job, {
    required bool hasInternet,
  }) {
    List transitions = jobDetailsModel.findJobWithId?.transitions ?? [];

    List timeLines = [
      {
        "time": job?.requestTime ?? 0,
        "status": "REGISTERED",
        "comment": "Job Created",
      },
      ...transitions.map(
        (e) {
          return {
            "time": e['transitionTime'] ?? e['time'],
            "status": e['currentStatus'] ?? e['status'],
            "comment": e['transitionComment'] ?? e['comment'],
          };
        },
      ).toList(),
    ];

    if (!hasInternet) {
      timelineUpdateBloc.state.timelines = timeLines;
    }

    return Column(
      children: [
        buildHeaderContainer(
          jobName: job?.jobName ?? "N/A",
          job: job,
        ),
        SizedBox(
          height: 5.sp,
        ),
        PermissionChecking(
          featureGroup: "jobManagement",
          feature: "job",
          permission: "view",
          showNoAccessWidget: true,
          paddingTop: 10.sp,
          child: Expanded(
            child: Column(
              children: [
                TabBar(
                    isScrollable: true,
                    padding: EdgeInsets.symmetric(
                        vertical: 10.sp, horizontal: 10.sp),
                    labelPadding:
                        EdgeInsets.symmetric(vertical: 5.sp, horizontal: 10.sp),
                    indicator: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(4.sp),
                    ),
                    tabs: List.generate(rowButtonList.length, (index) {
                      var title = rowButtonList[index]['title'];

                      return Text(
                        title,
                        style: TextStyle(
                          color: kBlack,
                        ),
                      );
                    })),
                Expanded(
                    child: TabBarView(
                  children: List.generate(rowButtonList.length, (index) {
                    String key = rowButtonList[index]['key'];

                    if (key == "tasks") {
                      return buildTasksWidget(
                        serviceRequestNumber:
                            job?.serviceRequest?.isEmpty ?? false
                                ? null
                                : job?.serviceRequest?.first.requestNumber,
                        jobDomain: jobDetailsModel.findJobWithId?.domain ?? "",
                        hasInternet: hasInternet,
                      );
                    } else if (key == "details") {
                      return buildDetailsWidget(
                        jobDetailsModel: jobDetailsModel,
                      );
                    } else if (key == "notes") {
                      return JobCommentsScreen(
                        commentId: commentId,
                        replyId: replyId,
                        jobId: jobId,
                        jobDomain: jobDetailsModel.findJobWithId?.domain ?? "",
                      );
                    } else if (key == "attachments") {
                      return JobAttachmentsScreen(
                        serviceRequestNumber:
                            job?.serviceRequest?.isEmpty ?? false
                                ? null
                                : job?.serviceRequest?.first.requestNumber,
                        jobDomain: jobDetailsModel.findJobWithId?.domain ?? "",
                        jobId: jobId,
                      );
                    } else if (key == "parts") {
                      return JobPartsWidget(
                        partsQuantityBloc: partsQuantityBloc,
                        jobId: jobId,
                        jobDetailsBloc: jobDetailsBloc,
                      );
                      //  buildPartsWidget(
                      //   noInternet: !hasInternet,
                      // );
                    } else if (key == "timeline") {
                      return TimelineWidget(
                        jobDetailsBloc: jobDetailsBloc,
                        hasInternet: hasInternet,
                        jobId: jobId,
                      );
                    }

                    return const SizedBox();
                  }),
                )),
                buildActionButton(job, hasInternet),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ActionButtons buildActionButton(FindJobWithId? job, bool hasInternet) {
    return ActionButtons(
      jobStatus: job?.status ?? "",
      hasTravelTime: job?.hasTravelTime ?? false,
      hasTravelTimeIncluded: job?.hasTravelTimeIncluded ?? false,
      hasInternet: hasInternet,
      startTravelButtonWidget: StartTravelButtonWidget(
        hasTravelTime: job?.hasTravelTime ?? false,
        hasTravelTimeIncluded: job?.hasTravelTimeIncluded ?? false,
        members: job?.members ?? [],
        jobId: jobId,
        actionButtonLoadingBloc: actionButtonLoadingBloc,
        startTravelBottomSheet: StartTravelBottomSheet(
          // startTravelService: startTravelService,
          domain: userData.domain,
          assignee: jobDetailsModel.findJobWithId?.assignee,
          members: job?.members ?? [],
          jobId: jobId,
          hasTravelTimeIncluded: job?.hasTravelTimeIncluded ?? false,
        ),
      ),
      stopTravelButton: StopTravelButton(
        jobId: jobId,
        travelTimeBloc: travelTimeBloc,
        startTime: travelTimeBloc.getLatestItem?.startTime,
        startLocation: travelTimeBloc.getLatestItem?.startLocation,
        startLocationName: travelTimeBloc.getLatestItem?.startLocationName,
        actionButtonLoadingBloc: actionButtonLoadingBloc,
      ),
      onPressed: (String key) async {
        actionButtonLoadingBloc
            .add(ActionButtonIsLoadingEvent(isLoading: true));

        String status = job?.status ?? "";
        String jobName = job?.jobName ?? "";

        ConnectivityResult connectivityResult =
            await Connectivity().checkConnectivity();

        bool noInternet = connectivityResult == ConnectivityResult.none;

        Box<SyncingLocalDb> box = syncdbgetBox();

        if (noInternet) {
          syncingdbHandling(key, box, status: status, jobName: jobName);

          actionButtonLoadingBloc
              .add(ActionButtonIsLoadingEvent(isLoading: false));
          return;
        }

        if (key == "retry") {
          travelTimeBloc.add(
            TravelTimeInitialEvent(
              /// assigneeIds refers to the id of current user logged in
              payload: {
                "domains": [userData.domain],
                "assignees": [],
                "assigneeIds": [userData.userId],
                "jobIds": jobId,

                /// if date range not given complete job list will be returned
                // "dateRange": {
                //   "startDate": 1723454585000,
                //   "endDate": 1721308200000,
                // }
              },
            ),
          );
        }

        if (key == "start" || key == "resume") {
          if (key == "start") {
            try {
              // NotificationService()
              //     .cancelScheduledNotfication(jobId);
            } catch (_) {}
          }

          int statusTime = DateTime.now().millisecondsSinceEpoch;

          var locationMap =
              await trackLocation.getCurrentLocationAndLocationName(context);

          // actionButtonLoadingBloc
          //     .add(ActionButtonIsLoadingEvent(isLoading: true));

          // ignore: use_build_context_synchronously
          var result =
              // ignore: use_build_context_synchronously
              await GraphqlServices().performMutation(
            context: context,
            query: JobsSchemas.jobStatusUpdateMutation,
            variables: {
              "id": jobId,
              "statusData": {
                "statusTime": DateTime.now().millisecondsSinceEpoch,
                "status": "INPROGRESS",
                "statusLocation": locationMap['location'],
                "statusLocationName": locationMap['locationName'],
              }
            },
          );

          // print(result.isLoading);

          // if (result.isLoading) {
          //   print("Result is not loading");

          //   actionButtonLoadingBloc
          //       .add(ActionButtonIsLoadingEvent(isLoading: true));
          // }

          if (result.hasException) {
            actionButtonLoadingBloc
                .add(ActionButtonIsLoadingEvent(isLoading: false));

            var graphqlErrors = result.exception?.graphqlErrors ?? [];

            String? errorMessage = graphqlErrors
                .firstOrNull?.extensions?['response']?['body']?['errorMessage'];

            if (errorMessage != null) {
              // ignore: use_build_context_synchronously
              buildSnackBar(
                context: context,
                value: errorMessage,
              );

              return;
            }

            // ignore: use_build_context_synchronously
            buildSnackBar(
              context: context,
              value: "Something went wrong. please try again.",
            );

            return;
          }

          actionButtonLoadingBloc
              .add(ActionButtonIsLoadingEvent(isLoading: false));

          jobControllerBloc.add(ChangeJobStatusEvent(status: "INPROGRESS"));
          JobsActionService.callTravelTimeSheetApi(
              travelTimeBloc: travelTimeBloc, jobId: jobId);

          timelineUpdateBloc.add(TimeLineChangeEvent(timeline: {
            "time": statusTime,
            "status": "INPROGRESS",
          }));

          if (key == "start") {
            jobControllerBloc.add(ChangeJobTimeEvent(
              actualStartTime: statusTime,
            ));
            // ignore: use_build_context_synchronously
            buildSnackBar(
              context: context,
              value: "Job started successfully",
            );
          } else {
            // ignore: use_build_context_synchronously
            buildSnackBar(
              context: context,
              value: "Job resumed successfully",
            );
          }

          // setState(() {
          //   status = "INPROGRESS";
          // });

          // actualStartTime = DateTime.now().millisecondsSinceEpoch;
        } else if (key == "cancel") {
          TextEditingController remarksController = TextEditingController();

          String? selectedReasonIdentifier;

          // ignore: use_build_context_synchronously
          buildCancellationModalSheet(
            context,
            selectedReasonIdentifier,
            remarksController,
          );
        } else if (key == "hold") {
          // ignore: use_build_context_synchronously
          buildHoldWidget(context);
        } else if (key == "complete") {
          int totalLength = checkLists.length;
          // int completed = jobManagementBloc.state.completed;

          int userChecklistCompleted = jobManagementBloc.state.completed;

          int assetChecklistCompleted =
              jobManagementBloc.state.assetChecklistCompleted;

          int completed = userChecklistCompleted + assetChecklistCompleted;

          if (totalLength != completed) {
            // ignore: use_build_context_synchronously
            if (context.mounted) {
              PlatformServices().showPlatformAlertDialog(
                context,
                title: "Complete",
                message: "Please update all checklists!",
              );
            }
            return;
          }

          var actualStartTime = jobControllerBloc.state.actualStartTime;

          bool isNotAssignee = job?.assignee?.id != userData.userId;

          if (isNotAssignee) {
            if (context.mounted) {
              JobsActionService().showCompleteConfirmationForNonAssignee(
                context,
                travelTimeBloc: travelTimeBloc,
                jobId: jobId,
              );
            }

            return;
          }

          // ignore: use_build_context_synchronously
          bool? complete = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JobCompleteScreen(
                travelTimeBloc: travelTimeBloc,
                jobDetailsBloc: jobDetailsBloc,
                jobDomain: jobDetailsModel.findJobWithId?.domain ?? "",
                jobControllerBloc: jobControllerBloc,
                duration: jobDetailsModel.findJobWithId!.expectedDuration!,
                assetAttached:
                    jobDetailsModel.findJobWithId?.resource?.displayName !=
                        null,
                jobName: jobName,
                jobStartTime: actualStartTime!,
                jobId: jobId,
                assetName:
                    jobDetailsModel.findJobWithId?.resource?.displayName ?? "",
                teamMembers: jobDetailsModel.findJobWithId?.members ?? [],
                assigneeId: jobDetailsModel.findJobWithId?.assignee?.id,
                assetEntity: jobDetailsModel.findJobWithId?.resource?.toJson(),
              ),
            ),
          );

          if (complete ?? false) {
            jobControllerBloc.add(
              ChangeJobStatusEvent(
                status: "COMPLETED",
              ),
            );
          }
        } else if (key == "stopTravel") {
          jobControllerBloc.add(ChangeJobStatusEvent(status: "SCHEDULED"));

          // startTravelService.startOrStopTimer();
        }

        actionButtonLoadingBloc
            .add(ActionButtonIsLoadingEvent(isLoading: false));
      },
    );
  }

  Widget fetchingDatafromLocalDb() {
    return ValueListenableBuilder(
      valueListenable: jobDetailsDbgetBox().listenable(),
      builder: (context, box, _) {
        // print('ValueListenableBuilder called');/

        JobDetailsDb? jobDetailsDb
            // = jobDetailsDbgetBox()
            = box.values.singleWhereOrNull((element) => element.id == jobId);

        if (jobDetailsDb == null) {
          return const Expanded(
            child: Center(
              child: Text("Job not found"),
            ),
          );
        }

        List<ChecklistDb> checklistsDb = jobDetailsDb.checklistDb ?? [];

        checkLists = [];

        checkLists = checklistsDb
            .map((e) => Checklist(
                  id: e.id,
                  item: e.item,
                  description: e.description,
                  commentCount: e.comments?.length ?? 0,
                  checkable: e.checkable,
                  checked: e.checked,
                  executionIndex: e.executionIndex,
                  choiceType: e.choiceType,
                  choices: e.choices,
                  selectedChoice: e.selectedChoice,
                ))
            .toList();

        jobDetailsModel = JobDetailsModel(
          findJobWithId: FindJobWithId.fromJson(
            jobDetailsDb.toJson(),
          ),
        );

        var job = jobDetailsModel.findJobWithId;

        jobControllerBloc.state.jobStatus = job?.status ?? "";

        jobControllerBloc.state.actualStartTime = job?.actualStartTime;
        jobControllerBloc.state.actualEndTime = job?.actualEndTime;

        return buildHeaderWithTabbar(
          job,
          hasInternet: false,
        );
      },
    );
  }

  // ========================================================================================
  // Showing the details widget.

  Widget buildDetailsWidget({
    required JobDetailsModel jobDetailsModel,
  }) {
    var job = jobDetailsModel.findJobWithId;

    String startTime = job?.jobStartTime == null
        ? "N/A"
        : DateFormat("d MMM, yyyy").add_jm().format(
              DateTime.fromMillisecondsSinceEpoch(job!.jobStartTime!),
            );

    String endTime = job?.expectedEndTime == null
        ? "N/A"
        : DateFormat("d MMM, yyyy").add_jm().format(
              DateTime.fromMillisecondsSinceEpoch(job!.expectedEndTime!),
            );

    String? community = job?.community?.clientName;
    String? subCommunity = job?.subCommunity?['name'];
    String? spaces = job?.spaces?.map((e) => e['name']).toList().join(" - ");
    String? buildingName = job?.building?['name'];

    getLocationPath(List<String?> list) {
      String value = list.where((element) => element != null).join(" - ");

      return value;
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        jobDetailsBloc.add(FetchJobDetailDataEvent(jobId: jobId));
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        children: [
          BuildDetailsCard(
            title: "Job Name",
            value: job?.jobName ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Status",
            value: job?.status ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Remarks",
            value: job?.jobRemark ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Job Id",
            value: job?.jobNumber ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          Builder(
            builder: (context) {
              var assignee = job?.assignee;

              if (assignee == null) {
                return const SizedBox();
              }

              String name = assignee.name ?? "N/A";
              String emailId = assignee.emailId ?? "N/A";
              String contactNumber = assignee.contactNumber ?? "N/A";

              return BuildDetailsCard(
                title: "Assigned To",
                onTap: () {
                  LauncherServices().launchPhoneDialer(
                    context,
                    contactNumber,
                  );
                },
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 2.sp,
                  ),
                  Text("$emailId - $contactNumber"),
                ],
              );
            },
          ),
          SizedBox(
            height: 5.sp,
          ),

          /// This widget shows the primary contact number
          Visibility(
            visible: job?.requestedBy != null,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5.sp),
              child: BuildDetailsCard(
                title: "Primary contact",
                onTap: () {
                  LauncherServices().launchPhoneDialer(
                    context,
                    job?.requestedBy?.contactNumber,
                  );
                },
                children: [
                  Text(
                    job?.requestedBy?.name ?? 'Null',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 2.sp,
                  ),
                  Text(
                    "${job?.requestedBy?.emailId} - ${job?.requestedBy?.contactNumber}",
                  ),
                ],
              ),
            ),
          ),

          /// This widget is used to show Secondary Contact
          Builder(builder: (context) {
            List<ContactPerson>? contacts =
                job?.serviceRequest?.isEmpty ?? false
                    ? null
                    : job?.serviceRequest?.first.contactPersons;

            return Visibility(
              visible: (contacts ?? []).isNotEmpty,
              child: BuildDetailsCard(
                title: "Secondary contact number",
                children: List.generate(contacts?.length ?? 0, (index) {
                  ContactPerson? contactPerson = contacts?[index];

                  String? name = contactPerson?.name;
                  String? contact = contactPerson?.contactNumber;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      LauncherServices().launchPhoneDialer(context, contact);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("$name : $contact"),
                    ),
                  );
                }),
              ),
            );
          }),

          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Expected Job Window",
            value: "$startTime  -  $endTime",
          ),
          SizedBox(
            height: 5.sp,
          ),

          /// This widget is used to show the Preferred visiting time
          Builder(builder: (context) {
            List<AvailableSlot>? availableSlots =
                job?.serviceRequest?.isEmpty ?? false
                    ? []
                    : job?.serviceRequest?.first.availableSlots;

            return Visibility(
              visible: (availableSlots ?? []).isNotEmpty,
              child: BuildDetailsCard(
                title: "Preferred visiting time",
                children: List.generate(availableSlots?.length ?? 0, (index) {
                  AvailableSlot? availableSlot = availableSlots?[index];

                  int? startTimeEpoch = availableSlot?.startTime;

                  int? endTimeEpoch = availableSlot?.endTime;

                  String? preferredStartTimeSlot = startTimeEpoch != null
                      ? DateFormat("d MMM yyyy,").add_jm().format(
                            DateTime.fromMillisecondsSinceEpoch(
                              startTimeEpoch,
                            ),
                          )
                      : "N/A";

                  String? preferredEndTimeSlot = endTimeEpoch != null
                      ? DateFormat("d MMM yyyy,").add_jm().format(
                            DateTime.fromMillisecondsSinceEpoch(
                              endTimeEpoch,
                            ),
                          )
                      : "N/A";

                  return Text(
                      "$preferredStartTimeSlot - $preferredEndTimeSlot");
                }),
              ),
            );
          }),

          SizedBox(
            height: 5.sp,
          ),

          BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
            builder: (context, state) {
              String actualStartTime = state.actualStartTime == null
                  ? "N/A"
                  : DateFormat("d MMM, yyyy").add_jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            state.actualStartTime!),
                      );

              String actualEndTime = state.actualEndTime == null
                  ? "N/A"
                  : DateFormat("d MMM, yyyy").add_jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            state.actualEndTime!),
                      );

              return BuildDetailsCard(
                title: "Actual Job Window",
                value: "$actualStartTime  -  $actualEndTime",
              );
            },
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Completion Remark",
            value: job?.completionRemark ?? "N/A",
          ),
          Builder(builder: (context) {
            String membersNames = job?.members
                    ?.map((e) => e['assignee']?['name'] ?? '')
                    .join(", ") ??
                "";

            return Visibility(
              visible: job?.members?.isNotEmpty ?? false,
              child: Column(
                children: [
                  SizedBox(
                    height: 5.sp,
                  ),
                  BuildDetailsCard(
                    title: "Team Members",
                    value: membersNames,
                  ),
                  SizedBox(
                    height: 5.sp,
                  ),
                ],
              ),
            );
          }),
          Visibility(
            visible: job?.runhours != null,
            child: Column(
              children: [
                SizedBox(
                  height: 5.sp,
                ),
                BuildDetailsCard(
                  title: "Runhours",
                  value: job?.runhours.toString() ?? "",
                ),
              ],
            ),
          ),
          Builder(builder: (context) {
            String value = getLocationPath([
              community,
              subCommunity,
              buildingName,
              spaces,
            ]);

            return Visibility(
                visible: value.isNotEmpty,
                child: Padding(
                  padding: EdgeInsets.only(top: 5.sp),
                  child: BuildDetailsCard(
                    title: "Location Path",
                    value: value,
                  ),
                ));
          }),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Job Location",
            value: job?.jobLocationName ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          Builder(builder: (context) {
            bool hasPermission = UserPermissionServices().checkingPermission(
              featureGroup: "assetManagement",
              feature: "dashboard",
              permission: "view",
            );
            return GestureDetector(
              onTap: () {
                if (!hasPermission) {
                  return;
                }

                var asset = job?.resource;

                // print(asset);

                if (asset != null) {
                  Navigator.of(context).pushNamed(
                    AssetDetailsScreen.id,
                    arguments: {
                      "name": asset.displayName,
                      "asset": {
                        "type": asset.type,
                        "data": {
                          "identifier": asset.identifier,
                          "domain": asset.domain,
                        }
                      },
                    },
                  );
                }
              },
              child: BuildDetailsCard(
                title: "Asset",
                value: job?.resource?.displayName ?? "N/A",
                showTrailing:
                    job?.resource?.displayName != null && hasPermission,
              ),
            );
          }),
          SizedBox(
            height: 5.sp,
          ),
          Builder(builder: (context) {
            List<ServiceRequest>? linkedServiceRequests =
                job?.serviceRequest ?? [];

            return Visibility(
              visible: linkedServiceRequests.isNotEmpty,
              child: Column(
                children: [
                  BuildDetailsCard(
                    title: "Linked Service Requests",
                    // value: job?.serviceRequests != null ? job!.id.toString() : "N/A",
                    children: List.generate(
                      linkedServiceRequests.length,
                      (index) {
                        ServiceRequest serviceRequest =
                            linkedServiceRequests[index];

                        // String

                        String? requestNumber = serviceRequest.requestNumber;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.sp),
                          child: Bounce(
                            duration: const Duration(milliseconds: 100),
                            onPressed: () {
                              bool hasPermission =
                                  UserPermissionServices().checkingPermission(
                                featureGroup: "serviceRequestManagement",
                                feature: "serviceRequests",
                                permission: "view",
                              );

                              if (hasPermission) {
                                Navigator.of(context).pushNamed(
                                  ServiceDetailsScreen.id,
                                  arguments: {
                                    "requestNumber": requestNumber,
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.sp, vertical: 5.sp),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                requestNumber ?? "N/A",
                                style: const TextStyle(
                                  color: kWhite,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5.sp,
                  ),
                ],
              ),
            );
          }),
          // BuildDetailsCard(
          //   title: "Timeline",
          //   showTrailing: true,
          //   value: job?.status == "CANCELLED"
          //       ? "Job is cancelled"
          //       : job?.id == null
          //           ? "Not assigned"
          //           : "Job is assigned",
          //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //     builder: (context) => JobTimeLineScreen(timeLines: timeLines),
          //   )),
          // ),
          // SizedBox(
          //   height: 5.sp,
          // ),
          BuildDetailsCard(
            title: "Priority",
            value: job?.priority ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Discipline",
            value: job?.discipline ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Type",
            value: job?.jobType ?? "N/A",
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Skills ",
            children: List.generate(job?.skillsRequired?.length ?? 0, (index) {
              Map<String, dynamic> map = job?.skillsRequired?[index];

              String title = map['skill']['name'] ?? "N/A";

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.sp),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        shortLetterConverter(title),
                      ),
                    ),
                    SizedBox(
                      width: 5.sp,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(
            height: 5.sp,
          ),
          BuildDetailsCard(
            title: "Tools ",
            children: List.generate(job?.toolsRequired?.length ?? 0, (index) {
              Map<String, dynamic> map = job?.toolsRequired?[index];

              String title = map['tool']?['name'] ?? "N/A";

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.sp),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        shortLetterConverter(title),
                      ),
                    ),
                    SizedBox(
                      width: 5.sp,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(
            height: 5.sp,
          ),
          buildSignatureWithName(
            signatureFilePath:
                "jobs/${userData.domain}/$jobId/hidden/signature",
            job: job,
          ),
          SizedBox(
            height: 5.sp,
          ),
        ],
      ),
    );
  }

  // ===============================================================================================================
  // Build Signature Widget

  Widget buildSignatureWithName({
    required String signatureFilePath,
    required FindJobWithId? job,
  }) {
    // return BuildDetailsCard(
    //   title: title,
    //   // value: "/",
    //   children: [
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        if (!state.isInternetAvailable) {
          int jobId = job?.id ?? 0;

          return ValueListenableBuilder(
            valueListenable: syncdbgetBox().listenable(),
            builder: (context, box, _) {
              SyncingLocalDb? syncingLocalDb = box.values.singleWhereOrNull(
                (element) =>
                    element.graphqlMethod == JobsSchemas.jobCompleteMutation &&
                    element.payload['data']['id'] == jobId,
              );

              var signatureData = syncingLocalDb?.payload['signatures'];

              Map<String, dynamic>? technicianData =
                  signatureData?['technician'];
              Map<String, dynamic>? clientData = signatureData?['client'];

              return buildSignatures(
                technicianData,
                job,
                null,
                clientData,
              );
            },
          );
        }

        return QueryWidget(
          options: GrapghQlClientServices().getQueryOptions(
            rereadPolicy: false,
            document: JobsSchemas.getAllFilesFromSamePath,
            variables: {
              "filePath": signatureFilePath,
              "traverseFiles": true,
              "showHiddenFolder": true,
            },
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (result.hasException) {
              return GraphqlServices().handlingGraphqlExceptions(
                result: result,
                context: context,
                refetch: refetch,
              );
            }

            List list = result.data?['getAllFilesFromSamePath']?['data'] ?? [];

            Map? technicianData = list.singleWhere(
              (element) =>
                  element['path'].toString().split('/').last == "technician",
              orElse: () => null,
            );

            Map? managerData = list.singleWhere(
              (element) =>
                  element['path'].toString().split('/').last == "manager",
              orElse: () => null,
            );

            Map? requesteeData = list.singleWhere(
              (element) =>
                  element['path'].toString().split('/').last == "requestee",
              orElse: () => null,
            );

            // return SizedBox();
            // hello();
            return buildSignatures(
                technicianData, job, managerData, requesteeData);
          },
        );
      },
    );

    //   ],
    // );
  }

  Column buildSignatures(
    Map<dynamic, dynamic>? technicianData,
    FindJobWithId? job,
    Map<dynamic, dynamic>? managerData,
    Map<dynamic, dynamic>? requesteeData,
  ) {
    return Column(
      children: [
        BuildDetailsCard(
          title: "Technician Signature",
          children: [
            displaySignature(
              technicianData?['data'],
              technicianData?['fileName'],
            ),
            Text(job?.signedTechnician ?? ""),
          ],
        ),
        SizedBox(
          height: 5.sp,
        ),
        BuildDetailsCard(
          title: "Manager Signature",
          children: [
            displaySignature(
              managerData?['data'],
              managerData?['fileName'],
            ),
            Text(job?.signedManager ?? ""),
          ],
        ),
        SizedBox(
          height: 5.sp,
        ),
        BuildDetailsCard(
          title: "Requestee Signature",
          children: [
            displaySignature(
              requesteeData?['data'],
              requesteeData?['fileName'],
            ),
            Text(job?.signedClient ?? ""),
          ],
        )
      ],
    );
  }

  // =================================================

  Widget displaySignature(String? data, String? fileName) {
    if (data == null) {
      return const Text(
        "Signature Not Available",
      );
    }

    Uint8List decodedbytes = base64Decode(data);

    return SizedBox(
      height: 40.sp,
      child: Image.memory(
        decodedbytes,
      ),
    );
  }

  void buildCancellationModalSheet(
      BuildContext context,
      String? selectedReasonIdentifier,
      TextEditingController remarksController) {
    int statusTime = DateTime.now().millisecondsSinceEpoch;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabelWidget(title: "Reason"),
              SizedBox(
                height: 3.sp,
              ),
              StatefulBuilder(builder: (context, setState) {
                return buildCancellationDropdown(
                  context,
                  selectedReasonIdentifier,
                  onChanged: (value) {
                    setState(
                      () {
                        selectedReasonIdentifier = value;
                      },
                    );
                  },
                );
              }),
              SizedBox(
                height: 10.sp,
              ),
              buildLabelWithTextfieldWidget(
                title: "Remarks",
                textEditingController: remarksController,
                hintText: "Enter Remarks",
                enabelRequiredText: false,
                maxLines: 5,
                enableValidator: false,
              ),
              const Spacer(),
              MutationWidget(
                options: GrapghQlClientServices().getMutateOptions(
                  context: context,
                  document: JobsSchemas.jobStatusUpdateMutation,
                  onCompleted: (data) {
                    if (data == null) {
                      return;
                    }

                    // if (result.hasException) {
                    //   // ignore: use_build_context_synchronously
                    //   Navigator.of(context).pop();
                    //   // ignore: use_build_context_synchronously
                    //   buildSnackBar(
                    //     context: context,
                    //     value: "Something went wrong.",
                    //   );

                    //   return;
                    // }

                    // print('Cancel result ${result.data}');

                    // setState(() {
                    //   // status = "CANCELLED";
                    // });

                    jobControllerBloc
                        .add(ChangeJobStatusEvent(status: "CANCELLED"));

                    JobsActionService.callTravelTimeSheetApi(
                        travelTimeBloc: travelTimeBloc, jobId: jobId);

                    jobControllerBloc
                        .add(ChangeJobTimeEvent(actualEndTime: statusTime));

                    timelineUpdateBloc.add(TimeLineChangeEvent(timeline: {
                      "time": statusTime,
                      "status": "CANCELLED",
                      "comment": remarksController.text.trim(),
                    }));

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    buildSnackBar(
                      context: context,
                      value: "Job cancelled successfully",
                    );
                  },
                ),
                builder: (runMutation, result) {
                  bool isLoading = result?.isLoading ?? false;

                  return BuildElevatedButton(
                    isLoading: isLoading,
                    title: "Save",
                    onPressed: () async {
                      if (selectedReasonIdentifier == null) {
                        Navigator.of(context).pop();
                        buildSnackBar(
                          context: context,
                          value: "Reason not selected",
                        );
                        return;
                      }

                      var locationMap = await trackLocation
                          .getCurrentLocationAndLocationName(context);

                      Map<String, dynamic> variables = {
                        "id": jobId,
                        "statusData": {
                          "statusTime": statusTime,
                          "status": "CANCELLED",
                          "cancellationReason": selectedReasonIdentifier,
                          "statusLocation": locationMap['location'],
                          "statusLocationName": locationMap['locationName'],
                        }
                      };

                      if (remarksController.text.trim().isNotEmpty) {
                        variables['statusData']['remark'] =
                            remarksController.text.trim();
                      }

                      ConnectivityResult connectivityResult =
                          await Connectivity().checkConnectivity();

                      bool noInternet =
                          connectivityResult == ConnectivityResult.none;

                      if (noInternet) {
                        syncingBox.add(
                          SyncingLocalDb(
                            payload: variables,
                            graphqlMethod: JobsSchemas.jobStatusUpdateMutation,
                            generatedTime:
                                DateTime.now().millisecondsSinceEpoch,
                          ),
                        );

                        // setState(() {
                        //   // status = "CANCELLED";
                        // });
                        // ignore: use_build_context_synchronously
                        buildSnackBar(
                          context: context,
                          value: "Job cancelled successfully",
                        );

                        JobDetailsDb? jobDetailsDb = jobBox.values
                            .singleWhereOrNull(
                                (element) => element.id == jobId);

                        if (jobDetailsDb != null) {
                          jobDetailsDb.status = "CANCELLED";

                          int index = jobBox.values
                              .toList()
                              .indexWhere((element) => element.id == jobId);

                          jobBox.putAt(index, jobDetailsDb);
                          jobControllerBloc
                              .add(ChangeJobStatusEvent(status: "CANCELLED"));
                          jobControllerBloc.add(
                            ChangeJobTimeEvent(actualEndTime: statusTime),
                          );

                          jobDetailsDb.transitions?.add({
                            "time": statusTime,
                            "status": "CANCELLED",
                            "comment": remarksController.text.trim(),
                          });

                          timelineUpdateBloc.add(TimeLineChangeEvent(timeline: {
                            "time": statusTime,
                            "status": "CANCELLED",
                            "comment": remarksController.text.trim(),
                          }));
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();

                        return;
                      }

                      runMutation(variables);
                    },
                  );
                },
              ),
              SizedBox(
                height: 10.sp,
              ),
            ],
          ),
        );
      },
    );
  }

  void buildHoldWidget(BuildContext context) {
    TextEditingController remarksController = TextEditingController();

    String? selectedReasonIdentifier;

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      // isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.sp),
            // padding:
            //     EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabelWidget(title: "Reason"),
                SizedBox(
                  height: 3.sp,
                ),
                StatefulBuilder(builder: (context, setState) {
                  return buildDropdownbutton(
                    selectedReasonIdentifier,
                    holdReasonItems,
                    onChanged: (String? value) {
                      setState(
                        () {
                          selectedReasonIdentifier = value;
                        },
                      );
                    },
                  );
                }),
                SizedBox(
                  height: 10.sp,
                ),
                buildLabelWithTextfieldWidget(
                  title: "Remarks",
                  textEditingController: remarksController,
                  hintText: "Enter Remarks",
                  enabelRequiredText: false,
                  maxLines: 3,
                ),
                // const Spacer(),
                SizedBox(
                  height: 20.sp,
                ),
                Builder(builder: (context) {
                  int statusTime = DateTime.now().millisecondsSinceEpoch;

                  return MutationWidget(
                    options: GrapghQlClientServices().getMutateOptions(
                      context: context,
                      document: JobsSchemas.jobStatusUpdateMutation,
                      onCompleted: (data) {
                        print("data>>>>>>: $data");
                        if (data == null) {
                          return;
                        }

                        print(
                            "selectedReasonIdentifier: $selectedReasonIdentifier");

                        jobControllerBloc.add(ChangeJobStatusEvent(
                            status: selectedReasonIdentifier!));

                        JobsActionService.callTravelTimeSheetApi(
                            travelTimeBloc: travelTimeBloc, jobId: jobId);

                        buildSnackBar(
                          context: context,
                          value: "Job held successfully",
                        );

                        timelineUpdateBloc.add(TimeLineChangeEvent(timeline: {
                          "time": statusTime,
                          "status": selectedReasonIdentifier,
                          "comment": remarksController.text.trim(),
                        }));

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                    ),
                    builder: (runMutation, result) {
                      bool isLoading = result?.isLoading ?? false;

                      return BuildElevatedButton(
                        isLoading: isLoading,
                        title: "Save",
                        onPressed: () async {
                          if (selectedReasonIdentifier == null) {
                            Navigator.of(context).pop();
                            buildSnackBar(
                                context: context, value: "Reason not selected");
                            return;
                          }

                          var locationMap = await trackLocation
                              .getCurrentLocationAndLocationName(context);

                          Map<String, dynamic> variables = {
                            "id": jobId,
                            "statusData": {
                              "statusTime": statusTime,
                              "status": selectedReasonIdentifier,
                              "statusLocation": locationMap['location'],
                              "statusLocationName": locationMap['locationName'],
                            }
                          };

                          if (remarksController.text.trim().isNotEmpty) {
                            variables['statusData']['remark'] =
                                remarksController.text.trim();
                          }

                          var connectivityResult =
                              await Connectivity().checkConnectivity();

                          bool noInternet =
                              connectivityResult == ConnectivityResult.none;

                          if (noInternet) {
                            syncingBox.add(
                              SyncingLocalDb(
                                payload: variables,
                                graphqlMethod:
                                    JobsSchemas.jobStatusUpdateMutation,
                                generatedTime:
                                    DateTime.now().millisecondsSinceEpoch,
                              ),
                            );

                            // setState(() {
                            //   // status = selectedReasonIdentifier!;
                            // });

                            // ignore: use_build_context_synchronously
                            buildSnackBar(
                              context: context,
                              value: "Job held successfully",
                            );

                            JobDetailsDb? jobDetailsDb = jobBox.values
                                .singleWhereOrNull(
                                    (element) => element.id == jobId);

                            if (jobDetailsDb != null) {
                              jobDetailsDb.status = selectedReasonIdentifier;

                              jobControllerBloc.add(ChangeJobStatusEvent(
                                  status: selectedReasonIdentifier!));

                              timelineUpdateBloc
                                  .add(TimeLineChangeEvent(timeline: {
                                "time": statusTime,
                                "status": selectedReasonIdentifier,
                                "comment": remarksController.text.trim(),
                              }));

                              jobDetailsDb.transitions?.add({
                                "time": statusTime,
                                "status": selectedReasonIdentifier,
                                "comment": remarksController.text.trim(),
                              });

                              int index = jobBox.values
                                  .toList()
                                  .indexWhere((element) => element.id == jobId);

                              jobBox.putAt(index, jobDetailsDb);
                            }

                            Navigator.of(context).pop();

                            return;
                          }

                          runMutation(variables);
                        },
                      );
                    },
                  );
                }),
                SizedBox(
                  height: 10.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void syncingdbHandling(
    String key,
    Box<SyncingLocalDb> box, {
    required String status,
    required String jobName,
  }) async {
    switch (key) {
      case "start":
      case "resume":
        if (key == "start") {
          // NotificationService().cancelScheduledNotfication(jobId);
        }

        int statusTime = DateTime.now().millisecondsSinceEpoch;

        var locationMap =
            await trackLocation.getCurrentLocationAndLocationName(context);

        box.add(
          SyncingLocalDb(
            payload: {
              "id": jobId,
              "statusData": {
                "statusTime": statusTime,
                "status": "INPROGRESS",
                "statusLocation": locationMap['location'],
                "statusLocationName": locationMap['locationName'],
              }
            },
            graphqlMethod: JobsSchemas.jobStatusUpdateMutation,
            generatedTime: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        jobControllerBloc.add(ChangeJobStatusEvent(status: "INPROGRESS"));

        if (key == "start") {
          jobControllerBloc.add(ChangeJobTimeEvent(
            actualStartTime: statusTime,
          ));
          buildSnackBar(
            context: context,
            value: "Job started successfully",
          );
        } else {
          buildSnackBar(
            context: context,
            value: "Job resumed successfully",
          );
        }

        JobDetailsDb? jobDetailsDb =
            jobBox.values.singleWhereOrNull((element) => element.id == jobId);

        if (jobDetailsDb != null) {
          jobDetailsDb.status = "INPROGRESS";

          jobDetailsDb.transitions?.add({
            "time": statusTime,
            "status": "INPROGRESS",
          });

          timelineUpdateBloc.add(TimeLineChangeEvent(timeline: {
            "time": statusTime,
            "status": "INPROGRESS",
          }));

          int index = jobBox.values
              .toList()
              .indexWhere((element) => element.id == jobId);

          jobBox.putAt(index, jobDetailsDb);
        }

        break;

      case "hold":
        buildHoldWidget(context);
        break;

      case "cancel":
        String? selectedReasonIdentifier;
        TextEditingController remarksController = TextEditingController();

        buildCancellationModalSheet(
          context,
          selectedReasonIdentifier,
          remarksController,
        );

        break;

      case "complete":
        int totalLength = checkLists.length;
        int userChecklistCompleted = jobManagementBloc.state.completed;

        int assetChecklistCompleted =
            jobManagementBloc.state.assetChecklistCompleted;

        int completed = userChecklistCompleted + assetChecklistCompleted;
        if (totalLength != completed) {
          // ignore: use_build_context_synchronously
          PlatformServices().showPlatformAlertDialog(
            context,
            title: "Alert",
            message: "Please update all checklists!",
          );
          return;
        }

        JobDetailsDb? jobDetailsModel = jobBox.values
            .toList()
            .singleWhereOrNull((element) => element.id == jobId);

        if (jobDetailsModel == null) {
          buildSnackBar(
            context: context,
            value: "Something went wrong!",
          );

          return;
        }

        // int? assigneeId = jobDetailsModel.assignee?.id;

        // bool isNotAssignee = userData.userId != assigneeId;

        bool? complete = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JobCompleteScreen(
              travelTimeBloc: travelTimeBloc,
              jobControllerBloc: jobControllerBloc,
              jobDetailsBloc: jobDetailsBloc,
              duration: jobDetailsModel.expectedDuration ?? 0,
              assetAttached: jobDetailsModel.resource?.displayName != null,
              jobName: jobName,
              jobStartTime: jobDetailsModel.actualStartTime ??
                  jobDetailsModel.jobStartTime ??
                  0,
              jobId: jobId,
              assetName: jobDetailsModel.resource?.displayName ?? "",
              jobDomain: jobDetailsModel.domain ?? "",
              assigneeId: jobDetailsModel.assignee?.id,
              teamMembers: [],
              assetEntity: jobDetailsModel.resource?.toJson(),
            ),
          ),
        );

        if (complete ?? false) {
          // setState(() {
          //   status = "COMPLETED";
          // });
          // ignore: use_build_context_synchronously
          jobControllerBloc.add(ChangeJobStatusEvent(status: "COMPLETED"));

          setState(() {
            buildSnackBar(
              context: context,
              value: "Job completed successfully",
            );
          });
        }

        break;

      default:
    }
  }

//=======================================================================================================
// Build cancellation dropdown button.

  Widget buildCancellationDropdown(
    BuildContext context,
    String? selectedReasonIdentifier, {
    required void Function(String?)? onChanged,
  }) {
    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        bool noInternet = snapshot.data == ConnectivityResult.none;

        if (noInternet) {
          List items = reasonsBox.values
              .map((e) => {"name": e.name, "identifier": e.identifier})
              .toList();

          return buildDropdownbutton(
            selectedReasonIdentifier,
            items,
            onChanged: onChanged,
          );
        }

        return QueryWidget(
          options: GraphqlServices().getQueryOptions(
            query: JobsSchemas.canecellationQuery,
            variables: {
              "domain": userData.domain,
            },
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return ShimmerLoadingContainerWidget(
                height: 40.sp,
              );
            }

            if (result.hasException) {
              return GraphqlServices().handlingGraphqlExceptions(
                result: result,
                context: context,
                refetch: refetch,
              );
            }

            List items = result.data!["listServiceCancelationReason"]['items'];

            return buildDropdownbutton(
              selectedReasonIdentifier,
              items,
              onChanged: onChanged,
            );
          },
        );
      },
    );
  }

  Container buildDropdownbutton(
    String? selectedReasonIdentifier,
    List<dynamic> items, {
    required void Function(String?)? onChanged,
  }) {
    return Container(
      height: 40.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: fwhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StatefulBuilder(builder: (context, setState) {
          return DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.expand_more,
              color: Theme.of(context).colorScheme.secondary,
            ),
            value: selectedReasonIdentifier,
            hint: const Text(
              "Select Reason",
              style: TextStyle(
                color: Colors.black26,
              ),
            ),
            items: List.generate(items.length, (index) {
              Map<String, dynamic> map = items[index];

              return DropdownMenuItem(
                value: map['identifier'],
                child: Text(map['name']),
              );
            }),
            onChanged: onChanged,
            // (value) {
            //   setState(() {
            //     selectedReasonIdentifier = value!;
            //   });
            // },
          );
        }),
      ),
    );
  }

  // ============================================================================
  Widget buildTasksWidget({
    required String? serviceRequestNumber,
    required String jobDomain,
    bool hasInternet = true,
  }) =>
      Container(
        color: kWhite,
        // height: 50.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.sp),
          child: JobTasksWidget(
            jobId: jobId,
            jobDomain: jobDomain,
            serviceRequestNumber: serviceRequestNumber,
            attachmentsControllerBloc: attachmentsControllerBloc,
            checkLists: checkLists,
            assetCheckLists: assetCheckLists,
            userCheckLists: userCheckLists,
            hasInternet: hasInternet,
            jobManagementBloc: jobManagementBloc,
            jobControllerBloc: jobControllerBloc,
            travelTimeBloc: travelTimeBloc,
            jobDetailsBloc: jobDetailsBloc,
          ),
        ),
      );

  // ===========================================================================
  // Build Header Container.
//  ===========================================================================

  Widget buildHeaderContainer({
    required String jobName,
    required FindJobWithId? job,
  }) {
    bool permission = UserPermissionServices().checkingPermission(
      featureGroup: "jobManagement",
      feature: "job",
      permission: "view",
    );

    if (!permission) {
      return Container(
        decoration: BoxDecoration(
          gradient: getGradientColors(context),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.sp),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "No Access",
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: getGradientColors(context),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30.sp),
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Tooltip(
              message: jobName,
              triggerMode: TooltipTriggerMode.tap,
              child: Text(
                jobName,
                maxLines: 1,
              ),
            ),
            actions: job == null
                ? []
                : [
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: 80.h,
                              child: buildDetailsWidget(
                                jobDetailsModel: jobDetailsModel,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.info_outline,
                      ),
                    ),
                    JobCardPopmenuButton(
                      jobId: jobId,
                      filePath: "jobs/${job.domain}/$jobId",
                    ),
                  ],
          ),
          Visibility(
            visible: job != null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.sp,
                vertical: 8.sp,
              ),
              child: BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
                builder: (context, state) {
                  String status = state.jobStatus;

                  int? startTime = state.actualStartTime ?? job?.jobStartTime;
                  int? endTime = state.actualEndTime ?? job?.expectedEndTime;

                  DateTime? jobStartTime = startTime == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(startTime);
                  DateTime? jobEndTime = endTime == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(endTime);

                  Duration? duration =
                      jobStartTime == null && jobEndTime == null
                          ? null
                          : jobEndTime?.difference(jobStartTime!);

                  String formatedStartTime = jobStartTime == null
                      ? ""
                      : DateFormat("MMM d, yyyy").add_jm().format(jobStartTime);

                  String tileTime = status == "COMPLETED" || status == "CLOSED"
                      ? jobEndTime == null
                          ? ""
                          : DateFormat("MMM d, yyyy")
                              .add_jm()
                              .format(jobEndTime)
                      : status == "INPROGRESS"
                          ? ""
                          : duration == null
                              ? ""
                              : "Total ${formatDuration(duration)}";

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatedStartTime,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: ThemeServices().getPrimaryFgColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Builder(builder: (context) {
                        if (status == "INPROGRESS") {
                          DateTime? actualEndTime = jobStartTime?.add(
                              Duration(minutes: job?.expectedDuration ?? 0));

                          Duration? remainingDuration =
                              actualEndTime?.difference(DateTime.now());

                          return Countdown(
                            seconds: remainingDuration?.inSeconds ?? 0,
                            build: (BuildContext context, double time) {
                              return Text(
                                formatDuration(
                                  Duration(
                                    seconds: time.toInt(),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: kWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                            interval: const Duration(seconds: 1),
                            onFinished: () {},
                          );
                        }

                        return Text(
                          tileTime,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: ThemeServices().getPrimaryFgColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                      SizedBox(
                        width: 10.sp,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
