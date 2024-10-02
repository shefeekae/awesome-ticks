class CommentReply {
  List<GetCommentReply>? getCommentReply;

  CommentReply({this.getCommentReply});

  CommentReply.fromJson(Map<String, dynamic> json) {
    if (json['getCommentReply'] != null) {
      getCommentReply = <GetCommentReply>[];
      json['getCommentReply'].forEach((v) {
        getCommentReply!.add(new GetCommentReply.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.getCommentReply != null) {
      data['getCommentReply'] =
          this.getCommentReply!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetCommentReply {
  int? id;
  String? comment;
  int? commentTime;
  String? commentBy;
  int? commentId;
  bool? replied;
  int? jobId;

  GetCommentReply(
      {this.id,
      this.comment,
      this.commentTime,
      this.commentBy,
      this.commentId,
      this.replied,
      this.jobId});

  GetCommentReply.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    commentTime = json['commentTime'];
    commentBy = json['commentBy'];
    commentId = json['commentId'];
    replied = json['replied'];
    jobId = json['jobId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['commentTime'] = this.commentTime;
    data['commentBy'] = this.commentBy;
    data['commentId'] = this.commentId;
    data['replied'] = this.replied;
    data['jobId'] = this.jobId;
    return data;
  }
}
