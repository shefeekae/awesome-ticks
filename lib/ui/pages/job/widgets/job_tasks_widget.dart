import 'dart:io';

import 'package:awesometicks/core/blocs/attachments/attachments_controller_bloc.dart';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/job/job_management_bloc.dart';
import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_event.dart';
import 'package:awesometicks/core/models/checklist_comments_model.dart';
import 'package:awesometicks/core/models/checklist_model.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/models/job_comments_model.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/ui/pages/job/job_checklist_comments.dart';
import 'package:awesometicks/ui/pages/job/widgets/asset_checklist_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/attachment_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/checklist_progressbar_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/checklist_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_widget.dart';
import 'package:awesometicks/ui/shared/widgets/build_bottomsheet.dart';
import 'package:awesometicks/ui/shared/widgets/build_custom_textfield.dart';
import 'package:awesometicks/ui/shared/widgets/build_elvetad_button.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import '../../../../core/services/internet_services.dart';
import '../../../../core/services/jobs/jobs_services.dart';
import 'before_and_after_attachments.dart';

class JobTasksWidget extends StatefulWidget {
  const JobTasksWidget({
    super.key,
    required this.jobId,
    required this.jobDomain,
    required this.serviceRequestNumber,
    required this.attachmentsControllerBloc,
    required this.checkLists,
    required this.hasInternet,
    required this.jobManagementBloc,
    required this.jobControllerBloc,
    required this.travelTimeBloc,
    required this.jobDetailsBloc,
    required this.userCheckLists,
    required this.assetCheckLists,
  });

  final int jobId;
  final String jobDomain;
  final String? serviceRequestNumber;
  final AttachmentsControllerBloc attachmentsControllerBloc;
  final List<Checklist> checkLists;
  final List<Checklist> userCheckLists;

  final List<Checklist> assetCheckLists;
  final bool hasInternet;
  final JobManagementBloc jobManagementBloc;
  final JobControllerBlocBloc jobControllerBloc;
  final TravelTimeBloc travelTimeBloc;
  final JobDetailsBloc jobDetailsBloc;

  @override
  State<JobTasksWidget> createState() => _JobTasksWidgetState();
}

class _JobTasksWidgetState extends State<JobTasksWidget> {
  final UserDataSingleton userData = UserDataSingleton();

  final ValueNotifier<int> checklistExpansionNotifier = ValueNotifier<int>(-1);

  final Box<SyncingLocalDb> syncingBox = syncdbgetBox();

  final JobsServices jobsServices = JobsServices();

  @override
  void initState() {
    widget.checkLists.sort(
      (a, b) => a.executionIndex ?? 0.compareTo(b.executionIndex ?? 0),
    );

    widget.jobManagementBloc.state.completed = 0;

    widget.jobManagementBloc.state.assetChecklistCompleted = 0;

    for (var element in widget.checkLists) {
      bool checked = element.checked ?? false;

      bool isAssetChecklist = element.type == "ASSET";

      bool checkable = element.checkable ?? false;

      bool choiceType = element.choiceType ?? false;

      bool radiobuttonEnabled = element.selectedChoice != null;

      int userChecklistCount = widget.jobManagementBloc.state.completed;

      int assetChecklistCount =
          widget.jobManagementBloc.state.assetChecklistCompleted;
      if (isAssetChecklist) {
        if (checked) {
          widget.jobManagementBloc.state.assetChecklistCompleted =
              assetChecklistCount + 1;
        } else if (radiobuttonEnabled) {
          widget.jobManagementBloc.state.assetChecklistCompleted =
              assetChecklistCount + 1;
        } else if (!checkable && !choiceType) {
          widget.jobManagementBloc.state.assetChecklistCompleted =
              assetChecklistCount + 1;
        }
      } else {
        if (checked) {
          widget.jobManagementBloc.state.completed = userChecklistCount + 1;
        } else if (radiobuttonEnabled) {
          widget.jobManagementBloc.state.completed = userChecklistCount + 1;
        } else if (!checkable && !choiceType) {
          widget.jobManagementBloc.state.completed = userChecklistCount + 1;
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        if (widget.hasInternet) {
          widget.travelTimeBloc.add(
            TravelTimeInitialEvent(
              /// assigneeIds refers to the id of current user logged in
              payload: {
                "domains": [userData.domain],
                "assignees": [],
                "assigneeIds": [userData.userId],
                "jobIds": [widget.jobId],

                /// if date range not given complete job list will be returned
                // "dateRange": {
                //   "startDate": 1723454585000,
                //   "endDate": 1721308200000,
                // }
              },
            ),
          );

          widget.jobDetailsBloc
              .add(FetchJobDetailDataEvent(jobId: widget.jobId));

          jobsServices.addJobAttachmentsToBlocState(
            jobAttachmentFilePath: "jobs/${widget.jobDomain}/${widget.jobId}",
            attachmentCategoryKey: "",
            serviceRequestAttachmentFilePath: widget.serviceRequestNumber ==
                    null
                ? null
                : "serviceRequests/${widget.jobDomain}/${widget.serviceRequestNumber}",
          );
        }
      },
      child: ListView(
        shrinkWrap: true,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BeforeAfterAttachmentsWidget(
            attachmentsControllerBloc: widget.attachmentsControllerBloc,
            title: "Before Attachments",
            attachmentCategoryKey: "__before",
            attachingFilePath:
                "jobs/${widget.jobDomain}/${widget.jobId}/__before",
            serviceRequestNumber: widget.serviceRequestNumber,
          ),
          BeforeAfterAttachmentsWidget(
            attachmentsControllerBloc: widget.attachmentsControllerBloc,
            title: "After Attachments",
            attachmentCategoryKey: "__after",
            attachingFilePath:
                "jobs/${widget.jobDomain}/${widget.jobId}/__after",
            serviceRequestNumber: widget.serviceRequestNumber,
          ),
          SizedBox(
            height: 10.sp,
          ),
          BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
            builder: (context, state) {
              String status = state.jobStatus;

              bool visible = status != "COMPLETED" &&
                  status != "CLOSED" &&
                  status != "CANCELLED";

              if (widget.checkLists.isEmpty && !visible) {
                return const SizedBox();
              }

              return Row(
                children: [
                  Expanded(
                    child: BlocBuilder<JobManagementBloc, JobManagementState>(
                      builder: (context, state) {
                        int userChecklistCount = state.completed;

                        return Padding(
                          padding: EdgeInsets.only(left: 7.sp),
                          child: Text(
                            "Completed $userChecklistCount/${widget.userCheckLists.length}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              // color: kBlack.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
                      builder: (context, state) {
                    String status = state.jobStatus;

                    bool visible = status != "COMPLETED" &&
                        status != "CLOSED" &&
                        status != "CANCELLED";

                    return Visibility(
                      visible: visible,
                      child: GestureDetector(
                        onTap: () {
                          buildChecklistBottomSheet();
                        },
                        child: Icon(
                          Icons.add,
                          size: 20.sp,
                        ),
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
          SizedBox(
            height: 3.sp,
          ),
          BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
            builder: (context, state) {
              String status = state.jobStatus;

              bool visible = status != "COMPLETED" &&
                  status != "CLOSED" &&
                  status != "CANCELLED";

              if (widget.userCheckLists.isEmpty && !visible) {
                return const SizedBox();
              }

              return ChecklistProgressBar(
                  checklistLength: widget.userCheckLists.length,
                  isAssetChecklist: false);
            },
          ),
          ChecklistWidget(
              jobManagementBloc: widget.jobManagementBloc,
              checkLists: widget.userCheckLists,
              jobControllerBloc: widget.jobControllerBloc,
              jobId: widget.jobId,
              domain: widget.jobDomain,
              hasInternet: widget.hasInternet),

          /// Asset Checklists =============================================
          AssetChecklistWidget(
              assetCheckLists: widget.assetCheckLists,
              hasInternet: widget.hasInternet,
              domain: widget.jobDomain,
              jobId: widget.jobId,
              jobManagementBloc: widget.jobManagementBloc,
              jobControllerBloc: widget.jobControllerBloc),
        ],
      ),
    );
  }

  /// Displaying the checklist comments

  Widget buildChecklistCommentsWidget(
    Checklist checklist,
  ) {
    return StatefulBuilder(builder: (context, setState) {
      return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
        builder: (context, state) {
          bool hasInternet = state.isInternetAvailable;

          if (!hasInternet) {
            return ValueListenableBuilder(
                valueListenable: jobDetailsDbgetBox().listenable(),
                builder: (context, box, _) {
                  JobDetailsDb? jobDetailsDb = box.values
                      .singleWhere((element) => element.id == widget.jobId);

                  ChecklistDb? checklistDb =
                      jobDetailsDb.checklistDb?.singleWhereOrNull(
                    (element) => element.id == checklist.id,
                  );

                  var checklistComments = checklistDb?.comments ?? [];

                  checklistComments.sort(
                    (a, b) => b.commentTime!.compareTo(a.commentTime!),
                  );

                  return Column(children: [
                    SizedBox(
                      height: 10.sp,
                    ),
                    buildChecklistCommentAttachmentAndTextfield(
                      context,
                      jobId: widget.jobId,
                      jobDomain: widget.jobDomain,
                      checklistId: checklist.id!,
                      setState: setState,
                    ),
                    const Divider(
                      // color: kWhite,
                      thickness: 1,
                    ),
                    ...List.generate(
                      checklistComments.length >= 2
                          ? 2
                          : checklistComments.length,
                      (index) {
                        var comment = checklistComments[index];

                        return Padding(
                          padding: EdgeInsets.only(top: 5.sp),
                          child: CommentWidget(
                            checklistId: checklist.id,
                            isChecklistComment: true,
                            comment: GetAllComments(
                              id: comment.id,
                              comment: comment.comment,
                              commentBy: comment.commentBy,
                              commentTime: comment.commentTime,
                            ),
                            jobId: widget.jobId,
                            jobDomain: widget.jobDomain,
                          ),
                        );
                      },
                    ),
                    Visibility(
                      visible: checklistComments.length > 2,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => JobChecklistCommentsScreen(
                              checklistId: checklist.id!,
                              jobDomain: widget.jobDomain,
                              jobId: widget.jobId,
                            ),
                          ));
                        },
                        child: const Text(
                          "View all comments",
                        ),
                      ),
                    ),
                  ]);
                });
          }

          return QueryWidget(
              options: GraphqlServices().getQueryOptions(
                query: JobsSchemas.checklistCommentsQuery,
                variables: {
                  "checklistId": checklist.id,
                },
              ),
              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (result.hasException) {
                  return GraphqlServices().handlingGraphqlExceptions(
                    result: result,
                    context: context,
                    refetch: refetch,
                  );
                }

                var data = CheckListComments.fromJson(result.data ?? {});

                var comments = data.listCheckListComments ?? [];

                if (comments.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 10.sp,
                      ),
                      buildChecklistCommentAttachmentAndTextfield(
                        context,
                        jobId: widget.jobId,
                        jobDomain: widget.jobDomain,
                        checklistId: checklist.id!,
                        setState: setState,
                      ),
                      const Divider(
                        // color: kWhite,
                        thickness: 1,
                      ),
                      const Center(
                        child: Text(
                          "No comments",
                        ),
                      ),
                    ],
                  );
                }

                comments.sort(
                  (a, b) => b.commentTime!.compareTo(a.commentTime!),
                );

                return Column(children: [
                  SizedBox(
                    height: 10.sp,
                  ),
                  buildChecklistCommentAttachmentAndTextfield(
                    context,
                    jobId: widget.jobId,
                    jobDomain: widget.jobDomain,
                    checklistId: checklist.id!,
                    setState: (_) {
                      refetch?.call();
                    },
                  ),
                  const Divider(
                    // color: kWhite,
                    thickness: 1,
                  ),
                  ...List.generate(
                    comments.length >= 2 ? 2 : comments.length,
                    (index) {
                      var comment = comments[index];

                      return Padding(
                        padding: EdgeInsets.only(top: 5.sp),
                        child: CommentWidget(
                          checklistId: checklist.id,
                          isChecklistComment: true,
                          comment: GetAllComments(
                            id: comment.id,
                            comment: comment.comment,
                            commentBy: comment.commentBy,
                            commentTime: comment.commentTime,
                          ),
                          jobId: widget.jobId,
                          jobDomain: widget.jobDomain,
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: comments.length > 2,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => JobChecklistCommentsScreen(
                            checklistId: checklist.id!,
                            jobDomain: widget.jobDomain,
                            jobId: widget.jobId,
                          ),
                        ));
                      },
                      child: const Text(
                        "View all comments",
                      ),
                    ),
                  ),
                ]);
              });
        },
      );
    });
  }

  /// Checklist Choice type widget

  Visibility buildChecklistChoiceTypeWidget(Checklist checklist, int index) {
    return Visibility(
      visible: checklist.choiceType ?? false,
      child: StatefulBuilder(builder: (context, setState) {
        bool checked = checklist.checked ?? true;

        return BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
            builder: (context, state) {
          String status = state.jobStatus;

          bool dropdownEnable = status == "INPROGRESS" && checked;

          List choices = checklist.choices;

          return StatefulBuilder(builder: (context, setState) {
            dynamic selectedChoice = checklist.selectedChoice;

            return GestureDetector(
              onTap: () {
                if (!dropdownEnable) {
                  if (!checked) {
                    buildSnackBar(
                      context: context,
                      value:
                          "Unable to select checklist choice: Checklist not checked.",
                    );
                    return;
                  }

                  buildSnackBar(
                    context: context,
                    value:
                        "Can't select checklist choice: The job status is $status.",
                  );
                }
              },
              child: AbsorbPointer(
                absorbing: !dropdownEnable,
                child: DropdownButton(
                  value: selectedChoice,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    "Select choice",
                  ),
                  items: choices
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.toString(),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    // print(value);

                    if (!widget.hasInternet) {
                      bool radioEnabled =
                          widget.checkLists[index].selectedChoice != null;

                      bool checked = widget.checkLists[index].checked ?? false;

                      if (!checked && !radioEnabled) {
                        int count = widget.jobManagementBloc.state.completed;
                        widget.jobManagementBloc.add(
                          ChangeCompletedCountEvent(
                            completed: count + 1,
                          ),
                        );
                      }

                      setState(
                        () {
                          widget.checkLists[index].selectedChoice = value;
                          selectedChoice = value;
                        },
                      );

                      JobsServices().updateChecklistToLocalDb(
                          checkLists: widget.checkLists, jobId: widget.jobId);
                      return;
                    }

                    List<Checklist> payloadChecklists = List<Checklist>.from(
                        widget.checkLists.map((model) => Checklist(
                              item: model.item,
                              attachments: model.attachments,
                              checkable: model.checkable,
                              checked: model.checked,
                              choiceType: model.choiceType,
                              choices: model.choices,
                              commentCount: model.commentCount,
                              description: model.description,
                              executionIndex: model.executionIndex,
                              id: model.id,
                              selectedChoice: model.selectedChoice,
                            )));

                    payloadChecklists[index].selectedChoice = value;

                    bool isUpdated = await JobsServices().updateChecklist(
                      context: context,
                      jobId: widget.jobId,
                      list: payloadChecklists,
                    );

                    if (!isUpdated) {
                      // ignore: use_build_context_synchronously
                      buildSnackBar(
                        context: context,
                        value: "Checklist updation failed",
                      );
                      return;
                    }

                    bool radioDisabled =
                        widget.checkLists[index].selectedChoice == null;

                    bool checked = widget.checkLists[index].checked ?? false;

                    if (!checked && radioDisabled) {
                      int count = widget.jobManagementBloc.state.completed;

                      widget.jobManagementBloc.add(
                        ChangeCompletedCountEvent(
                          completed: count + 1,
                        ),
                      );
                    }

                    setState(
                      () {
                        widget.checkLists[index].selectedChoice = value;
                        checklist.selectedChoice = value;
                      },
                    );
                  },
                ),
              ),
            );
          });
        });
      }),
    );
  }

  /// Checklist Comments count text

  Text buildChecklistCommentCountWidget(
      Checklist checklist, BuildContext context) {
    return Text(
      "${checklist.commentCount} comments",
      style: TextStyle(
        fontSize: 8.sp,
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// If the comment is added while offline, the comment count will not update and showing the offline text.

  Row buildWithoutInternetCommentCount() {
    Color color = Colors.red.shade500;

    return Row(
      children: [
        Icon(
          Icons.signal_wifi_off,
          size: 12.sp,
          color: color,
        ),
        SizedBox(
          width: 1.sp,
        ),
        Text(
          "Offline",
          style: TextStyle(
            fontSize: 8.sp,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Displaying the checklist Name

  Text buildChecklistName(Checklist checklist) {
    return Text(
      checklist.item ?? "",
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// if the checklist checkable option this widget
  /// * User can click the widget to updat

  Visibility buildCheckableWidget(
      bool checkable, int index, StateSetter setState) {
    bool checked = widget.checkLists[index].checked ?? false;

    return Visibility(
      visible: checkable,
      child: Padding(
        padding: EdgeInsets.only(right: 5.sp),
        child: MutationWidget(
          options: GrapghQlClientServices().getMutateOptions(
            context: context,
            document: JobsSchemas.updateCheckListMutation,
            onCompleted: (data) {
              if (data == null) {
                return;
              }

              setState(
                () {
                  int count = widget.jobManagementBloc.state.completed;
                  widget.checkLists[index].checked = !checked;

                  bool radioButtonSelected =
                      widget.checkLists[index].selectedChoice == null;

                  if (radioButtonSelected) {
                    if (checked) {
                      widget.jobManagementBloc
                          .add(ChangeCompletedCountEvent(completed: count - 1));
                    } else {
                      widget.jobManagementBloc.add(
                        ChangeCompletedCountEvent(
                          completed: count + 1,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
          builder: (runMutation, result) {
            bool isLoading = result?.isLoading ?? false;

            return GestureDetector(
              onTap: isLoading
                  ? null
                  : () async {
                      String status = widget.jobControllerBloc.state.jobStatus;

                      if (status != "INPROGRESS") {
                        if (status == "COMPLETED" || status == "CANCELLED") {
                          buildSnackBar(
                            context: context,
                            value:
                                "Can't update checklist: The job status is ${status.toLowerCase()}.",
                          );
                        } else {
                          buildSnackBar(
                            context: context,
                            value:
                                "Can't update checklist: The job is currently inactive or not in progress.",
                          );
                        }
                        return;
                      }

                      if (!widget.hasInternet) {
                        setState(
                          () {
                            int count =
                                widget.jobManagementBloc.state.completed;
                            widget.checkLists[index].checked = !checked;

                            bool radioButtonSelected =
                                widget.checkLists[index].selectedChoice == null;

                            if (radioButtonSelected) {
                              if (checked) {
                                widget.jobManagementBloc.add(
                                    ChangeCompletedCountEvent(
                                        completed: count - 1));
                              } else {
                                widget.jobManagementBloc.add(
                                  ChangeCompletedCountEvent(
                                    completed: count + 1,
                                  ),
                                );
                              }
                            }
                          },
                        );

                        JobsServices().updateChecklistToLocalDb(
                            checkLists: widget.checkLists, jobId: widget.jobId);

                        return;
                      }

                      List<Checklist> payloadChecklists = List<Checklist>.from(
                          widget.checkLists.map((model) => Checklist(
                                item: model.item,
                                attachments: model.attachments,
                                checkable: model.checkable,
                                checked: model.checked,
                                choiceType: model.choiceType,
                                choices: model.choices,
                                commentCount: model.commentCount,
                                description: model.description,
                                executionIndex: model.executionIndex,
                                id: model.id,
                                selectedChoice: model.selectedChoice,
                              )));

                      payloadChecklists[index].checked = !checked;

                      List<Map<String, dynamic>> checklists = [];

                      for (var element in payloadChecklists) {
                        checklists.add(element.toJson());
                      }

                      runMutation(
                        {
                          "checkListData": {
                            "checklists": checklists,
                            "jobId": widget.jobId,
                          }
                        },
                      );
                    },
              child: Builder(builder: (context) {
                if (isLoading) {
                  return Center(
                    child: CupertinoActivityIndicator(
                      radius: 10.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }

                return Container(
                  height: 20.sp,
                  width: 20.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked ? Theme.of(context).primaryColor : kWhite,
                    border: Border.all(
                      width: 2.5,
                      color: checked ? Theme.of(context).primaryColor : kWhite,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.done,
                      color: checked ? kWhite : Colors.black12,
                      size: 12.sp,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

// ====================================================================================================
// Checklist.

  buildChecklistBottomSheet() async {
    List<CheckListModel> checkLists = [];

    bool checkable = false;
    bool choiceType = false;

    List<String> choiceTypes = [];

    TextEditingController choiceTypeController = TextEditingController();
    TextEditingController controller = TextEditingController();

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    GlobalKey<FormState> choiceTypeFormKey = GlobalKey<FormState>();

    buildModalBottomSheet(
      context,
      title: "Checklists",
      height: 70.h,
      child: Expanded(
        child: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 5.sp,
              vertical: 5.sp,
            ),
            child: Form(
              key: formKey,
              child: StatefulBuilder(builder: (ctx, saveSetState) {
                return Column(
                  children: [
                    BuildCustomTextformField(
                      hintText: "Enter checklist item",
                      controller: controller,
                      customValidator: (value) {
                        // removing symbols
                        String removedSymbols =
                            value!.replaceAll(RegExp(r'[^\w\s]'), '');

                        // removing white spaces
                        String result =
                            removedSymbols.replaceAll(RegExp(r'\s'), '');

                        bool duplicate = checkLists.any((element) {
                          String title = element.title;

                          String removedSymbols =
                              title.replaceAll(RegExp(r'[^\w\s]'), '');

                          // removing white spaces
                          String titleResult =
                              removedSymbols.replaceAll(RegExp(r'\s'), '');

                          return titleResult.toLowerCase() ==
                              result.toLowerCase();
                        });

                        if (duplicate) {
                          return "*The title is already used";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 5.sp,
                    ),
                    StatefulBuilder(
                        builder: (context, setState) => Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          value: checkable,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                checkable = value!;
                                              },
                                            );
                                          },
                                        ),
                                        const Text("Checkable"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          value: choiceType,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                choiceType = value!;
                                              },
                                            );
                                          },
                                        ),
                                        const Text("Choice Type"),
                                      ],
                                    )
                                  ],
                                ),
                                Visibility(
                                  visible: choiceType,
                                  child: Form(
                                    key: choiceTypeFormKey,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: BuildCustomTextformField(
                                            hintText: "Enter Choice Types",
                                            enableValidator:
                                                choiceTypeController
                                                    .text.isEmpty,
                                            controller: choiceTypeController,
                                            customValidator: (value) {
                                              String removedSymbols = value!
                                                  .replaceAll(
                                                      RegExp(r'[^\w\s]'), '');

                                              // removing white spaces
                                              String result =
                                                  removedSymbols.replaceAll(
                                                      RegExp(r'\s'), '');

                                              bool duplicate =
                                                  choiceTypes.any((element) {
                                                String title = element;

                                                String removedSymbols =
                                                    title.replaceAll(
                                                        RegExp(r'[^\w\s]'), '');

                                                // removing white spaces
                                                String titleResult =
                                                    removedSymbols.replaceAll(
                                                        RegExp(r'\s'), '');

                                                return titleResult
                                                        .toLowerCase() ==
                                                    result.toLowerCase();
                                              });

                                              if (duplicate) {
                                                return "*The choice type is already used";
                                              }
                                              return null;

                                              //  if (value!.isEmpty || value.startsWith(" ")) {
                                              //    return ""
                                              //  }
                                            },
                                          ),
                                        ),
                                        // Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            ///////////////
                                            //////////////
                                            ////////////
                                            if (choiceTypeFormKey.currentState!
                                                .validate()) {
                                              setState(
                                                () {
                                                  choiceTypes.add(
                                                      choiceTypeController
                                                          .text);
                                                },
                                              );
                                              choiceTypeController.clear();
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.add,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: choiceTypes.isNotEmpty,
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.sp),
                                    decoration: BoxDecoration(
                                      color: fwhite,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Wrap(
                                      // runSpacing: 10,
                                      spacing: 5,
                                      children: List.generate(
                                        choiceTypes.length,
                                        (index) => Chip(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          label: Text(
                                            choiceTypes[index],
                                            style: const TextStyle(
                                              color: kWhite,
                                            ),
                                          ),
                                          deleteIcon: Icon(
                                            Icons.close,
                                            color: kWhite,
                                            size: 12.sp,
                                          ),
                                          onDeleted: () {
                                            setState(
                                              () {
                                                choiceTypes
                                                    .remove(choiceTypes[index]);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.sp,
                                ),
                                BuildElevatedButton(
                                  onPressed: () {
                                    bool isValid =
                                        formKey.currentState!.validate();
                                    if (isValid) {
                                      saveSetState(
                                        () {
                                          checkLists.add(CheckListModel(
                                            title: controller.text.trim(),
                                            checkable: checkable,
                                            choiceType: choiceType,
                                            choiceTypes: choiceTypes,
                                          ));
                                          controller.clear();

                                          choiceType = false;
                                          checkable = false;
                                          choiceTypes = [];
                                        },
                                      );
                                    }
                                  },
                                  title: "Add Checklist",
                                ),
                                SizedBox(
                                  height: 10.sp,
                                ),
                              ],
                            )),
                    Expanded(
                      child: ListView.builder(
                        itemCount: checkLists.length,
                        padding: EdgeInsets.symmetric(horizontal: 5.sp),
                        itemBuilder: (context, index) {
                          CheckListModel checklist = checkLists[index];

                          return buildChecklistsWidget(
                            checklist,
                          );
                        },
                      ),
                    ),
                    buildChecklistSaveButton(checkLists, context),
                    SizedBox(
                      height: 10.sp,
                    ),
                  ],
                );
              }),
            ),
          );
        }),
      ),
    );

    // setState(
    //   () {},
    // );
  }

// =============================================================
// Adding the checklists;

  Widget buildChecklistSaveButton(
    List<CheckListModel> checkLists,
    BuildContext context,
  ) {
    return MutationWidget(
        options: GrapghQlClientServices().getMutateOptions(
          context: context,
          document: JobsSchemas.addChecklistMutation,
          onCompleted: (data) {
            if (data == null) {
              return;
            }

            widget.jobDetailsBloc
                .add(FetchJobDetailDataEvent(jobId: widget.jobId));

            Navigator.of(context).pop();
          },
        ),
        builder: (runMutation, result) {
          bool isLoading = result?.isLoading ?? false;

          return BuildElevatedButton(
            isLoading: isLoading,
            onPressed: () async {
              List<Map> list = checkLists
                  .map(
                    (e) => {
                      "item": e.title,
                      "checkable": e.checkable,
                      "choiceType": e.choiceType,
                      "choices": e.choiceTypes,
                      "executionIndex":
                          widget.checkLists.length + checkLists.indexOf(e),
                    },
                  )
                  .toList();

              if (list.isEmpty) {
                if (!Platform.isAndroid) {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text("Alert"),
                        content: const Text("Please add checklist"),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Alert"),
                        content: const Text("Please add checklists"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }

                return;
              }

              bool hasInternet =
                  await InterNetServices().checkInternetConnectivity();

              int jobId = widget.jobId;

              if (!hasInternet) {
                var box = jobDetailsDbgetBox();

                JobDetailsDb? jobDetailsDb = box.values
                    .toList()
                    .singleWhereOrNull((element) => element.id == widget.jobId);

                if (jobDetailsDb == null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  buildSnackBar(
                    // snackBarBehavior: SnackBarBehavior.fixed,
                    context: context,
                    value:
                        "Can't add checklists to the local database because the job is not found in the local database.",
                  );

                  return;
                }

                List<ChecklistDb> dbChecklists = jobDetailsDb.checklistDb ?? [];

                int index = box.values
                    .toList()
                    .indexWhere((element) => element.id == widget.jobId);

                for (var i = 0; i < checkLists.length; i++) {
                  var e = checkLists[i];
                  dbChecklists.add(
                    ChecklistDb(
                      checkable: e.checkable,
                      item: e.title,
                      choiceType: e.choiceType,
                      choices: e.choiceTypes,
                      executionIndex: dbChecklists.length + i,
                    ),
                  );
                }

                box.putAt(index, jobDetailsDb);

                var syncList = syncingBox.values.toList();

                if (syncList.isEmpty) {
                  syncingBox.add(SyncingLocalDb(
                    payload: {
                      "checkListData": {
                        "checklists": list,
                        "jobId": jobId,
                      }
                    },
                    generatedTime: DateTime.now().millisecondsSinceEpoch,
                    graphqlMethod: JobsSchemas.addChecklistMutation,
                  ));
                }

                for (var element in syncList) {
                  if (element.payload['checkListData']['jobId'] == jobId) {
                    int index = syncList.indexOf(element);

                    element.payload['checkListData']['checklists'].addAll(list);

                    syncingBox.putAt(index, element);

                    break;
                  } else {
                    syncingBox.add(SyncingLocalDb(
                      payload: {
                        "checkListData": {
                          "checklists": list,
                          "jobId": jobId,
                        }
                      },
                      generatedTime: DateTime.now().millisecondsSinceEpoch,
                      graphqlMethod: JobsSchemas.addChecklistMutation,
                    ));
                  }
                }

                Navigator.of(context).pop();

                return;
              }

              runMutation(
                {
                  "checkListData": {
                    "checklists": list,
                    "jobId": widget.jobId,
                  },
                },
              );

              // var result = await GraphqlServices().performMutation(
              //     query: JobsSchemas.addChecklistMutation,
              //     variables: {
              //       "checkListData": {
              //         "checklists": list,
              //         "jobId": jobId,
              //       }
              //     });

              // if (result.hasException) {
              //   // ignore: use_build_context_synchronously
              //   Navigator.of(context).pop();
              //   // ignore: use_build_context_synchronously
              //   buildSnackBar(
              //     // snackBarBehavior: SnackBarBehavior.fixed,
              //     context: context,
              //     value: "Something went wrong",
              //   );
              //   return;
              // }

              // print(result.data);
              // print("Success");
              // Navigator.of(context).pop();
              // setState(
              //   () {},
              // );
            },
            title: "Save",
          );
        });
  }

//  ==========================================================================================

  Column buildChecklistsWidget(CheckListModel checkListModel) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: fwhite,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //   height: 5.sp,
                // ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        checkListModel.title,
                      ),
                    ),
                    Checkbox(
                      value: checkListModel.checkable,
                      onChanged: null,
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 5.sp,
                // ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 5,
                  direction: Axis.horizontal,
                  children: List.generate(
                    checkListModel.choiceTypes.length,
                    (index) => Chip(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      label: Text(
                        checkListModel.choiceTypes[index],
                        style: const TextStyle(
                          color: kWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5.sp,
        ),
      ],
    );
  }

// =========================================================================
// Checklist completed progress bar.

  Widget buildChecklistprogressBar() {
    return BlocBuilder<JobManagementBloc, JobManagementState>(
      builder: (context, state) {
        int total = widget.checkLists.length;

        int completed = state.completed;

        double widthFactor = 0;
        try {
          widthFactor = total == 0 ? 0 : completed / total;
        } catch (_) {
          widthFactor = 0;
        }

        return LinearPercentIndicator(
          width: 95.w,
          animation: true,
          lineHeight: 10.sp,
          animationDuration: 500,
          percent: widthFactor,
          barRadius: Radius.circular(5.sp),
          animateFromLastPercent: true,
          backgroundColor: fwhite,
          progressColor: Colors.green,
        );
      },
    );
  }
}
