import 'dart:convert';

import 'package:app_filter_form/core/blocs/filter/filter%20applied/filter_applied_bloc.dart';
import 'package:app_filter_form/core/blocs/filter/filter_selection/filter_selection_bloc.dart';
import 'package:app_filter_form/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:app_filter_form/core/services/form_filter_enum.dart';
import 'package:app_filter_form/widgets/filter_widgets.dart';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/blocs/pagination%20controller/pagination_controller_bloc.dart';
import 'package:awesometicks/core/models/listalljobsmodel.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/ui/pages/home/widgets/jobs_list_builder.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';

class AssetJobListWidget extends StatefulWidget {
  const AssetJobListWidget(
      {super.key,
      required this.type,
      required this.domain,
      required this.resourceId});

  final String type;
  final String domain;
  final String resourceId;

  @override
  State<AssetJobListWidget> createState() => _AssetJobListWidgetState();
}

class _AssetJobListWidgetState extends State<AssetJobListWidget> {
  UserDataSingleton userDataSingleton = UserDataSingleton();

  late PaginationControllerBloc paginationControllerBloc;
  late PayloadManagementBloc payloadManagementBloc;
  late FilterAppliedBloc filterAppliedBloc;
  late FilterSelectionBloc filterSelectionBloc;

  @override
  void initState() {
    paginationControllerBloc =
        BlocProvider.of<PaginationControllerBloc>(context);
    payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);

    filterAppliedBloc = BlocProvider.of<FilterAppliedBloc>(context);

    filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);

    // payloadManagementBloc.state.payload = {};

    filterAppliedBloc.add(UpdateFilterAppliedCount(count: 1));

    payloadManagementBloc.state.payload = {
      "status": [
        "SCHEDULED",
        "RESCHEDULED",
        "INPROGRESS",
        "WAITINGFORPARTS",
        "NOACCESS",
        "HELD",
        "TRANSFERRED_TO_VENDOR",
        "COMPLETED",
      ],
    };

    super.initState();
  }

  @override
  void dispose() {
    filterSelectionBloc.state.filterLabelsMap[FilterType.jobs] = [];

    // filterSelectionBloc.state.filterLabelsMap[FilterType.jobs] = [];
    // filterAppliedBloc.add(UpdateFilterAppliedCount(count: 1));
    // // payloadManagementBloc.state.payload = {};

    // payloadManagementBloc.state.payload = {
    //   "status": JobsServices.initialStatusList,
    // };

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        // if (!state.isInternetAvailable) {
        //   return buildfetchingallJobsFromLocalDb();
        // }

        payloadManagementBloc.state.payload['resource'] = [
          {
            "type": widget.type,
            "domain": widget.domain,
            "resourceId": widget.resourceId,
          }
        ];

        return BlocBuilder<PayloadManagementBloc, PayloadManagementState>(
          builder: (context, state) {
            Map<String, dynamic> variables = {
              "queryParam": {
                "page": 0,
                "size": 10,
                "sort": "jobStartTime,desc",
              },
              "data": {
                "domain": userDataSingleton.domain,
                "resource": [
                  {
                    "type": widget.type,
                    "domain": widget.domain,
                    "resourceId": widget.resourceId,
                  }
                ],
                "hasInTeam": true,
                ...state.payload,
              },
            };

            return StatefulBuilder(
              builder: (context, refreshState) {
                return FutureBuilder(
                  future: GraphqlServices().performQuery(
                    query: JobsSchemas.listAllJobsQuery,
                    variables: variables,
                  ),

                  // options: GraphqlServices().getQueryOptions(
                  //   query: JobsSchemas.listAllJobsQuery,
                  //   variables: variables,
                  // ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return BuildShimmerLoadingWidget(
                        height: 15.h,
                        padding: EdgeInsets.symmetric(vertical: 10.sp),
                      );
                    }

                    var result = snapshot.data;

                    if (result == null) {
                      return const Center(
                        child: Text("Error loading data"),
                      );
                    }

                    if (result.hasException) {
                      return GraphqlServices().handlingGraphqlExceptions(
                        result: result,
                        context: context,
                        setState: refreshState,
                        // refetch: refetch,
                      );
                    }

                    // var data = result.data ?? {};

                    var listallJobs =
                        ListAllJobsModel.fromJson(result.data ?? {});

                    var list = listallJobs
                            .listAllJobsWithPaginationSortSearch?.items ??
                        [];

                    paginationControllerBloc.state.result = list;
                    paginationControllerBloc.state.currentPage = 0;
                    paginationControllerBloc.state.isCompleted = false;

                    int totalCount = listallJobs
                            .listAllJobsWithPaginationSortSearch?.totalItems ??
                        0;

                    // countBloc.add(ChangeCountEvent(count: totalCount));

                    JobsServices().listAlljobsStoreToLocalDb();

                    if (list.isEmpty) {
                      return Center(
                        child: Lottie.asset(
                          "assets/lotties/134394-no-transaction.json",
                          repeat: false,
                          width: 70.w,
                          height: 50.h,
                        ),
                      );
                    }

                    return RefreshIndicator.adaptive(
                      onRefresh: () async {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          refreshState(
                            () {},
                          );
                        });
                      },
                      child: JobListviewBuilder(
                        setState: refreshState,
                        padding: EdgeInsets.symmetric(vertical: 10.sp),
                        // paginationControllerBloc:
                        //     paginationControllerBloc,
                        // payloadManagementBloc: payloadManagementBloc,
                        // status: status,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ======================================================================================================
  // Build Filter widget.

  Widget buildFilterWidget(Map<String, dynamic> assetData) {
    return Center(
      child: BlocBuilder<FilterAppliedBloc, FilterAppliedState>(
        builder: (context, state) {
          var count = state.filterAppliedCount;

          bool filterApplied = count != 0;

          return IconButton(
            onPressed: () async {
              // List status = tabBarList[countBloc.state.tabBarIndex]['key'];

              // List payloadStatus =
              //     payloadManagementBloc.state.payload['status'] ?? [];

              // bool equal = areArraysEqual(status, payloadStatus);

              // List values = status.map((e) {
              //   String? data = jobStatusList
              //       .singleWhere((element) => element['key'] == e)['value'];

              //   return {
              //     "name": data,
              //     "data": e,
              //   };
              // }).toList();

              await FilterWidgetHelpers().filterBottomSheet(
                isMobile: true,
                context: context,
                filterType: FilterType.jobs,
                initialValues: [
                  {
                    "key": "assets",
                    "identifier": assetData,
                    "values": [
                      {
                        "name": assetData['data']['displayName'],
                        "data": jsonEncode(assetData),
                      }
                    ]
                  }
                ],
                excludeFieldsKeys: ["assets"],
                useInitailValueRepeatly: true,
                saveButtonTap: (value) {
                  // if (value.isEmpty) {
                  //   DefaultTabController.of(context).animateTo(0);
                  // }
                },
              );
            },
            icon: Builder(builder: (context) {
              if (!filterApplied) {
                return const Icon(
                  Icons.filter_alt_off,
                  // color: Theme.of(context).colorScheme.secondary,
                );
              }

              return Badge.count(
                count: count,
                child: Icon(
                  filterApplied ? Icons.filter_alt : Icons.filter_alt_off,
                  color: Theme.of(context).primaryColor,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
