import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/schemas/jobs_schemas.dart';
import 'package:awesometicks/core/services/graphql_services.dart';
import 'package:awesometicks/core/services/platform_services.dart';
import 'package:awesometicks/ui/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:secure_storage/model/user_data_model.dart';
import 'package:track_location/track_location.dart';
import '../../blocs/travel_time_bloc/travel_time_event.dart';

class JobsActionService {
  static final UserDataSingleton userData = UserDataSingleton();

  final PlatformServices platformServices = PlatformServices();

  final TrackLocation trackLocation = TrackLocation();

  static void callTravelTimeSheetApi({
    required TravelTimeBloc travelTimeBloc,
    required int jobId,
  }) {
    travelTimeBloc.add(
      TravelTimeInitialEvent(
        /// assigneeIds refers to the id of current user logged in
        payload: {
          "domains": [userData.domain],
          "assignees": [],
          "assigneeIds": [userData.userId],
          "jobIds": [jobId],

          /// if date range not given complete job list will be returned
          // "dateRange": {
          //   "startDate": 1723454585000,
          //   "endDate": 1721308200000,
          // }
        },
      ),
    );
  }

//   --------------------------------------------------------------------------------

  void showCompleteConfirmationForNonAssignee(
    BuildContext context, {
    required TravelTimeBloc travelTimeBloc,
    required int jobId,
  }) async {
    var locationData =
        await trackLocation.getCurrentLocationAndLocationName(context);

    if (context.mounted) {
      platformServices.showPlatformDialog(context,
          title: "Confirmation",
          message: "Are you sure you want to complete the job?", onPressed: () {
        GraphqlServices().performMutation(
          query: JobsSchemas.jobCompleteMutation,
          context: context,
          variables: {
            "id": jobId,
            "data": {
              "jobEndTime": DateTime.now().millisecondsSinceEpoch,
              "statusLocation": locationData['location'],
              "statusLocationName": locationData['locationName'],
            }
          },
        ).then((value) {
          if (value.hasException) {
            buildSnackBar(
                context: context,
                value: "Something went wrong. Please try again");
          }

          if (value.data != null) {
            callTravelTimeSheetApi(
                travelTimeBloc: travelTimeBloc, jobId: jobId);
            buildSnackBar(
              context: context,
              value: "Job completed successfully",
            );
          }
          Navigator.of(context).pop();
        });
      });
    }
  }

  /// Job Action Confirmation Alert Dialog
  /// * The confirmation message will only appear when the user clicks the 'Start' or 'Resume' button.
  /// * If the action is neither 'Start' nor 'Resume', the onPressed function will be called instead

  void confimationPopUp(
    BuildContext context, {
    required String buttonKey,

    /// if user click the yes button this fuction will be called
    required Function onPressed,
  }) {
    bool hasConfirmation =
        ["start", "resume"].any((element) => element == buttonKey);

    if (!hasConfirmation) {
      onPressed.call();
      return;
    }

    Map<String, String> jobActionMessageMap = {
      "start": "start",
      "resume": "resume",
    };

    String jobActionMessage = jobActionMessageMap[buttonKey] ?? "";

    platformServices.showPlatformDialog(
      context,
      title: "Confirmation",
      message: jobActionMessage.isEmpty
          ? "Are you sure?"
          : "Are you sure you want to $jobActionMessage the job?",
      onPressed: () {
        Navigator.of(context).pop();
        onPressed.call();
      },
    );
  }

  /// This function is calling to the Start Trip Api and updating the jobs status too.

  Future<void> startTravelApiCall(
    BuildContext context, {
    required int jobId,
    required TravelTimeBloc travelTimeBloc,
    required TimelineUpdateBloc timelineUpdateBloc,
    required JobControllerBlocBloc jobControllerBlocBloc,
    required ActionButtonLoadingBloc actionButtonLoadingBloc,
    required bool hasTravelTimeIncluded,
  }) async {
    DateTime now = DateTime.now();

    var locationMap =
        await trackLocation.getCurrentLocationAndLocationName(context);

    actionButtonLoadingBloc.add(ActionButtonIsLoadingEvent(isLoading: true));

    // ignore: use_build_context_synchronously
    var result = await GraphqlServices()
        .performMutation(context: context,query: JobsSchemas.startTrip, variables: {
      "data": {
        "startTime": now.millisecondsSinceEpoch,
        "startLocationName": locationMap["locationName"],
        // "endLocationName": "kunnamkulam",
        "tripPurpose": "TO_WORK",
        "startLocation": locationMap["location"],
        // "endLocation": "POINT(1232323,2323123)",
        "jobId": jobId,
        "assignees": ["${userData.identifier}@${userData.domain}"]
      }
    });

    if (result.hasException) {
      actionButtonLoadingBloc.add(ActionButtonIsLoadingEvent(isLoading: false));

      if (context.mounted) {
        buildSnackBar(
            context: context, value: "Something went wrong. Please try again");
      }
      return;
    }

    JobsActionService.callTravelTimeSheetApi(
        travelTimeBloc: travelTimeBloc, jobId: jobId);

    String jobStatus = jobControllerBlocBloc.state.jobStatus;

    if (travelTimeBloc.isWorkLogsIsEmpty &&
        jobStatus != "COMPLETED" &&
        jobStatus != "CLOSED") {
      if (hasTravelTimeIncluded == true) {
        jobControllerBlocBloc.add(
          ChangeJobStatusEvent(status: "INPROGRESS"),
        );

        timelineUpdateBloc.add(
          TimeLineChangeEvent(
            timeline: {
              "time": now.millisecondsSinceEpoch,
              "status": "INPROGRESS",
            },
          ),
        );
      }
    }

    // widget.startTravelService.startOrStopTimer();
    actionButtonLoadingBloc.add(ActionButtonIsLoadingEvent(isLoading: false));

    // if (context.mounted) {
    //   Navigator.of(context).pop();
    // }
  }
}
