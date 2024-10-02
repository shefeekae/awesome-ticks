import 'package:awesometicks/core/models/time_sheet_data_model.dart';
import 'package:awesometicks/core/services/jobs/job_permission_services.dart';
import 'package:awesometicks/utils/themes/colors.dart';
import 'package:flutter/material.dart';

class ButtonModel {
  final String key;

  ButtonModel({required this.key});
}

class ButtonViewModel {
  final String name;
  final Color color;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;

  ButtonViewModel({
    required this.name,
    required this.color,
    required this.icon,
    this.iconColor,
    this.textColor,
  });
}

class JobActionsButtonHelper {
  static Map getButtonsIconsAndColor(String key) {
    switch (key) {
      case "cancel":
        return {
          "color": Colors.red.shade800,
          "icon": Icons.close,
        };

      case "resume":
      case "start":
        return {
          "color": Colors.green,
          "icon": Icons.play_arrow_outlined,
        };

      case "hold":
        return {
          "color": Colors.amber.shade800,
          "icon": Icons.pause,
        };

      case "complete":
        return {
          "color": Colors.green.shade900,
          "icon": Icons.done,
        };

      case "startTravel":
        return {
          "color": kWhite,
          "icon": Icons.directions_run_rounded,
          "iconColor": Colors.blue,
        };

      case "stopTravel":
        return {
          "color": kWhite,
          "icon": Icons.directions_run_rounded,
          "iconColor": Colors.red,
        };

      default:
        return {
          "color": Colors.amber.shade800,
          "icon": Icons.abc,
        };
    }
  }

  static ButtonViewModel getButtonView(String key) {
    ButtonViewModel resumeButtonViewModel = ButtonViewModel(
      name: key == 'resume' ? 'Resume' : 'Start',
      color: Colors.green,
      icon: Icons.play_arrow_outlined,
    );

    Map<String, ButtonViewModel> data = {
      "cancel": ButtonViewModel(
        name: 'Cancel',
        color: Colors.red.shade800,
        icon: Icons.close,
      ),
      "resume": resumeButtonViewModel,
      "start": resumeButtonViewModel,
      "hold": ButtonViewModel(
        name: 'Hold',
        color: Colors.amber.shade800,
        icon: Icons.pause,
      ),
      "complete": ButtonViewModel(
        name: 'Complete',
        color: Colors.green.shade900,
        icon: Icons.done,
      ),
      "startTravel": ButtonViewModel(
        name: 'Start Travel',
        color: kWhite,
        icon: Icons.directions_run_rounded,
        iconColor: Colors.blue,
      ),
      "stopTravel": ButtonViewModel(
        name: 'Stop Travel',
        color: kWhite,
        icon: Icons.directions_run_rounded,
        iconColor: Colors.red,
      ),
      "retry": ButtonViewModel(
        name: 'Retry',
        color: Colors.orange,
        icon: Icons.refresh_rounded,
        iconColor: kWhite,
        textColor: Colors.orange,
      )
    };

    return data[key] ??
        ButtonViewModel(
          name: '',
          color: Colors.amber.shade800,
          icon: Icons.abc,
        );
  }

  /// The 'Cancel Action' was commented due to changes in the flow, so the technician no longer needs to change the job status to 'Cancelled.

  static List<ButtonModel> getActionButtons({
    required String jobStatus,
    required bool isTimeSheetEmpty,
    required GetTimeSheetData? timeSheetData,
    required bool hasTravelTime,
    required bool hasTravelTimeIncluded,
    required bool hasInternet,
    required bool isOnlyTripPresent,
    bool hasTimeSheetErrorOccurred = false,
  }) {
    String activity = timeSheetData?.activity ?? '';
    int? startTime = timeSheetData?.startTime;
    int? endTime = timeSheetData?.endTime;

    bool startTimeEndTimeNotNull = startTime != null && endTime != null;
    bool isActivityTrip = activity == "TRIP";
    bool isActivityWork = activity == "WORK";

    if (hasTimeSheetErrorOccurred && hasInternet) {
      return [ButtonModel(key: 'retry')];
    }

    if ('CANCELLED' == jobStatus) {
      return [];
    }

    if (!hasInternet) {
      bool isJobHeld =
          ["HELD", "NOACCESS", "WAITINGFORPARTS"].any((e) => e == jobStatus);

      if (isJobHeld) {
        return [
          // ButtonModel(key: "cancel"),
          ButtonModel(key: "resume"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      }

      List<ButtonModel> buttons = <String, List<ButtonModel>>{
            'RESCHEDULED': [
              ButtonModel(key: "start"),
              // ButtonModel(key: "cancel"),
            ],
            'SCHEDULED': [
              ButtonModel(key: "start"),
              // ButtonModel(key: "cancel"),
            ],
            'INPROGRESS': [
              // ButtonModel(key: "cancel"),
              ButtonModel(key: "hold"),
              ButtonModel(key: "complete"),
            ]
          }[jobStatus] ??
          [];

// Filter the buttons based on permissions
      buttons.removeWhere(
        (element) => JobPermissionServices.hasNoButtonPermission(
          buttonKey: element.key,
        ),
      );

      return buttons;
    }

    /// WITHOUT TRAVEL TIME LOGIC

    if (!hasTravelTime) {
      List<ButtonModel> buttons = [];

      bool isJobHeld =
          ["HELD", "NOACCESS", "WAITINGFORPARTS"].any((e) => e == jobStatus);

      if (['COMPLETED', 'CLOSED', 'CANCELLED'].any((e) => e == jobStatus)) {
        return [];
      } else if ((['SCHEDULED', 'RESCHEDULED'].any((e) => e == jobStatus)) ||
          (jobStatus == "INPROGRESS" && isTimeSheetEmpty) ||
          (isJobHeld && isTimeSheetEmpty)) {
        buttons = [
          ButtonModel(key: "start"),
        ];
      } else if (jobStatus == "INPROGRESS" &&
          isActivityWork &&
          startTime != null &&
          endTime == null) {
        buttons = [
          ButtonModel(key: "hold"),
          ButtonModel(key: "complete"),
        ];
      } else if ((jobStatus == "INPROGRESS" &&
              isActivityWork &&
              startTimeEndTimeNotNull) ||
          (isJobHeld && isActivityWork && startTimeEndTimeNotNull)) {
        buttons = [
          ButtonModel(key: "resume"),
        ];
      }

      // Filter the buttons based on permissions
      buttons.removeWhere(
        (element) => JobPermissionServices.hasNoButtonPermission(
          buttonKey: element.key,
        ),
      );

      return buttons;
    }

    /// WITH TRAVEL TIME LOGIC

    if (jobStatus == "CLOSED") {
      if (isActivityTrip && startTime != null && endTime == null) {
        return [
          ButtonModel(key: "stopTravel"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      }
      return [];
    }

    if (isTimeSheetEmpty || isOnlyTripPresent) {
      if (jobStatus == "COMPLETED") {
        return [
          ButtonModel(key: "startTravel"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      }

      return [
        ButtonModel(key: "startTravel"),
        ButtonModel(key: "start"),
        // ButtonModel(key: "cancel"),
      ]..removeWhere(
          (element) => JobPermissionServices.hasNoButtonPermission(
              buttonKey: element.key),
        );
    } else if (jobStatus != 'INPROGRESS') {
      if (jobStatus == 'COMPLETED') {
        if (startTime != null && endTime != null) {
          return [
            ButtonModel(key: "startTravel"),
          ]..removeWhere(
              (element) => JobPermissionServices.hasNoButtonPermission(
                  buttonKey: element.key),
            );
        }
      }

      bool isJobHeld =
          ["HELD", "NOACCESS", "WAITINGFORPARTS"].any((e) => e == jobStatus);

      bool starTimeEndTimeNotNull = startTime != null && endTime != null;

      if (activity == 'WORK' && starTimeEndTimeNotNull) {
        return [
          ButtonModel(key: "startTravel"),
          // ButtonModel(key: "cancel"),
          ButtonModel(key: "resume"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      }
      if (isJobHeld && activity == "TRIP" && starTimeEndTimeNotNull) {
        return [
          ButtonModel(key: "startTravel"),
          // ButtonModel(key: "cancel"),
          ButtonModel(key: "resume"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      } else if (activity == "TRIP" && starTimeEndTimeNotNull) {
        return [
          ButtonModel(key: "startTravel"),
          ButtonModel(key: "start"),
          // ButtonModel(key: "cancel"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      } else if (activity == 'TRIP' && startTime != null && endTime == null) {
        return [
          ButtonModel(key: "stopTravel"),
        ]..removeWhere(
            (element) => JobPermissionServices.hasNoButtonPermission(
                buttonKey: element.key),
          );
      }
    } else if (jobStatus == 'INPROGRESS') {
      if (activity == 'TRIP') {
        if (startTime != null && endTime == null) {
          return [
            ButtonModel(key: "stopTravel"),
          ]..removeWhere(
              (element) => JobPermissionServices.hasNoButtonPermission(
                  buttonKey: element.key),
            );
        } else if (startTime != null && endTime != null) {
          return [
            ButtonModel(key: "startTravel"),
            ButtonModel(key: "resume"),
            // ButtonModel(key: "cancel"),
            // ButtonModel(key: "complete"),
          ]..removeWhere(
              (element) => JobPermissionServices.hasNoButtonPermission(
                  buttonKey: element.key),
            );
        }
      } else if (activity == 'WORK') {
        if (startTime != null && endTime == null) {
          return [
            // ButtonModel(key: "startTravel"),
            // ButtonModel(key: "cancel"),
            ButtonModel(key: "hold"),
            ButtonModel(key: "complete"),
          ]..removeWhere(
              (element) => JobPermissionServices.hasNoButtonPermission(
                  buttonKey: element.key),
            );
        } else if (startTime != null && endTime != null) {
          return [
            ButtonModel(key: "startTravel"),
            ButtonModel(key: "resume"),
            // ButtonModel(key: "cancel"),
          ]..removeWhere(
              (element) => JobPermissionServices.hasNoButtonPermission(
                  buttonKey: element.key),
            );
        }
      }
    }

    return [];
  }
}
