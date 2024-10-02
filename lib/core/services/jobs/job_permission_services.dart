// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:user_permission/user_permission.dart';

class JobPermissionServices {
  static final UserPermissionServices userPermissionServices =
      UserPermissionServices();

  //  ================================================
  /// Used to return job action permission
  /// * If permission is not available return true else return false

  static bool hasNoButtonPermission({
    required String buttonKey,
  }) {
    if (["startTravel", "stopTravel"].any(
      (e) => e == buttonKey,
    )) {
      return false;
    }

    const String featureGroup = "jobManagement";
    const String feature = "job";

    Map<String, dynamic> permissions = {
      "start": "startJob",
      "resume": "startJob",
      "hold": "holdJob",
      "cancel": "cancelJob",
      "complete": "completeJob",
    };

    String? permission = permissions[buttonKey];

    if (permission == null) {
      return true;
    }

    return !userPermissionServices.checkingPermission(
        featureGroup: featureGroup, feature: feature, permission: permission);
  }
}
