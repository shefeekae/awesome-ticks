import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/jobs/jobs_action_service.dart';
import 'package:awesometicks/ui/pages/job/functions/job_actions_button_helper.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:track_location/track_location.dart';

class StopTravelButton extends StatelessWidget {
  StopTravelButton({
    super.key,
    required this.jobId,
    required this.startTime,
    required this.startLocation,
    required this.startLocationName,
    required this.travelTimeBloc,
    required this.actionButtonLoadingBloc,
  });

  final int? jobId;
  final int? startTime;
  final String? startLocation;
  final String? startLocationName;
  final TravelTimeBloc travelTimeBloc;
  final TrackLocation trackLocation = TrackLocation();
  final UserDataSingleton userData = UserDataSingleton();
  final ActionButtonLoadingBloc actionButtonLoadingBloc;

  @override
  Widget build(BuildContext context) {
    ButtonViewModel buttonView =
        JobActionsButtonHelper.getButtonView('stopTravel');

    return BlocBuilder<ActionButtonLoadingBloc, ActionButtonLoadingState>(
      builder: (context, state) {
        return Bounce(
          duration: const Duration(milliseconds: 100),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: buttonView.color,
                radius: 22.sp,
                child: state.isLoading
                    ? CircularProgressIndicator.adaptive(
                        backgroundColor: buttonView.iconColor,
                      )
                    : Icon(
                        buttonView.icon,
                        size: 25.sp,
                        color: buttonView.iconColor ?? kWhite,
                      ),
              ),
              Text(
                'Stop Travel',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 8.sp,
                    color: buttonView.iconColor),
              ),
            ],
          ),
          onPressed: () async {
            if (state.isLoading) {
              return;
            }

            await showAdaptiveDialog(
              context: context,
              builder: (_) => AlertDialog.adaptive(
                title: const Text("Stop Travel ?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        // actionButtonLoadingBloc
                        //     .add(ActionButtonIsLoadingEvent(isLoading: false));
                        Navigator.of(context).pop();
                      },
                      child: const Text("No")),
                  TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              actionButtonLoadingBloc.add(
                                  ActionButtonIsLoadingEvent(isLoading: true));

                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              DateTime now = DateTime.now();

                              var locationMap = await trackLocation
                                  .getCurrentLocationAndLocationName(context);

                              // ignore: use_build_context_synchronously
                              var result = await GraphqlServices()
                                  .performMutation(
                                      context: context,
                                      query: JobsSchemas.stopTrip,
                                      variables: {
                                    "data": {
                                      "startTime": startTime,
                                      "endTime": now.millisecondsSinceEpoch,
                                      "jobTripReference": travelTimeBloc
                                          .getLatestItem?.jobTripReference,
                                      "tripPurpose": "TO_WORK",
                                      "startLocation": startLocation,
                                      "endLocation": locationMap["location"],
                                      "jobId": jobId,
                                      "endLocationName":
                                          locationMap["locationName"],
                                      "startLocationName": startLocationName,
                                      "assignees": [
                                        "${userData.identifier}@${userData.domain}"
                                      ]
                                    }
                                  });

                              if (result.hasException) {
                                actionButtonLoadingBloc.add(
                                    ActionButtonIsLoadingEvent(
                                        isLoading: false));
                                if (context.mounted) {
                                  buildSnackBar(
                                      context: context,
                                      value:
                                          "Something went wrong. Please try again");
                                  // Navigator.of(context).pop();
                                }

                                return;
                              }

                              if (jobId != null) {
                                JobsActionService.callTravelTimeSheetApi(
                                    travelTimeBloc: travelTimeBloc,
                                    jobId: jobId!);
                              }

                              actionButtonLoadingBloc.add(
                                  ActionButtonIsLoadingEvent(isLoading: false));
                            },
                      child: const Text("Yes"))
                ],
              ),
            );
          },
        );
      },
    );
  }
}
