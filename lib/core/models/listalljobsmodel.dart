class ListAllJobsModel {
  ListAllJobsWithPaginationSortSearch? listAllJobsWithPaginationSortSearch;

  ListAllJobsModel({this.listAllJobsWithPaginationSortSearch});

  ListAllJobsModel.fromJson(Map<String, dynamic> json) {
    listAllJobsWithPaginationSortSearch =
        json['listAllJobsWithPaginationSortSearch'] != null
            ? ListAllJobsWithPaginationSortSearch.fromJson(
                json['listAllJobsWithPaginationSortSearch'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listAllJobsWithPaginationSortSearch != null) {
      data['listAllJobsWithPaginationSortSearch'] =
          listAllJobsWithPaginationSortSearch!.toJson();
    }
    return data;
  }
}

class ListAllJobsWithPaginationSortSearch {
  List<Items>? items;
  int? totalItems;

  ListAllJobsWithPaginationSortSearch({this.items, this.totalItems});

  ListAllJobsWithPaginationSortSearch.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    totalItems = json['totalItems'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['totalItems'] = totalItems;
    return data;
  }
}

class Items {
  int? id;
  String? criticality;
  String? priority;
  String? jobName;
  int? jobStartTime;
  int? expectedEndTime;
  int? expectedDuration;
  int? actualStartTime;
  int? actualEndTime;
  int? actualDuration;
  String? jobType;
  String? nature;
  String? status;
  Assignee? assignee;
  List<ServiceRequest>? serviceRequest;
  Resource? resource;
  String? jobLocation;
  String? jobNumber;

  Items(
      {this.id,
      this.criticality,
      this.priority,
      this.jobName,
      this.jobStartTime,
      this.expectedEndTime,
      this.expectedDuration,
      this.actualStartTime,
      this.actualEndTime,
      this.actualDuration,
      this.jobType,
      this.nature,
      this.status,
      this.jobLocation,
      this.serviceRequest,
      this.assignee,
      this.resource});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    criticality = json['criticality'];
    priority = json['priority'];
    jobName = json['jobName'];
    jobStartTime = json['jobStartTime'];
    expectedEndTime = json['expectedEndTime'];
    expectedDuration = json['expectedDuration'];
    actualStartTime = json['actualStartTime'];
    actualEndTime = json['actualEndTime'];
    actualDuration = json['actualDuration'];
    jobType = json['jobType'];
    nature = json['nature'];
    status = json['status'];
    jobLocation = json['jobLocation'];
    jobNumber = json['jobNumber'];
    if (json['serviceRequest'] != null) {
      serviceRequest = <ServiceRequest>[];
      json['serviceRequest'].forEach((v) {
        serviceRequest!.add(ServiceRequest.fromJson(v));
      });
    }
    assignee =
        json['assignee'] != null ? Assignee.fromJson(json['assignee']) : null;
    resource =
        json['resource'] != null ? Resource.fromJson(json['resource']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['criticality'] = criticality;
    data['priority'] = priority;
    data['jobName'] = jobName;
    data['jobStartTime'] = jobStartTime;
    data['expectedEndTime'] = expectedEndTime;
    data['expectedDuration'] = expectedDuration;
    data['actualStartTime'] = actualStartTime;
    data['actualEndTime'] = actualEndTime;
    data['actualDuration'] = actualDuration;
    data['jobType'] = jobType;
    data['nature'] = nature;
    data['status'] = status;
    data['jobLocation'] = jobLocation;
    if (serviceRequest != null) {
      data['serviceRequest'] = serviceRequest!.map((v) => v.toJson()).toList();
    }
    if (assignee != null) {
      data['assignee'] = assignee!.toJson();
    }
    if (resource != null) {
      data['resource'] = resource!.toJson();
    }
    return data;
  }
}

class Assignee {
  int? id;
  String? name;

  Assignee({this.id, this.name});

  Assignee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Resource {
  String? domain;
  String? identifier;
  String? displayName;
  dynamic referenceId;
  dynamic resourceId;
  String? type;

  Resource(
      {this.domain,
      this.identifier,
      this.displayName,
      this.referenceId,
      this.resourceId,
      this.type});

  Resource.fromJson(Map<String, dynamic> json) {
    domain = json['domain'];
    identifier = json['identifier'];
    displayName = json['displayName'];
    referenceId = json['referenceId'];
    resourceId = json['resourceId'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['domain'] = domain;
    data['identifier'] = identifier;
    data['displayName'] = displayName;
    data['referenceId'] = referenceId;
    data['resourceId'] = resourceId;
    data['type'] = type;
    return data;
  }
}

class ServiceRequest {
  String? requestType;
  String? priority;
  int? requestTime;
  int? assignedTime;
  String? requestNumber;
  String? serviceTicketNumber;
  String? requestSubjectLine;
  String? requestStatus;
  String? requestDescription;
  List<ContactPersons>? contactPersons;
  List<AvailableSlots>? availableSlots;

  ServiceRequest(
      {this.requestType,
      this.priority,
      this.requestTime,
      this.assignedTime,
      this.requestNumber,
      this.serviceTicketNumber,
      this.requestSubjectLine,
      this.requestStatus,
      this.requestDescription,
      this.contactPersons,
      this.availableSlots});

  ServiceRequest.fromJson(Map<String, dynamic> json) {
    requestType = json['requestType'];
    priority = json['priority'];
    requestTime = json['requestTime'];
    assignedTime = json['assignedTime'];
    requestNumber = json['requestNumber'];
    serviceTicketNumber = json['serviceTicketNumber'];
    requestSubjectLine = json['requestSubjectLine'];
    requestStatus = json['requestStatus'];
    requestDescription = json['requestDescription'];
    if (json['contactPersons'] != null) {
      contactPersons = <ContactPersons>[];
      json['contactPersons'].forEach((v) {
        contactPersons!.add(ContactPersons.fromJson(v));
      });
    }
    if (json['availableSlots'] != null) {
      availableSlots = <AvailableSlots>[];
      json['availableSlots'].forEach((v) {
        availableSlots!.add(AvailableSlots.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestType'] = requestType;
    data['priority'] = priority;
    data['requestTime'] = requestTime;
    data['assignedTime'] = assignedTime;
    data['requestNumber'] = requestNumber;
    data['serviceTicketNumber'] = serviceTicketNumber;
    data['requestSubjectLine'] = requestSubjectLine;
    data['requestStatus'] = requestStatus;
    data['requestDescription'] = requestDescription;
    if (contactPersons != null) {
      data['contactPersons'] = contactPersons!.map((v) => v.toJson()).toList();
    }
    if (availableSlots != null) {
      data['availableSlots'] = availableSlots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ContactPersons {
  String? name;
  String? contactNumber;

  ContactPersons({this.name, this.contactNumber});

  ContactPersons.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    contactNumber = json['contactNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['contactNumber'] = contactNumber;
    return data;
  }
}

class AvailableSlots {
  int? endTime;
  int? startTime;

  AvailableSlots({this.endTime, this.startTime});

  AvailableSlots.fromJson(Map<String, dynamic> json) {
    endTime = json['endTime'];
    startTime = json['startTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endTime'] = endTime;
    data['startTime'] = startTime;
    return data;
  }
}
