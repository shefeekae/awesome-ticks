import 'package:awesometicks/core/models/listalljobsmodel.dart';
import 'package:awesometicks/core/services/jobs/jobs_services.dart';
import 'package:awesometicks/core/services/wkt_services.dart';
import 'package:awesometicks/ui/pages/job/functions/format_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/services/launcher_services.dart';
import '../../../../utils/themes/colors.dart';
import '../../../shared/functions/get_color_icons.dart';
import '../../../shared/widgets/status_widget.dart';

// ignore: must_be_immutable
class BuildJobCardWidget extends StatelessWidget {
  BuildJobCardWidget({
    required this.item,
    required this.onPressed,
    super.key,
  });

  final Items item;

  void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    Color criticalityColor = getCriticalityColor(item.criticality ?? "");
    Color statusColor = getStatusColor(item.status ?? "");

    String startTime = item.jobStartTime == null && item.actualStartTime == null
        ? "N/A"
        : DateFormat("d MMM yyyy,").add_jm().format(
              DateTime.fromMillisecondsSinceEpoch(
                item.actualStartTime ?? item.jobStartTime ?? 0,
              ),
            );

    String endTime = item.expectedEndTime == null && item.actualEndTime == null
        ? "N/A"
        : DateFormat("d MMM yyyy,").add_jm().format(
              DateTime.fromMillisecondsSinceEpoch(
                item.actualEndTime ?? item.expectedEndTime ?? 0,
              ),
            );

    int? preferredVisitStartTimeEpoch =
        item.serviceRequest?.first.availableSlots?.first.startTime;

    int? preferredVisitEndTimeEpoch =
        item.serviceRequest?.first.availableSlots?.first.endTime;

    String preferredVisitStartTime =
        item.serviceRequest?.first.availableSlots?.first.startTime == null
            ? "N/A"
            : DateFormat("d MMM yyyy,").add_jm().format(
                  DateTime.fromMillisecondsSinceEpoch(
                    preferredVisitStartTimeEpoch ?? 0,
                  ),
                );

    String preferredVisitEndTime =
        item.serviceRequest?.first.availableSlots?.first.endTime == null
            ? "N/A"
            : DateFormat("d MMM yyyy,").add_jm().format(
                  DateTime.fromMillisecondsSinceEpoch(
                    preferredVisitEndTimeEpoch ?? 0,
                  ),
                );

    String preferredVisitTime =
        "$preferredVisitStartTime - $preferredVisitEndTime";

    // getDuration(DateTime startDate, DateTime endDate) {
    //   final d1 = startDate;
    //   final d2 = endDate;

    //   Duration duration = d2.difference(d1);

    //   return duration;
    // }

    Duration duration = DateTime.fromMillisecondsSinceEpoch(
      item.actualEndTime ?? item.expectedEndTime ?? 0,
    ).difference(DateTime.fromMillisecondsSinceEpoch(
      item.actualStartTime ?? item.jobStartTime ?? 0,
    ));

    // getDuration(
    //   DateTime.fromMillisecondsSinceEpoch(
    //     item.actualStartTime ?? item.jobStartTime ?? 0,
    //   ),
    //   DateTime.fromMillisecondsSinceEpoch(
    //     item.actualEndTime ?? item.expectedEndTime ?? 0,
    //   ),
    // );

    String durationString = formatDuration(duration);

    // String startTime = item.jobStartTime == null
    //     ? "N/A"
    //     : DateFormat("MMM d, yyyy")
    //         .add_jm()
    //         .format(DateTime.fromMillisecondsSinceEpoch(item.jobStartTime!));

    return Bounce(
      duration: const Duration(milliseconds: 50),
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: fwhite,
          borderRadius: BorderRadius.circular(7),
        ),
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.jobName ?? "N/A",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 7.sp,
                      ),
                      BuildStatusWidget(
                        status: item.status ?? "",
                        statusColor: statusColor,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Builder(builder: (context) {
                      return Visibility(
                        visible: item.status != "COMPLETED" &&
                            item.jobLocation != null &&
                            WKTServices().isWKTFormat(item.jobLocation!),
                        child: Bounce(
                          duration: const Duration(milliseconds: 100),
                          onPressed: () {
                            /// Call a method to check if the asset is communicating

                            JobsServices().launchGoogleMap(
                              context: context,
                              location: item.jobLocation,
                              assetType: item.resource?.type,
                              assetIdentifier: item.resource?.identifier,
                              domain: item.resource?.domain,
                            );
                          },
                          child: SvgPicture.asset(
                            "assets/images/map-map-marker-svgrepo-com.svg",
                            height: 25.sp,
                            width: 25.sp,
                          ),
                        ),
                      );
                    }),
                    // Column(
                    //   children: [
                    //     CircleAvatar(
                    //       backgroundColor: kWhite,
                    //       radius: 12.sp,
                    //       child: Icon(
                    //         Icons.directions_run,
                    //         color: Colors.blue,
                    //         size: 20.sp,
                    //       ),
                    //     ),
                    //     const Text(
                    //       "30m 18s",
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     )
                    //   ],
                    // )
                  ],
                )
                // Container(
                //   height: 30.sp,
                //   width: 30.sp,
                //   color: Colors.amber,
                // )
              ],
            ),
            SizedBox(
              height: 5.sp,
            ),
            Text(
              item.jobNumber ?? "",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 2.sp,
            ),
            Builder(builder: (context) {
              String? assetName = item.resource?.displayName;

              return Visibility(
                visible: assetName != null,
                child: Text(
                  assetName ?? "",
                  style: TextStyle(
                      // color: Colors.red.shade200,
                      color: Theme.of(context).primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              );
            }),
            SizedBox(
              height: 5.sp,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildDateText(startTime),
                // if (durationString.isNotEmpty) ...[
                //   Text(
                //     "Duration\n$durationString",
                //     style: TextStyle(
                //       color: Colors.grey.shade600,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 10.sp,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ],
                buildDateText(endTime),
              ],
            ),
            if (durationString.isNotEmpty) ...[
              Center(
                child: Text(
                  "Duration\n$durationString",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Visibility(
              visible:
                  item.serviceRequest?.first.availableSlots?.first.startTime !=
                      null,
              child: Container(
                margin: EdgeInsets.only(top: 5.sp),
                padding: EdgeInsets.symmetric(
                  horizontal: 5.sp,
                  vertical: 3.sp,
                ),
                decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(6.sp)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Preferred visiting time",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 8.sp,
                      ),
                    ),
                    Text(
                      preferredVisitTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 8.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================================================================================
  // Showing the start and end time.

  Text buildDateText(String value) {
    return Text(
      value,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
        fontSize: 10.sp,
      ),
    );
  }
}
