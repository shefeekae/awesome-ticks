// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:secure_storage/services/shared_prefrences_services.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'notification_controller.dart';
// // import 'package:awesome_notifications/awesome_notifications.dart';
// // import 'package:aweso';

// class NotificationService {
//   // Box<NotifyMeDb> box = Hive.box(NotifyMeDb.boxName);

//   void showLocalNotification(
//     RemoteMessage message,
//     String channelKey, {
//     NotificationCalendar? notificationCalendar,
//     // Map<String, String?>? payload,
//   }) {
//     RemoteNotification? remoteNotification = message.notification;
//     AndroidNotification? androidNotification = message.notification?.android;

//     if (remoteNotification != null && androidNotification != null) {
//       print(message.data);
//       // scheduleNotifyNotification(message.data);

//       Map<String, String> payload = message.data.map(
//         (key, value) {
//           // if (key == 'serviceRequestId') {
//           //   // ===================================================================================
//           //   // Can't recieve the list of service request id its recieving String.
//           //   // Remove String Brackets.

//           //   String serviceRequestId = value;

//           //   String replaced =
//           //       serviceRequestId.substring(1, serviceRequestId.length - 1);

//           //   List<String> splited = replaced.split(",").toList();

//           //   //  replaced.split(",");

//           //   return MapEntry(
//           //     key,
//           //     splited[0],
//           //   );
//           // }

//           return MapEntry(
//             key,
//             value,
//           );
//         },
//       );

//       AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: remoteNotification.hashCode,
//           channelKey: channelKey,
//           title: remoteNotification.title,
//           body: remoteNotification.body,
//           category: NotificationCategory.Status,
//           // actionType: ActionType.KeepOnTop,
//           fullScreenIntent: false,
//           payload: payload,
//         ),
//         schedule: notificationCalendar,
//       );
//     } else {
//       print("null value called");
//     }
//   }

//   // =======================================================================================================================
//   // This method is used to call when the manager scheduled the job then this mehod will call and schedule the notify me notification

//   Future<void> scheduleNotifyNotification({
//     required int identifier,
//     required String jobName,
//     required DateTime notifyTime,
//     required Map<String, String>? payload,
//     bool notifyMe = true,
//     String minutes = "10",
//   }) async {
//     if (notifyMe) {
//       print("notifyMe called");
//       NotificationService().scheduleLocalNotification(
//         identifier: identifier,
//         title: "Job Reminder",
//         body: '"$jobName" will start in 10 minutes',
//         // body: "$jobName start to after $minutes Minutes",
//         notificationCalendar: NotificationCalendar.fromDate(
//           date: notifyTime,
//         ),
//         payload: payload,
//       );
//     } else {
//       AwesomeNotifications().cancelSchedule(identifier.hashCode);
//     }

//     // await box.put(
//     //   identifier,
//     //   NotifyMeDb(
//     //     notify: notifyMe,
//     //     title: minutes,
//     //     id: identifier.hashCode,
//     //     parentIdentifier: parentIdentifier,
//     //   ),
//     // );
//   }

//   // =================================================================================================================
//   // Cancel notification ------------------------------------------

//   void cancelScheduledNotfication(int id) async {
//     await AwesomeNotifications().cancelSchedule(id);
//   }

//   void scheduleLocalNotification({
//     required int identifier,
//     required String title,
//     required String body,
//     required Map<String, String>? payload,
//     required NotificationCalendar notificationCalendar,
//   }) {
//     try {
//       AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: identifier,
//           channelKey: NotificationController.notifyMeChannelKey,
//           title: title,
//           body: body,
//           category: NotificationCategory.Reminder,
//           locked: true,
//           fullScreenIntent: true,
//           payload: payload,
//         ),
//         schedule: notificationCalendar,
//       );
//     } catch (e) {
//       print('schedule notification function catch bloc called');
//       print(e);
//     }
//   }

//   // // ==================================================================================================================================================
//   // // This method is used to initialise the flutter local notification and control the user's clicking notification and redirect to a specific page.
//   // // ============================================ Flutter Local Notification Handling =================================================================

//   // static void setListeners(BuildContext context) {
//   //   try {
//   //     AwesomeNotifications().actionStream.listen((action) {
//   //       // ReceivedAction action = eve

//   //       print("SET LISTERNES CALED");
//   //       print("Action Channel Key : ${action.channelKey}");
//   //       print("Acion button pressed ${action.buttonKeyPressed}");

//   //       if (action.channelKey == NotificationController.notifyMeChannelKey ||
//   //           action.channelKey == NotificationController.jobsChannelKey) {
//   //         if (action.buttonKeyPressed.isEmpty) {
//   //           print("ONPRESSED CALLED ON SETLISTNERES ${action.payload}");

//   //           Map<String, String> notifyMepayload = action.payload!;

//   //           Map<String, dynamic> arguments = {
//   //             "jobId": int.parse(notifyMepayload['jobId']!),
//   //           };

//   //           MyApp.navigatorKey.currentState?.pushNamed(
//   //             JobDetailsScreen.id,
//   //             arguments: arguments,
//   //           );
//   //         }
//   //       }
//   //     });
//   //   } catch (e) {
//   //     print("setListeners catch_bloc called");
//   //     print(e);
//   //   }
//   // }

//   // ==================================================================================================================================
//   // This method is used when the user clicks the notification and is redirected to a specific page.
//   // ===========================Firebase Cloud Messaging Background notification handling ===========================================

//   static void firebaseBackgroundNotificationClickableHandling(
//       BuildContext context) {
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       RemoteNotification? remoteNotification = message.notification;
//       AndroidNotification? androidNotification = message.notification?.android;

//       if (remoteNotification != null && androidNotification != null) {
//         // var alarmModel = AlarmNotifcationModel.fromJson(message.data);

//         // print(
//         //     "======================PAYLOD ===========================================");
//         // print(
//         //   {
//         //     "eventId": alarmModel.eventId,
//         //     "name": alarmModel.name,
//         //     "sourceId": alarmModel.sourceId,
//         //     // "multiselectAsset": eventLog.
//         //   },
//         // );

//         // loadSingletonPage(
//         //   MyApp.navigatorKey.currentState,
//         //   targetPage: AlarmsDetailsScreen.id,
//         //   payload: {
//         //     "eventId": alarmModel.eventId,
//         //     "name": alarmModel.name,
//         //     "sourceId": alarmModel.sourceId,
//         //   },
//         // );

//         print("foreground onMessageOPenedApp called ${message.data}");
//       }
//     });
//   }

//   // ==============================================================================================================================================
//   // This method is used when the app is terminated and the user clicks the notification to redirect to a specific page. (Terminated app means the app is closed from recent apps).
//   // ========================Firebase Cloud Messaging Terminated app notification handling ========================================================

//   static void firebaseAppTerminatedNotificationClickableHandling(
//       BuildContext context) {
//     print("firebaseAppTerminatedNotificationClickableHandling called");

//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       RemoteNotification? remoteNotification = message?.notification;
//       AndroidNotification? androidNotification = message?.notification?.android;

//       if (remoteNotification != null && androidNotification != null) {
//         print(message?.data);
//         print('--------------------------------------------------');
//         // Future.delayed(const Duration(seconds: 1), () {
//         //   // Navigator.of(context).pushNamed(JobDetailsScreen.id, arguments: {
//         //   //   "title": message!.data['title'],
//         //   // });

//         //   var alarmModel = AlarmNotifcationModel.fromJson(message!.data);

//         //   print(
//         //       "======================PAYLOD ===========================================");
//         //   print(
//         //     {
//         //       "eventId": alarmModel.eventId,
//         //       "name": alarmModel.name,
//         //       "sourceId": alarmModel.sourceId,
//         //       // "multiselectAsset": eventLog.
//         //     },
//         //   );

//         //   loadSingletonPage(
//         //     MyApp.navigatorKey.currentState,
//         //     targetPage: AlarmsDetailsScreen.id,
//         //     payload: {
//         //       "eventId": alarmModel.eventId,
//         //       "name": alarmModel.name,
//         //       "sourceId": alarmModel.sourceId,
//         //     },
//         //   );
//         // });
//       }
//     });
//   }

//   // ============================================================================================================================================
//   // This method is used to handle the backround message from FCM and scheduling a alert notification to user.
//   // ============================================================================================================================================

//   static Future<void> firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     // If you're going to use other Firebase services in the background, such as Firestore,
//     // make sure you call `initializeApp` before using other Firebase services
//     print("firebaseMessagingBackgroundHandler called");

//     try {
//       await Firebase.initializeApp();
//       // NotificationService().showLocalNotification(message, "job_alert");

//       RemoteNotification? remoteNotification = message.notification;
//       AndroidNotification? androidNotification = message.notification?.android;

//       if (remoteNotification != null && androidNotification != null) {
//         // NotificationService().showLocalNotification(RemoteMessage());
//         print(message.data);
//         print('--------------------------------------------------');

//         // var alarmModel = AlarmNotifcationModel.fromJson(message.data);

//         // print(
//         //     "======================PAYLOD ===========================================");
//         // print(
//         //   {
//         //     "eventId": alarmModel.eventId,
//         //     "name": alarmModel.name,
//         //     "sourceId": alarmModel.sourceId,
//         //     // "multiselectAsset": eventLog.
//         //   },
//         // );

//         print(
//             "===========================================================================");
//         print("Firebase message recieved ${message.data}");
//         print(
//             '====================================================================');

//         NotificationService().showLocalNotification(
//           message,
//           NotificationController.jobsChannelKey,
//         );
//       } else {
//         print("REMOTE NOTIFICATION VALUE CALLED");
//       }

//       // print(DateTime.fromMillisecondsSinceEpoch())
//     } on FirebaseException catch (e) {
//       print("firebase catch bloc called");
//       print(e.message);
//     } catch (e) {
//       print("catch bloc called");
//       print(e);
//     }
//   }

//   // ============================================================================================
//   // Firebase foreground message handler.

//   void firebaseMessageForegroundHandler() {
//     try {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         RemoteNotification? remoteNotification = message.notification;
//         AndroidNotification? androidNotification =
//             message.notification?.android;

//         if (remoteNotification != null && androidNotification != null) {
//           // NotificationService().showLocalNotification(RemoteMessage());
//           print(
//               "===========================================================================");
//           print("foreground onMessage called ${message.data}");
//           print('--------------------------------------------------');

//           showLocalNotification(
//             message,
//             NotificationController.jobsChannelKey,
//           );
//         } else {
//           print("REMOTE NOTIFICATION ELSE CALLED");
//         }
//       });
//     } on FirebaseException catch (e) {
//       print("foreground handler firebase catch bloc called");
//       print(e.message);
//     } catch (e) {
//       print("foreground handler catch bloc called");
//       print(e);
//     }
//   }

// //  =====================================================================================
// // This method is used to checking the notification allowed

//   Future<bool> checkNotificationPermission() async {
//     bool? notFirstTime = SharedPrefrencesServices().getFirstTimeStore();

//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

//     print("Notification permission $isAllowed");

//     if (!isAllowed) {
//       if (notFirstTime == null) {
//         isAllowed =
//             await AwesomeNotifications().requestPermissionToSendNotifications();
//         SharedPrefrencesServices().firstTimeStore();
//       }

//       return isAllowed;
//     }

//     return isAllowed;
//   }


// }
