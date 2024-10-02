// // ignore: camel_case_types
// import 'job_details_model.dart';

// class ListAllJobsWithDetailsForSync {
//   int? id;
//   String? jobName;
//   String? jobType;
//   String? criticality;
//   String? nature;
//   String? priority;
//   int? requestTime;
//   int? jobStartTime;
//   int? expectedEndTime;
//   int? actualEndTime;
//   int? lastStatusTime;
//   int? expectedDuration;
//   String? domain;
//   String? status;
//   int? costOfJob;
//   int? costOfParts;
//   int? costOfWork;
//   int? paymentReceived;
//   // List<Null>? skillsRequired;
//   // List<Null>? toolsRequired;
//   int? attendedIn;
//   int? resolvedIn;
//   int? actualDuration;
//   String? cancellationReason;
//   Schedule? schedule;
//   AssigneeSchedule? assigneeSchedule;
//   Assignee? assignee;
//   List<Checklist>? checklist;
//   List<Parts>? parts;
//   List<Transitions>? transitions;
//   List<Comments>? comments;
//   // List<Null>? members;

//   ListAllJobsWithDetailsForSync({
//     this.id,
//     this.jobName,
//     this.jobType,
//     this.criticality,
//     this.nature,
//     this.priority,
//     this.requestTime,
//     this.jobStartTime,
//     this.expectedEndTime,
//     this.actualEndTime,
//     this.lastStatusTime,
//     this.expectedDuration,
//     this.domain,
//     this.status,
//     this.costOfJob,
//     this.costOfParts,
//     this.costOfWork,
//     this.paymentReceived,
//     // this.skillsRequired,
//     // this.toolsRequired,
//     this.attendedIn,
//     this.resolvedIn,
//     this.actualDuration,
//     this.cancellationReason,
//     this.schedule,
//     this.assigneeSchedule,
//     this.assignee,
//     this.checklist,
//     this.parts,
//     this.transitions,
//     this.comments,
//     // this.members,
//   });

//   ListAllJobsWithDetailsForSync.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     jobName = json['jobName'];
//     jobType = json['jobType'];
//     criticality = json['criticality'];
//     nature = json['nature'];
//     priority = json['priority'];
//     requestTime = json['requestTime'];
//     jobStartTime = json['jobStartTime'];
//     expectedEndTime = json['expectedEndTime'];
//     actualEndTime = json['actualEndTime'];
//     lastStatusTime = json['lastStatusTime'];
//     expectedDuration = json['expectedDuration'];
//     domain = json['domain'];
//     status = json['status'];
//     costOfJob = json['costOfJob'];
//     costOfParts = json['costOfParts'];
//     costOfWork = json['costOfWork'];
//     paymentReceived = json['paymentReceived'];
//     // if (json['skillsRequired'] != null) {
//     //   skillsRequired = <Null>[];
//     //   json['skillsRequired'].forEach((v) {
//     //     skillsRequired!.add( Null.fromJson(v));
//     //   });
//     // }
//     // if (json['toolsRequired'] != null) {
//     //   toolsRequired = <Null>[];
//     //   json['toolsRequired'].forEach((v) {
//     //     toolsRequired!.add( Null.fromJson(v));
//     //   });
//     // }
//     attendedIn = json['attendedIn'];
//     resolvedIn = json['resolvedIn'];
//     actualDuration = json['actualDuration'];
//     cancellationReason = json['cancellationReason'];
//     schedule = json['schedule'] != null
//         ?  Schedule.fromJson(json['schedule'])
//         : null;
//     assigneeSchedule = json['assigneeSchedule'] != null
//         ?  AssigneeSchedule.fromJson(json['assigneeSchedule'])
//         : null;
//     // assignee = json['assignee'] != null
//     //     ?  Assignee.fromJson(json['assignee'])
//     //     : null;
//     if (json['checklist'] != null) {
//       checklist = <Checklist>[];
//       json['checklist'].forEach((v) {
//         checklist!.add( Checklist.fromJson(v));
//       });
//     }
//     if (json['parts'] != null) {
//       parts = <Parts>[];
//       json['parts'].forEach((v) {
//         parts!.add( Parts.fromJson(v));
//       });
//     }
//     if (json['transitions'] != null) {
//       transitions = <Transitions>[];
//       json['transitions'].forEach((v) {
//         transitions!.add( Transitions.fromJson(v));
//       });
//     }
//     if (json['comments'] != null) {
//       comments = <Comments>[];
//       json['comments'].forEach((v) {
//         comments!.add( Comments.fromJson(v));
//       });
//     }
//     // if (json['members'] != null) {
//     //   members = <Null>[];
//     //   json['members'].forEach((v) {
//     //     members!.add( Null.fromJson(v));
//     //   });
//     // }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['jobName'] = this.jobName;
//     data['jobType'] = this.jobType;
//     data['criticality'] = this.criticality;
//     data['nature'] = this.nature;
//     data['priority'] = this.priority;
//     data['requestTime'] = this.requestTime;
//     data['jobStartTime'] = this.jobStartTime;
//     data['expectedEndTime'] = this.expectedEndTime;
//     data['actualEndTime'] = this.actualEndTime;
//     data['lastStatusTime'] = this.lastStatusTime;
//     data['expectedDuration'] = this.expectedDuration;
//     data['domain'] = this.domain;
//     data['status'] = this.status;
//     data['costOfJob'] = this.costOfJob;
//     data['costOfParts'] = this.costOfParts;
//     data['costOfWork'] = this.costOfWork;
//     data['paymentReceived'] = this.paymentReceived;
//     // if (this.skillsRequired != null) {
//     //   data['skillsRequired'] =
//     //       this.skillsRequired!.map((v) => v.toJson()).toList();
//     // }
//     // if (this.toolsRequired != null) {
//     //   data['toolsRequired'] =
//     //       this.toolsRequired!.map((v) => v.toJson()).toList();
//     // }
//     data['attendedIn'] = this.attendedIn;
//     data['resolvedIn'] = this.resolvedIn;
//     data['actualDuration'] = this.actualDuration;
//     data['cancellationReason'] = this.cancellationReason;
//     if (this.schedule != null) {
//       data['schedule'] = this.schedule!.toJson();
//     }
//     if (this.assigneeSchedule != null) {
//       data['assigneeSchedule'] = this.assigneeSchedule!.toJson();
//     }
//     if (this.assignee != null) {
//       data['assignee'] = this.assignee!.toJson();
//     }
//     if (this.checklist != null) {
//       data['checklist'] = this.checklist!.map((v) => v.toJson()).toList();
//     }
//     if (this.parts != null) {
//       data['parts'] = this.parts!.map((v) => v.toJson()).toList();
//     }
//     if (this.transitions != null) {
//       data['transitions'] = this.transitions!.map((v) => v.toJson()).toList();
//     }
//     if (this.comments != null) {
//       data['comments'] = this.comments!.map((v) => v.toJson()).toList();
//     }
//     // if (this.members != null) {
//     //   data['members'] = this.members!.map((v) => v.toJson()).toList();
//     // }
//     return data;
//   }
// }

// class Schedule {
//   int? id;
//   String? jobDay;
//   String? jobStartTime;
//   String? expectedEndTime;
//   int? expectedDuration;

//   Schedule(
//       {this.id,
//       this.jobDay,
//       this.jobStartTime,
//       this.expectedEndTime,
//       this.expectedDuration});

//   Schedule.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     jobDay = json['jobDay'];
//     jobStartTime = json['jobStartTime'];
//     expectedEndTime = json['expectedEndTime'];
//     expectedDuration = json['expectedDuration'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['jobDay'] = this.jobDay;
//     data['jobStartTime'] = this.jobStartTime;
//     data['expectedEndTime'] = this.expectedEndTime;
//     data['expectedDuration'] = this.expectedDuration;
//     return data;
//   }
// }

// class AssigneeSchedule {
//   int? id;
//   String? jobDay;
//   String? jobStartTime;
//   String? expectedEndTime;
//   int? expectedDuration;
//   Assignee? assignee;

//   AssigneeSchedule(
//       {this.id,
//       this.jobDay,
//       this.jobStartTime,
//       this.expectedEndTime,
//       this.expectedDuration,
//       this.assignee});

//   AssigneeSchedule.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     jobDay = json['jobDay'];
//     jobStartTime = json['jobStartTime'];
//     expectedEndTime = json['expectedEndTime'];
//     expectedDuration = json['expectedDuration'];
//     assignee = json['assignee'] != null
//         ?  Assignee.fromJson(json['assignee'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['jobDay'] = this.jobDay;
//     data['jobStartTime'] = this.jobStartTime;
//     data['expectedEndTime'] = this.expectedEndTime;
//     data['expectedDuration'] = this.expectedDuration;
//     if (this.assignee != null) {
//       data['assignee'] = this.assignee!.toJson();
//     }
//     return data;
//   }
// }

// class Assignee {
//   int? id;
//   String? name;
//   Type? type;
//   String? referenceId;
//   String? contactNumber;
//   String? emailId;
//   String? domain;
//   String? status;
//   int? costPerHour;

//   Assignee(
//       {this.id,
//       this.name,
//       this.type,
//       this.referenceId,
//       this.contactNumber,
//       this.emailId,
//       this.domain,
//       this.status,
//       this.costPerHour});

//   Assignee.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     // type = json['type'] != null ?  Type.fromJson(json['type']) : null;
//     referenceId = json['referenceId'];
//     contactNumber = json['contactNumber'];
//     emailId = json['emailId'];
//     domain = json['domain'];
//     status = json['status'];
//     costPerHour = json['costPerHour'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     // if (this.type != null) {
//     //   data['type'] = this.type!.toJson();
//     // }
//     data['referenceId'] = this.referenceId;
//     data['contactNumber'] = this.contactNumber;
//     data['emailId'] = this.emailId;
//     data['domain'] = this.domain;
//     data['status'] = this.status;
//     data['costPerHour'] = this.costPerHour;
//     return data;
//   }
// }

// class Type {
//   String? name;
//   String? templateName;
//   String? parentName;
//   String? status;

//   Type({this.name, this.templateName, this.parentName, this.status});

//   Type.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     templateName = json['templateName'];
//     parentName = json['parentName'];
//     status = json['status'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['name'] = this.name;
//     data['templateName'] = this.templateName;
//     data['parentName'] = this.parentName;
//     data['status'] = this.status;
//     return data;
//   }
// }

// // class Assignee {
// //   String? name;
// //   int? id;
// //   String? emailId;
// //   String? referenceId;
// //   String? status;
// //   String? contactNumber;
// //   String? domain;
// //   String? type;
// //   int? costPerHour;

// //   Assignee(
// //       {this.name,
// //       this.id,
// //       this.emailId,
// //       this.referenceId,
// //       this.status,
// //       this.contactNumber,
// //       this.domain,
// //       this.type,
// //       this.costPerHour});

// //   Assignee.fromJson(Map<String, dynamic> json) {
// //     name = json['name'];
// //     id = json['id'];
// //     emailId = json['emailId'];
// //     referenceId = json['referenceId'];
// //     status = json['status'];
// //     contactNumber = json['contactNumber'];
// //     domain = json['domain'];
// //     type = json['type'];
// //     costPerHour = json['costPerHour'];
// //   }

// //   Map<String, dynamic> toJson() {
// //     final Map<String, dynamic> data =  Map<String, dynamic>();
// //     data['name'] = this.name;
// //     data['id'] = this.id;
// //     data['emailId'] = this.emailId;
// //     data['referenceId'] = this.referenceId;
// //     data['status'] = this.status;
// //     data['contactNumber'] = this.contactNumber;
// //     data['domain'] = this.domain;
// //     data['type'] = this.type;
// //     data['costPerHour'] = this.costPerHour;
// //     return data;
// //   }
// // }

// // class Checklist {
// //   int? id;
// //   String? item;
// //   String? description;
// //   bool? checkable;
// //   int? executionIndex;
// //   int? maxDuration;
// //   int? startTime;
// //   int? endTime;
// //   bool? choiceType;
// //   List<Comments>? comments;

// //   Checklist(
// //       {this.id,
// //       this.item,
// //       this.description,
// //       this.checkable,
// //       this.executionIndex,
// //       this.maxDuration,
// //       this.startTime,
// //       this.endTime,
// //       this.choiceType,
// //       this.comments});

// //   Checklist.fromJson(Map<String, dynamic> json) {
// //     id = json['id'];
// //     item = json['item'];
// //     description = json['description'];
// //     checkable = json['checkable'];
// //     executionIndex = json['executionIndex'];
// //     maxDuration = json['maxDuration'];
// //     startTime = json['startTime'];
// //     endTime = json['endTime'];
// //     choiceType = json['choiceType'];
// //     if (json['comments'] != null) {
// //       comments = <Comments>[];
// //       json['comments'].forEach((v) {
// //         comments!.add( Comments.fromJson(v));
// //       });
// //     }
// //   }

// //   Map<String, dynamic> toJson() {
// //     final Map<String, dynamic> data =  Map<String, dynamic>();
// //     data['id'] = this.id;
// //     data['item'] = this.item;
// //     data['description'] = this.description;
// //     data['checkable'] = this.checkable;
// //     data['executionIndex'] = this.executionIndex;
// //     data['maxDuration'] = this.maxDuration;
// //     data['startTime'] = this.startTime;
// //     data['endTime'] = this.endTime;
// //     data['choiceType'] = this.choiceType;
// //     if (this.comments != null) {
// //       data['comments'] = this.comments!.map((v) => v.toJson()).toList();
// //     }
// //     return data;
// //   }
// // }

// class Comments {
//   int? id;
//   String? comment;
//   int? commentTime;
//   String? commentBy;
//   List<Replies>? replies;

//   Comments(
//       {this.id, this.comment, this.commentTime, this.commentBy, this.replies});

//   Comments.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     comment = json['comment'];
//     commentTime = json['commentTime'];
//     commentBy = json['commentBy'];
//     if (json['replies'] != null) {
//       replies = <Replies>[];
//       json['replies'].forEach((v) {
//         replies!.add( Replies.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['comment'] = this.comment;
//     data['commentTime'] = this.commentTime;
//     data['commentBy'] = this.commentBy;
//     if (this.replies != null) {
//       data['replies'] = this.replies!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Replies {
//   int? id;
//   String? comment;
//   int? commentTime;
//   String? commentBy;

//   Replies({this.id, this.comment, this.commentTime, this.commentBy});

//   Replies.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     comment = json['comment'];
//     commentTime = json['commentTime'];
//     commentBy = json['commentBy'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['comment'] = this.comment;
//     data['commentTime'] = this.commentTime;
//     data['commentBy'] = this.commentBy;
//     return data;
//   }
// }

// class Parts {
//   int? id;
//   String? name;
//   String? sparePartId;
//   String? partReference;
//   int? unitCost;
//   int? quantity;
//   int? totalCost;
//   String? domain;

//   Parts(
//       {this.id,
//       this.name,
//       this.sparePartId,
//       this.partReference,
//       this.unitCost,
//       this.quantity,
//       this.totalCost,
//       this.domain});

//   Parts.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     sparePartId = json['sparePartId'];
//     partReference = json['partReference'];
//     unitCost = json['unitCost'];
//     quantity = json['quantity'];
//     totalCost = json['totalCost'];
//     domain = json['domain'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['sparePartId'] = this.sparePartId;
//     data['partReference'] = this.partReference;
//     data['unitCost'] = this.unitCost;
//     data['quantity'] = this.quantity;
//     data['totalCost'] = this.totalCost;
//     data['domain'] = this.domain;
//     return data;
//   }
// }

// class Transitions {
//   int? id;
//   int? transitionTime;
//   String? currentStatus;
//   String? previousStatus;
//   String? transitionComment;

//   Transitions(
//       {this.id,
//       this.transitionTime,
//       this.currentStatus,
//       this.previousStatus,
//       this.transitionComment});

//   Transitions.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     transitionTime = json['transitionTime'];
//     currentStatus = json['currentStatus'];
//     previousStatus = json['previousStatus'];
//     transitionComment = json['transitionComment'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  Map<String, dynamic>();
//     data['id'] = this.id;
//     data['transitionTime'] = this.transitionTime;
//     data['currentStatus'] = this.currentStatus;
//     data['previousStatus'] = this.previousStatus;
//     data['transitionComment'] = this.transitionComment;
//     return data;
//   }
// }

// // class Comments {
// //   int? id;
// //   String? comment;
// //   int? commentTime;
// //   String? commentBy;
// //   Null? commentId;
// //   bool? replied;

// //   Comments(
// //       {this.id,
// //       this.comment,
// //       this.commentTime,
// //       this.commentBy,
// //       this.commentId,
// //       this.replied});

// //   Comments.fromJson(Map<String, dynamic> json) {
// //     id = json['id'];
// //     comment = json['comment'];
// //     commentTime = json['commentTime'];
// //     commentBy = json['commentBy'];
// //     commentId = json['commentId'];
// //     replied = json['replied'];
// //   }

// //   Map<String, dynamic> toJson() {
// //     final Map<String, dynamic> data =  Map<String, dynamic>();
// //     data['id'] = this.id;
// //     data['comment'] = this.comment;
// //     data['commentTime'] = this.commentTime;
// //     data['commentBy'] = this.commentBy;
// //     data['commentId'] = this.commentId;
// //     data['replied'] = this.replied;
// //     return data;
// //   }
// // }
