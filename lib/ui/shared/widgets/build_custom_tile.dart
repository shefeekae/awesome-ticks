import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/models/list_service_request_model.dart';
import '../../../utils/themes/colors.dart';
import '../../pages/service request/details/service_details.dart';
import '../functions/get_color_icons.dart';

class BuildCustomListTileWidget extends StatelessWidget {
  const BuildCustomListTileWidget({
    required this.item,
    required this.refresh,
    super.key,
  });

  final Items item;
  final   Function() refresh;

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(item.requestStatus ?? "");
    Color? textColor = getStatusTextColor(item.requestStatus ?? "");
    IconData iconData = getIcon(item.requestType ?? "");

    String formatedDate = item.requestTime == null
        ? ""
        : timeago
            .format(DateTime.fromMillisecondsSinceEpoch(item.requestTime!));

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed(ServiceDetailsScreen.id, arguments: {
          "requestNumber": item.requestNumber,
          "jobId": item.jobId != null
              ? int.parse(
                  item.jobId!,
                )
              : null,
        });
        refresh.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.sp),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(5),
        ),
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.sp),
            child: Row(
              children: [
                Builder(builder: (context) {
                  return CircleAvatar(
                    backgroundColor: fwhite,
                    radius: 15.sp,
                    child: Icon(
                      iconData,
                      // color: Colors.red,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 22.sp,
                    ),
                  );
                }),
                SizedBox(
                  width: 10.sp,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.requestSubjectLine ?? "N/A",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 5.sp,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 3.sp, horizontal: 5.sp),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Builder(builder: (context) {
                          String requestType = item.requestType ?? "";

                          String status = item.requestStatus ?? "N/A";

                          if (requestType == "MOVE_IN" ||
                              requestType == "MOVE_OUT") {
                            if (status == "COMPLETED") {
                              status = "APPROVED";
                            } else if (status == "CANCELLED") {
                              status = "REJECTED";
                            }
                          }

                          return Text(
                            status,
                            style: TextStyle(
                              color: textColor,
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
                // Spacer(),
                Text(
                  formatedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
