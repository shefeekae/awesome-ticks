import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/dialog_action_model.dart';

class PlatformServices {
  bool checkPlatformIsAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }

  // void showPlatformDialog(
  //   BuildContext context, {
  //   required String title,
  //   required String message,
  //   required void Function()? onPressed,
  // }) {
  //  bool isAndroid = checkPlatformIsAndroid(context);

  //   if (!isAndroid) {
  //     showCupertinoDialog(
  //       context: context,
  //       builder: (context) {
  //         return CupertinoAlertDialog(
  //           title: Text(title),
  //           content: Text(message),
  //           actions: [
  //             CupertinoDialogAction(
  //               child: Text('Cancel'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //              CupertinoDialogAction(
  //               child: Text('Ok'),
  //               onPressed: onPressed,

  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: Text(message),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child:  Text('OK'),
  //             onPressed: onPressed,
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // ==============================================================================
  // Show platform specific error dialog

  void showPlatformAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    bool isAndroid = checkPlatformIsAndroid(context);

    if (!isAndroid) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// ==========================================================================================
// This method is used to change the desing dialogbox to platform depending

  void showPlatformDialog(
    BuildContext context, {
    required String title,
    required String message,
    void Function()? onPressed,
  }) {
    bool isAndroid = checkPlatformIsAndroid(context);

    if (!isAndroid) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                onPressed: onPressed,
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: onPressed,
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

// ============================================================================
// Currently its showing material ui date range picker.
//

  Future<DateTimeRange?> showPlatformDateRange(BuildContext context,
      [DateTimeRange? dateTimeRange]) async {
    // bool isAndroid = checkPlatformIsAndroid(context);

    // if (!isAndroid) {
    DateTimeRange? selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
      initialDateRange: dateTimeRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: Theme.of(context).primaryColor,
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onSurface: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDateRange != null) {
      DateTime selectedStartDate = selectedDateRange.start;
      DateTime selectedEndDate = selectedDateRange.end;

      DateTime startDate = DateTime(selectedStartDate.year,
          selectedStartDate.month, selectedStartDate.day);

      // Set the time to the end of the day (just before midnight of the next day)
      DateTime endDate = DateTime(selectedEndDate.year, selectedEndDate.month,
              selectedEndDate.day + 1)
          .subtract(const Duration(milliseconds: 1));

      return DateTimeRange(start: startDate, end: endDate);
    }

    return null;
  }

// ==========================================================================================
// This method is used to change the desing dialogbox to platform depending

  void showDialogWithDialogActions(
    BuildContext context, {
    required String title,
    // required String message,
    // void Function()? onPressed,
    required List<DialogActionModel> list,
  }) {
    bool isAndroid = checkPlatformIsAndroid(context);

    if (!isAndroid) {
      List<CupertinoDialogAction> actionList = list
          .map(
            (e) => CupertinoDialogAction(
              onPressed: e.onPressed,
              child: e.child,
            ),
          )
          .toList();

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            // content: Text(message),
            actions: actionList,
          );
        },
      );
    } else {
      List<TextButton> actionList = list
          .map(
            (e) => TextButton(
              onPressed: e.onPressed,
              child: e.child,
            ),
          )
          .toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            // content: Text(message),
            actions: actionList,
          );
        },
      );
    }
  }
}
