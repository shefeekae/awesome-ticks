class CheckListComments {
  List<ListCheckListComments>? listCheckListComments;

  CheckListComments({this.listCheckListComments});

  CheckListComments.fromJson(Map<String, dynamic> json) {
    if (json['listCheckListComments'] != null) {
      listCheckListComments = <ListCheckListComments>[];
      json['listCheckListComments'].forEach((v) {
        listCheckListComments!.add(new ListCheckListComments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listCheckListComments != null) {
      data['listCheckListComments'] =
          this.listCheckListComments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListCheckListComments {
  int? id;
  String? comment;
  int? commentTime;
  String? commentBy;
  int? attachmentRef;
  int? status;
  int? commentId;
  int? hasReplies;
  int? replyCount;

  ListCheckListComments(
      {this.id,
      this.comment,
      this.commentTime,
      this.commentBy,
      this.attachmentRef,
      this.status,
      this.commentId,
      this.hasReplies,
      this.replyCount});

  ListCheckListComments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    commentTime = json['commentTime'];
    commentBy = json['commentBy'];
    attachmentRef = json['attachmentRef'];
    status = json['status'];
    commentId = json['commentId'];
    hasReplies = json['hasReplies'];
    replyCount = json['replyCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['commentTime'] = this.commentTime;
    data['commentBy'] = this.commentBy;
    data['attachmentRef'] = this.attachmentRef;
    data['status'] = this.status;
    data['commentId'] = this.commentId;
    data['hasReplies'] = this.hasReplies;
    data['replyCount'] = this.replyCount;
    return data;
  }
}
