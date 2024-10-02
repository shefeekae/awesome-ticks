import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:timeline_tile/timeline_tile.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class TimelineWidget extends StatelessWidget {
  TimelineWidget({
    super.key,
    required this.hasInternet,
    required this.jobId,
    required this.jobDetailsBloc,
  });

  final bool hasInternet;
  final int jobId;
  final JobDetailsBloc jobDetailsBloc;

  final List statusList = [
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.sp),
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          jobDetailsBloc.add(FetchJobDetailDataEvent(jobId: jobId));
        },
        child: BlocBuilder<TimelineUpdateBloc, TimelineUpdateState>(
            builder: (context, state) {
          List<dynamic> timeLines = state.timelines;

          timeLines.sort(
            (a, b) {
              int aTime = a['time'] ?? 0;
              int bTime = b['time'] ?? 0;

              return bTime.compareTo(aTime);
            },
          );

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.sp),
              // color: kWhite,
            ),
            width: double.infinity,
            // height: 45.sp,
            child: ListView.builder(
              padding: EdgeInsets.all(5.sp),
              // shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: timeLines.length,
              itemBuilder: (context, index) {
                // return Text("data");

                var timeLine = timeLines[index];

                String formatedDate = timeLine['time'] == null
                    ? "N/A"
                    : DateFormat("d MMM yyyy").add_jm().format(
                          DateTime.fromMillisecondsSinceEpoch(timeLine['time']),
                        );

                bool isFirst = index == 0;

                bool isLast = index == timeLines.length - 1;
                // index == timeLines.last;

                String status = statusList.singleWhereOrNull(
                      (element) => element['key'] == timeLine['status'],
                    )?['value'] ??
                    "N/A";

                String comment = timeLine['comment'] ?? "";

                return SizedBox(
                  height: 100.sp,
                  child: TimelineTile(
                    // lineXY: 0.2,

                    isFirst: isFirst,
                    isLast: isLast,
                    axis: TimelineAxis.vertical,

                    alignment: TimelineAlign.center,
                    afterLineStyle: LineStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    beforeLineStyle: LineStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    indicatorStyle: IndicatorStyle(
                        width: 25.sp,
                        iconStyle: IconStyle(
                            iconData: getTimelineIcon(status),
                            fontSize: 18.sp,
                            color: kWhite),
                        color: Theme.of(context).primaryColor),
                    startChild: Padding(
                      padding: EdgeInsets.only(left: 10.sp),
                      child: Text(
                        formatedDate,
                        style: TextStyle(
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    endChild: Padding(
                      padding: EdgeInsets.only(left: 10.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 2.sp,
                          ),
                          Text(
                            comment,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  IconData getTimelineIcon(String key) {
    switch (key) {
      case "Open":
        return Icons.menu_book_rounded;

      case "Registered":
        return Icons.app_registration_rounded;

      case "Scheduled":
        return Icons.schedule_rounded;

      case "In progress":
        return Icons.downloading_rounded;

      case "Rescheduled":
        return Icons.update_rounded;

      case "Transferred to vendor":
        return Icons.connect_without_contact_rounded;

      case "Waiting for parts":
        return Icons.hourglass_top_rounded;

      case "Held":
        return Icons.stop;

      case "No Access":
        return Icons.block;

      case "Access Granted":
        return Icons.how_to_reg_rounded;

      case "Parts Approved":
        return Icons.recommend_rounded;

      case "Cancelled":
        return Icons.cancel_rounded;

      case "Completed":
        return Icons.done_rounded;

      case "Closed":
        return Icons.door_front_door_rounded;

      default:
        return Icons.add_box;
    }
  }
}
