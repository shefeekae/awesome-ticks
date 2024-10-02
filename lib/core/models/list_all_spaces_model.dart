class ListAllSpacesModel {
  List<ListAllSpacesPagination>? listAllSpacesPagination;

  ListAllSpacesModel({this.listAllSpacesPagination});

  ListAllSpacesModel.fromJson(Map<String, dynamic> json) {
    if (json['listAllSpacesPagination'] != null) {
      listAllSpacesPagination = <ListAllSpacesPagination>[];
      json['listAllSpacesPagination'].forEach((v) {
        listAllSpacesPagination!.add(new ListAllSpacesPagination.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listAllSpacesPagination != null) {
      data['listAllSpacesPagination'] =
          this.listAllSpacesPagination!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListAllSpacesPagination {
  Space? space;
  String? site;
  String? subCommunity;

  ListAllSpacesPagination({this.space, this.site, this.subCommunity});

  ListAllSpacesPagination.fromJson(Map<String, dynamic> json) {
    space = json['space'] != null ? new Space.fromJson(json['space']) : null;
    site = json['site'];
    subCommunity = json['subCommunity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.space != null) {
      data['space'] = this.space!.toJson();
    }
    data['site'] = this.site;
    data['subCommunity'] = this.subCommunity;
    return data;
  }
}

class Space {
  String? type;
  Data? data;

  Space({this.type, this.data});

  Space.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? dashboardLink;
  String? identifier;
  String? ddLink;
  String? createdBy;
  String? level;
  String? domain;
  String? typeName;
  String? name;
  String? description;
  String? createdOn;
  String? status;

  Data(
      {this.dashboardLink,
      this.identifier,
      this.ddLink,
      this.createdBy,
      this.level,
      this.domain,
      this.typeName,
      this.name,
      this.description,
      this.createdOn,
      this.status});

  Data.fromJson(Map<String, dynamic> json) {
    dashboardLink = json['dashboardLink'];
    identifier = json['identifier'];
    ddLink = json['ddLink'];
    createdBy = json['createdBy'];
    level = json['level'];
    domain = json['domain'];
    typeName = json['typeName'];
    name = json['name'];
    description = json['description'];
    createdOn = json['createdOn'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dashboardLink'] = this.dashboardLink;
    data['identifier'] = this.identifier;
    data['ddLink'] = this.ddLink;
    data['createdBy'] = this.createdBy;
    data['level'] = this.level;
    data['domain'] = this.domain;
    data['typeName'] = this.typeName;
    data['name'] = this.name;
    data['description'] = this.description;
    data['createdOn'] = this.createdOn;
    data['status'] = this.status;
    return data;
  }
}
