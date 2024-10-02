class ListServiceRequestModel {
  ListServiceRequests? listServiceRequests;

  ListServiceRequestModel({this.listServiceRequests});

  ListServiceRequestModel.fromJson(Map<String, dynamic> json) {
    listServiceRequests = json['listServiceRequests'] != null
        ? new ListServiceRequests.fromJson(json['listServiceRequests'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listServiceRequests != null) {
      data['listServiceRequests'] = this.listServiceRequests!.toJson();
    }
    return data;
  }
}

class ListServiceRequests {
  List<Items>? items;
  int? totalItems;

  ListServiceRequests({this.items, this.totalItems});

  ListServiceRequests.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    totalItems = json['totalItems'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['totalItems'] = this.totalItems;
    return data;
  }
}

class Items {
  String? requestNumber;
  String? requestType;
  int? requestTime;
  Null? assignedTime;
  String? requestSubjectLine;
  String? requestDescription;
  String? requestStatus;
  String? requestSourceLocation;
  String? domain;
  String? jobId;
  Requestee? requestee;
  ManagedBy? managedBy;
  String? createdBy;
  int? createdOn;
  String? updatedBy;
  String? updatedOn;

  Items(
      {this.requestNumber,
      this.requestType,
      this.requestTime,
      this.assignedTime,
      this.requestSubjectLine,
      this.requestDescription,
      this.requestStatus,
      this.requestSourceLocation,
      this.domain,
      this.jobId,
      this.requestee,
      this.managedBy,
      this.createdBy,
      this.createdOn,
      this.updatedBy,
      this.updatedOn});

  Items.fromJson(Map<String, dynamic> json) {
    requestNumber = json['requestNumber'];
    requestType = json['requestType'];
    requestTime = json['requestTime'];
    assignedTime = json['assignedTime'];
    requestSubjectLine = json['requestSubjectLine'];
    requestDescription = json['requestDescription'];
    requestStatus = json['requestStatus'];
    requestSourceLocation = json['requestSourceLocation'];
    domain = json['domain'];
    jobId = json['jobId'];
    requestee = json['requestee'] != null
        ? new Requestee.fromJson(json['requestee'])
        : null;
    managedBy = json['managedBy'] != null
        ? new ManagedBy.fromJson(json['managedBy'])
        : null;
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    updatedBy = json['updatedBy'];
    updatedOn = json['updatedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requestNumber'] = this.requestNumber;
    data['requestType'] = this.requestType;
    data['requestTime'] = this.requestTime;
    data['assignedTime'] = this.assignedTime;
    data['requestSubjectLine'] = this.requestSubjectLine;
    data['requestDescription'] = this.requestDescription;
    data['requestStatus'] = this.requestStatus;
    data['requestSourceLocation'] = this.requestSourceLocation;
    data['domain'] = this.domain;
    data['jobId'] = this.jobId;
    if (this.requestee != null) {
      data['requestee'] = this.requestee!.toJson();
    }
    if (this.managedBy != null) {
      data['managedBy'] = this.managedBy!.toJson();
    }
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['updatedBy'] = this.updatedBy;
    data['updatedOn'] = this.updatedOn;
    return data;
  }
}

class Requestee {
  String? name;
  String? id;
  String? emailId;
  String? contactNumber;

  Requestee({this.name, this.id, this.emailId, this.contactNumber});

  Requestee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    emailId = json['emailId'];
    contactNumber = json['contactNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['emailId'] = this.emailId;
    data['contactNumber'] = this.contactNumber;
    return data;
  }
}

class ManagedBy {
  String? name;
  int? id;
  String? referenceId;

  ManagedBy({this.name, this.id, this.referenceId});

  ManagedBy.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    referenceId = json['referenceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['referenceId'] = this.referenceId;
    return data;
  }
}
