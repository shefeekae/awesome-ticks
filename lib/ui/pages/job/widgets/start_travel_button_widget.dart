import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/timeline/timeline_update_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_state.dart';
import 'package:awesometicks/core/services/jobs/jobs_action_service.dart';
import 'package:awesometicks/ui/pages/job/functions/job_actions_button_helper.dart';
import 'package:awesometicks/ui/pages/job/widgets/start_travel_bottom_sheet.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:track_location/track_location.dart';

class StartTravelButtonWidget extends StatefulWidget {
  const StartTravelButtonWidget({
    super.key,
    required this.hasTravelTime,
    required this.hasTravelTimeIncluded,
    required this.startTravelBottomSheet,
    required this.members,
    required this.jobId,
    required this.actionButtonLoadingBloc,
  });

  final bool hasTravelTime;
  final bool hasTravelTimeIncluded;
  final List<dynamic> members;
  final int jobId;
  final ActionButtonLoadingBloc actionButtonLoadingBloc;
  final StartTravelBottomSheet startTravelBottomSheet;

  @override
  State<StartTravelButtonWidget> createState() =>
      _StartTravelButtonWidgetState();
}

class _StartTravelButtonWidgetState extends State<StartTravelButtonWidget> {
  final TrackLocation trackLocation = TrackLocation();
  final JobsActionService jobsActionService = JobsActionService();
  final UserDataSingleton userData = UserDataSingleton();

  late TravelTimeBloc travelTimeBloc;
  late JobControllerBlocBloc jobControllerBlocBloc;
  late TimelineUpdateBloc timelineUpdateBloc;

  @override
  void initState() {
    travelTimeBloc = BlocProvider.of<TravelTimeBloc>(context);
    jobControllerBlocBloc = BlocProvider.of<JobControllerBlocBloc>(context);
    timelineUpdateBloc = BlocProvider.of<TimelineUpdateBloc>(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelTimeBloc, TravelTimeState>(
      builder: (context, state) {
        return BlocBuilder<ActionButtonLoadingBloc, ActionButtonLoadingState>(
          builder: (context, loadingState) {
            return Bounce(
              duration: const Duration(milliseconds: 100),
              child: Builder(builder: (context) {
                var buttonMap = JobActionsButtonHelper.getButtonsIconsAndColor(
                    'startTravel');
                return Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: buttonMap['color'],
                      radius: 22.sp,
                      child: loadingState.isLoading
                          ? CircularProgressIndicator.adaptive(
                              backgroundColor: buttonMap['iconColor'],
                            )
                          : Icon(
                              buttonMap['icon'],
                              size: 25.sp,
                              color: buttonMap['iconColor'] ?? kWhite,
                            ),
                    ),
                    Text(
                      'Start Travel',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 8.sp,
                          color: buttonMap['iconColor']),
                    ),
                  ],
                );
              }),
              onPressed: () {
                if (loadingState.isLoading) {
                  return;
                }

                if (widget.members.isEmpty) {
                  showAdaptiveDialog(
                    context: context,
                    builder: (_) => AlertDialog.adaptive(
                      title: const Text("Start travel"),
                      content:
                          const Text("Are you sure you want to start travel ?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // widget.actionButtonLoadingBloc.add(
                            //     ActionButtonIsLoadingEvent(isLoading: false));

                            Navigator.of(context).pop();
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: loadingState.isLoading
                              ? null
                              : () async {
                                  widget.actionButtonLoadingBloc.add(
                                      ActionButtonIsLoadingEvent(
                                          isLoading: true));

                                  Navigator.of(context).pop();

                                  jobsActionService.startTravelApiCall(
                                    context,
                                    jobId: widget.jobId,
                                    travelTimeBloc: travelTimeBloc,
                                    timelineUpdateBloc: timelineUpdateBloc,
                                    jobControllerBlocBloc:
                                        jobControllerBlocBloc,
                                    hasTravelTimeIncluded:
                                        widget.hasTravelTimeIncluded,
                                    actionButtonLoadingBloc:
                                        widget.actionButtonLoadingBloc,
                                  );
                                },
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );
                } else {
                  if (context.mounted) {
                    showModalBottomSheet(
                      scrollControlDisabledMaxHeightRatio: 0.8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp)),
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        return widget.startTravelBottomSheet;
                      },
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}
