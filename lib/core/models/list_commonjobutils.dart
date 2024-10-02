
class ListJobCommonUtilsModel {
  ListJobCommonUtils? listJobCommonUtils;

  ListJobCommonUtilsModel({this.listJobCommonUtils});

  ListJobCommonUtilsModel.fromJson(Map<String, dynamic> json) {
    listJobCommonUtils = json['listJobCommonUtils'] != null
        ? new ListJobCommonUtils.fromJson(json['listJobCommonUtils'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listJobCommonUtils != null) {
      data['listJobCommonUtils'] = this.listJobCommonUtils!.toJson();
    }
    return data;
  }
}

class ListJobCommonUtils {
  List<CommonData>? jobTypes;
  List<CommonData>? criticality;
  List<CommonData>? jobNature;
  List<CommonData>? priorities;
  List<CommonData>? ticketStatus;

  ListJobCommonUtils(
      {this.jobTypes,
      this.criticality,
      this.jobNature,
      this.priorities,
      this.ticketStatus});

  ListJobCommonUtils.fromJson(Map<String, dynamic> json) {
    if (json['jobTypes'] != null) {
      jobTypes = <CommonData>[];
      json['jobTypes'].forEach((v) {
        jobTypes!.add(new CommonData.fromJson(v));
      });
    }
    if (json['criticality'] != null) {
      criticality = <CommonData>[];
      json['criticality'].forEach((v) {
        criticality!.add(new CommonData.fromJson(v));
      });
    }
    if (json['jobNature'] != null) {
      jobNature = <CommonData>[];
      json['jobNature'].forEach((v) {
        jobNature!.add(new CommonData.fromJson(v));
      });
    }
    if (json['priorities'] != null) {
      priorities = <CommonData>[];
      json['priorities'].forEach((v) {
        priorities!.add(new CommonData.fromJson(v));
      });
    }
    if (json['ticketStatus'] != null) {
      ticketStatus = <CommonData>[];
      json['ticketStatus'].forEach((v) {
        ticketStatus!.add(new CommonData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.jobTypes != null) {
      data['jobTypes'] = this.jobTypes!.map((v) => v.toJson()).toList();
    }
    if (this.criticality != null) {
      data['criticality'] = this.criticality!.map((v) => v.toJson()).toList();
    }
    if (this.jobNature != null) {
      data['jobNature'] = this.jobNature!.map((v) => v.toJson()).toList();
    }
    if (this.priorities != null) {
      data['priorities'] = this.priorities!.map((v) => v.toJson()).toList();
    }
    if (this.ticketStatus != null) {
      data['ticketStatus'] = this.ticketStatus!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommonData {
  String? key;
  String? value;

  CommonData({this.key, this.value});

  CommonData.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}
