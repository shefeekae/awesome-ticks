// ignore_for_file: public_member_api_docs, sort_constructors_first
class ServiceDetailsModel {
  FindServiceRequest? findServiceRequest;

  ServiceDetailsModel({this.findServiceRequest});

  ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    findServiceRequest = json['findServiceRequest'] != null
        ? FindServiceRequest.fromJson(json['findServiceRequest'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (findServiceRequest != null) {
      data['findServiceRequest'] = findServiceRequest!.toJson();
    }
    return data;
  }
}

class FindServiceRequest {
  String? requestNumber;
  String? requestType;
  int? requestTime;
  String? requestSubjectLine;
  String? requestDescription;
  String? requestStatus;
  String? requestSourceLocation;
  String? requestSourceLocationName;
  String? domain;
  Community? community;
  Building? building;
  Building? subCommunity;
  Requestee? requestee;
  List<Spaces>? spaces;
  Assignee? assignee;
  int? jobId;
  String? jobNumber;
  num? customerSatisfaction;
  Resource? resource;
  String? priority;
  String? discipline;
  String? serviceTicketNumber;
  List<ContactPersons>? contactPersons;
  List<AvailableSlots>? availableSlots;

  FindServiceRequest({
    this.requestNumber,
    this.requestType,
    this.requestTime,
    this.requestSubjectLine,
    this.requestDescription,
    this.requestStatus,
    this.requestSourceLocation,
    this.requestSourceLocationName,
    this.domain,
    this.community,
    this.building,
    this.subCommunity,
    this.requestee,
    this.assignee,
    this.jobNumber,
    this.jobId,
    this.priority,
    this.discipline,
    this.serviceTicketNumber,
    this.availableSlots,
    this.contactPersons,
  });

  FindServiceRequest.fromJson(Map<String, dynamic> json) {
    requestNumber = json['requestNumber'];
    requestType = json['requestType'];
    requestTime = json['requestTime'];
    requestSubjectLine = json['requestSubjectLine'];
    requestDescription = json['requestDescription'];
    requestStatus = json['requestStatus'];
    requestSourceLocation = json['requestSourceLocation'];
    domain = json['domain'];
    customerSatisfaction = json['customerSatisfaction'];
    requestSourceLocationName = json['requestSourceLocationName'];
    resource =
        json['resource'] != null ? Resource.fromJson(json['resource']) : null;
    community = json['community'] != null
        ? Community.fromJson(json['community'])
        : null;
    building =
        json['building'] != null ? Building.fromJson(json['building']) : null;
    subCommunity = json['subCommunity'] != null
        ? Building.fromJson(json['subCommunity'])
        : null;
    requestee = json['requestee'] != null
        ? Requestee.fromJson(json['requestee'])
        : null;
    if (json['spaces'] != null) {
      spaces = <Spaces>[];
      json['spaces'].forEach((v) {
        spaces!.add(Spaces.fromJson(v));
      });
    }
    assignee =
        json['assignee'] != null ? Assignee.fromJson(json['assignee']) : null;
    jobId = json['jobId'];
    jobNumber = json['jobNumber'];
    priority = json['priority'];
    discipline = json['discipline'];
    serviceTicketNumber = json['serviceTicketNumber'];
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
    data['requestNumber'] = requestNumber;
    data['requestType'] = requestType;
    data['requestTime'] = requestTime;
    data['requestSubjectLine'] = requestSubjectLine;
    data['requestDescription'] = requestDescription;
    data['requestStatus'] = requestStatus;
    data['requestSourceLocation'] = requestSourceLocation;
    data['domain'] = domain;
    if (community != null) {
      data['community'] = community!.toJson();
    }
    if (building != null) {
      data['building'] = building!.toJson();
    }
    if (subCommunity != null) {
      data['subCommunity'] = subCommunity!.toJson();
    }
    if (requestee != null) {
      data['requestee'] = requestee!.toJson();
    }
    if (spaces != null) {
      data['spaces'] = spaces!.map((v) => v.toJson()).toList();
    }

    data['jobId'] = jobId;
    data['jobNumber'] = jobNumber;
    data['requestSourceLocationName'] = requestSourceLocationName;
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

class Community {
  String? clientId;
  String? clientName;
  String? domain;
  String? type;

  Community({this.clientId, this.clientName, this.domain, this.type});

  Community.fromJson(Map<String, dynamic> json) {
    clientId = json['clientId'];
    clientName = json['clientName'];
    domain = json['domain'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientId'] = clientId;
    data['clientName'] = clientName;
    data['domain'] = domain;
    data['type'] = type;
    return data;
  }
}

class Building {
  String? identifier;
  String? type;
  String? domain;
  String? name;
  String? geoLocation;
  String? status;

  Building(
      {this.identifier,
      this.type,
      this.domain,
      this.name,
      this.geoLocation,
      this.status});

  Building.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    type = json['type'];
    domain = json['domain'];
    name = json['name'];
    geoLocation = json['geoLocation'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['type'] = type;
    data['domain'] = domain;
    data['name'] = name;
    data['geoLocation'] = geoLocation;
    data['status'] = status;
    return data;
  }
}

class Requestee {
  String? name;
  int? id;
  String? emailId;
  String? referenceId;
  String? status;
  String? contactNumber;
  String? domain;
  String? type;

  Requestee(
      {this.name,
      this.id,
      this.emailId,
      this.referenceId,
      this.status,
      this.contactNumber,
      this.domain,
      this.type});

  Requestee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    emailId = json['emailId'];
    referenceId = json['referenceId'];
    status = json['status'];
    contactNumber = json['contactNumber'];
    domain = json['domain'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['emailId'] = emailId;
    data['referenceId'] = referenceId;
    data['status'] = status;
    data['contactNumber'] = contactNumber;
    data['domain'] = domain;
    data['type'] = type;
    return data;
  }
}

class Assignee {
  String? name;
  int? id;
  String? emailId;
  String? referenceId;
  String? status;
  String? contactNumber;
  String? domain;
  String? type;

  Assignee(
      {this.name,
      this.id,
      this.emailId,
      this.referenceId,
      this.status,
      this.contactNumber,
      this.domain,
      this.type});

  Assignee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    emailId = json['emailId'];
    referenceId = json['referenceId'];
    status = json['status'];
    contactNumber = json['contactNumber'];
    domain = json['domain'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['emailId'] = emailId;
    data['referenceId'] = referenceId;
    data['status'] = status;
    data['contactNumber'] = contactNumber;
    data['domain'] = domain;
    data['type'] = type;
    return data;
  }
}

class Spaces {
  String? identifier;
  String? type;
  String? domain;
  String? name;
  String? status;

  Spaces({this.identifier, this.type, this.domain, this.name, this.status});

  Spaces.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    type = json['type'];
    domain = json['domain'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['type'] = type;
    data['domain'] = domain;
    data['name'] = name;
    data['status'] = status;
    return data;
  }
}

class Resource {
  final String type;
  final String identifier;
  final String displayName;
  final String domain;
  Resource({
    required this.type,
    required this.identifier,
    required this.displayName,
    required this.domain,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      type: json['type'] ?? "",
      identifier: json['identifier'] ?? "",
      displayName: json['displayName'] ?? "",
      domain: json['domain'] ?? "",
    );
  }
}
