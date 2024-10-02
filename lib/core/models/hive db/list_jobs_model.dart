// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:hive/hive.dart';
part 'list_jobs_model.g.dart';

Box<JobDetailsDb> jobDetailsDbgetBox() =>
    Hive.box<JobDetailsDb>(JobDetailsDb.boxName);

Box<Parts> partsDbgetBox() => Hive.box<Parts>(Parts.boxName);

@HiveType(typeId: 1)
class JobDetailsDb {
  static const String boxName = "jobdetails";

  @HiveField(0)
  int? id;

  @HiveField(1)
  String? criticality;

  @HiveField(2)
  String? priority;

  @HiveField(3)
  String? jobName;

  @HiveField(4)
  int? jobStartTime;

  @HiveField(5)
  int? expectedEndTime;

  @HiveField(6)
  int? expectedDuration;

  @HiveField(7)
  int? actualStartTime;

  @HiveField(8)
  int? actualEndTime;

  @HiveField(9)
  int? actualDuration;

  @HiveField(10)
  String? jobType;

  @HiveField(11)
  String? nature;

  @HiveField(12)
  String? status;

  @HiveField(13)
  Assignee? assignee;

  @HiveField(14)
  Resource? resource;

  @HiveField(15)
  List<ChecklistDb>? checklistDb;

  @HiveField(16)
  List<JobComments>? jobComments;

  @HiveField(17)
  List<Parts>? parts;

  @HiveField(18)
  String? domain;

  @HiveField(19)
  List<Skills>? skills;

  @HiveField(20)
  List<Tools>? tools;

  @HiveField(21)
  String? communityName;

  @HiveField(22)
  String? subCommunityName;

  @HiveField(23)
  List<dynamic>? spaces;

  @HiveField(24)
  String? buildingName;

  @HiveField(25)
  String? jobLocationName;

  @HiveField(26)
  String? jobLocation;

  @HiveField(27)
  String? signedClient;

  @HiveField(28)
  String? signedTechnician;

  @HiveField(29)
  String? signedManager;

  @HiveField(30)
  List<dynamic>? transitions;

  @HiveField(31)
  int? requestTime;

  JobDetailsDb({
    this.id,
    this.requestTime,
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
    this.assignee,
    this.checklistDb,
    this.jobComments,
    this.resource,
    this.domain,
    this.skills,
    this.parts,
    this.tools,
    this.communityName,
    this.spaces,
    this.subCommunityName,
    this.buildingName,
    this.jobLocation,
    this.jobLocationName,
    this.signedClient,
    this.signedTechnician,
    this.signedManager,
    this.transitions,
  });

  JobDetailsDb.fromJson(Map<String, dynamic> json) {
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
    domain = json['domain'];
    requestTime = json['requestTime'];
    assignee =
        json['assignee'] != null ? Assignee.fromJson(json['assignee']) : null;
    resource =
        json['resource'] != null ? Resource.fromJson(json['resource']) : null;

    if (json['checklist'] != null) {
      checklistDb = [];
      json['checklist'].forEach((v) {
        checklistDb!.add(ChecklistDb.fromJson(v));
      });
    } else {
      checklistDb = [];
    }

    if (json['comments'] != null) {
      jobComments = [];
      json['comments'].forEach((v) {
        jobComments!.add(JobComments.fromJson(v));
      });
    } else {
      jobComments = [];
    }

    if (json['parts'] != null) {
      parts = <Parts>[];
      json['parts'].forEach((v) {
        parts!.add(new Parts.fromJson(v));
      });
    } else {
      parts = [];
    }

    if (json['skillsRequired'] != null) {
      skills = [];
      json['skillsRequired'].forEach((e) {
        skills!.add(Skills.fromJson(e));
      });
    }

    if (json['toolsRequired'] != null) {
      tools = [];
      json['toolsRequired'].forEach((e) {
        tools!.add(Tools.fromJson(e));
      });
    }

    jobLocationName = json['jobLocationName'];

    communityName =
        json['community'] == null ? null : json['community']["clientName"];
    subCommunityName =
        json['subCommunity'] == null ? null : json["subCommunity"]?['name'];
    if (json['spaces'] != null) {
      spaces = json['spaces'].map((e) => e['name']).toList();
    }

    buildingName = json['building'] == null ? null : json["building"]?["name"];
    jobLocation = json['jobLocation'];
    jobLocationName = json['jobLocationName'];
    signedClient = json['signedClient'];
    signedTechnician = json['signedTechnician'];
    signedManager = json['signedManager'];
    transitions = json["transitions"] == null
        ? []
        : List<dynamic>.from(json["transitions"]!.map((x) => x));
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
    data['domain'] = domain;
    data['requestTime'] = requestTime;
    if (assignee != null) {
      data['assignee'] = assignee!.toJson();
    }
    if (resource != null) {
      data['resource'] = resource!.toJson();
    }
    if (skills != null) {
      data['skillsRequired'] = skills!.map((v) => v.toJson()).toList();
    }
    if (tools != null) {
      data['toolsRequired'] = tools!.map((v) => v.toJson()).toList();
    }

    data['jobLocationName'] = jobLocationName;

    data['community'] = {"clientName": communityName};
    data['subCommunity'] = {"name": subCommunityName};
    data['building'] = {"name": buildingName};
    data['spaces'] = spaces?.map((e) => {"name": e}).toList();
    data['jobLocation'] = jobLocation;
    data['jobLocationName'] = jobLocationName;
    data['signedClient'] = signedClient;
    data['signedTechnician'] = signedTechnician;
    data['transitions'] = transitions == null
        ? []
        : List<dynamic>.from(transitions!.map((x) => x));

    return data;
  }
}

@HiveType(typeId: 2)
class Assignee {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  Assignee({id, name});

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

@HiveType(typeId: 3)
class Resource {
  @HiveField(0)
  String? domain;

  @HiveField(1)
  String? identifier;

  @HiveField(2)
  String? displayName;

  @HiveField(3)
  int? referenceId;

  @HiveField(4)
  int? resourceId;

  @HiveField(5)
  String? type;

  Resource({domain, identifier, displayName, referenceId, resourceId, type});

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

@HiveType(typeId: 4)
class ChecklistDb {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? item;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool? checkable;

  @HiveField(4)
  int? executionIndex;

  // @HiveField(5)
  // int? maxDuration;

  // @HiveField(6)
  // int? startTime;

  // @HiveField(7)
  // int? endTime;

  @HiveField(5)
  bool? choiceType;

  @HiveField(6)
  List<String>? choices;

  @HiveField(7)
  List<Comments>? comments;

  @HiveField(8)
  bool? checked;

  @HiveField(9)
  String? selectedChoice;

  @HiveField(10)
  String? type;

  ChecklistDb({
    this.id,
    this.item,
    this.description,
    this.checkable,
    this.executionIndex,
    // this.maxDuration,
    // this.startTime,
    // this.endTime,
    this.selectedChoice,
    this.choices,
    this.checked,
    this.choiceType,
    this.comments,
    this.type,
  });

  ChecklistDb.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    item = json['item'];
    description = json['description'];
    checkable = json['checkable'];
    executionIndex = json['executionIndex'];
    // maxDuration = json['maxDuration'];
    // startTime = json['startTime'];
    // endTime = json['endTime'];
    selectedChoice = json['selectedChoice'];
    choiceType = json['choiceType'];
    choices = json['choices']?.cast<String>();
    type = json['type'];
    checked = json['checked'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item'] = item;
    data['description'] = description;
    data['checkable'] = checkable;
    data['executionIndex'] = executionIndex;
    // data['maxDuration'] = maxDuration;
    // data['startTime'] = startTime;
    // data['endTime'] = endTime;
    data['choiceType'] = choiceType;
    data['selectedChoice'] = selectedChoice;
    if (comments != null) {
      data['comments'] = comments!.map((v) => v.toJson()).toList();
    }
    data['choices'] = choices;
    data['type'] = type;
    return data;
  }

  ChecklistDb copyWith({
    int? id,
    String? item,
    String? description,
    bool? checkable,
    int? executionIndex,
    bool? choiceType,
    List<String>? choices,
    List<Comments>? comments,
    bool? checked,
    String? type,
  }) {
    return ChecklistDb(
      id: id ?? this.id,
      item: item ?? this.item,
      description: description ?? this.description,
      checkable: checkable ?? this.checkable,
      executionIndex: executionIndex ?? this.executionIndex,
      choiceType: choiceType ?? this.choiceType,
      choices: choices ?? this.choices,
      comments: comments ?? this.comments,
      checked: checked ?? this.checked,
      type: type ?? this.type,
    );
  }
}

@HiveType(typeId: 5)
class Comments {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? comment;

  @HiveField(2)
  int? commentTime;

  @HiveField(3)
  String? commentBy;

  @HiveField(4)
  List<Replies>? replies;

  Comments({
    this.id,
    this.comment,
    this.commentTime,
    this.commentBy,
    this.replies,
  });

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    commentTime = json['commentTime'];
    commentBy = json['commentBy'];
    if (json['replies'] != null) {
      replies = <Replies>[];
      json['replies'].forEach((v) {
        replies!.add(Replies.fromJson(v));
      });
    } else {
      // json['replies'] = [];
      replies = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['comment'] = comment;
    data['commentTime'] = commentTime;
    data['commentBy'] = commentBy;
    if (replies != null) {
      data['replies'] = replies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 6)
class Replies {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? comment;

  @HiveField(2)
  int? commentTime;

  @HiveField(3)
  String? commentBy;

  Replies({this.id, this.comment, this.commentTime, this.commentBy});

  Replies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    commentTime = json['commentTime'];
    commentBy = json['commentBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['comment'] = comment;
    data['commentTime'] = commentTime;
    data['commentBy'] = commentBy;
    return data;
  }
}

@HiveType(typeId: 7)
class JobComments {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? comment;

  @HiveField(2)
  int? commentTime;

  @HiveField(3)
  String? commentBy;

  @HiveField(4)
  List<Replies>? replies;

  JobComments({
    this.id,
    this.comment,
    this.commentTime,
    this.commentBy,
    this.replies,
  });

  JobComments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    commentTime = json['commentTime'];
    commentBy = json['commentBy'];
    if (json['replies'] != null) {
      replies = <Replies>[];
      json['replies'].forEach((v) {
        replies!.add(Replies.fromJson(v));
      });
    } else {
      replies = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['comment'] = comment;
    data['commentTime'] = commentTime;
    data['commentBy'] = commentBy;
    if (replies != null) {
      data['replies'] = replies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 8)
class Parts {
  static String boxName = "parts";

  @HiveField(0)
  int? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? sparePartId;

  @HiveField(3)
  String? partReference;

  @HiveField(4)
  int? unitCost;
  @HiveField(5)
  int? quantity;
  @HiveField(6)
  int? totalCost;
  @HiveField(7)
  String? domain;

  Parts(
      {this.id,
      this.name,
      this.sparePartId,
      this.partReference,
      this.unitCost,
      this.quantity,
      this.totalCost,
      this.domain});

  Parts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sparePartId = json['sparePartId'];
    partReference = json['partReference'];
    unitCost = json['unitCost'];
    quantity = json['quantity'];
    totalCost = json['totalCost'];
    domain = json['domain'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['identifier'] = this.sparePartId;
    data['partReference'] = this.partReference;
    data['unitCost'] = this.unitCost;
    data['quantity'] = this.quantity;
    data['totalCost'] = this.totalCost;
    data['domain'] = this.domain;
    return data;
  }
}

@HiveType(typeId: 9)
class Skills {
  @HiveField(0)
  String? name;

  Skills({
    required this.name,
  });

  Skills.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> skill = json['skill'];

    name = skill['name'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'skill': {
        "name": name,
      },
    };
  }
}

@HiveType(typeId: 10)
class Tools {
  @HiveField(0)
  String? name;

  Tools({
    required this.name,
  });

  Tools.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> tool = json['tool'];

    name = tool['name'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tool': {
        "name": name,
      },
    };
  }
}

class Community {
  // String? sTypename;
  // String? type;
  String? clientName;
  // String? domain;
  // String? clientId;

  Community({required this.clientName});

  Community.fromJson(Map<String, dynamic> json) {
    // sTypename = json['__typename'];
    // type = json['type'];
    clientName = json['clientName'];
    // domain = json['domain'];
    // clientId = json['clientId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['__typename'] = this.sTypename;
    // data['type'] = this.type;
    data['clientName'] = this.clientName;
    // data['domain'] = this.domain;
    // data['clientId'] = this.clientId;
    return data;
  }
}

void partsStoreTolLocalDb(Map<String, dynamic> element) {
  var box = partsDbgetBox();
  box.add(Parts.fromJson(element));
}
