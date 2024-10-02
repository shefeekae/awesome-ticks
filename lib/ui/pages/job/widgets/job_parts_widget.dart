import 'package:app_filter_form/core/blocs/filter/filter_selection/filter_selection_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/core/blocs/parts/parts_quantity_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/models/hive%20db/syncing_local_db.dart';
import 'package:awesometicks/core/models/parts_model.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/internet_services.dart';
import 'package:awesometicks/core/services/platform_services.dart';
import 'package:awesometicks/ui/shared/functions/no_leading_zero_textinputfromaters.dart';
import 'package:awesometicks/ui/shared/widgets/build_custom_textfield.dart';
import 'package:awesometicks/ui/shared/widgets/build_elvetad_button.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/ui/shared/widgets/label_with_textfield.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_config/widget/mutation_widget.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';

class JobPartsWidget extends StatelessWidget {
  JobPartsWidget(
      {super.key,
      required this.partsQuantityBloc,
      required this.jobId,
      required this.jobDetailsBloc});

  final PartsQuantityBloc partsQuantityBloc;
  final int jobId;
  final JobDetailsBloc jobDetailsBloc;

  final UserDataSingleton userData = UserDataSingleton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartsQuantityBloc, PartsQuantityState>(
      builder: (context, state) {
        List<PartsModel> parts = state.localParts;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.sp),
          child: Column(
            children: [
              SizedBox(
                height: 5.sp,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      parts.isEmpty
                          ? "No Parts Attached"
                          : "${parts.length} Parts",
                      style: TextStyle(
                        fontSize: parts.isEmpty ? 10.sp : 13.sp,
                        fontWeight:
                            parts.isEmpty ? FontWeight.w500 : FontWeight.w600,
                      ),
                    ),
                    // BlocBuilder<PartsQuantityBloc, PartsQuantityState>(
                    //   bloc: partsQuantityBloc,
                    //   builder: (context, state) {
                    //     bool isChanged = state.isRendered;

                    BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
                        builder: (context, jobState) {
                      String status = jobState.jobStatus;

                      bool visible = status != "COMPLETED" &&
                          status != "CLOSED" &&
                          status != "CANCELLED";

                      return Visibility(
                        visible: visible,
                        child: Builder(
                          builder: (context) {
                            bool isChanged = state.isRendered;

                            if (isChanged) {
                              return Row(
                                children: [
                                  buildPartsControlWidget(
                                    context,
                                    label: "Reset",
                                    key: "reset",
                                  ),
                                  SizedBox(
                                    width: 5.sp,
                                  ),
                                  buildPartsControlWidget(
                                    context,
                                    label: "Save",
                                    key: "save",
                                  ),
                                ],
                              );
                            }

                            return buildPartsControlWidget(
                              context,
                              label: "Add new part",
                              key: "add",
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(
                height: 5.sp,
              ),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    jobDetailsBloc.add(FetchJobDetailDataEvent(jobId: jobId));
                  },
                  child: ListView.separated(
                    // padding: EdgeInsets.symmetric(horizontal: 5.sp),
                    itemBuilder: (context, index) {
                      var map = parts[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: EdgeInsets.all(10.sp),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    map.name ?? "N/A",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.sp,
                                  ),
                                  Text(
                                    map.partReference ?? "N/A",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<JobControllerBlocBloc,
                                    JobControllerBlocState>(
                                builder: (context, state) {
                              String status = state.jobStatus;

                              bool visible = status != "COMPLETED" &&
                                  status != "CLOSED" &&
                                  status != "CANCELLED";

                              return Visibility(
                                visible: visible,
                                child: buildQunatityAndRemoveWidget(
                                  context,
                                  quantity: map.quantity.toString(),
                                  index: index,
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 5.sp,
                      );
                    },
                    itemCount: parts.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =================================================================================
  // SAVE RESET CONTAINER

  Widget buildPartsControlWidget(
    BuildContext context, {
    required String label,
    required String key,
  }) {
    Color? getColor(String key) {
      switch (key) {
        case "save":
          return Colors.green.shade700;

        case "reset":
          return Colors.red.shade700;
        case "add":
          return Theme.of(context).primaryColor;

        default:
          return null;
      }
    }

    IconData? getIcon(String key) {
      switch (key) {
        case "save":
          return Icons.done;

        case "add":
          return Icons.add;
        case "reset":
          return Icons.refresh;

        default:
          return null;
      }
    }

    return FutureBuilder(
        future: InterNetServices().checkInternetConnectivity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }

          if (!snapshot.data!) {
            return SizedBox();
          }

          return Bounce(
            duration: const Duration(milliseconds: 100),
            onPressed: () async {
              switch (key) {
                case "save":
                  List removedParts = [];

                  List localParts = partsQuantityBloc.state.localParts
                      .map((e) => e.toJson())
                      .toList();

                  List partsList = partsQuantityBloc.state.partsList;

                  // removedParts = partsList
                  //     .where((map1) => !localParts
                  //         .any((map2) => map2['identifier'] == map1['identifier']))
                  //     .toList();

                  var result = await GraphqlServices().performMutation(
                    context: context,
                    query: JobsSchemas.partsUpdateMutation,
                    variables: {
                      "partsData": {
                        "parts": partsQuantityBloc.state.localParts
                            .map((e) => e.toJson())
                            .toList(),
                        "jobId": jobId,
                      }
                    },
                  );

                  if (result.hasException) {
                    // ignore: use_build_context_synchronously
                    partsQuantityBloc.add(ResetQuantityEvent());
                    // ignore: use_build_context_synchronously
                    buildSnackBar(
                      context: context,
                      value: "Parts update failed",
                    );

                    return;
                  }

                  removedParts = partsList
                      .where((map1) => !localParts.any(
                          (map2) => map2['identifier'] == map1['identifier']))
                      .toList();

                  if (removedParts.isNotEmpty) {
                    // ignore: use_build_context_synchronously
                    var result = await GraphqlServices().performMutation(
                      context: context,
                      query: JobsSchemas.removePartsMutation,
                      variables: {
                        "partsData": {
                          "parts": removedParts,
                          "jobId": jobId,
                        }
                      },
                    );

                    if (result.hasException) {
                      // ignore: use_build_context_synchronously
                      partsQuantityBloc.add(ResetQuantityEvent());

                      // print("parts remove exception ${result.exception}");
                      // ignore: use_build_context_synchronously
                      buildSnackBar(
                        context: context,
                        value: "Parts remove failed",
                      );
                      return;
                    }
                  }

                  // print(result.data);
                  // // setState(() {});
                  partsQuantityBloc.add(SaveQuantityEvent());

                  break;

                case "reset":
                  partsQuantityBloc.add(ResetQuantityEvent());
                  break;

                case "add":
                  buildPartsBottomsheet(context);
                  break;

                default:
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3.sp, horizontal: 10.sp),
              decoration: BoxDecoration(
                color: getColor(key),
                borderRadius: BorderRadius.circular(3.sp),
              ),
              child: Row(
                children: [
                  Icon(
                    getIcon(key),
                    color: kWhite,
                  ),
                  SizedBox(
                    width: 5.sp,
                  ),
                  Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: kWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // =============================================
  // Showing the quantity widget adn remove icon.

  Widget buildQunatityAndRemoveWidget(BuildContext context,
      {required String quantity, required int index}) {
    return Row(
      children: [
        buildQuantityControllerWidget(context,
            isPlus: false, index: index, quantity: quantity),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.sp),
          decoration: BoxDecoration(
            border: Border.all(
              color: fwhite,
            ),
          ),
          // width: 20.sp,
          height: 20.sp,
          child: Center(
            child: Text(
              quantity,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        buildQuantityControllerWidget(
          context,
          isPlus: true,
          index: index,
          quantity: quantity,
        ),
        SizedBox(
          width: 16.sp,
        ),
        GestureDetector(
          onTap: () async {
            bool hasInternet =
                await InterNetServices().checkInternetConnectivity();

            // ignore: use_build_context_synchronously
            PlatformServices().showPlatformDialog(
              context,
              title: "Are you sure?",
              message: "Delete the part.",
              onPressed: () {
                if (!hasInternet) {
                  var box = jobDetailsDbgetBox();
                  var syncBox = syncdbgetBox();

                  var syncList = syncBox.values.toList();

                  JobDetailsDb jobDetailsDb =
                      box.values.singleWhere((element) => element.id == jobId);

                  if (syncList.isEmpty) {
                    syncBox.add(
                      SyncingLocalDb(
                        payload: {
                          "partsData": {
                            "parts": [
                              jobDetailsDb.parts![index].toJson(),
                            ],
                            "jobId": jobId,
                          }
                        },
                        generatedTime: DateTime.now().millisecondsSinceEpoch,
                        graphqlMethod: JobsSchemas.removePartsMutation,
                      ),
                    );
                  }

                  for (var element in syncList) {
                    if (element.graphqlMethod ==
                            JobsSchemas.removePartsMutation &&
                        element.payload['partsData']['jobId'] == jobId) {
                      int syncIndex = syncList.indexOf(element);

                      List parts = element.payload['partsData']['parts'];

                      parts.add(
                        jobDetailsDb.parts![index].toJson(),
                      );

                      syncBox.putAt(syncIndex, element);

                      break;
                    }
                  }

                  int jobIndex = box.values
                      .toList()
                      .indexWhere((element) => element.id == jobId);

                  jobDetailsDb.parts!.removeAt(index);
                  box.putAt(jobIndex, jobDetailsDb);
                } else {
                  partsQuantityBloc.add(PartsRemoveEvent(index));
                }
                Navigator.of(context).pop();
              },
            );
          },
          child: Icon(
            Icons.close,
            size: 16.sp,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  // ==========================================
  // Used for to controll quantity update

  Widget buildQuantityControllerWidget(
    BuildContext context, {
    required bool isPlus,
    required int index,
    required String quantity,
  }) {
    return GestureDetector(
      onTap: () async {
        // partsQuantityBloc.state.isRendered = true;

        bool hasInternet = await InterNetServices().checkInternetConnectivity();

        if (!hasInternet) {
          var box = jobDetailsDbgetBox();
          var syncBox = syncdbgetBox();

          var syncList = syncBox.values.toList();

          JobDetailsDb jobDetailsDb =
              box.values.singleWhere((element) => element.id == jobId);

          int qty = int.parse(quantity);

          int jobIndex =
              box.values.toList().indexWhere((element) => element.id == jobId);

          if (qty == 1 && !isPlus) {
            // ignore: use_build_context_synchronously
            PlatformServices().showPlatformDialog(
              context,
              title: "Are you sure?",
              message: "Delete the part",
              onPressed: () {
                // partsQuantityBloc.add(PartsRemoveEvent(index));

                jobDetailsDb.parts!.removeAt(index);
                box.putAt(jobIndex, jobDetailsDb);

                Navigator.of(context).pop();
              },
            );
            return;
          }

          jobDetailsDb.parts![index].quantity = isPlus ? qty + 1 : qty - 1;

          box.putAt(jobIndex, jobDetailsDb);

          if (syncList.isEmpty) {
            syncBox.add(
              SyncingLocalDb(
                payload: {
                  "partsData": {
                    "parts": [
                      jobDetailsDb.parts![index].toJson(),
                    ],
                    "jobId": jobId,
                  }
                },
                generatedTime: DateTime.now().millisecondsSinceEpoch,
                graphqlMethod: JobsSchemas.partsUpdateMutation,
              ),
            );
          }

          for (var element in syncList) {
            if (element.graphqlMethod == JobsSchemas.partsUpdateMutation &&
                element.payload['partsData']['jobId'] == jobId) {
              int syncIndex = syncList.indexOf(element);

              List parts = element.payload['partsData']['parts'];

              int partIndex = parts.indexWhere(
                  (element) => element['id'] == jobDetailsDb.parts![index].id);

              if (partIndex != -1) {
                // jobDetailsDb.parts![index].quantity =
                //     isPlus ? qty + 1 : qty - 1;

                parts[partIndex] = jobDetailsDb.parts![index].toJson();
              } else {
                // jobDetailsDb.parts![index].quantity =
                //     isPlus ? qty + 1 : qty - 1;

                parts.add(
                  jobDetailsDb.parts![index].toJson(),
                );
              }

              syncBox.putAt(syncIndex, element);

              break;
            }
          }

          return;
        }

        if (quantity == "1" && !isPlus) {
          // ignore: use_build_context_synchronously
          PlatformServices().showPlatformDialog(
            context,
            title: "Are you sure?",
            message: "Delete the part",
            onPressed: () {
              partsQuantityBloc.add(PartsRemoveEvent(index));
              Navigator.of(context).pop();
            },
          );
        } else if (isPlus) {
          partsQuantityBloc.add(QuantityAddEvent(
            index: index,
          ));
        } else {
          partsQuantityBloc.add(QuantityRemoveEvent(index: index));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: fwhite,
          borderRadius: BorderRadius.horizontal(
            left: isPlus ? Radius.zero : Radius.circular(4.sp),
            right: isPlus ? Radius.circular(4.sp) : Radius.zero,
          ),
        ),
        height: 20.sp,
        width: 20.sp,
        child: Icon(
          isPlus ? Icons.add : Icons.remove,
          color: kBlack,
          size: 16.sp,
        ),
      ),
    );
  }

  // ====================================================================
  // ====================================================================

  Future<dynamic> buildPartsBottomsheet(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    TextEditingController quantityController = TextEditingController();

    final ValueNotifier<bool> valueNotifier = ValueNotifier<bool>(false);

    final ValueNotifier<Map<String, dynamic>?> partsSelectionNotifier =
        ValueNotifier<Map<String, dynamic>?>(null);

    final ValueNotifier<bool> searchEnableNotifier = ValueNotifier<bool>(false);

    final ValueNotifier<String> searchValueNotifier = ValueNotifier<String>("");

    return showModalBottomSheet(
      // title: "Add Parts",
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabelWidget(
              title: "Parts",
            ),
            BlocBuilder<FilterSelectionBloc, FilterSelectionState>(
              builder: (context, state) {
                // for (var element in list) {
                //   print(element.selectedValues);
                //   print("Filter Applied called");
                // }

                return ValueListenableBuilder(
                  valueListenable: valueNotifier,
                  builder: (context, value, child) {
                    bool show = value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: kWhite,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      topRight: Radius.circular(7),
                                    ),
                                  ),
                                  height: 70.h,
                                  child: Builder(
                                    builder: (context) {
                                      return Column(
                                        children: [
                                          ValueListenableBuilder(
                                              valueListenable:
                                                  searchEnableNotifier,
                                              builder: (context, value, _) {
                                                return ListTile(
                                                  title: value
                                                      ? CupertinoTextField(
                                                          // controller: searchTextController,
                                                          autofocus: true,
                                                          placeholder: "Search",
                                                          // cursorColor: primaryColor,
                                                          onChanged: (value) {
                                                            searchValueNotifier
                                                                .value = value;
                                                          },
                                                        )
                                                      : const Text("Parts"),
                                                  trailing: IconButton(
                                                    onPressed: () {
                                                      bool enabled =
                                                          searchEnableNotifier
                                                              .value;

                                                      if (enabled) {
                                                        searchValueNotifier
                                                            .value = "";
                                                      }

                                                      searchEnableNotifier
                                                          .value = !enabled;
                                                    },
                                                    icon:
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                searchEnableNotifier,
                                                            builder: (contex,
                                                                value, _) {
                                                              return Icon(
                                                                value
                                                                    ? Icons
                                                                        .close
                                                                    : Icons
                                                                        .search,
                                                              );
                                                            }),
                                                  ),
                                                );
                                              }),
                                          const Divider(
                                            thickness: 1,
                                            height: 1,
                                          ),
                                          Expanded(
                                            child: StatefulBuilder(
                                                builder: (context, setState) {
                                              return ValueListenableBuilder(
                                                  valueListenable:
                                                      searchValueNotifier,
                                                  builder: (context, value, _) {
                                                    return FutureBuilder(
                                                      future:
                                                          GrapghQlClientServices()
                                                              .performQuery(
                                                        query: JobsSchemas
                                                            .listAllServicePartsQuery,
                                                        variables: {
                                                          "queryParam": {
                                                            "page": -1,
                                                            // "size": 10,
                                                            "sort": "name,asc",
                                                          },
                                                          "body": {
                                                            "domain":
                                                                userData.domain,
                                                            "status": "ACTIVE",
                                                            "name": value,
                                                          },
                                                        },
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return BuildShimmerLoadingWidget(
                                                            height: 30.sp,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10.sp),
                                                          );
                                                        }

                                                        var result =
                                                            snapshot.data!;

                                                        if (result
                                                            .hasException) {
                                                          return GraphqlServices()
                                                              .handlingGraphqlExceptions(
                                                            result: result,
                                                            context: context,
                                                            setState: setState,
                                                            // refetch: refetch,
                                                          );
                                                        }

                                                        var savedParts =
                                                            partsQuantityBloc
                                                                .state
                                                                .localParts;

                                                        List parts = result
                                                                        .data?[
                                                                    "listAllServiceParts"]
                                                                ?['items'] ??
                                                            [];

                                                        parts.removeWhere((e) =>
                                                            savedParts.any((element) =>
                                                                element
                                                                    .identifier ==
                                                                e['identifier']));

                                                        if (parts.isEmpty) {
                                                          return const Center(
                                                            child: Text(
                                                                "No Items found "),
                                                          );
                                                        }

                                                        return ListView.builder(
                                                          itemCount:
                                                              parts.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return ValueListenableBuilder(
                                                                valueListenable:
                                                                    partsSelectionNotifier,
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        _) {
                                                                  Map map =
                                                                      parts[
                                                                          index];

                                                                  String?
                                                                      selectedIdentifier =
                                                                      value?[
                                                                          'identifier'];

                                                                  String
                                                                      identifier =
                                                                      map['identifier'] ??
                                                                          "";

                                                                  return RadioListTile<
                                                                      String?>(
                                                                    value:
                                                                        selectedIdentifier,
                                                                    groupValue:
                                                                        identifier,
                                                                    onChanged:
                                                                        (value) {
                                                                      partsSelectionNotifier
                                                                          .value = {
                                                                        "identifier":
                                                                            map['identifier'],
                                                                        "name":
                                                                            map['name'],
                                                                        "domain":
                                                                            map['domain'],
                                                                        "partReference":
                                                                            map['partReference'],
                                                                        "unitCost":
                                                                            map['unitCost'],
                                                                      };
                                                                    },
                                                                    title: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            map['name'] ??
                                                                                "N/A",
                                                                          ),
                                                                        ),
                                                                        Text(map['partReference'] ??
                                                                            ""),
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                        );
                                                      },
                                                    );
                                                  });
                                            }),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            );

                            if (partsSelectionNotifier.value != null) {
                              valueNotifier.value = false;
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border:
                                    show ? Border.all(color: Colors.red) : null,
                                color: fwhite,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.sp, vertical: 10.sp),
                              child: ValueListenableBuilder(
                                  valueListenable: partsSelectionNotifier,
                                  builder: (context, value, _) {
                                    String title = "";

                                    if (value == null) {
                                      title = "Select Parts";
                                    } else {
                                      title = value['name'] ?? "";
                                      title =
                                          "$title (${value['partReference'] ?? ""})";

                                      // valueNotifier.value = false;
                                    }

                                    bool selected = value != null;

                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.sp),
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color:
                                              selected ? null : Colors.black26,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: show,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5.sp,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.sp),
                                child: Text(
                                  "*required",
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 10.sp,
            ),
            buildLabelWidget(
              title: "Quantity",
            ),
            Form(
              key: formKey,
              child: BuildCustomTextformField(
                hintText: "Enter Quanity",
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NoLeadingZeroTextInputFormatter(),
                ],
              ),
            ),
            const Spacer(),
            MutationWidget(
              options: GrapghQlClientServices().getMutateOptions(
                context: context,
                document: JobsSchemas.addPartsMutation,
                onCompleted: (data) {
                  if (data == null) {
                    return;
                  }

                  jobDetailsBloc.add(FetchJobDetailDataEvent(jobId: jobId));

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
              ),
              builder: (runMutation, result) {
                return BuildElevatedButton(
                  isLoading: result?.isLoading ?? false,
                  onPressed: () async {
                    bool isValid = formKey.currentState!.validate();

                    Map<String, dynamic>? partMap =
                        partsSelectionNotifier.value;

                    if (partMap == null) {
                      valueNotifier.value = true;
                      return;
                    } else {
                      valueNotifier.value = false;
                    }

                    if (isValid) {
                      valueNotifier.value = false;

                      partMap['quantity'] =
                          int.parse(quantityController.text.trim());

                      runMutation(
                        {
                          "partsData": {
                            "parts": [
                              partMap,
                            ],
                            "jobId": jobId,
                          }
                        },
                      );
                    }
                  },
                  title: "Save",
                );
              },
            ),
            SizedBox(
              height: 10.sp,
            ),
          ],
        ),
      ),
    );
  }
}
