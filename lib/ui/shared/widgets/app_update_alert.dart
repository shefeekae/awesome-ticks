import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:upgrader/upgrader.dart';

import '../../../main.dart';

class AppUpdateAlert extends StatelessWidget {
  const AppUpdateAlert({this.enabled = true, required this.child, super.key});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return UpgradeAlert(
      navigatorKey: MyApp.navigatorKey,
      barrierDismissible: false,
      showLater: false,
      showIgnore: false,
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      showReleaseNotes: true,
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(seconds: 1),
        debugLogging: false,
      ),
      child: child,
    );
  }
}
