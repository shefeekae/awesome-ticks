import 'dart:async';
import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/ui/shared/functions/array_helpers.dart';
import 'package:awesometicks/ui/shared/widgets/app_update_alert.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_config/services/notifications/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/core/services/notifications/notification_controller.dart';
import 'package:awesometicks/ui/pages/home/widgets/jobs_list_builder.dart';
import 'package:awesometicks/ui/pages/job/job_search_screen.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../core/blocs/count/count_bloc.dart';
import '../../../core/blocs/internet/bloc/internet_available_bloc.dart';
import '../../../core/blocs/pagination controller/pagination_controller_bloc.dart';
import '../../../core/models/listalljobsmodel.dart';
import '../../../core/schemas/jobs_schemas.dart';
import '../job/job_details.dart';
import 'widgets/job_card.dart';
import 'package:app_filter_form/widgets/filter_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String id = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map> tabBarList = [
    {
      "title": "All",
      "key": [
        // "OPEN",
        // "REGISTERED",
        "SCHEDULED",
        "RESCHEDULED",
        "INPROGRESS",
        "WAITINGFORPARTS",
        "NOACCESS",
        "HELD",
        "TRANSFERRED_TO_VENDOR",
        "COMPLETED",
      ],
    },
    {
      "title": "Inprogress",
      "key": [
        "SCHEDULED",
        "INPROGRESS",
        "WAITINGFORPARTS",
        "NOACCESS",
        "HELD",
      ],
    },
    {
      "title": "Completed",
      "key": [
        "COMPLETED",
        "CANCELLED",
      ],
    },
  ];

  int tabbarIndex = 0;

  DateTime now = DateTime.now();

  List<Map> jobStatusList = [
    {"key": "OPEN", "value": "Open"},
    {"key": "REGISTERED", "value": "Registered"},
    {"key": "SCHEDULED", "value": "Scheduled"},
    {"key": "RESCHEDULED", "value": "Rescheduled"},
    {"key": "TRANSFERRED_TO_VENDOR", "value": "Transferred to vendor"},
    {"key": "INPROGRESS", "value": "In progress"},
    {"key": "HELD", "value": "Held"},
    {"key": "NOACCESS", "value": "No Access"},
    {"key": "WAITINGFORPARTS", "value": "Waiting for parts"},
    {"key": "ACCESSGRANTED", "value": "Access Granted"},
    {"key": "PARTSAPPROVED", "value": "Parts Approved"},
    {"key": "CANCELLED", "value": "Cancelled"},
    {"key": "COMPLETED", "value": "Completed"},
    {"key": "CLOSED", "value": "Closed"}
  ];

  late FilterSelectionBloc filterSelectionBloc;
  late FilterAppliedBloc filterAppliedBloc;
  late PayloadManagementBloc payloadManagementBloc;
  late CountBloc countBloc;
  late PaginationControllerBloc paginationControllerBloc;

  late Timer timer;

  UserDataSingleton userDataSingleton = UserDataSingleton();

  @override
  void initState() {
    filterAppliedBloc = BlocProvider.of<FilterAppliedBloc>(context);

    filterAppliedBloc.state.filterAppliedCount = 1;

    filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);

    payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);
    countBloc = BlocProvider.of<CountBloc>(context);
    paginationControllerBloc =
        BlocProvider.of<PaginationControllerBloc>(context);

    NotificationService().checkNotificationPermission();
    NotificationController.startListeningNotificationEvents();

    // SyncingServices().listenForInternet(context);

    payloadManagementBloc.state.payload = {
      "status": JobsServices.initialStatusList,
    };

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    filterSelectionBloc.state.filterLabelsMap[FilterType.jobs] = [];
    filterAppliedBloc.add(UpdateFilterAppliedCount(count: 0));
    filterSelectionBloc.state.filterValueMap[FilterType.jobs] = [];
    filterAppliedBloc.state.filterAppliedCount = 0;

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppUpdateAlert(
      enabled: false,
      child: DefaultTabController(
        length: tabBarList.length,
        initialIndex: 0,
        child: Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SafeArea(
            bottom: false,
            child: Scaffold(
              backgroundColor: kWhite,
              body: Column(
                children: [
                  buildHeaderContainer(context),
                  PermissionChecking(
                    featureGroup: "jobManagement",
                    feature: "job",
                    permission: "list",
                    showNoAccessWidget: true,
                    paddingTop: 10.sp,
                    child: buildTabBarAndTabbarView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =================================================================================================================================
  // Tab bar view data

  Widget buildTabBarAndTabbarView() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    automaticIndicatorColorAdjustment: mounted,
                    indicatorWeight: 3.sp,
                    padding: EdgeInsets.zero,
                    // labelPadding: EdgeInsets.symmetric(horizontal: 8.sp),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: RoundedTabIndicator(
                      borderRadius: 5.sp,
                      height: 3.sp,
                      accentColor: Theme.of(context).primaryColor,
                    ),
                    labelColor: Colors.black,
                    splashBorderRadius: BorderRadius.circular(5.sp),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.secondary,
                    dividerColor: Colors.blue,
                    tabs: List.generate(
                      tabBarList.length,
                      (index) {
                        var map = tabBarList[index];

                        String title = map['title'];

                        return BlocBuilder<CountBloc, CountState>(
                          builder: (context, state) {
                            int tabBarIndex = state.tabBarIndex;
                            // DefaultTabController.of(context).index;

                            bool selected = tabBarIndex == index;

                            int count = state.count;

                            if (count == 0) {
                              return Tab(
                                height: 30.sp,
                                text: title,
                              );
                            }

                            return Tab(
                              height: 30.sp,
                              iconMargin: EdgeInsets.zero,
                              child: selected
                                  ? FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              color: kBlack,
                                              fontSize: 10.sp,
                                              // selected ? FontWeight.bold : null,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Badge.count(
                                            count: count,
                                          )
                                        ],
                                      ),
                                    )
                                  : Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                buildFilterWidget(),
              ],
            ),
            Expanded(
              child: TabBarView(
                // controller: _tabController,
                children: List.generate(
                  tabBarList.length,
                  (index) {
                    Map map = tabBarList[index];

                    return Builder(builder: (context) {
                      bool contains = payloadManagementBloc.state.payload
                          .containsKey("status");

                      if (!contains) {
                        int count = filterAppliedBloc.state.filterAppliedCount;
                        filterAppliedBloc
                            .add(UpdateFilterAppliedCount(count: count + 1));
                      }

                      payloadManagementBloc.state.payload['status'] =
                          map['key'];

                      countBloc.state.tabBarIndex = index;

                      return buildTabbarViewWidget();
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // =============================================================================================================
  // Today Tasks widgets.

  Widget buildTodayTasksHandler() {
    DateTime startDate = DateTime(now.year, now.month, now.day);

    // Set the time to the end of the day (just before midnight of the next day)
    DateTime endDate = DateTime(now.year, now.month, now.day + 1)
        .subtract(const Duration(milliseconds: 1));

    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder(
          future: Connectivity().checkConnectivity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }

            ConnectivityResult connectivityResult = snapshot.data!;

            if (connectivityResult == ConnectivityResult.none) {
              Box<JobDetailsDb> box = jobDetailsDbgetBox();

              // DateTime today = DateTime(now.year, now.month, now.day);

              var items = box.values.where((element) {
                DateTime jobStartTime =
                    DateTime.fromMillisecondsSinceEpoch(element.jobStartTime!);
                // DateTime jobEndTime = DateTime.fromMillisecondsSinceEpoch(
                //     element.expectedEndTime!);

                return jobStartTime.isAfter(startDate) &&
                    jobStartTime.isBefore(endDate);
              });

              int scheduledCount = items
                  .where((element) => element.status == "SCHEDULED")
                  .length;

              int inprogressCount = items
                  .where((element) => element.status == "COMPLETED")
                  .length;

              return buildTodayTaskswidget(
                scheduledCount,
                inprogressCount,
              );
            }

            return FutureBuilder(
              future: GraphqlServices().performQuery(
                  query: JobsSchemas.getJobCountCategorisedToDaysQuery,
                  variables: {
                    "data": {
                      "startDate": startDate.millisecondsSinceEpoch,
                      "endDate": endDate.millisecondsSinceEpoch,
                      "status": JobsServices.initialStatusList,
                      "domain": userDataSingleton.domain,
                    }
                  }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildTodayTaskswidget(0, 0);
                }

                var result = snapshot.data;

                if (result!.hasException) {
                  return GraphqlServices().handlingGraphqlExceptions(
                    result: result,
                    context: context,
                    setState: setState,
                  );
                }

                JobsServices().storeReasonsToLocalDb();

                List list = result.data?['getJobCountCategorisedToDays'] ?? [];

                if (list.isEmpty) {
                  return buildTodayTaskswidget(0, 0);
                }

                var map = list.where((element) {
                  DateTime date =
                      DateTime.fromMillisecondsSinceEpoch(element['date']);

                  return date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                }).first;

                int totalCompleted = map['totalCompleted'] ?? 0;
                int totalJobs = map['total'] ?? 0;

                return buildTodayTaskswidget(
                  totalJobs,
                  totalCompleted,
                );
              },
            );
          },
        );
      },
    );
  }

  //===============================================================================================
  //

  Column buildTodayTaskswidget(int scheduledCount, int completedCount) {
    Color accentColor = Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "You have ",
            style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontSize: 15.sp,
            ),
            children: [
              TextSpan(
                text: scheduledCount.toString(),
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: " task today",
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.sp,
        ),
        RichText(
          text: TextSpan(
            text: "$completedCount",
            style: TextStyle(
              color: accentColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: " tasks completed",
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================================================================
  // Tabbar with filter.

  // Widget buildTabBarsandData() {
  //   return StatefulBuilder(builder: (context, tabBarSetState) {
  //     return Expanded(
  //       child: Column(
  //         children: [
  //           buildTabBarCustomTabbar(context, tabBarSetState),
  //           SizedBox(
  //             height: 5.sp,
  //           ),
  //           buildListallJobsmanagingwidget(tabBarSetState)
  //         ],
  //       ),
  //     );
  //   });
  // }

  // =========================================================================
  //

  BlocBuilder<InternetAvailableBloc, InternetAvailableState>
      buildTabbarViewWidget() {
    return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
      builder: (context, state) {
        if (!state.isInternetAvailable) {
          return buildfetchingallJobsFromLocalDb();
        }

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
                "hasInTeam": true,
                ...state.payload,
              },
            };

            return StatefulBuilder(
              builder: (context, refreshState) => FutureBuilder(
                future: GraphqlServices().performQuery(
                  query: JobsSchemas.listAllJobsQuery,
                  variables: variables,
                ),
                builder: (context, snapshot) {
                  countBloc.add(ChangeCountEvent(count: 0));

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
                    );
                  }

                  var listallJobs = ListAllJobsModel.fromJson(result.data!);

                  var list =
                      listallJobs.listAllJobsWithPaginationSortSearch?.items ??
                          [];

                  paginationControllerBloc.state.result = list;
                  paginationControllerBloc.state.currentPage = 0;
                  paginationControllerBloc.state.isCompleted = false;

                  int totalCount = listallJobs
                          .listAllJobsWithPaginationSortSearch?.totalItems ??
                      0;

                  countBloc.add(ChangeCountEvent(count: totalCount));

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
              ),
            );
          },
        );
      },
    );
  }

  // BlocBuilder<InternetAvailableBloc, InternetAvailableState>
  //     buildListallJobsmanagingwidget(StateSetter tabBarSetState) {
  //   return BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
  //     builder: (context, state) {
  //       if (!state.isInternetAvailable) {
  //         return buildfetchingallJobsFromLocalDb();
  //       }

  //       return BlocBuilder<PayloadManagementBloc, PayloadManagementState>(
  //         builder: (context, state) {
  //           Map<String, dynamic> variables = {
  //             "queryParam": {
  //               "page": 0,
  //               "size": 10,
  //               "sort": "jobStartTime,desc",
  //             },
  //             "data": {
  //               "domain": userDataSingleton.domain,
  //               "hasInTeam": true,
  //               ...state.payload,
  //             }
  //           };

  //           print("variables: $variables");

  //           return StatefulBuilder(
  //             builder: (context, refreshState) => FutureBuilder(
  //               future: GraphqlServices().performQuery(
  //                 query: JobsSchemas.listAllJobsQuery,
  //                 variables: variables,
  //               ),
  //               builder: (context, snapshot) {
  //                 countBloc.add(ChangeCountEvent(count: 0));

  //                 if (snapshot.connectionState == ConnectionState.waiting) {
  //                   return Expanded(
  //                     child: BuildShimmerLoadingWidget(
  //                       height: 15.h,
  //                       padding: EdgeInsets.symmetric(vertical: 10.sp),
  //                     ),
  //                   );
  //                 }

  //                 var result = snapshot.data;

  //                 if (result == null) {
  //                   return const Center(
  //                     child: Text("Error loading data"),
  //                   );
  //                 }

  //                 if (result.hasException) {
  //                   return GraphqlServices().handlingGraphqlExceptions(
  //                     result: result,
  //                     context: context,
  //                     setState: refreshState,
  //                   );
  //                 }

  //                 var listallJobs = ListAllJobsModel.fromJson(result.data!);

  //                 var list =
  //                     listallJobs.listAllJobsWithPaginationSortSearch?.items ??
  //                         [];

  //                 paginationControllerBloc.state.result = list;
  //                 paginationControllerBloc.state.currentPage = 0;
  //                 paginationControllerBloc.state.isCompleted = false;

  //                 int totalCount = listallJobs
  //                         .listAllJobsWithPaginationSortSearch?.totalItems ??
  //                     0;

  //                 countBloc.add(ChangeCountEvent(count: totalCount));

  //                 JobsServices().listAlljobsStoreToLocalDb();
  //                 // JobsServices().storeReasonsToLocalDb();

  //                 // totalItemsValueNotifier.value = totalCount;
  //                 // totalItemsValueNotifier.notifyListeners();

  //                 if (list.isEmpty) {
  //                   return Expanded(
  //                     child: Center(
  //                       child: Lottie.asset(
  //                         "assets/lotties/134394-no-transaction.json",
  //                         repeat: false,
  //                         width: 70.w,
  //                         height: 50.h,
  //                       ),
  //                     ),
  //                   );
  //                 }

  //                 return Expanded(
  //                   child: RefreshIndicator.adaptive(
  //                     onRefresh: () async {
  //                       setState(() {});
  //                     },
  //                     child: JobListviewBuilder(
  //                       setState: refreshState,
  //                       // paginationControllerBloc:
  //                       //     paginationControllerBloc,
  //                       // payloadManagementBloc: payloadManagementBloc,
  //                       // status: status,
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // ===========================================================================================
  // ValueListenableBuilder

  Widget buildfetchingallJobsFromLocalDb() {
    return BlocBuilder<PayloadManagementBloc, PayloadManagementState>(
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: jobDetailsDbgetBox().listenable(),
          builder: (context, box, child) {
            List<JobDetailsDb> jobDetailsList = box.values.toList();

            List<Items> items = [];

            jobDetailsList.sort(
              (a, b) {
                return b.jobStartTime!.compareTo(a.jobStartTime!);
              },
            );

            for (var element in jobDetailsList) {
              items.add(Items.fromJson(element.toJson()));
            }

            // if (status == "hold") {
            //   items = items
            //       .where((element) =>
            //           element.status == "HELD" ||
            //           element.status == "NOACCESS" ||
            //           element.status == "WAITINGFORPARTS")
            //       .toList();

            //   // ["HELD", "NOACCESS", "WAITINGFORPARTS"];
            // } else if (status.isNotEmpty) {
            //   items =
            //       items.where((element) => element.status == status).toList();
            // }

            List<String> status = payloadManagementBloc.state.payload['status'];

            items = items.where((element) {
              return status.any((e) => e == element.status);
            }).toList();

            // String value = state.payload['jobName'] ?? "";

            // // =========================================================================
            // // If the search value is empty returning all values.
            // List<Items> searchedList = items.where((element) {
            //   String jobName = element.jobName ?? "";
            //   String jobId = element.id == null ? "" : element.id.toString();

            //   return jobName.toLowerCase().contains(value) ||
            //       jobId.toLowerCase().contains(value);
            // }).toList();

            countBloc.add(ChangeCountEvent(count: items.length));

            if (items.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: 0.h),
                child: Center(
                  child: Lottie.asset(
                    "assets/lotties/134394-no-transaction.json",
                    repeat: false,
                  ),
                ),
              );
            }

            return RefreshIndicator.adaptive(
              onRefresh: () async {
                // setState(
                //   () {},
                // );
              },
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 5.sp,
                  );
                },
                itemBuilder: (context, index) {
                  Items item = items[index];

                  return BuildJobCardWidget(
                    item: item,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        JobDetailsScreen.id,
                        arguments: {
                          "jobId": item.id,
                          // "jobName": item.jobName ?? "N/A",
                          // "status": item.status ?? "",
                          // "criticality": item.criticality ?? "",
                        },
                      );

                      // widget.setState(
                      //   () {},
                      // );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ========================================================================================================
  // ========================================================================================================

  Widget buildTabBarCustomTabbar(
    BuildContext context,
    StateSetter setState,
  ) {
    ItemScrollController scrollController = ItemScrollController();

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 30.sp,
            child: ScrollablePositionedList.separated(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemScrollController: scrollController,
              itemBuilder: (context, index) {
                bool selected = tabbarIndex == index;

                Map map = tabBarList[index];

                String title = map['title'];
                List<String> statusList = map['key'];

                return GestureDetector(
                  onTap: () {
                    scrollController.scrollTo(
                        index: index,
                        duration: const Duration(milliseconds: 500));
                    // countBloc.state.count = 0;
                    if (tabbarIndex != index) {
                      setState(
                        () {
                          tabbarIndex = index;
                          payloadManagementBloc.state.payload['status'] =
                              statusList;
                        },
                      );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selected
                            ? Row(
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 10.sp,
                                      fontWeight:
                                          selected ? FontWeight.bold : null,
                                    ),
                                  ),
                                  BlocBuilder<CountBloc, CountState>(
                                    builder: (context, state) {
                                      int count = state.count;

                                      if (count == 0) {
                                        return const SizedBox();
                                      }

                                      return Row(
                                        children: [
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Badge.count(
                                            count: count,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            textColor: Colors.black,
                                          )
                                        ],
                                      );
                                    },
                                  )
                                ],
                              )
                            : Text(
                                title,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: selected ? FontWeight.bold : null,
                                ),
                              ),
                        SizedBox(
                          height: 5.sp,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.3),
                            borderRadius: selected
                                ? BorderRadius.circular(
                                    5.sp,
                                  )
                                : BorderRadius.circular(5.sp),
                          ),
                          width: 25.w,
                          height: 3.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 5.sp,
                );
              },
              itemCount: tabBarList.length,
            ),
          ),
        ),
        buildFilterWidget()
      ],
    );
  }

  // ======================================================================================================
  // Build Filter widget.

  Widget buildFilterWidget() {
    return Center(
      child: BlocBuilder<FilterAppliedBloc, FilterAppliedState>(
        builder: (context, state) {
          var count = state.filterAppliedCount;

          bool filterApplied = count != 0;

          return IconButton(
            onPressed: () async {
              List status = tabBarList[countBloc.state.tabBarIndex]['key'];

              List payloadStatus =
                  payloadManagementBloc.state.payload['status'] ?? [];

              bool equal = areArraysEqual(status, payloadStatus);

              List values = status.map((e) {
                String? data = jobStatusList
                    .singleWhere((element) => element['key'] == e)['value'];

                return {
                  "name": data,
                  "data": e,
                };
              }).toList();

              await FilterWidgetHelpers().filterBottomSheet(
                isMobile: true,
                context: context,
                filterType: FilterType.jobs,
                initialValues: equal
                    ? [
                        {
                          "key": "status",
                          "identifier": status,
                          "values": values,
                        }
                      ]
                    : [],
                useInitailValueRepeatly: true,
                saveButtonTap: (value) {
                  if (value.isEmpty) {
                    DefaultTabController.of(context).animateTo(0);
                  }
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

  // // ==================================================================================
  // Widget buildCustomCard(
  //   BuildContext context, {
  //   required String title,
  //   required IconData iconData,
  //   required String subTitle,
  // }) {
  //   return GestureDetector(
  //     onTap: () {
  //       // Navigator.of(context).pushNamed(JobListScreen.id);
  //     },
  //     child: Card(
  //       elevation: 5,
  //       child: Container(
  //         width: 45.w,
  //         decoration: BoxDecoration(
  //           color: kWhite,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         padding: EdgeInsets.all(10.sp),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     color: Theme.of(context).colorScheme.secondary,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 12.sp,
  //                   ),
  //                 ),
  //                 Spacer(),
  //                 Icon(
  //                   iconData,
  //                   color: Colors.red.shade800.withOpacity(0.3),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 10.sp,
  //             ),
  //             Center(
  //               child: Text(
  //                 "30",
  //                 style: TextStyle(
  //                   fontSize: 25.sp,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 10.sp,
  //             ),
  //             Align(
  //               alignment: Alignment.centerRight,
  //               child: RichText(
  //                 text: TextSpan(
  //                   text: "16",
  //                   style: TextStyle(
  //                     color: Theme.of(context).colorScheme.secondary,
  //                   ),
  //                   children: [
  //                     TextSpan(
  //                       text: " $subTitle",
  //                       style: TextStyle(
  //                         color: Colors.grey,
  //                         fontSize: 8.sp,
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // =============================================================================
  Widget buildProgressBarWidget({required double value}) {
    return Container(
      height: 10.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        // color: fwhite,
        color: fwhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        alignment: Alignment.bottomLeft,
        child: Container(
          height: 10.sp,
          decoration: BoxDecoration(
            // color: fwhite,
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ================================================================================

  Container buildHeaderContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 30.h,
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor,
        gradient: getGradientColors(context),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30.sp),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "AwesomeTicks",
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                PermissionChecking(
                  featureGroup: "jobManagement",
                  feature: "job",
                  permission: "list",
                  child: IconButton(
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: JobsSearchDelegate(
                            paginationControllerBloc: paginationControllerBloc,
                            payloadManagementBloc: payloadManagementBloc,
                          ));
                    },
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
            PermissionChecking(
              featureGroup: "jobManagement",
              feature: "job",
              permission: "list",
              child: buildTodayTasksHandler(),
            ),
            SizedBox(
              height: 10.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================================
  // Showing the text field to search the jobs.

  Widget buildSearchTextfield(
      TextEditingController searchTextEditingController) {
    return SizedBox(
      height: 25.sp,
      child: TextField(
        controller: searchTextEditingController,
        cursorHeight: 13.sp,
        focusNode: FocusNode(),
        autofocus: true,
        onChanged: (value) {
          Map<String, dynamic> payload = payloadManagementBloc.state.payload;

          payload['jobName'] = searchTextEditingController.text.trim();

          EasyDebounce.debounce(
              "search-jobs", const Duration(milliseconds: 500), () {
            payloadManagementBloc.add(
              ChangePayloadEvent(payload: payload),
            );
          });
        },
        decoration: InputDecoration(
          focusColor: kWhite,
          fillColor: kWhite,
          filled: true,
          hintText: "Search",
          contentPadding: EdgeInsets.symmetric(horizontal: 5.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.sp),
          ),
        ),
      ),
    );
  }
}

class RoundedTabIndicator extends Decoration {
  final double borderRadius;
  final double height;
  final Color accentColor;

  RoundedTabIndicator(
      {required this.borderRadius,
      required this.height,
      required this.accentColor});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedTabIndicatorPainter(
        this, onChanged, borderRadius, height, accentColor);
  }
}

class _RoundedTabIndicatorPainter extends BoxPainter {
  final RoundedTabIndicator decoration;
  final double borderRadius;
  final double height;
  final Color accentColor;

  _RoundedTabIndicatorPainter(this.decoration, VoidCallback? onChanged,
      this.borderRadius, this.height, this.accentColor)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint();
    paint.color = accentColor;
    // decoration.color!;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left + 16.0, // Adjust the left padding as needed
          rect.bottom - height,
          rect.width - 32.0, // Adjust the total width and padding as needed
          height,
        ),
        Radius.circular(
            8.0), // Adjust the radius value to set the border radius
      ),
      paint,
    );
  }
}
