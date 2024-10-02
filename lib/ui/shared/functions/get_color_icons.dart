// =================================================================
// GEt criticality colors.

import 'package:flutter/material.dart';

import '../../../utils/themes/colors.dart';

Color getStatusColor(String key) {
  switch (key) {
    case "REGISTERED":
    case "SCHEDULED":
      return Colors.blue.shade800;

    case "COMPLETED":
      return Colors.green;

    case "INPROGRESS":
      return Colors.amber;

    case "CANCELED":
    case "CANCELLED":
      return Colors.red;

    case "CLOSED":
      return Colors.green.shade700;

    // case "INPROGRESS":
    // case "HELD":
    //   return Colors.amber.shade300;

    // case "SCHEDULED":
    //   return Colors.lime.shade700;

    case "OPEN":
      return Colors.red.shade500;

    // case "CLOSED":
    //   return Colors.green;

    // case "CANCELLED":
    //   return Colors.red.shade800;

    // case "COMPLETED":
    //   return Colors.green.shade700;  

    default:
      return Colors.orange;
  }
}

// =================================================================
// GEt criticality colors.

Color getCriticalityColor(String key) {
  switch (key) {
    case "MEDIUM":
      return Colors.amber;

    case "CRITICAL":
      return Colors.red.shade800;

    case "HIGH":
      return Colors.red;

    case "LOW":
      return Colors.blue;

    default:
      return Colors.blue.shade800;
  }
}

// ================================================================

Color getStatusTextColor(String key) {
  switch (key) {
    case "INPROGRESS":
      return kBlack;

    default:
      return kWhite;
  }
}

IconData getIcon(String key) {

  switch (key) {
    case "MAINTENANCE":
      return Icons.label_important_outline_rounded;

    case "COMPLAINT":
      return Icons.info_outline;

    case "FEEDBACK":
      return Icons.star_border_outlined;

    case "SERVICE":
      return Icons.safety_check;

    case "ISSUE":
      return Icons.flag_outlined;

    case "INSPECTION":
      return Icons.import_contacts;

    case "SUGGESTION":
      return Icons.settings_suggest;

    case "INSIDENT":
      return Icons.all_inclusive_rounded;

    case "CALLOUT":
      return Icons.call_outlined;

    case "MOVE_IN":
      return Icons.login;

    case "MOVE_OUT":
      return Icons.logout;

    default:
      return Icons.more_outlined;
  }
}


// =========================================================================================
//TODO : This method is used to show the criticality wise colors


Color getCriticalityColors({required String criticaliy}) {
    if (criticaliy == "HIGH") {
      return Colors.red;
    } else if (criticaliy == "CRITICAL") {
      return Colors.red.shade900;
    } else if (criticaliy == "MEDIUM") {
      return Colors.orange;
    } else if (criticaliy == "LOW") {
      return Colors.yellow.shade700;
    }

    return Colors.white;
  }

  // ===========================================================================================
// This method is used to show the status of alarm.

  Map<String, dynamic> getStausofAlarm(
      {required bool active, required bool resolved}) {
    if (active) {
      return {"text": "Active", "color": Colors.red.shade700};
    } else if (resolved) {
      return {"text": "Resolved", "color": Colors.green};
    }
    return {
      "text": "",
      "color": Colors.yellow,
    };
  }