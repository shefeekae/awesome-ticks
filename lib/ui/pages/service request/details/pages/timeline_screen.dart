import 'package:flutter/material.dart';
import 'package:graphql_config/graphql_config.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:timelines/timelines.dart';
import '../../../../../core/models/timeline_model.dart';
import '../../../../../core/schemas/service_request_schemas.dart';
import '../../../../../core/services/graphql_services.dart';
import '../../../../../utils/themes/colors.dart';
import '../../../../shared/widgets/loading_widget.dart';

class TimeLineScreen extends StatelessWidget {
  TimeLineScreen(
      {required this.requestNumber, required this.createdOn, super.key});

  final String requestNumber;
  final int createdOn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: const Text("Timeline"),
      ),
      body: QueryWidget(
        options: GraphqlServices().getQueryOptions(
            query: ServiceRequestSchemas.getServiceRequestTransitionsQuery,
            variables: {
              "requestNumber": requestNumber,
            }),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return BuildShimmerLoadingWidget(
              height: 15.h,
              itemCount: 4,
            );
          }

          if (result.hasException) {
            return GraphqlServices().handlingGraphqlExceptions(
              result: result,
              context: context,
              refetch: refetch,
            );
          }

          TimelineModel timelineModel = TimelineModel.fromJson(result.data!);

          var timeLines = timelineModel.getServiceRequestTransitions;

          if (timeLines == null) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          timeLines.add(
            GetServiceRequestTransitions(
              currentStatus: "Open",
              transitionTime: createdOn,
              transitionComment: "Service Request Created",
            ),
          );

          timeLines.sort(
            (a, b) => b.transitionTime!.compareTo(a.transitionTime!),
          );

          return TimelineTheme(
            data: TimelineThemeData(
              color: Theme.of(context).primaryColor,
            ),
            child: Timeline.tileBuilder(
              builder: TimelineTileBuilder.fromStyle(
                itemCount: timeLines.length,

                nodePositionBuilder: (context, index) {
                  return 0.35;
                },
                oppositeContentsBuilder: (context, index) {
                  var timeLine = timeLines[index];

                  String formatedDate =
                      DateFormat("d MMM yyyy").add_jm().format(
                            DateTime.fromMillisecondsSinceEpoch(
                                timeLine.transitionTime!),
                          );

                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          formatedDate,
                          style: const TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                // contentsAlign: ContentsAlign.alternating,
                contentsBuilder: (context, index) {
                  var timeLine = timeLines[index];

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: fwhite,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeLine.currentStatus ?? "N/A",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Visibility(
                            visible: timeLine.transitionComment != null,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5.sp,
                                ),
                                Text(
                                  timeLine.transitionComment ?? "",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
