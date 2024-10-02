// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_jobs_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobDetailsDbAdapter extends TypeAdapter<JobDetailsDb> {
  @override
  final int typeId = 1;

  @override
  JobDetailsDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobDetailsDb(
      id: fields[0] as int?,
      requestTime: fields[31] as int?,
      criticality: fields[1] as String?,
      priority: fields[2] as String?,
      jobName: fields[3] as String?,
      jobStartTime: fields[4] as int?,
      expectedEndTime: fields[5] as int?,
      expectedDuration: fields[6] as int?,
      actualStartTime: fields[7] as int?,
      actualEndTime: fields[8] as int?,
      actualDuration: fields[9] as int?,
      jobType: fields[10] as String?,
      nature: fields[11] as String?,
      status: fields[12] as String?,
      assignee: fields[13] as Assignee?,
      checklistDb: (fields[15] as List?)?.cast<ChecklistDb>(),
      jobComments: (fields[16] as List?)?.cast<JobComments>(),
      resource: fields[14] as Resource?,
      domain: fields[18] as String?,
      skills: (fields[19] as List?)?.cast<Skills>(),
      parts: (fields[17] as List?)?.cast<Parts>(),
      tools: (fields[20] as List?)?.cast<Tools>(),
      communityName: fields[21] as String?,
      spaces: (fields[23] as List?)?.cast<dynamic>(),
      subCommunityName: fields[22] as String?,
      buildingName: fields[24] as String?,
      jobLocation: fields[26] as String?,
      jobLocationName: fields[25] as String?,
      signedClient: fields[27] as String?,
      signedTechnician: fields[28] as String?,
      signedManager: fields[29] as String?,
      transitions: (fields[30] as List?)?.cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, JobDetailsDb obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.criticality)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.jobName)
      ..writeByte(4)
      ..write(obj.jobStartTime)
      ..writeByte(5)
      ..write(obj.expectedEndTime)
      ..writeByte(6)
      ..write(obj.expectedDuration)
      ..writeByte(7)
      ..write(obj.actualStartTime)
      ..writeByte(8)
      ..write(obj.actualEndTime)
      ..writeByte(9)
      ..write(obj.actualDuration)
      ..writeByte(10)
      ..write(obj.jobType)
      ..writeByte(11)
      ..write(obj.nature)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.assignee)
      ..writeByte(14)
      ..write(obj.resource)
      ..writeByte(15)
      ..write(obj.checklistDb)
      ..writeByte(16)
      ..write(obj.jobComments)
      ..writeByte(17)
      ..write(obj.parts)
      ..writeByte(18)
      ..write(obj.domain)
      ..writeByte(19)
      ..write(obj.skills)
      ..writeByte(20)
      ..write(obj.tools)
      ..writeByte(21)
      ..write(obj.communityName)
      ..writeByte(22)
      ..write(obj.subCommunityName)
      ..writeByte(23)
      ..write(obj.spaces)
      ..writeByte(24)
      ..write(obj.buildingName)
      ..writeByte(25)
      ..write(obj.jobLocationName)
      ..writeByte(26)
      ..write(obj.jobLocation)
      ..writeByte(27)
      ..write(obj.signedClient)
      ..writeByte(28)
      ..write(obj.signedTechnician)
      ..writeByte(29)
      ..write(obj.signedManager)
      ..writeByte(30)
      ..write(obj.transitions)
      ..writeByte(31)
      ..write(obj.requestTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobDetailsDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssigneeAdapter extends TypeAdapter<Assignee> {
  @override
  final int typeId = 2;

  @override
  Assignee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Assignee(
      id: fields[0] as dynamic,
      name: fields[1] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, Assignee obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssigneeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResourceAdapter extends TypeAdapter<Resource> {
  @override
  final int typeId = 3;

  @override
  Resource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Resource(
      domain: fields[0] as dynamic,
      identifier: fields[1] as dynamic,
      displayName: fields[2] as dynamic,
      referenceId: fields[3] as dynamic,
      resourceId: fields[4] as dynamic,
      type: fields[5] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, Resource obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.domain)
      ..writeByte(1)
      ..write(obj.identifier)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.referenceId)
      ..writeByte(4)
      ..write(obj.resourceId)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChecklistDbAdapter extends TypeAdapter<ChecklistDb> {
  @override
  final int typeId = 4;

  @override
  ChecklistDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChecklistDb(
      id: fields[0] as int?,
      item: fields[1] as String?,
      description: fields[2] as String?,
      checkable: fields[3] as bool?,
      executionIndex: fields[4] as int?,
      selectedChoice: fields[9] as String?,
      choices: (fields[6] as List?)?.cast<String>(),
      checked: fields[8] as bool?,
      choiceType: fields[5] as bool?,
      comments: (fields[7] as List?)?.cast<Comments>(),
      type: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChecklistDb obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.item)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.checkable)
      ..writeByte(4)
      ..write(obj.executionIndex)
      ..writeByte(5)
      ..write(obj.choiceType)
      ..writeByte(6)
      ..write(obj.choices)
      ..writeByte(7)
      ..write(obj.comments)
      ..writeByte(8)
      ..write(obj.checked)
      ..writeByte(9)
      ..write(obj.selectedChoice)
      ..writeByte(10)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommentsAdapter extends TypeAdapter<Comments> {
  @override
  final int typeId = 5;

  @override
  Comments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comments(
      id: fields[0] as int?,
      comment: fields[1] as String?,
      commentTime: fields[2] as int?,
      commentBy: fields[3] as String?,
      replies: (fields[4] as List?)?.cast<Replies>(),
    );
  }

  @override
  void write(BinaryWriter writer, Comments obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.comment)
      ..writeByte(2)
      ..write(obj.commentTime)
      ..writeByte(3)
      ..write(obj.commentBy)
      ..writeByte(4)
      ..write(obj.replies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepliesAdapter extends TypeAdapter<Replies> {
  @override
  final int typeId = 6;

  @override
  Replies read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Replies(
      id: fields[0] as int?,
      comment: fields[1] as String?,
      commentTime: fields[2] as int?,
      commentBy: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Replies obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.comment)
      ..writeByte(2)
      ..write(obj.commentTime)
      ..writeByte(3)
      ..write(obj.commentBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepliesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JobCommentsAdapter extends TypeAdapter<JobComments> {
  @override
  final int typeId = 7;

  @override
  JobComments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobComments(
      id: fields[0] as int?,
      comment: fields[1] as String?,
      commentTime: fields[2] as int?,
      commentBy: fields[3] as String?,
      replies: (fields[4] as List?)?.cast<Replies>(),
    );
  }

  @override
  void write(BinaryWriter writer, JobComments obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.comment)
      ..writeByte(2)
      ..write(obj.commentTime)
      ..writeByte(3)
      ..write(obj.commentBy)
      ..writeByte(4)
      ..write(obj.replies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobCommentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartsAdapter extends TypeAdapter<Parts> {
  @override
  final int typeId = 8;

  @override
  Parts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parts(
      id: fields[0] as int?,
      name: fields[1] as String?,
      sparePartId: fields[2] as String?,
      partReference: fields[3] as String?,
      unitCost: fields[4] as int?,
      quantity: fields[5] as int?,
      totalCost: fields[6] as int?,
      domain: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Parts obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sparePartId)
      ..writeByte(3)
      ..write(obj.partReference)
      ..writeByte(4)
      ..write(obj.unitCost)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.totalCost)
      ..writeByte(7)
      ..write(obj.domain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SkillsAdapter extends TypeAdapter<Skills> {
  @override
  final int typeId = 9;

  @override
  Skills read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Skills(
      name: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Skills obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ToolsAdapter extends TypeAdapter<Tools> {
  @override
  final int typeId = 10;

  @override
  Tools read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tools(
      name: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Tools obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
