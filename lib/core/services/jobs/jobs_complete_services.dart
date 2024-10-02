import 'dart:convert';

import 'package:secure_storage/secure_storage.dart';

class JobCompleteServices {
// =================================================
// This function return the true/false if the runHours field show or not show.

  bool checkRunHoursMandatory() {
    var data = SharedPrefrencesServices().getData(key: "appTheme");

    Map<String, dynamic>? appthemeDataDecoded =
        data == null ? null : jsonDecode(data);

    bool runHoursMandatory = appthemeDataDecoded?['jobConfiguration']
            ?['runHoursMandatory'] ??
        false;

    return runHoursMandatory;
  }
}
