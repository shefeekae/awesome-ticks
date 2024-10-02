import 'package:awesometicks/core/blocs/asset_checklist/asset_checklist_management_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/job/job_management_bloc.dart';
import 'package:awesometicks/core/models/checklist_comments_model.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/job_comments_model.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/ui/pages/job/job_checklist_comments.dart';
import 'package:awesometicks/ui/pages/job/widgets/attachment_textfield.dart';
import 'package:awesometicks/ui/pages/job/widgets/comment_widget.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path/path.dart';
import 'package:sizer/sizer.dart';
import 'package:collection/collection.dart';

/// This is a checklist widget
class ChecklistWidget extends StatefulWidget {
  ChecklistWidget(
      {super.key,
      required this.jobManagementBloc,
      required this.checkLists,
      required this.jobControllerBloc,
      required this.jobId,
      required this.domain,
      required this.hasInternet,
      this.selectAll = false});

  final JobManagementBloc jobManagementBloc;
  final JobControllerBlocBloc jobControllerBloc;

  final List<Checklist> checkLists;
  final int jobId;
  final String domain;
  final bool hasInternet;
  final bool selectAll;

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  final ValueNotifier<int> checklistExpansionNotifier = ValueNotifier<int>(-1);

  late AssetChecklistManagementBloc assetChecklistManagementBloc;

  @override
  void initState() {
    assetChecklistManagementBloc =
        BlocProvider.of<AssetChecklistManagementBloc>(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (widget.checkLists.isEmpty) {
        return const SizedBox();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 7.sp),
        itemBuilder: (context, index) {
          Checklist checklist = widget.checkLists[index];

          bool isAssetChecklist = checklist.type == "ASSET";

          bool checkable = checklist.checkable ?? false;

          // ValueNotifier<bool> commentNotifier =
          //     ValueNotifier<bool>(false);

          return GestureDetector(
            onTap: widget.selectAll
                ? () {
                    List<int> selectedChecklists =
                        assetChecklistManagementBloc.state.selectedChecklists;

                    bool contains = selectedChecklists.contains(checklist.id);

                    if (contains) {
                      assetChecklistManagementBloc.add(
                          RemoveFromSelectedChecklistEvent(
                              assetChecklistId: checklist.id ?? 0));
                    } else {
                      assetChecklistManagementBloc.add(
                          AddToSelectedChecklistEvent(
                              assetChecklistId: checklist.id ?? 0));
                    }
                  }
                : null,
            child: Builder(builder: (context) {
              List<int> selectedChecklists =
                  assetChecklistManagementBloc.state.selectedChecklists;

              bool contains = selectedChecklists.contains(checklist.id);

              return Container(
                  // height: 30.sp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: contains
                        ? Theme.of(context).primaryColor.withOpacity(0.5)
                        : fwhite,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      8.sp,
                    ),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Visibility(
                                visible: checkable,
                                child: Row(
                                  children: [
                                    Builder(
                                      builder: (
                                        context,
                                      ) {
                                        bool checked =
                                            widget.checkLists[index].checked ??
                                                false;
                                        return MutationWidget(
                                          options: GrapghQlClientServices()
                                              .getMutateOptions(
                                            context: context,
                                            document: JobsSchemas
                                                .updateCheckListMutation,
                                            onCompleted: (data) {
                                              if (data == null) {
                                                return;
                                              }

                                              // if (result
                                              //     .hasException) {
                                              //   // ignore: use_build_context_synchronously
                                              //   buildSnackBar(
                                              //       context: context,
                                              //       value:
                                              //           "Checklist updation failed");
                                              //   return;
                                              // }

                                              setState(
                                                () {
                                                  if (isAssetChecklist) {
                                                    int count = widget
                                                        .jobManagementBloc
                                                        .state
                                                        .assetChecklistCompleted;

                                                    widget.checkLists[index]
                                                        .checked = !checked;

                                                    // bool radioButtonSelected =
                                                    //     checkLists[index]
                                                    //             .selectedChoice ==
                                                    //         null;

                                                    // if (radioButtonSelected) {
                                                    if (checked) {
                                                      widget.jobManagementBloc.add(
                                                          ChangeAssetChecklistCompletedCountEvent(
                                                              assetChecklistCompleted:
                                                                  count - 1));
                                                    } else {
                                                      widget.jobManagementBloc
                                                          .add(
                                                        ChangeAssetChecklistCompletedCountEvent(
                                                          assetChecklistCompleted:
                                                              count + 1,
                                                        ),
                                                      );
                                                    }
                                                    // }
                                                  } else {
                                                    int count = widget
                                                        .jobManagementBloc
                                                        .state
                                                        .completed;
                                                    widget.checkLists[index]
                                                        .checked = !checked;

                                                    bool radioButtonSelected =
                                                        widget.checkLists[index]
                                                                .selectedChoice ==
                                                            null;

                                                    if (radioButtonSelected) {
                                                      if (checked) {
                                                        widget.jobManagementBloc
                                                            .add(
                                                                ChangeCompletedCountEvent(
                                                                    completed:
                                                                        count -
                                                                            1));
                                                      } else {
                                                        widget.jobManagementBloc
                                                            .add(
                                                          ChangeCompletedCountEvent(
                                                            completed:
                                                                count + 1,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                          builder: (runMutation, result) {
                                            bool isLoading =
                                                result?.isLoading ?? false;

                                            return GestureDetector(
                                              onTap: isLoading
                                                  ? null
                                                  : () async {
                                                      String status = widget
                                                          .jobControllerBloc
                                                          .state
                                                          .jobStatus;

                                                      if (status !=
                                                          "INPROGRESS") {
                                                        if (status ==
                                                                "COMPLETED" ||
                                                            status ==
                                                                "CANCELLED") {
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
                                                            if (isAssetChecklist) {
                                                              int count = widget
                                                                  .jobManagementBloc
                                                                  .state
                                                                  .assetChecklistCompleted;

                                                              widget
                                                                      .checkLists[
                                                                          index]
                                                                      .checked =
                                                                  !checked;

                                                              bool radioButtonSelected = widget
                                                                      .checkLists[
                                                                          index]
                                                                      .selectedChoice ==
                                                                  null;

                                                              if (radioButtonSelected) {
                                                                if (checked) {
                                                                  widget
                                                                      .jobManagementBloc
                                                                      .add(ChangeAssetChecklistCompletedCountEvent(
                                                                          assetChecklistCompleted:
                                                                              count - 1));
                                                                } else {
                                                                  widget
                                                                      .jobManagementBloc
                                                                      .add(
                                                                    ChangeAssetChecklistCompletedCountEvent(
                                                                      assetChecklistCompleted:
                                                                          count +
                                                                              1,
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                            } else {
                                                              int count = widget
                                                                  .jobManagementBloc
                                                                  .state
                                                                  .completed;
                                                              widget
                                                                      .checkLists[
                                                                          index]
                                                                      .checked =
                                                                  !checked;

                                                              bool radioButtonSelected = widget
                                                                      .checkLists[
                                                                          index]
                                                                      .selectedChoice ==
                                                                  null;

                                                              if (radioButtonSelected) {
                                                                if (checked) {
                                                                  widget
                                                                      .jobManagementBloc
                                                                      .add(ChangeCompletedCountEvent(
                                                                          completed:
                                                                              count - 1));
                                                                } else {
                                                                  widget
                                                                      .jobManagementBloc
                                                                      .add(
                                                                    ChangeCompletedCountEvent(
                                                                      completed:
                                                                          count +
                                                                              1,
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                            }
                                                          },
                                                        );

                                                        JobsServices()
                                                            .updateChecklistToLocalDb(
                                                                checkLists: widget
                                                                    .checkLists,
                                                                jobId: widget
                                                                    .jobId);

                                                        return;
                                                      }

                                                      List<Checklist>
                                                          payloadChecklists =
                                                          List<Checklist>.from(
                                                              widget.checkLists
                                                                  .map((model) =>
                                                                      Checklist(
                                                                        item: model
                                                                            .item,
                                                                        attachments:
                                                                            model.attachments,
                                                                        checkable:
                                                                            model.checkable,
                                                                        checked:
                                                                            model.checked,
                                                                        choiceType:
                                                                            model.choiceType,
                                                                        choices:
                                                                            model.choices,
                                                                        commentCount:
                                                                            model.commentCount,
                                                                        description:
                                                                            model.description,
                                                                        executionIndex:
                                                                            model.executionIndex,
                                                                        id: model
                                                                            .id,
                                                                        selectedChoice:
                                                                            model.selectedChoice,
                                                                      )));

                                                      payloadChecklists[index]
                                                          .checked = !checked;

                                                      List<Map<String, dynamic>>
                                                          checklists = [];

                                                      for (var element
                                                          in payloadChecklists) {
                                                        checklists.add(
                                                            element.toJson());
                                                      }

                                                      runMutation(
                                                        {
                                                          "checkListData": {
                                                            "checklists":
                                                                checklists,
                                                            "jobId":
                                                                widget.jobId,
                                                          }
                                                        },
                                                      );
                                                    },
                                              child:
                                                  Builder(builder: (context) {
                                                if (isLoading) {
                                                  return Center(
                                                    child:
                                                        CupertinoActivityIndicator(
                                                      radius: 10.sp,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  );
                                                }

                                                return Container(
                                                  height: 20.sp,
                                                  width: 20.sp,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: checked
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : kWhite,
                                                    border: Border.all(
                                                      width: 2.5,
                                                      color: checked
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : kWhite,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.done,
                                                      color: checked
                                                          ? kWhite
                                                          : Colors.black12,
                                                      size: 12.sp,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  checklist.item ?? "",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 3.sp,
                              ),
                              Builder(builder: (context) {
                                if (checklist.id == null) {
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

                                return GestureDetector(
                                  onTap: () {
                                    int value =
                                        checklistExpansionNotifier.value;
                                    checklistExpansionNotifier.value =
                                        value == index ? -1 : index;
                                  },
                                  child: Text(
                                    "${checklist.commentCount} comments",
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          Visibility(
                            visible: checklist.choiceType ?? false,
                            child:
                                StatefulBuilder(builder: (context, setState) {
                              bool checked = checklist.checked ?? true;

                              return BlocBuilder<JobControllerBlocBloc,
                                      JobControllerBlocState>(
                                  builder: (context, state) {
                                String status = state.jobStatus;

                                bool dropdownEnable =
                                    status == "INPROGRESS" && checked;

                                dynamic selectedChoice =
                                    checklist.selectedChoice;

                                List choices = checklist.choices;

                                return StatefulBuilder(
                                    builder: (context, setState) =>
                                        GestureDetector(
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
                                                  bool radioEnabled = widget
                                                          .checkLists[index]
                                                          .selectedChoice !=
                                                      null;

                                                  bool checked = widget
                                                          .checkLists[index]
                                                          .checked ??
                                                      false;

                                                  if (!checked &&
                                                      !radioEnabled) {
                                                    if (isAssetChecklist) {
                                                      int count = widget
                                                          .jobManagementBloc
                                                          .state
                                                          .assetChecklistCompleted;
                                                      widget.jobManagementBloc
                                                          .add(
                                                        ChangeAssetChecklistCompletedCountEvent(
                                                          assetChecklistCompleted:
                                                              count + 1,
                                                        ),
                                                      );
                                                    } else {
                                                      int count = widget
                                                          .jobManagementBloc
                                                          .state
                                                          .completed;
                                                      widget.jobManagementBloc
                                                          .add(
                                                        ChangeCompletedCountEvent(
                                                          completed: count + 1,
                                                        ),
                                                      );
                                                    }
                                                  }

                                                  setState(
                                                    () {
                                                      widget.checkLists[index]
                                                              .selectedChoice =
                                                          value;
                                                      selectedChoice = value;
                                                    },
                                                  );

                                                  JobsServices()
                                                      .updateChecklistToLocalDb(
                                                          checkLists:
                                                              widget.checkLists,
                                                          jobId: widget.jobId);
                                                  return;
                                                }

                                                List<Checklist>
                                                    payloadChecklists =
                                                    List<Checklist>.from(widget
                                                        .checkLists
                                                        .map((model) =>
                                                            Checklist(
                                                              item: model.item,
                                                              attachments: model
                                                                  .attachments,
                                                              checkable: model
                                                                  .checkable,
                                                              checked:
                                                                  model.checked,
                                                              choiceType: model
                                                                  .choiceType,
                                                              choices:
                                                                  model.choices,
                                                              commentCount: model
                                                                  .commentCount,
                                                              description: model
                                                                  .description,
                                                              executionIndex: model
                                                                  .executionIndex,
                                                              id: model.id,
                                                              selectedChoice: model
                                                                  .selectedChoice,
                                                            )));

                                                payloadChecklists[index]
                                                    .selectedChoice = value;

                                                bool isUpdated =
                                                    await JobsServices()
                                                        .updateChecklist(
                                                  context: context,
                                                  jobId: widget.jobId,
                                                  list: payloadChecklists,
                                                );

                                                if (!isUpdated) {
                                                  // ignore: use_build_context_synchronously
                                                  buildSnackBar(
                                                    context: context,
                                                    value:
                                                        "Checklist updation failed",
                                                  );
                                                  return;
                                                }

                                                bool radioDisabled = widget
                                                        .checkLists[index]
                                                        .selectedChoice ==
                                                    null;

                                                bool checked = widget
                                                        .checkLists[index]
                                                        .checked ??
                                                    false;

                                                if (!checked && radioDisabled) {
                                                  if (isAssetChecklist) {
                                                    int count = widget
                                                        .jobManagementBloc
                                                        .state
                                                        .assetChecklistCompleted;

                                                    widget.jobManagementBloc
                                                        .add(
                                                      ChangeAssetChecklistCompletedCountEvent(
                                                        assetChecklistCompleted:
                                                            count + 1,
                                                      ),
                                                    );
                                                  } else {
                                                    int count = widget
                                                        .jobManagementBloc
                                                        .state
                                                        .completed;

                                                    widget.jobManagementBloc
                                                        .add(
                                                      ChangeCompletedCountEvent(
                                                        completed: count + 1,
                                                      ),
                                                    );
                                                  }
                                                }

                                                setState(
                                                  () {
                                                    widget.checkLists[index]
                                                        .selectedChoice = value;
                                                    selectedChoice = value;
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ));
                              });
                            }),
                          ),
                          ValueListenableBuilder(
                              valueListenable: checklistExpansionNotifier,
                              builder: (context, value, _) {
                                bool show = value == index;

                                if (!show) {
                                  return const SizedBox();
                                }

                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return Column(children: [
                                    SizedBox(
                                      height: 10.sp,
                                    ),
                                    buildChecklistCommentAttachmentAndTextfield(
                                      context,
                                      jobId: widget.jobId,
                                      jobDomain: widget.domain ?? "",
                                      checklistId: checklist.id!,
                                      setState: setState,
                                    ),
                                    const Divider(
                                      // color: kWhite,
                                      thickness: 1,
                                    ),
                                    FutureBuilder(
                                        future: InterNetServices()
                                            .checkInternetConnectivity(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox();
                                          }

                                          bool hasInternet = snapshot.data!;

                                          if (!hasInternet) {
                                            return ValueListenableBuilder(
                                                valueListenable:
                                                    jobDetailsDbgetBox()
                                                        .listenable(),
                                                builder: (context, box, _) {
                                                  JobDetailsDb? jobDetailsDb =
                                                      box.values.singleWhere(
                                                          (element) =>
                                                              element.id ==
                                                              widget.jobId);

                                                  ChecklistDb? checklistDb =
                                                      jobDetailsDb.checklistDb
                                                          ?.singleWhereOrNull(
                                                    (element) =>
                                                        element.id ==
                                                        checklist.id,
                                                  );

                                                  var checklistComments =
                                                      checklistDb?.comments ??
                                                          [];

                                                  checklistComments.sort(
                                                    (a, b) => b.commentTime!
                                                        .compareTo(
                                                            a.commentTime!),
                                                  );

                                                  return Column(children: [
                                                    ...List.generate(
                                                      checklistComments
                                                                  .length >=
                                                              2
                                                          ? 2
                                                          : checklistComments
                                                              .length,
                                                      (index) {
                                                        var comment =
                                                            checklistComments[
                                                                index];

                                                        return CommentWidget(
                                                          checklistId:
                                                              checklist.id,
                                                          isChecklistComment:
                                                              true,
                                                          comment:
                                                              GetAllComments(
                                                            id: comment.id,
                                                            comment:
                                                                comment.comment,
                                                            commentBy: comment
                                                                .commentBy,
                                                            commentTime: comment
                                                                .commentTime,
                                                          ),
                                                          jobId: widget.jobId,
                                                          jobDomain:
                                                              widget.domain ??
                                                                  "",
                                                        );
                                                      },
                                                    ),
                                                    Visibility(
                                                      visible: checklistComments
                                                              .length >
                                                          2,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                            builder: (context) =>
                                                                JobChecklistCommentsScreen(
                                                              checklistId:
                                                                  checklist.id!,
                                                              jobDomain: widget
                                                                      .domain ??
                                                                  "",
                                                              jobId:
                                                                  widget.jobId,
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

                                          return FutureBuilder(
                                              future: GraphqlServices()
                                                  .performQuery(
                                                query: JobsSchemas
                                                    .checklistCommentsQuery,
                                                variables: {
                                                  "checklistId": checklist.id!,
                                                },
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator
                                                      .adaptive();
                                                }

                                                var result = snapshot.data!;

                                                var data =
                                                    CheckListComments.fromJson(
                                                        result.data ?? {});

                                                var comments =
                                                    data.listCheckListComments ??
                                                        [];

                                                if (comments.isEmpty) {
                                                  return const Center(
                                                    child: Text(
                                                      "No comments",
                                                    ),
                                                  );
                                                }

                                                comments.sort(
                                                  (a, b) => b.commentTime!
                                                      .compareTo(
                                                          a.commentTime!),
                                                );

                                                return Column(children: [
                                                  ...List.generate(
                                                    comments.length >= 2
                                                        ? 2
                                                        : comments.length,
                                                    (index) {
                                                      var comment =
                                                          comments[index];

                                                      // print(
                                                      //     "=====================================");
                                                      // print(
                                                      //     "Comment Id ${comment.commentId}");
                                                      // print(
                                                      //     "==========================================");

                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5.sp),
                                                        child: CommentWidget(
                                                          checklistId:
                                                              checklist.id,
                                                          isChecklistComment:
                                                              true,
                                                          comment:
                                                              GetAllComments(
                                                            id: comment.id,
                                                            comment:
                                                                comment.comment,
                                                            commentBy: comment
                                                                .commentBy,
                                                            commentTime: comment
                                                                .commentTime,
                                                          ),
                                                          jobId: widget.jobId,
                                                          jobDomain:
                                                              widget.domain ??
                                                                  "",
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        comments.length > 2,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                          builder: (context) =>
                                                              JobChecklistCommentsScreen(
                                                            checklistId:
                                                                checklist.id!,
                                                            jobDomain:
                                                                widget.domain ??
                                                                    "",
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
                                        }),
                                  ]);
                                });
                              })
                        ],
                      );
                    }),
                  ));
            }),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 11.sp,
          );
        },
        itemCount: widget.checkLists.length,
      );
    });
  }
}
