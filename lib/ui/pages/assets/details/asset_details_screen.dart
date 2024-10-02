import 'dart:convert';

import 'package:app_filter_form/core/blocs/filter/filter%20applied/filter_applied_bloc.dart';
import 'package:app_filter_form/core/blocs/filter/filter_selection/filter_selection_bloc.dart';
import 'package:app_filter_form/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:app_filter_form/core/services/form_filter_enum.dart';
import 'package:app_filter_form/widgets/filter_widgets.dart';
import 'package:awesometicks/core/models/list_alarms_model.dart';
import 'package:awesometicks/core/models/list_service_request_model.dart';
import 'package:awesometicks/core/schemas/alarms_schemas.dart';
import 'package:awesometicks/core/schemas/assets_schemas.dart';
import 'package:awesometicks/core/schemas/service_request_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/core/services/theme_services.dart';
import 'package:awesometicks/core/services/wkt_services.dart';
import 'package:awesometicks/ui/pages/assets/details/data_update_screen.dart';
import 'package:awesometicks/ui/pages/assets/details/widgets/alarm_card.dart';
import 'package:awesometicks/ui/pages/assets/details/widgets/job_list_widget.dart';
import 'package:awesometicks/ui/pages/assets/details/widgets/service_request_list_widget.dart';
import 'package:awesometicks/ui/shared/functions/array_helpers.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:data_collection_package/data_collection_package.dart'
    as dataCollection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:user_permission/services/user_permission_services.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
import '../../../../core/models/assets/asset_info_model.dart';
import '../../../../core/models/job_get_count_categorised_model.dart';
import '../../../../core/services/platform_services.dart';
import '../../job/job_details.dart';
import '../../job/widgets/details_card.dart';
import 'functions/get_assets_info_list.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({super.key});

  static const String id = "asset/details";

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  ValueNotifier<int> tabIndexValueNotifier = ValueNotifier<int>(0);

  List<Map<String, dynamic>> horizontalItemsList = [
    {
      "title": "Details",
      "key": "details",
    },
    {
      "title": "Alarms",
      "key": "alarms",
    },
    {
      "title": "Job Trends",
      "key": "trends",
    },
    {
      "title": "Jobs",
      "key": "jobs",
    },
    {
      "title": "Service requests",
      "key": "serviceRequests",
    },
  ];

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

  int selectedIndex = 0;

  late Map<String, dynamic> assetEntity;

  String? domain;

  String? identifier;

  String? type;

  String? displayName;

  UserDataSingleton userData = UserDataSingleton();

  final UserPermissionServices userPermissionServices =
      UserPermissionServices();

  late bool alarmsListPermission, trendsPermission;

  late PayloadManagementBloc payloadManagementBloc;
  late FilterSelectionBloc filterSelectionBloc;
  late FilterAppliedBloc filterAppliedBloc;

  @override
  void initState() {
    filterAppliedBloc = BlocProvider.of<FilterAppliedBloc>(context);

    // filterAppliedBloc.state.filterAppliedCount = 1;

    filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);

    payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);

    alarmsListPermission = userPermissionServices.checkingPermission(
      featureGroup: "alarmManagement",
      feature: "list",
      permission: "list",
    );

    trendsPermission = userPermissionServices.checkingPermission(
      featureGroup: "jobManagement",
      feature: "jobInsights",
      permission: "view",
    );

    if (!alarmsListPermission) {
      horizontalItemsList.removeWhere((element) => element['key'] == "alarms");
    }

    if (!trendsPermission) {
      horizontalItemsList.removeWhere((element) => element['key'] == "trends");
    }

    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    assetEntity = args['asset'];

    type = assetEntity['type'];
    identifier = assetEntity['data']?['identifier'];
    domain = assetEntity['data']?['domain'];

    Map<String, dynamic> assetData = {
      "type": type,
      "data": {
        "domain": domain,
        "identifier": identifier,
        "displayName": args['name'],
      }
    };

    return Scaffold(
      appBar: GradientAppBar(
        title: args['name'] ?? "Asset Details",
      ),
      // appBar: AppBar(
      //   // title: Text(args['name'] ?? "Asset Details"),
      // ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   var result = await GraphqlServices().performQuery(
      //     query: ServiceRequestSchemas.getLastServiceInfoQuery,
      //     variables: {
      //       "identifier": identifier,
      //       "jobType": "Service",
      //       "jobStatus": "CLOSED",
      //     },
      //   );

      //   if (result.hasException) {
      //     print(result.exception);
      //     return;
      //   }
      //   print(result.data);
      // }),
      body: PermissionChecking(
        featureGroup: "assetManagement",
        feature: "assetList",
        permission: "view",
        showNoAccessWidget: true,
        paddingTop: 10.sp,
        child: Padding(
          padding: EdgeInsets.all(5.sp),
          child: QueryWidget(
              options: GraphqlServices().getQueryOptions(
                query: AssetSchema.findAssetSchema,
                variables: {
                  "identifier": identifier,
                  "type": type,
                  "domain": domain,
                },
              ),
              // future: GraphqlServices().performQuery(
              //   query: AssetSchema.findAssetSchema,
              //   variables: {
              //     "identifier": identifier,
              //     "type": type,
              //     "domain": domain,
              //   },
              // ),

              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return BuildShimmerLoadingWidget(
                    height: 50.sp,
                    seperatedHeight: 4.sp,
                  );
                }

                if (result.hasException) {
                  return GraphqlServices().handlingGraphqlExceptions(
                    result: result,
                    context: context,
                    refetch: refetch,
                  );
                }

                AssetInfoModel assetInfoModel =
                    assetInfoModelFromJson(result.data ?? {});

                FindAsset? findAsset = assetInfoModel.findAsset;

                dataCollection.FindAssetModel findAssetModel =
                    dataCollection.FindAssetModel.fromJson(result.data ?? {});

                return ValueListenableBuilder(
                    valueListenable: tabIndexValueNotifier,
                    builder: (context, tabIndex, child) {
                      selectedIndex = tabIndex;

                      return Column(
                        children: [
                          SizedBox(
                            height: 5.sp,
                          ),
                          buildHorizontalButtons(),
                          SizedBox(
                            height: 5.sp,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                  visible: horizontalItemsList[selectedIndex]
                                              ['key'] ==
                                          'jobs' ||
                                      horizontalItemsList[selectedIndex]
                                              ['key'] ==
                                          'serviceRequests',
                                  child:
                                      buildFilterWidget(assetData, setState)),
                            ],
                          ),
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: tabIndexValueNotifier,
                              builder: (context, tabIndex, child) {
                                String key =
                                    horizontalItemsList[tabIndex]['key'];

                                if (key == "details") {
                                  return buildDetailsWidget(
                                      findAsset, findAssetModel);
                                } else if (key == "alarms") {
                                  return buildAlarmsBuilder();
                                } else if (key == "trends") {
                                  return buildTrends();
                                } else if (key == "jobs") {
                                  return AssetJobListWidget(
                                    domain: domain ?? "",
                                    resourceId: identifier ?? "",
                                    type: type ?? "",
                                  );
                                } else if (key == "serviceRequests") {
                                  return AssetServiceRequestWidget(
                                    domain: domain ?? "",
                                    resourceId: identifier ?? "",
                                    assetData: assetData,
                                  );
                                }

                                //  else if (key == "dataCollection") {
                                //   return dataCollection.AddDataForm(
                                //       latestPoints: latestPoints,
                                //       assetType: assetType,
                                //       domain: assetDomain,
                                //       identifier: assetIdentifier,
                                //       sourceId: sourceId);
                                // }

                                return const SizedBox();
                              },
                            ),
                          )
                        ],
                      );
                    });
              }),
        ),
      ),
    );
  }

  // ===========================================================
  // Showing bar chart of the month.

  Widget buildTrends() {
    DateTime now = DateTime.now();

    DateTime startDate = DateTime(now.year, now.month, 1);

    DateTime endDate = DateTime(now.year, now.month + 1, 0);

    TextStyle dateTextStyle = TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w600,
    );

    return StatefulBuilder(builder: (context, setState) {
      String pattern = "dd MMM yyyy";

      String formatedStartDate = DateFormat(pattern).format(startDate);

      String formatedEndDate = DateFormat(pattern).format(endDate);
      return Column(
        children: [
          SizedBox(
            height: 5.sp,
          ),
          buildDateRangeButtonsWidget(
            formatedStartDate: formatedStartDate,
            dateTextStyle: dateTextStyle,
            formatedEndDate: formatedEndDate,
            onTap: () async {
              DateTimeRange? dateTimeRange = await PlatformServices()
                  .showPlatformDateRange(
                      context, DateTimeRange(start: startDate, end: endDate));
              if (dateTimeRange != null) {
                setState(
                  () {
                    startDate = dateTimeRange.start;
                    endDate = dateTimeRange.end;
                  },
                );
              }
            },
          ),
          // SizedBox(
          //   height: 0.sp,
          // ),
          Expanded(
            child: FutureBuilder(
                future: GraphqlServices().performQuery(
                  query: AssetSchema.getJobCountCategorisedToDaysQuery,
                  variables: {
                    "data": {
                      "startDate": startDate.millisecondsSinceEpoch,
                      "endDate": endDate.millisecondsSinceEpoch,
                      "domain": userData.domain,
                      "resources": [
                        assetEntity,
                      ]
                    }
                  },
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Stack(
                      children: [
                        LoadingIosAndroidWidget(
                          radius: 20.sp,
                        ),
                        SfCartesianChart(),
                      ],
                    );
                  }

                  var result = snapshot.data!;

                  if (result.hasException) {
                    return GraphqlServices().handlingGraphqlExceptions(
                      result: result,
                      context: context,
                      setState: setState,
                    );
                  }

                  var model =
                      GetJobCountCategorisedModel.fromJson(result.data!);

                  var totalJobs = model.getJobCountCategorisedToDays ?? [];

                  totalJobs = totalJobs
                      .where((element) =>
                          element.total != null && element.total != 0)
                      .toList();

                  return SfCartesianChart(
                    // enableAxisAnimation: true,
                    // Columns will be rendered back to back

                    legend: Legend(
                      isVisible: true,
                      // height: "20",
                      // isResponsive: true,
                      // height: "80%",
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    onLegendItemRender: (args) {
                      // print(args.seriesIndex);
                      if (args.seriesIndex == 0) {
                        args.color = Theme.of(context).primaryColor;
                      } else if (args.seriesIndex == 1) {
                        args.color = Colors.green;
                      }
                    },
                    enableSideBySideSeriesPlacement: false,
                    primaryXAxis: CategoryAxis(
                      // labelStyle: TextStyle(fontSize: 200),
                      // maximumLabels: 100,
                      autoScrollingDelta: 5,
                      autoScrollingMode: AutoScrollingMode.start,
                      // majorGridLines: MajorGridLines(width: 0),
                      // majorTickLines: MajorTickLines(width: 0),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    primaryYAxis: NumericAxis(
                        // minimum: 1.0,
                        majorGridLines: const MajorGridLines(
                      width: 0,
                    )),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      enablePinching: true,
                    ),
                    series: <ChartSeries>[
                      ColumnSeries<_ChartData, String>(
                        name: "Total Jobs",
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                        width: 0.4,
                        dataSource: List.generate(
                          totalJobs.length,
                          (index) {
                            var data = totalJobs[index];

                            DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                    data.date ?? 0);

                            String formatedDate =
                                DateFormat("MMM d").format(dateTime);

                            double total = data.total?.toDouble() ?? 0.0;

                            return _ChartData(formatedDate, total);
                          },
                        ),
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                        pointColorMapper: (datum, index) =>
                            Theme.of(context).primaryColor,
                        emptyPointSettings: EmptyPointSettings(
                          // Mode of empty point
                          mode: EmptyPointMode.average,
                        ),
                      ),
                      buildLineSeriesChart(
                        getJobCountCategorisedToDaysList: totalJobs,
                        name: "Total Closed",
                        key: "closed",
                        lineColor: Colors.green,
                      ),
                      // buildLineSeriesChart(
                      //   getJobCountCategorisedToDaysList: totalJobs,
                      //   name: "Total Cancelled",
                      //   key: "cancelled",
                      //   lineColor: Colors.red.shade500,
                      // ),
                      // buildLineSeriesChart(
                      //   getJobCountCategorisedToDaysList: totalJobs,
                      //   name: "Total Inprogress",
                      //   key: "inprogress",
                      //   lineColor: Colors.amber,
                      // ),
                    ],
                  );
                }),
          ),
        ],
      );
    });
  }

//  ===========================================================================================
// Build DateRange Buttons.

  GestureDetector buildDateRangeButtonsWidget(
      {required void Function()? onTap,
      required String formatedStartDate,
      required TextStyle dateTextStyle,
      required String formatedEndDate}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // height: 30.sp,
        margin: EdgeInsets.symmetric(horizontal: 7.sp),
        padding: EdgeInsets.all(7.sp),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(5),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                formatedStartDate,
                style: dateTextStyle,
              ),
              const VerticalDivider(
                width: 2,
              ),
              Text(
                formatedEndDate,
                style: dateTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================================================================================
  // Build Line Series.

  LineSeries<_ChartData, String> buildLineSeriesChart({
    required List<GetJobCountCategorisedToDays>
        getJobCountCategorisedToDaysList,
    required String name,
    required String key,
    required Color lineColor,
  }) {
    return LineSeries<_ChartData, String>(
      animationDuration: 300,
      markerSettings: const MarkerSettings(
        isVisible: true,
        color: kWhite,
      ),
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        textStyle: TextStyle(
          color: kWhite,
        ),
      ),
      // borderRadius: const BorderRadius.vertical(
      //   top: Radius.circular(3),
      // ),
      name: name,
      opacity: 0.9,
      width: 2.sp,
      dataSource: List.generate(
        getJobCountCategorisedToDaysList.length,
        (index) {
          var data = getJobCountCategorisedToDaysList[index];

          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(data.date ?? 0);

          String formatedDate = DateFormat("MMM d").format(dateTime);

          double jobs = 0.0;

          if (key == "completed") {
            jobs = data.totalCompleted?.toDouble() ?? 0.0;
          } else if (key == "cancelled") {
            jobs = data.totalCancelled?.toDouble() ?? 0.0;
          } else if (key == "inprogress") {
            jobs = data.totalInProgress?.toDouble() ?? 0.0;
          } else if (key == "closed") {
            jobs = data.closed?.toDouble() ?? 0.0;
          }

          return _ChartData(formatedDate, jobs);
        },
      ),
      xValueMapper: (_ChartData data, _) => data.x,
      yValueMapper: (_ChartData data, _) => data.y,
      pointColorMapper: (datum, index) => lineColor,
      emptyPointSettings: EmptyPointSettings(
        // Mode of empty point
        mode: EmptyPointMode.average,
      ),
    );
  }

  // ===========================================================================================
  // Showing the asset against alarms.

  Widget buildAlarmsBuilder() {
    return FutureBuilder(
        future: GraphqlServices().performQuery(
          query: AlarmsSchema.listAlarmsQuery,
          variables: {
            "filter": {
              "domain": userData.domain,
              // "offset": 1,
              // "pageSize": 20,
              "assets": [
                assetEntity,
              ],
              "status": ["active"],
              "criticalities": [],
              "workOrderStatus": "ALL",
              "groups": []
            }
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return GraphqlServices().loadingWidget();
            return BuildShimmerLoadingWidget();
          }

          QueryResult result = snapshot.data!;

          if (result.hasException) {
            return GraphqlServices().handlingGraphqlExceptions(
              result: result,
              context: context,
              setState: setState,
            );
          }

          ListAlarmsModel listAlarmsModel =
              ListAlarmsModel.fromJson(result.data!);

          List<EventLogs> eventLogs = listAlarmsModel.listAlarms!.eventLogs!;

          if (eventLogs.isEmpty) {
            return const Center(
              child: Text("No data to show"),
            );
          }

          return ListView.separated(
            itemCount: eventLogs.length,
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 10.sp,
              );
            },
            itemBuilder: (context, index) {
              return AlarmCardWidget(
                eventLog: eventLogs[index],
              );
            },
          );
        });
  }

  // ======================================================================================================
  // Build Filter widget.

  Widget buildFilterWidget(
      Map<String, dynamic> assetData, void Function(void Function()) setState) {
    return Center(
      child: BlocBuilder<FilterAppliedBloc, FilterAppliedState>(
        builder: (context, state) {
          var count = state.filterAppliedCount;

          bool filterApplied = count != 0;

          return IconButton(
            onPressed: () async {
              List status = [
                "SCHEDULED",
                "RESCHEDULED",
                "INPROGRESS",
                "WAITINGFORPARTS",
                "NOACCESS",
                "HELD",
                "TRANSFERRED_TO_VENDOR",
                "COMPLETED",
              ];

              // List payloadStatus =
              //     payloadManagementBloc.state.payload['status'] ?? [];

              // bool equal = areArraysEqual(status, payloadStatus);

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
                filterType: horizontalItemsList[selectedIndex]['key'] ==
                        'serviceRequests'
                    ? FilterType.serviceRequest
                    : FilterType.jobs,
                initialValues: [
                  // {
                  //   "key": "assets",
                  //   "identifier": assetData,
                  //   "values": [
                  //     {
                  //       "name": assetData['data']['displayName'],
                  //       "data": jsonEncode(assetData),
                  //     }
                  //   ]
                  // },
                  horizontalItemsList[selectedIndex]['key'] == 'serviceRequests'
                      ? {}
                      : {
                          "key": "status",
                          "identifier": status,
                          "values": values,
                        }
                ],
                excludeFieldsKeys: ["assets"],
                useInitailValueRepeatly: true,
                saveButtonTap: (value) {
                  horizontalItemsList[selectedIndex]['key'] == 'serviceRequests'
                      ? setState
                      : null;
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

  // ==================================================================================================
  Widget buildDetailsWidget(
      FindAsset? findAsset, dataCollection.FindAssetModel findAssetModel) {
    List<dataCollection.LatestPoint> latestPoints =
        findAssetModel.findAsset?.assetLatest?.points ?? [];

    String? assetType = findAssetModel.findAsset?.asset?.type;

    String? assetName = findAsset?.asset?.data?.displayName;

    String? sourceId = findAssetModel.findAsset?.device?.data?.sourceId;

    String? assetIdentifier = findAssetModel.findAsset?.asset?.data?.identifier;

    String? assetDomain = findAssetModel.findAsset?.asset?.data?.domain;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildServiceCardWidget(
              title: "Last Service",
              jobType: "Service",
            ),
            buildServiceCardWidget(
              title: "Last PPM Service",
              jobType: "PPM",
            ),
          ],
        ),
        SizedBox(
          height: 10.sp,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UpdateDataScreen(
                      latestPoints: latestPoints,
                      assetType: assetType,
                      domain: assetDomain,
                      assetName: assetName,
                      identifier: assetIdentifier,
                      sourceId: sourceId),
                ));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.update,
                    size: 15.sp,
                  ),
                  SizedBox(
                    width: 5.sp,
                  ),
                  Text(
                    "Update data",
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: ThemeServices().getPrimaryFgColor(context)),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                  )
                ],
              )),
        ),
        SizedBox(
          height: 10.sp,
        ),
        Expanded(
          child: StatefulBuilder(builder: (context, refreshState) {
            return Builder(
              builder: (context) {
                // print("Asset info result");
                // print(result.data);

                AssetData? assetData = findAsset?.asset?.data!;

                AssetLatest? assetLatest = findAsset?.assetLatest;

                List assetInfoList = getAssetsInfoList(
                  assetData: assetData,
                  assetLatest: assetLatest,
                );

                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.separated(
                    itemCount: assetInfoList.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 4.sp,
                      );
                    },
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = assetInfoList[index];

                      if (map['title'] == "Location") {
                        return GestureDetector(
                          onTap: () {
                            LatLng latLng =
                                WKTServices().parseWktPoint(map['value']);

                            String googleUrl =
                                'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}';

                            launchUrlString(googleUrl);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              child: Row(
                                children: [
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                      // color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      LatLng latLng = WKTServices()
                                          .parseWktPoint(map['value']);

                                      String googleUrl =
                                          'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}';

                                      launchUrlString(googleUrl);
                                    },
                                    icon: const Icon(
                                      Icons.location_on,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return BuildDetailsCard(
                        title: map['title'],
                        value: map['value'],
                      );
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

// ============================================
// Showing the Last PPM Service and Last Service.

  Widget buildServiceCardWidget({
    required String title,
    required String jobType,
  }) {
    return QueryWidget(
      options: GraphqlServices().getQueryOptions(
        query: ServiceRequestSchemas.getLastServiceInfoQuery,
        variables: {
          "identifier": identifier,
          "jobType": jobType,
          "jobStatus": "CLOSED",
        },
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return ShimmerLoadingContainerWidget(
            height: 30.sp,
          );
        }

        // if (result.hasException) {
        //   return GraphqlServices().handlingGraphqlExceptions(
        //     result: result,
        //     context: context,
        //     refetch: refetch,
        //   );
        // }

        Map<String, dynamic> data = result.data?['getLastServiceInfo'] ?? {};

        int dateMilliSeconds = data['actualEndTime'] == null
            ? data['expectedEndTime'] ?? 0
            : data['actualEndTime'] ?? 0;

        String foramtedDate = dateMilliSeconds == 0
            ? "Service not available"
            : DateFormat("dd MMM yyyy").add_jm().format(
                  DateTime.fromMillisecondsSinceEpoch(dateMilliSeconds),
                );

        return Bounce(
          duration: const Duration(milliseconds: 100),
          onPressed: () {
            int? jobId = data['id'];

            if (jobId != null) {
              Navigator.of(context).pushNamed(
                JobDetailsScreen.id,
                arguments: {
                  "jobId": jobId,
                  // "jobName": item.jobName ?? "N/A",
                  // "status": item.status ?? "",
                  // "criticality": item.criticality ?? "",
                },
              );
            }
          },
          child: Container(
            width: 45.w,
            padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 8.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.sp),
              // border: Border.all(width: 0.5),
              color: kWhite,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 10.sp,
                          // color: primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 10.sp,
                      ),
                      SizedBox(
                        height: 23.sp,
                        child: Text(
                          foramtedDate,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 8.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================================
  Widget buildHorizontalButtons() {
    return ValueListenableBuilder(
        valueListenable: tabIndexValueNotifier,
        builder: (context, tabIndex, child) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                horizontalItemsList.length,
                (index) {
                  var map = horizontalItemsList[index];

                  bool selected = tabIndex == index;

                  return GestureDetector(
                    onTap: () {
                      tabIndexValueNotifier.value = index;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.sp, vertical: 5.sp),
                      decoration: BoxDecoration(
                        color: selected ? kWhite : null,
                        borderRadius:
                            selected ? BorderRadius.circular(5.sp) : null,
                        border: selected ? Border.all(width: 0.1) : null,
                      ),
                      child: Center(
                        child: Text(
                          map['title'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: selected ? FontWeight.w700 : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
