class AllJobComments {
  List<GetAllComments>? getAllComments;

  AllJobComments({this.getAllComments});

  AllJobComments.fromJson(Map<String, dynamic> json) {
    if (json['getAllComments'] != null) {
      getAllComments = <GetAllComments>[];
      json['getAllComments'].forEach((v) {
        getAllComments!.add(new GetAllComments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.getAllComments != null) {
      data['getAllComments'] =
          this.getAllComments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetAllComments {
  int? id;
  String? comment;
  int? commentTime;
  String? commentBy;
  int? commentId;
  bool? replied;

  GetAllComments(
      {this.id,
      this.comment,
      this.commentTime,
      this.commentBy,
      this.commentId,
      this.replied});

  GetAllComments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    commentTime = json['commentTime'];
    commentBy = json['commentBy'];
    commentId = json['commentId'];
    replied = json['replied'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['commentTime'] = this.commentTime;
    data['commentBy'] = this.commentBy;
    data['commentId'] = this.commentId;
    data['replied'] = this.replied;
    return data;
  }
}
