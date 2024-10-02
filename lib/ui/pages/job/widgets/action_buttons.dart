import 'package:app_filter_form/app_filter_form.dart';
import 'package:awesometicks/core/blocs/action%20button%20loading/action_button_loading_bloc.dart';
import 'package:awesometicks/core/blocs/job%20controller/job_controller_bloc_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_bloc.dart';
import 'package:awesometicks/core/blocs/travel_time_bloc/travel_time_state.dart';
import 'package:awesometicks/core/services/jobs/jobs_action_service.dart';
import 'package:awesometicks/ui/pages/job/functions/job_actions_button_helper.dart';
import 'package:awesometicks/ui/pages/job/widgets/start_travel_button_widget.dart';
import 'package:awesometicks/ui/pages/job/widgets/stop_travel_button.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sizer/sizer.dart';

class ActionButtons extends StatelessWidget {
  ActionButtons({
    required this.jobStatus,
    required this.hasTravelTime,
    required this.hasTravelTimeIncluded,
    required this.hasInternet,
    required this.onPressed,
    required this.startTravelButtonWidget,
    required this.stopTravelButton,
    super.key,
  });

  final String jobStatus;
  final bool hasTravelTime;
  final bool hasTravelTimeIncluded;
  final bool hasInternet;
  final Future Function(String key) onPressed;
  final StartTravelButtonWidget startTravelButtonWidget;
  final StopTravelButton stopTravelButton;

  final JobsActionService jobsActionService = JobsActionService();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (isKeyboardVisible) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<TravelTimeBloc, TravelTimeState>(
            builder: (context, state) {
          return BlocBuilder<JobControllerBlocBloc, JobControllerBlocState>(
            builder: (context, jobState) {
              List<ButtonModel> actionButtons =
                  JobActionsButtonHelper.getActionButtons(
                jobStatus: jobState.jobStatus,
                isTimeSheetEmpty:
                    context.read<TravelTimeBloc>().isTimeSheetDataEmpty,
                timeSheetData: state.timeSheetData,
                hasTravelTime: hasTravelTime,
                hasTravelTimeIncluded: hasTravelTimeIncluded,
                hasInternet: hasInternet,
                isOnlyTripPresent:
                    context.read<TravelTimeBloc>().isOnlyTripPresent,
                hasTimeSheetErrorOccurred: state.hasErrorOccurred,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: 15.sp, top: 5.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(actionButtons.length, (index) {
                    return ActionButtonWidget(
                      buttonKey: actionButtons[index].key,
                      stopTravelButton: stopTravelButton,
                      startTravelButtonWidget: startTravelButtonWidget,
                      buttonViewModel: JobActionsButtonHelper.getButtonView(
                        actionButtons[index].key,
                      ),
                      onTap: () {
                        String actionKey = actionButtons[index].key;

                        jobsActionService.confimationPopUp(
                          context,
                          buttonKey: actionKey,
                          onPressed: () => onPressed.call(actionKey),
                        );
                      },
                    );
                  }),
                ),
              );
            },
          );
        });
      },
    );
  }
}

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget(
      {required this.buttonKey,
      required this.buttonViewModel,
      required this.onTap,
      required this.stopTravelButton,
      required this.startTravelButtonWidget,
      super.key});

  final ButtonViewModel buttonViewModel;
  final void Function()? onTap;
  final String buttonKey;
  final StartTravelButtonWidget startTravelButtonWidget;
  final StopTravelButton stopTravelButton;

  @override
  Widget build(BuildContext context) {
    if (buttonKey == "startTravel") {
      return startTravelButtonWidget;
    }

    if (buttonKey == "stopTravel") {
      return stopTravelButton;
    }

    return BlocBuilder<ActionButtonLoadingBloc, ActionButtonLoadingState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: state.isLoading ? null : onTap,
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: state.isLoading
                    ? buttonViewModel.color.withOpacity(0.8)
                    : buttonViewModel.color,
                radius: 22.sp,
                child: state.isLoading
                    ? const CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      )
                    : Icon(
                        buttonViewModel.icon,
                        size: 25.sp,
                        color: buttonViewModel.iconColor ?? kWhite,
                      ),
              ),
              Text(
                buttonViewModel.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 8.sp,
                  color: buttonViewModel.textColor ?? buttonViewModel.iconColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
