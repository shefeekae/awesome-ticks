class GetJobCountCategorisedModel {
  List<GetJobCountCategorisedToDays>? getJobCountCategorisedToDays;

  GetJobCountCategorisedModel({this.getJobCountCategorisedToDays});

  GetJobCountCategorisedModel.fromJson(Map<String, dynamic> json) {
    if (json['getJobCountCategorisedToDays'] != null) {
      getJobCountCategorisedToDays = <GetJobCountCategorisedToDays>[];
      json['getJobCountCategorisedToDays'].forEach((v) {
        getJobCountCategorisedToDays!
            .add( GetJobCountCategorisedToDays.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (getJobCountCategorisedToDays != null) {
      data['getJobCountCategorisedToDays'] =
          getJobCountCategorisedToDays!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetJobCountCategorisedToDays {
  int? totalUnresolved;
  int? totalCompleted;
  int? totalCancelled;
  int? totalInProgress;
  int? totalHeld;
  int? date;
  int? total;
  int? closed;
  List<Details>? details;

  GetJobCountCategorisedToDays(
      {this.totalUnresolved,
      this.totalCompleted,
      this.totalCancelled,
      this.totalInProgress,
      this.totalHeld,
      this.date,
      this.total,
      this.closed,
      this.details});

  GetJobCountCategorisedToDays.fromJson(Map<String, dynamic> json) {
    totalUnresolved = json['totalUnresolved'];
    totalCompleted = json['totalCompleted'];
    totalCancelled = json['totalCancelled'];
    totalInProgress = json['totalInProgress'];
    totalHeld = json['totalHeld'];
    date = json['date'];
    total = json['total'];
    closed = json['closed'];
    if (json['details'] != null) {
      details = <Details>[];
      json['details'].forEach((v) {
        details!.add( Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['totalUnresolved'] = totalUnresolved;
    data['totalCompleted'] = totalCompleted;
    data['totalCancelled'] = totalCancelled;
    data['totalInProgress'] = totalInProgress;
    data['totalHeld'] = totalHeld;
    data['date'] = date;
    data['total'] = total;
    data['closed'] = closed;
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Details {
  String? status;
  int? ticketCount;
  int? ticketDate;

  Details({this.status, this.ticketCount, this.ticketDate});

  Details.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    ticketCount = json['ticketCount'];
    ticketDate = json['ticketDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['ticketCount'] = ticketCount;
    data['ticketDate'] = ticketDate;
    return data;
  }
}
