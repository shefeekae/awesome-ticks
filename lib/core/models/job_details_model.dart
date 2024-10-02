// To parse this JSON data, do
//
//     final jobDetailsModel = jobDetailsModelFromJson(jsonString);

import 'dart:convert';

JobDetailsModel jobDetailsModelFromJson(Map<String, dynamic> map) =>
    JobDetailsModel.fromJson(map);

String jobDetailsModelToJson(JobDetailsModel data) =>
    json.encode(data.toJson());

class JobDetailsModel {
  JobDetailsModel({
    this.findJobWithId,
  });

  FindJobWithId? findJobWithId;

  factory JobDetailsModel.fromJson(Map<String, dynamic> json) =>
      JobDetailsModel(
        findJobWithId: json["findJobWithId"] == null
            ? null
            : FindJobWithId.fromJson(json["findJobWithId"]),
      );

  Map<String, dynamic> toJson() => {
        "findJobWithId": findJobWithId?.toJson(),
      };
}

class FindJobWithId {
  FindJobWithId({
    this.checklist,
    this.completionRemark,
    this.costOfJob,
    this.costOfParts,
    this.costOfWork,
    this.criticality,
    this.priority,
    this.customerSatisfaction,
    this.expectedDuration,
    this.expectedEndTime,
    this.generatedFrom,
    this.id,
    // this.jobDomain,
    this.domain,
    this.jobLocation,
    this.jobSource,
    this.jobStartTime,
    this.jobType,
    this.jobRemark,
    this.nature,
    this.parts,
    this.paymentReceived,
    this.requestRemark,
    this.requestTime,
    this.requesteeName,
    this.toolsRequired,
    this.skillsRequired,
    this.status,
    this.resource,
    this.jobName,
    this.actualStartTime,
    this.assignee,
    this.managedBy,
    this.requestedBy,
    this.actualEndTime,
    this.lastStatusTime,
    this.jobAssignedTime,
    this.vendor,
    this.community,
    this.subCommunity,
    this.building,
    this.spaces,
    this.transitions,
    this.serviceRequest,
    this.members,
    this.runhours,
    this.odometer,
    this.jobLocationName,
    this.jobNumber,
    this.signedClient,
    this.signedManager,
    this.signedTechnician,
    this.discipline,
    this.hasTravelTime,
    this.hasTravelTimeIncluded,
  });

  List<Checklist>? checklist;
  String? completionRemark;
  int? costOfJob;
  int? costOfParts;
  int? costOfWork;
  String? criticality;
  String? signedTechnician;
  String? signedClient;
  String? signedManager;
  String? priority;
  String? discipline;
  dynamic customerSatisfaction;
  int? expectedDuration;
  int? expectedEndTime;
  dynamic generatedFrom;
  int? id;
  String? jobNumber;
  // dynamic jobDomain;
  String? domain;
  String? jobLocation;
  dynamic jobSource;
  int? jobStartTime;
  String? jobType;
  dynamic jobRemark;
  String? nature;
  List<dynamic>? parts;
  int? paymentReceived;
  dynamic requestRemark;
  int? requestTime;
  dynamic requesteeName;
  List<dynamic>? toolsRequired;
  List<dynamic>? skillsRequired;
  String? status;
  Resource? resource;
  String? jobName;
  String? jobLocationName;
  dynamic actualStartTime;
  Assignee? assignee;
  dynamic managedBy;
  Assignee? requestedBy;
  dynamic actualEndTime;
  dynamic lastStatusTime;
  dynamic jobAssignedTime;
  dynamic vendor;
  Community? community;
  dynamic subCommunity;
  dynamic building;
  dynamic spaces;
  List<dynamic>? transitions;
  List<ServiceRequest>? serviceRequest;
  List<dynamic>? members;
  dynamic runhours;
  dynamic odometer;
  bool? hasTravelTime;
  bool? hasTravelTimeIncluded;

  factory FindJobWithId.fromJson(Map<String, dynamic> json) => FindJobWithId(
        jobLocationName: json["jobLocationName"],

        checklist: json["checklist"] == null
            ? []
            : List<Checklist>.from(
                json["checklist"]!.map((x) => Checklist.fromJson(x))),
        completionRemark: json["completionRemark"],
        costOfJob: json["costOfJob"],
        costOfParts: json["costOfParts"],
        costOfWork: json["costOfWork"],
        criticality: json["criticality"],
        priority: json["priority"],
        customerSatisfaction: json["customerSatisfaction"],
        expectedDuration: json["expectedDuration"],
        expectedEndTime: json["expectedEndTime"],
        generatedFrom: json["generatedFrom"],
        id: json["id"],
        jobNumber: json['jobNumber'],
        // jobDomain: json["jobDomain"],
        jobLocation: json["jobLocation"],
        jobSource: json["jobSource"],
        jobStartTime: json["jobStartTime"],
        jobType: json["jobType"],
        jobRemark: json["jobRemark"],
        nature: json["nature"],
        parts: json["parts"] == null
            ? []
            : List<dynamic>.from(json["parts"]!.map((x) => x)),
        paymentReceived: json["paymentReceived"],
        requestRemark: json["requestRemark"],
        requestTime: json["requestTime"],
        requesteeName: json["requesteeName"],
        toolsRequired: json["toolsRequired"] == null
            ? []
            : List<dynamic>.from(json["toolsRequired"]!.map((x) => x)),
        skillsRequired: json["skillsRequired"] == null
            ? []
            : List<dynamic>.from(json["skillsRequired"]!.map((x) => x)),
        status: json["status"],
        resource: json["resource"] == null
            ? null
            : Resource.fromJson(json["resource"]),
        jobName: json["jobName"],
        actualStartTime: json["actualStartTime"],
        assignee: json['assignee'] == null
            ? null
            : Assignee.fromJson(json["assignee"]),
        managedBy: json["managedBy"],
        requestedBy: json['requestedBy'] == null
            ? null
            : Assignee.fromJson(json["requestedBy"]),
        actualEndTime: json["actualEndTime"],
        lastStatusTime: json["lastStatusTime"],
        jobAssignedTime: json["jobAssignedTime"],
        vendor: json["vendor"],
        community: json["community"] == null
            ? null
            : Community.fromJson(json["community"]),
        subCommunity: json["subCommunity"],
        building: json["building"],
        spaces: json["spaces"],
        transitions: json["transitions"] == null
            ? []
            : List<dynamic>.from(json["transitions"]!.map((x) => x)),
        serviceRequest: json["serviceRequest"] == null
            ? []
            : List<ServiceRequest>.from(
                json["serviceRequest"]!.map((x) => ServiceRequest.fromJson(x))),
        members: json["members"] == null
            ? []
            : List<dynamic>.from(json["members"]!.map((x) => x)),
        runhours: json["runhours"],
        odometer: json["odometer"],
        domain: json['domain'],
        signedTechnician: json['signedTechnician'],
        signedClient: json['signedClient'],
        signedManager: json['signedManager'],
        discipline: json['discipline'],
        hasTravelTime: json['hasTravelTime'],
        hasTravelTimeIncluded: json['hasTravelTimeIncluded'],
      );

  Map<String, dynamic> toJson() => {
        "jobLocationName": jobLocationName,
        "checklist": checklist == null
            ? []
            : List<dynamic>.from(checklist!.map((x) => x.toJson())),
        "completionRemark": completionRemark,
        "costOfJob": costOfJob,
        "costOfParts": costOfParts,
        "costOfWork": costOfWork,
        "criticality": criticality,
        "priority": priority,
        "customerSatisfaction": customerSatisfaction,
        "expectedDuration": expectedDuration,
        "expectedEndTime": expectedEndTime,
        "generatedFrom": generatedFrom,
        "id": id,
        // "jobDomain": jobDomain,
        "jobLocation": jobLocation,
        "jobSource": jobSource,
        "jobStartTime": jobStartTime,
        "jobType": jobType,
        "jobRemark": jobRemark,
        "nature": nature,
        "parts": parts == null ? [] : List<dynamic>.from(parts!.map((x) => x)),
        "paymentReceived": paymentReceived,
        "requestRemark": requestRemark,
        "requestTime": requestTime,
        "requesteeName": requesteeName,
        "toolsRequired": toolsRequired == null
            ? []
            : List<dynamic>.from(toolsRequired!.map((x) => x)),
        "skillsRequired": skillsRequired == null
            ? []
            : List<dynamic>.from(skillsRequired!.map((x) => x)),
        "status": status,
        "resource": resource?.toJson(),
        "jobName": jobName,
        "actualStartTime": actualStartTime,
        "assignee": assignee,
        "managedBy": managedBy,
        "requestedBy": requestedBy,
        "actualEndTime": actualEndTime,
        "lastStatusTime": lastStatusTime,
        "jobAssignedTime": jobAssignedTime,
        "vendor": vendor,
        "community": community?.toJson(),
        "subCommunity": subCommunity,
        "building": building,
        "spaces": spaces,
        "transitions": transitions == null
            ? []
            : List<dynamic>.from(transitions!.map((x) => x)),
        "serviceRequest": serviceRequest == null
            ? []
            : List<dynamic>.from(serviceRequest!.map((x) => x.toJson())),
        "members":
            members == null ? [] : List<dynamic>.from(members!.map((x) => x)),
        "runhours": runhours,
        "odometer": odometer,
        "hasTravelTime": hasTravelTime,
        "hasTravelTimeIncluded": hasTravelTimeIncluded,
      };
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
  List<ContactPerson>? contactPersons;
  List<AvailableSlot>? availableSlots;

  ServiceRequest({
    this.requestType,
    this.priority,
    this.requestTime,
    this.assignedTime,
    this.requestNumber,
    this.serviceTicketNumber,
    this.requestSubjectLine,
    this.requestStatus,
    this.requestDescription,
    this.contactPersons,
    this.availableSlots,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
        requestType: json["requestType"],
        priority: json["priority"],
        requestTime: json["requestTime"],
        assignedTime: json["assignedTime"],
        requestNumber: json["requestNumber"],
        serviceTicketNumber: json["serviceTicketNumber"],
        requestSubjectLine: json["requestSubjectLine"],
        requestStatus: json["requestStatus"],
        requestDescription: json["requestDescription"],
        contactPersons: json["contactPersons"] == null
            ? []
            : List<ContactPerson>.from(
                json["contactPersons"]!.map((x) => ContactPerson.fromJson(x))),
        availableSlots: json["availableSlots"] == null
            ? []
            : List<AvailableSlot>.from(
                json["availableSlots"]!.map((x) => AvailableSlot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "requestType": requestType,
        "priority": priority,
        "requestTime": requestTime,
        "assignedTime": assignedTime,
        "requestNumber": requestNumber,
        "serviceTicketNumber": serviceTicketNumber,
        "requestSubjectLine": requestSubjectLine,
        "requestStatus": requestStatus,
        "requestDescription": requestDescription,
        "contactPersons": contactPersons == null
            ? []
            : List<dynamic>.from(contactPersons!.map((x) => x.toJson())),
        "availableSlots": availableSlots == null
            ? []
            : List<dynamic>.from(availableSlots!.map((x) => x.toJson())),
      };
}

class AvailableSlot {
  int? endTime;
  int? startTime;

  AvailableSlot({
    this.endTime,
    this.startTime,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
        endTime: json["endTime"],
        startTime: json["startTime"],
      );

  Map<String, dynamic> toJson() => {
        "endTime": endTime,
        "startTime": startTime,
      };
}

class ContactPerson {
  String? name;
  String? contactNumber;

  ContactPerson({
    this.name,
    this.contactNumber,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) => ContactPerson(
        name: json["name"],
        contactNumber: json["contactNumber"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "contactNumber": contactNumber,
      };
}

class Checklist {
  Checklist({
    this.item,
    this.id,
    this.description,
    this.commentCount,
    this.checkable,
    this.checked,
    this.executionIndex,
    this.attachments,
    this.choiceType,
    this.choices,
    this.selectedChoice,
    this.type,
  });

  String? item;
  int? id;
  String? description;
  int? commentCount;
  bool? checkable;
  dynamic checked;
  int? executionIndex;
  dynamic attachments;
  bool? choiceType;
  dynamic choices;
  dynamic selectedChoice;
  String? type;

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        item: json["item"],
        id: json["id"],
        description: json["description"],
        commentCount: json["commentCount"],
        checkable: json["checkable"],
        checked: json["checked"],
        executionIndex: json["executionIndex"],
        attachments: json["attachments"],
        choiceType: json["choiceType"],
        choices: json["choices"],
        selectedChoice: json["selectedChoice"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "item": item,
        "id": id,
        "description": description,
        "commentCount": commentCount,
        "checkable": checkable,
        "checked": checked,
        "executionIndex": executionIndex,
        "attachments": attachments,
        "choiceType": choiceType,
        "choices": choices,
        "selectedChoice": selectedChoice,
        "type": type,
      };
}

class Community {
  Community({
    this.type,
    this.clientName,
    this.domain,
    this.clientId,
  });

  String? type;
  String? clientName;
  String? domain;
  String? clientId;

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        type: json["type"],
        clientName: json["clientName"],
        domain: json["domain"],
        clientId: json["clientId"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "clientName": clientName,
        "domain": domain,
        "clientId": clientId,
      };
}

class Resource {
  Resource({
    this.domain,
    this.identifier,
    this.displayName,
    this.referenceId,
    this.resourceId,
    this.type,
  });

  String? domain;
  String? identifier;
  String? displayName;
  dynamic referenceId;
  dynamic resourceId;
  String? type;

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
        domain: json["domain"],
        identifier: json["identifier"],
        displayName: json["displayName"],
        referenceId: json["referenceId"],
        resourceId: json["resourceId"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "domain": domain,
        "identifier": identifier,
        "displayName": displayName,
        "referenceId": referenceId,
        "resourceId": resourceId,
        "type": type,
      };
}

class Assignee {
  String? name;
  int? id;
  String? domain;
  int? costPerHour;
  String? contactNumber;
  String? referenceId;
  String? status;
  String? emailId;

  Assignee(
      {this.name,
      this.id,
      this.domain,
      this.costPerHour,
      this.contactNumber,
      this.referenceId,
      this.status,
      this.emailId});

  Assignee.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    domain = json['domain'];
    costPerHour = json['costPerHour'];
    contactNumber = json['contactNumber'];
    referenceId = json['referenceId'];
    status = json['status'];
    emailId = json['emailId'];
  }
}
