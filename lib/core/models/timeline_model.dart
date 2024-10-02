class TimelineModel {
  List<GetServiceRequestTransitions>? getServiceRequestTransitions;

  TimelineModel({this.getServiceRequestTransitions});

  TimelineModel.fromJson(Map<String, dynamic> json) {
    if (json['getServiceRequestTransitions'] != null) {
      getServiceRequestTransitions = <GetServiceRequestTransitions>[];
      json['getServiceRequestTransitions'].forEach((v) {
        getServiceRequestTransitions!
            .add(GetServiceRequestTransitions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getServiceRequestTransitions != null) {
      data['getServiceRequestTransitions'] =
          getServiceRequestTransitions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetServiceRequestTransitions {
  int? id;
  int? transitionTime;
  String? currentStatus;
  String? previousStatus;
  String? transitionComment;

  GetServiceRequestTransitions(
      {this.id,
      this.transitionTime,
      this.currentStatus,
      this.previousStatus,
      this.transitionComment});

  GetServiceRequestTransitions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transitionTime = json['transitionTime'];
    currentStatus = json['currentStatus'];
    previousStatus = json['previousStatus'];
    transitionComment = json['transitionComment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['transitionTime'] = transitionTime;
    data['currentStatus'] = currentStatus;
    data['previousStatus'] = previousStatus;
    data['transitionComment'] = transitionComment;
    return data;
  }
}
