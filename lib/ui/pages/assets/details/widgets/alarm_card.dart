import 'package:awesometicks/ui/shared/functions/get_color_icons.dart';
import 'package:awesometicks/utils/themes/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/models/list_alarms_model.dart';
import '../../../../../utils/themes/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../functions/get_path.dart';

class AlarmCardWidget extends StatelessWidget {
  AlarmCardWidget({
    required this.eventLog,
    this.isEventDetails = false,
    super.key,
  });

  final EventLogs eventLog;
  bool isEventDetails;
  final double borderRadius = 10;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      eventLog.eventTime ?? 0,
    );

    String formatedDateTime = timeago.format(dateTime);

    return Bounce(
      duration: Duration(milliseconds: isEventDetails ? 0 : 100),
      onPressed: isEventDetails
          ? () {}
          : () {
              // Navigator.of(context).pushNamed(
              //   AlarmsDetailsScreen.id,
              //   arguments: {
              //     "eventId": eventLog.eventId,
              //     "name": eventLog.name,
              //     "sourceId": eventLog.sourceId,
              //     // "multiselectAsset": eventLog.
              //   },
              // );
              // print(eventLog.eventId);
            },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: fwhite,
          border: Border.all(color: kBlack, width: 0.05.sp),
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCardHeader(formatedTime: formatedDateTime),
                  SizedBox(
                    height: 2.h,
                  ),
                  buildCardCenter(),
                  SizedBox(
                    height: 0.3.h,
                  ),
                  Text(
                    eventLog.sourceTypeName ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
            BuildAssetPathFooter(
              context: context,
              borderRadius: borderRadius,
              assetPath: getPath(
                list: eventLog.sourceTagPath ?? [],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ======================================================================================
  // This method is used to show the center of alarm card.
  // Displaying alram name and acknwoledge, unacknowledge status.

  Row buildCardCenter() {
    print(eventLog.acknowledged);

    bool acknowledged = eventLog.acknowledged!;

    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: acknowledged ? 0.5 : 1,
            child: Text(
              eventLog.name ?? "No Name",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: kBlack,
              ),
            ),
          ),
        ),
        Visibility(
          visible: !acknowledged,
          child: Builder(builder: (context) {
            return Container(
              decoration: BoxDecoration(
                // gradient: linearGradientPrimaryTheme,
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5.sp),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5.sp,
                  horizontal: 5.sp,
                ),
                child: Center(
                  child: Text(
                    "Unacknowledged",
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        // SizedBox(
        //   width: 3.w,
        // )
      ],
    );
  }

  // =========================================================================================
  // This method is used to show the alarms card header.
  // Displaying alarm category, alarm status, alarm generated time.

  Row buildCardHeader({required String formatedTime}) {
    String criticality = eventLog.criticality ?? "";

    String statusText = getStausofAlarm(
      active: eventLog.active ?? false,
      resolved: eventLog.resolved ?? false,
    )['text'];

    Color statusColor = getStausofAlarm(
      active: eventLog.active ?? false,
      resolved: eventLog.resolved ?? false,
    )['color'];

    return Row(
      children: [
        Container(
          // height: 4.h,
          // width: 6.h,
          decoration: BoxDecoration(
            color: getCriticalityColor(criticality),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.sp,
              horizontal: 16.sp,
            ),
            child: Center(
              child: Text(
                criticality[0],
                style: TextStyle(
                  fontSize: 15.sp,
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5.w,
        ),
        Container(
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4.sp,
              horizontal: 7.sp,
            ),
            child: Center(
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: kWhite,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 6.w,
        ),
        Text(
          formatedTime,
          style: TextStyle(
            fontSize: 10.sp,
            // color: kBlack,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class BuildAssetPathFooter extends StatelessWidget {
  BuildAssetPathFooter({
    super.key,
    required this.borderRadius,
    required this.assetPath,
    required this.context,
  });

  final double borderRadius;
  final BuildContext context;

  String assetPath;

  @override
  Widget build(BuildContext _) {
    return Container(
      // height: ,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: getGradientColors(
          context,
          begin: Alignment.bottomLeft,
          end: Alignment.bottomCenter,
        ),
        // gradient: LinearGradient(
        //   colors: [
        //     Theme.of(context).primaryColor,
        //     Theme.of(context).colorScheme.secondary,
        //   ],
        // begin: Alignment.bottomLeft,
        // end: Alignment.bottomCenter,
        // ),
        // getGradientColors(context),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(5.sp),
        child: Text(
          assetPath,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: kWhite,
            fontSize: 8.sp,
          ),
        ),
      ),
    );
  }
}
