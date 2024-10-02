class TimeSheetDataModel {
  List<GetTimeSheetData>? getTimeSheetData;

  TimeSheetDataModel({
    this.getTimeSheetData,
  });

  factory TimeSheetDataModel.fromJson(Map<String, dynamic> json) =>
      TimeSheetDataModel(
        getTimeSheetData: json["getTimeSheetData"] == null
            ? []
            : List<GetTimeSheetData>.from(json["getTimeSheetData"]!
                .map((x) => GetTimeSheetData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "getTimeSheetData": getTimeSheetData == null
            ? []
            : List<dynamic>.from(getTimeSheetData!.map((x) => x.toJson())),
      };
}

class GetTimeSheetData {
  Assignee? assignee;
  int? startTime;
  int? endTime;
  String? startLocation;
  dynamic endLocation;
  String? startLocationName;
  dynamic endLocationName;
  int? timesheetDay;
  dynamic duration;
  String? activity;
  String? jobTripReference;

  GetTimeSheetData({
    this.assignee,
    this.startTime,
    this.endTime,
    this.startLocation,
    this.endLocation,
    this.startLocationName,
    this.endLocationName,
    this.timesheetDay,
    this.duration,
    this.activity,
    this.jobTripReference,
  });

  factory GetTimeSheetData.fromJson(Map<String, dynamic> json) =>
      GetTimeSheetData(
        assignee: json["assignee"] == null
            ? null
            : Assignee.fromJson(json["assignee"]),
        startTime: json["startTime"],
        endTime: json["endTime"],
        startLocation: json["startLocation"],
        endLocation: json["endLocation"],
        startLocationName: json["startLocationName"],
        endLocationName: json["endLocationName"],
        timesheetDay: json["timesheetDay"],
        duration: json["duration"],
        activity: json["activity"],
        jobTripReference: json["jobTripReference"],
      );

  Map<String, dynamic> toJson() => {
        "assignee": assignee?.toJson(),
        "startTime": startTime,
        "endTime": endTime,
        "startLocation": startLocation,
        "endLocation": endLocation,
        "startLocationName": startLocationName,
        "endLocationName": endLocationName,
        "timesheetDay": timesheetDay,
        "duration": duration,
        "activity": activity,
        "jobTripReference": jobTripReference,
      };
}

class Assignee {
  int? id;
  String? name;

  Assignee({
    this.id,
    this.name,
  });

  factory Assignee.fromJson(Map<String, dynamic> json) => Assignee(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
