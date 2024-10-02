import 'package:app_filter_form/core/blocs/filter/payload/payload_management_bloc.dart';
import 'package:awesometicks/core/blocs/internet/bloc/internet_available_bloc.dart';
import 'package:awesometicks/core/models/hive%20db/list_jobs_model.dart';
import 'package:awesometicks/ui/shared/functions/get_color_icons.dart';
import 'package:awesometicks/ui/shared/widgets/custom_app_bar.dart';
import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:user_permission/widgets/permission_checking_widget.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';

// import '../../../core/blocs/filter/payload/payload_management_bloc.dart';
import '../../../core/models/calendar_model.dart';
import '../../../core/models/listalljobsmodel.dart';
import '../../../core/schemas/jobs_schemas.dart';
import '../../../core/services/graphql_services.dart';
import 'package:secure_storage/services/shared_prefrences_services.dart';
import '../job/job_details.dart';

class JobCalendarScreen extends StatefulWidget {
  const JobCalendarScreen({super.key});

  static const String id = "job/calendar";

  @override
  State<JobCalendarScreen> createState() => _JobCalendarScreenState();
}

class _JobCalendarScreenState extends State<JobCalendarScreen> {
  late PayloadManagementBloc payloadManagementBloc;

  bool init = true;

//  This used to the calendar automatically calling the onView changed function.
// Bool using check the view changed automatically and do nothing.
  bool firstViewChanged = true;

  CalendarController calendarController = CalendarController();

  UserDataSingleton userData = UserDataSingleton();

  @override
  void initState() {
    payloadManagementBloc = BlocProvider.of<PayloadManagementBloc>(context);

    DateTime now = DateTime.now();

    DateTime startDayofMonth = DateTime(now.year, now.month, 1);

    DateTime lastDayofMonth = DateTime(now.year, now.month + 1, 0);

    payloadManagementBloc.state.payload = {
      "hasInTeam": true,
      "domain": userData.domain,
      "startDate": startDayofMonth.millisecondsSinceEpoch,
      "endDate": lastDayofMonth.millisecondsSinceEpoch,
    };

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: "Calendar",
        actions: [
          PermissionChecking(
            featureGroup: "jobManagement",
            feature: "job",
            permission: "list",
            child: IconButton(
              onPressed: () {
                firstViewChanged = true;

                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),

      // AppBar(
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: getGradientColors(context),
      //     ),
      //   ),
      //   title: const Text("Calendar"),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         firstViewChanged = true;

      //         setState(() {});
      //       },
      //       icon: const Icon(Icons.refresh),
      //     ),
      //   ],
      // ),
      body: PermissionChecking(
        featureGroup: "jobManagement",
        feature: "job",
        permission: "list",
        showNoAccessWidget: true,
        paddingTop: 10.sp,
        child: BlocBuilder<InternetAvailableBloc, InternetAvailableState>(
          builder: (context, state) {
            bool hasInternet = state.isInternetAvailable;

            if (!hasInternet) {
              return dataFetchfromLocalDb();
            }

            return BlocBuilder<PayloadManagementBloc, PayloadManagementState>(
              builder: (context, state) {
                return FutureBuilder(
                  future: GraphqlServices().performQuery(
                    query: JobsSchemas.listAllJobsQuery,
                    variables: {
                      "queryParam": {
                        "page": -1,
                        "size": 0,
                        "sort": "jobStartTime,desc",
                      },
                      "data": state.payload,
                    },
                  ),
                  builder: (context, snapshot) {
                    bool isLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    if (isLoading) {
                      return Stack(
                        children: [
                          LoadingIosAndroidWidget(
                            radius: 20,
                          ),
                          Opacity(
                            opacity: 0.3,
                            child: AbsorbPointer(
                              child: SfCalendar(
                                controller: calendarController,
                                view: CalendarView.month,
                                monthViewSettings:
                                    const MonthViewSettings(showAgenda: true),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    var result = snapshot.data!;

                    if (result.hasException) {
                      return GraphqlServices().handlingGraphqlExceptions(
                        result: result,
                        context: context,
                        setState: setState,
                        // refetch: refetch,
                      );
                    }

                    var listallJobs = ListAllJobsModel.fromJson(result.data!);

                    var list = listallJobs
                            .listAllJobsWithPaginationSortSearch?.items ??
                        [];

                    // return Text("data");
                    return buildCalendar(list, context);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ==============================================================================================
  // data showing when the user offline.

  ValueListenableBuilder<Box<JobDetailsDb>> dataFetchfromLocalDb() {
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

        return buildCalendar(items, context);
      },
    );
  }

  SfCalendar buildCalendar(List<Items> list, BuildContext context) {
    return SfCalendar(
      controller: calendarController,
      view: CalendarView.month,
      initialSelectedDate: DateTime.now(),
      dataSource: MeetingDataSource(_getDataSource(list)),
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        // showTrailingAndLeadingDates: fa,
      ),
      onViewChanged: (viewChangedDetails) {
        // print('changed ${viewChangedDetails.visibleDates}');
        if (firstViewChanged) {
          // Avoiding the initial call
          firstViewChanged = false;
          return;
        }

        var visibleDates = viewChangedDetails.visibleDates;

        if (visibleDates.isNotEmpty) {
          DateTime middleDate =
              visibleDates[viewChangedDetails.visibleDates.length ~/ 2];

          var payload = payloadManagementBloc.state.payload;

          DateTime start = DateTime(middleDate.year, middleDate.month, 1);

          payload['startDate'] = start.millisecondsSinceEpoch;
          payload['endDate'] =
              DateTime(middleDate.year, middleDate.month + 1, 0)
                  .millisecondsSinceEpoch;

          payloadManagementBloc.add(ChangePayloadEvent(payload: payload));
          calendarController.displayDate = start;
          firstViewChanged = true;
        }
      },
      onTap: (calendarTapDetails) {
        calendarTapped(calendarTapDetails, context);
      },
    );
  }

  // ==========================================================
  void calendarTapped(
      CalendarTapDetails calendarTapDetails, BuildContext context) async {
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      Meeting item = calendarTapDetails.appointments![0];
      await Navigator.of(context).pushNamed(
        JobDetailsScreen.id,
        arguments: {
          "jobId": item.id,
        },
      );
      // setState(() {});
    }
  }

  // ==================================================================================================
  List<Meeting> _getDataSource(List<Items> items) {
    final List<Meeting> meetings = <Meeting>[];
    // final DateTime today = DateTime.now();
    // final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    // final DateTime endTime = startTime.add(const Duration(hours: 2));
    // meetings.add(Meeting(
    //     'Conference', startTime, endTime, const Color(0xFF0F8644), false));

    for (var element in items) {
      DateTime startTime;
      DateTime endTime;

      if (element.actualStartTime == null) {
        startTime = DateTime.fromMillisecondsSinceEpoch(element.jobStartTime!);
        endTime = DateTime.fromMillisecondsSinceEpoch(element.expectedEndTime!);
      } else {
        startTime =
            DateTime.fromMillisecondsSinceEpoch(element.actualStartTime!);

        // int endTimeMillisecondsEpoch =
        //     element.actualEndTime ?? element.expectedEndTime!;

        if (element.actualEndTime == null) {
          endTime = startTime.add(Duration(minutes: element.expectedDuration!));
        } else {
          endTime = DateTime.fromMillisecondsSinceEpoch(element.actualEndTime!);
        }
      }

      meetings.add(
        Meeting(
          eventName: element.jobName ?? "N/A",
          from: startTime,
          to: endTime,
          background: getStatusColor(element.status ?? ""),
          id: element.id!,
          criticality: element.criticality ?? "",
          status: element.status ?? "",
          // location: element.job
        ),
      );
    }

    return meetings;
  }
}
