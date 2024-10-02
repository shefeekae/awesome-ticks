import 'package:awesometicks/core/blocs/asset_checklist/asset_checklist_management_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/job/job_management_bloc.dart';
import 'package:awesometicks/core/models/job_details_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/ui/pages/job/widgets/checklist_progressbar_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/checklist_widget.dart';
import 'package:awesometicks/ui/shared/widgets/custom_searchfield.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sizer/sizer.dart';

class AssetChecklistWidget extends StatefulWidget {
  AssetChecklistWidget(
      {super.key,
      required this.assetCheckLists,
      required this.hasInternet,
      required this.domain,
      required this.jobId,
      required this.jobManagementBloc,
      required this.jobControllerBloc});

  final List<Checklist> assetCheckLists;
  final bool hasInternet;
  final String domain;
  final int jobId;
  final JobManagementBloc jobManagementBloc;
  final JobControllerBlocBloc jobControllerBloc;

  @override
  State<AssetChecklistWidget> createState() => _AssetChecklistWidgetState();
}

class _AssetChecklistWidgetState extends State<AssetChecklistWidget> {
  final ValueNotifier<List<Checklist>> assetChecklistSearchNotifier =
      ValueNotifier<List<Checklist>>([]);

  late ValueNotifier<bool> markAsDoneNotifier;

  late AssetChecklistManagementBloc assetChecklistManagmentBloc;

  // bool? isCheckedList;

  // final ValueNotifier<bool> showAllNotifier = ValueNotifier<bool>(false);
  // bool showAll = false;

  @override
  void initState() {
    assetChecklistManagmentBloc =
        BlocProvider.of<AssetChecklistManagementBloc>(context);

    assetChecklistSearchNotifier.value = widget.assetCheckLists;

    markAsDoneNotifier = ValueNotifier<bool>(false);

    super.initState();
  }

  @override
  void dispose() {
    assetChecklistManagmentBloc.state.selectedChecklists = [];
    assetChecklistManagmentBloc.state.checkedUncheckedList = [];
    // showAllNotifier.dispose();
    assetChecklistManagmentBloc.state.showAll = false;

    // assetChecklistManagmentBloc.state.unCheckedList = [];

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // bool showAll = false;

    return Visibility(
      visible: widget.assetCheckLists.isNotEmpty,
      child: Container(
        // padding: EdgeInsets.all(5.sp),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.sp)),
        child: BlocBuilder<AssetChecklistManagementBloc,
            AssetChecklistManagementState>(
          builder: (context, selectedChecklistState) {
            List<int> checkedUncheckedList =
                selectedChecklistState.checkedUncheckedList;
            // List<Checklist> unCheckedList =
            //     selectedChecklistState.unCheckedList;

            bool showAll = selectedChecklistState.showAll;

            if (checkedUncheckedList.isEmpty && !showAll) {
              assetChecklistSearchNotifier.value = widget.assetCheckLists;
            } else {
              // if (isCheckedList ?? false) {
              assetChecklistSearchNotifier.value = widget.assetCheckLists
                  .where(
                    (element) => assetChecklistManagmentBloc
                        .state.checkedUncheckedList
                        .contains(element.id),
                  )
                  .toList();

              // }

              // if (isCheckedList == false) {
              //   assetChecklistSearchNotifier.value = unCheckedList;
              // }
            }

            // showAll = checkedUncheckedList.isNotEmpty;

            // assetChecklistManagmentBloc.add(ShowAllAssetChecklistEvent(
            //     showAll: checkedList.isNotEmpty || unCheckedList.isNotEmpty));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<JobManagementBloc, JobManagementState>(
                  builder: (context, jobState) {
                    int assetChecklistCount = jobState.assetChecklistCompleted;

                    return Padding(
                      padding: EdgeInsets.only(left: 7.sp),
                      child: Text(
                        "Asset Checklist $assetChecklistCount/${widget.assetCheckLists.length}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          // color: kBlack.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 3.sp,
                ),
                ChecklistProgressBar(
                    checklistLength: widget.assetCheckLists.length,
                    isAssetChecklist: true),
                SizedBox(
                  height: 5.sp,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Row(
                    children: [
                      Flexible(child: BuildCustomSearchField(
                        onChanged: (value) {
                          List<Checklist> listToBeSearched = [];

                          if (checkedUncheckedList.isEmpty) {
                            listToBeSearched = widget.assetCheckLists;
                          } else {
                            // if (isCheckedList ?? false) {
                            listToBeSearched = widget.assetCheckLists
                                .where(
                                  (element) => assetChecklistManagmentBloc
                                      .state.checkedUncheckedList
                                      .contains(element.id),
                                )
                                .toList();
                            // }

                            // if (isCheckedList == false) {
                            //   listToBeSearched = unCheckedList;
                            // }
                          }

                          assetChecklistSearchNotifier.value = listToBeSearched
                              .where((element) =>
                                  element.item
                                      ?.toLowerCase()
                                      .contains(value.toLowerCase()) ??
                                  false)
                              .toList();
                        },
                      )),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (value) {
                          toggleSelection(value);
                        },
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                              value: "selectAll",
                              child: Text("Select all"),
                            ),
                            PopupMenuItem(
                              value: "unselectAll",
                              child: Text("Unselect all"),
                            ),
                            PopupMenuItem(
                              value: "showChecked",
                              child: Text("Show checked assets"),
                            ),
                            PopupMenuItem(
                              value: "showUnchecked",
                              child: Text("Show unchecked assets"),
                            ),
                          ];
                        },
                      )
                    ],
                  ),
                ),
                Visibility(
                    visible: checkedUncheckedList.isNotEmpty || showAll,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.sp),
                      child: Row(
                        children: [
                          Text(
                            "Total : ${assetChecklistSearchNotifier.value.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // isCheckedList = null;

                              assetChecklistManagmentBloc.add(
                                  ShowCheckedUncheckedChecklistEvent(
                                      checkedUncheckedList: []));

                              // assetChecklistManagmentBloc.add(
                              //     ShowUncheckedChecklistEvent(
                              //         uncheckedList: []));

                              assetChecklistManagmentBloc
                                  .add(ShowAllButtonEvent(showAll: false));
                            },
                            child: const Text("Show all"),
                          ),
                        ],
                      ),
                    )),
                Visibility(
                    visible:
                        selectedChecklistState.selectedChecklists.isNotEmpty,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.sp,
                        ),
                        child: ValueListenableBuilder(
                            valueListenable: markAsDoneNotifier,
                            builder: (context, markValue, child) {
                              return BlocBuilder<JobManagementBloc,
                                      JobManagementState>(
                                  builder: (context, jobState) {
                                return MutationWidget(
                                    options: GrapghQlClientServices()
                                        .getMutateOptions(
                                      document:
                                          JobsSchemas.updateCheckListMutation,
                                      context: context,
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

                                        List<Checklist> selectedChecklist =
                                            widget.assetCheckLists
                                                .where(
                                                  (element) =>
                                                      selectedChecklistState
                                                          .selectedChecklists
                                                          .contains(element.id),
                                                )
                                                .toList();

                                        setState(
                                          () {
                                            // int count = widget.jobManagementBloc
                                            //     .state.assetChecklistCompleted;

                                            int assetChecklistCount = jobState
                                                .assetChecklistCompleted;

                                            for (Checklist assetCheckList
                                                in selectedChecklist) {
                                              bool checked =
                                                  assetCheckList.checked ??
                                                      false;

                                              assetCheckList.checked =
                                                  markValue;

                                              if (markValue && !checked) {
                                                assetChecklistCount++;

                                                widget.jobManagementBloc.add(
                                                  ChangeAssetChecklistCompletedCountEvent(
                                                    assetChecklistCompleted:
                                                        assetChecklistCount,
                                                  ),
                                                );
                                              } else if (!markValue &&
                                                  checked) {
                                                assetChecklistCount--;

                                                assetChecklistCount =
                                                    assetChecklistCount;

                                                widget.jobManagementBloc.add(
                                                    ChangeAssetChecklistCompletedCountEvent(
                                                        assetChecklistCompleted:
                                                            assetChecklistCount));
                                              }

                                              // if (checked) {
                                              //   widget.jobManagementBloc.add(
                                              //       ChangeAssetChecklistCompletedCountEvent(
                                              //           assetChecklistCompleted:
                                              //               count - updateCount));
                                              // } else {
                                              //   widget.jobManagementBloc.add(
                                              //     ChangeAssetChecklistCompletedCountEvent(
                                              //       assetChecklistCompleted:
                                              //           count + updateCount,
                                              //     ),
                                              //   );
                                              // }
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    builder: (runMutation, result) {
                                      bool isLoading =
                                          result?.isLoading ?? false;

                                      if (isLoading) {
                                        showAdaptiveDialog(
                                          context: context,
                                          builder: (context) => Dialog(

                                              // insetPadding: EdgeInsets.symmetric(horizontal: 10.sp),
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20.sp,
                                                    horizontal: 5.sp),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const CircularProgressIndicator
                                                        .adaptive(),
                                                    SizedBox(
                                                      width: 5.sp,
                                                    ),
                                                    const Text(
                                                      "Please wait...",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        );

                                        if (result?.isNotLoading ?? false) {
                                          Navigator.of(context).pop();
                                        }
                                      }

                                      return Row(
                                        children: [
                                          Text(
                                            "Total  ${selectedChecklistState.selectedChecklists.length}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () {
                                                      showAdaptiveDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog
                                                                .adaptive(
                                                          title: const Text(
                                                              "Mark As Done"),
                                                          content: const Text(
                                                              "Mark all the selected items as done ?"),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "No")),
                                                            TextButton(
                                                                onPressed:
                                                                    isLoading
                                                                        ? null
                                                                        : () {
                                                                            Navigator.of(context).pop();

                                                                            markValue =
                                                                                true;

                                                                            checkAllOrUncheckAllChecklists(
                                                                              mark: true,
                                                                              // checkLists: selectedChecklistState.selectedChecklists,
                                                                              runMutation: runMutation,
                                                                            );

                                                                            assetChecklistManagmentBloc.add(UnSelectAllAssetChecklistEvent());
                                                                          },
                                                                child:
                                                                    const Text(
                                                                        "Yes"))
                                                          ],
                                                        ),
                                                      );
                                                    },
                                              child:
                                                  const Text("Mark as done")),
                                          TextButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () {
                                                      showAdaptiveDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog
                                                                .adaptive(
                                                          title: const Text(
                                                              "Mark As Not Done"),
                                                          content: const Text(
                                                              "Mark all the selected items as not done ?"),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "No")),
                                                            TextButton(
                                                                onPressed:
                                                                    isLoading
                                                                        ? null
                                                                        : () {
                                                                            Navigator.of(context).pop();

                                                                            markValue =
                                                                                false;

                                                                            checkAllOrUncheckAllChecklists(
                                                                              mark: false,
                                                                              // checkLists: selectedChecklistState.selectedChecklists,
                                                                              runMutation: runMutation,
                                                                            );

                                                                            assetChecklistManagmentBloc.add(UnSelectAllAssetChecklistEvent());
                                                                          },
                                                                child:
                                                                    const Text(
                                                                        "Yes"))
                                                          ],
                                                        ),
                                                      );
                                                    },
                                              child: const Text(
                                                  "Mark as not done")),
                                        ],
                                      );
                                    });
                              });
                            }))),
                ValueListenableBuilder(
                    valueListenable: assetChecklistSearchNotifier,
                    builder: (context, searchedAssetChecklist, child) {
                      if (searchedAssetChecklist.isEmpty) {
                        return const Center(
                            child: Text(
                          "Checklist not found",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ));
                      }

                      return ChecklistWidget(
                          jobManagementBloc: widget.jobManagementBloc,
                          checkLists: searchedAssetChecklist,
                          jobControllerBloc: widget.jobControllerBloc,
                          jobId: widget.jobId,
                          selectAll: selectedChecklistState
                              .selectedChecklists.isNotEmpty,
                          domain: widget.domain,
                          hasInternet: widget.hasInternet);
                    }),
              ],
            );
          },
        ),
      ),
    );
  }

  checkAllOrUncheckAllChecklists(
      {required bool mark,
      // required List<Checklist> checkLists,
      required MultiSourceResult<dynamic> Function(Map<String, dynamic>,
              {Object? optimisticResult})
          runMutation}) {
    String status = widget.jobControllerBloc.state.jobStatus;

    List<Checklist> selectedChecklist = widget.assetCheckLists
        .where(
          (element) => assetChecklistManagmentBloc.state.selectedChecklists
              .contains(element.id),
        )
        .toList();

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
          int count = widget.jobManagementBloc.state.assetChecklistCompleted;

          for (Checklist checkList in selectedChecklist) {
            checkList.checked = mark;

            bool checked = checkList.checked ?? false;

            // bool radioButtonSelected = checkList.selectedChoice == null;

            // if (radioButtonSelected) {
            if (mark && !checked) {
              count++;

              widget.jobManagementBloc.add(
                  ChangeAssetChecklistCompletedCountEvent(
                      assetChecklistCompleted: count));
            } else if (!mark && checked) {
              count--;

              widget.jobManagementBloc.add(
                ChangeAssetChecklistCompletedCountEvent(
                  assetChecklistCompleted: count,
                ),
              );
            }
            // }
          }
        },
      );

      JobsServices().updateChecklistToLocalDb(
          checkLists: selectedChecklist, jobId: widget.jobId);

      return;
    }

    List<Checklist> payloadChecklists =
        List<Checklist>.from(selectedChecklist.map((model) => Checklist(
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

    for (Checklist payloadChecklist in payloadChecklists) {
      payloadChecklist.checked = mark;
    }

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
  }

  toggleSelection(String value) {
    switch (value) {
      case "selectAll":
        assetChecklistManagmentBloc.add(SelectAllAssetChecklistEvent(
            assetChecklist:
                widget.assetCheckLists.map((e) => e.id ?? 0).toList()));
        break;

      case "unselectAll":
        assetChecklistManagmentBloc.add(UnSelectAllAssetChecklistEvent());
        break;

      case "showChecked":
        showCheckedAssets(widget.assetCheckLists);
        break;

      case "showUnchecked":
        showUnCheckedAssets(widget.assetCheckLists);
        break;

      default:
    }
  }

  showCheckedAssets(
    List<Checklist> assetChecklists,
  ) {
    assetChecklistManagmentBloc.add(ShowAllButtonEvent(showAll: true));

    // isCheckedList = true;

    List<int> checkedAssets = assetChecklists
        .where((element) => element.checked)
        .map((e) => e.id ?? 0)
        .toList();

    assetChecklistManagmentBloc.add(ShowCheckedUncheckedChecklistEvent(
        checkedUncheckedList: checkedAssets));
  }

  showUnCheckedAssets(
    List<Checklist> assetChecklists,
  ) {
    assetChecklistManagmentBloc.add(ShowAllButtonEvent(showAll: true));

    // isCheckedList = false;

    List<int> unCheckedAssets = assetChecklists
        .where((element) => element.checked == false || element.checked == null)
        .map((e) => e.id ?? 0)
        .toList();

    assetChecklistManagmentBloc.add(ShowCheckedUncheckedChecklistEvent(
        checkedUncheckedList: unCheckedAssets));
  }
}
