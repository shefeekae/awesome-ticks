// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesometicks/core/blocs/job_details/job_details_bloc.dart';
import 'package:awesometicks/ui/pages/service%20request/details/service_details.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main.dart';
import '../../../ui/pages/job/job_details.dart';
import 'package:firebase_config/firebase_config.dart';

class NotificationController {
  //  ====================================================================================================
  // These keys are used to identify the notification channel. Same keys used in firebase_config.

  static const String jobsChannelKey = 'job-alerts';

  static const String serviceRequestChannelKey = "service-request-alerts";

  static const String notifyMeChannelKey = "notify-me";

  // ======================================================================================================
  // This method is used to initilize the awesome notification plugin and adding notification channels.
  // =====================================================================================================

  static void awesomeNotificationinitialise() {
    AwesomeNotifications().initialize(
      // 'resource://drawable/ic_launcher',
      null,
      [
        NotificationChannel(
          channelKey: jobsChannelKey,
          channelName: 'Job alerts',
          channelDescription: 'Job notifications',
          vibrationPattern: lowVibrationPattern,
          importance: NotificationImportance.High,
          soundSource: 'resource://raw/res_notification_sound',
          playSound: true,
        ),
        NotificationChannel(
          channelKey: serviceRequestChannelKey,
          channelName: 'Service request alerts',
          channelDescription: 'Service request notifications ',
          vibrationPattern: lowVibrationPattern,
          importance: NotificationImportance.High,
          soundSource: 'resource://raw/res_notification_sound',
          playSound: true,
        ),
        NotificationChannel(
          channelKey: notifyMeChannelKey,
          channelName: 'NotifyMe alerts',
          channelDescription: 'NotifyMe notifications',
          vibrationPattern: lowVibrationPattern,
          importance: NotificationImportance.High,
          ledColor: Colors.yellow,
          locked: true,
          soundSource: 'resource://raw/res_notification_sound',
          playSound: true,
        ),
      ],
      // debug: false,
    ).onError((error, stackTrace) {
      return true;
    });
  }

  // ======================================================================================================
  // Set listeners for Aweosme Notification

  static startListeningNotificationEvents() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );
  }

  //  ================================================================================
  /// Use this method to detect when the user taps on a notification or action button

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction action,
  ) async {
    try {
      Map<String, String?> payload = action.payload!;

      String updateItemType = payload['updateItemType'] ?? "";

      if (updateItemType == "JOB") {
        int? commentId =
            payload['commentId'] == null || payload['commentId']!.isEmpty
                ? null
                : int.parse(payload['commentId']!);

        int? replyId = payload['replyId'] == null || payload['replyId']!.isEmpty
            ? null
            : int.parse(payload['replyId']!);

        int? checkListId =
            payload['checkListId'] == null || payload['checkListId']!.isEmpty
                ? null
                : int.parse(payload['checkListId']!);

        MyApp.navigatorKey.currentState?.pushNamed(
          JobDetailsScreen.id,
          arguments: {
            "jobId": int.parse(payload['jobId']!),
            "commentId": commentId,
            "replyId": replyId,
            "checklistId": checkListId,
          },
        );
      } else if (updateItemType == "SERVICE REQUEST") {
        String serviceRequestId = payload["serviceRequestId"] ?? "";

        if (serviceRequestId.isEmpty) {
          return;
        }

        //  replaced.split(",");
        String replaced =
            serviceRequestId.substring(1, serviceRequestId.length - 1);

        List<String> splited = replaced.split(",").toList();

        // if (serviceRequestId.isNotEmpty) {
        MyApp.navigatorKey.currentState?.pushNamed(
          ServiceDetailsScreen.id,
          arguments: {
            "requestNumber": splited[0],
          },
        );
        // }
      } else {}
    } catch (e) {
      // TODO
    }
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts
        .speak('${receivedNotification.title} ${receivedNotification.body}');
  }

  void loadSingletonPage(
    NavigatorState? navigatorState, {
    required String targetPage,
    Map<String, String?>? payload,
  }) {
    // Avoid to open the notification details page over another details page already opened
    // Navigate into pages, avoiding to open the notification details page over another details page already opened

    // print(navigatorState == null);

    navigatorState?.pushNamed(
      targetPage,
      arguments: payload,
    );
  }
}
