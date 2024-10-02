class TeamMembersDataModel {
  String? sTypename;
  ListAllAssigneesUnPaged? listAllAssigneesUnPaged;

  TeamMembersDataModel({this.sTypename, this.listAllAssigneesUnPaged});

  TeamMembersDataModel.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    listAllAssigneesUnPaged = json['listAllAssigneesUnPaged'] != null
        ? ListAllAssigneesUnPaged.fromJson(json['listAllAssigneesUnPaged'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (listAllAssigneesUnPaged != null) {
      data['listAllAssigneesUnPaged'] = listAllAssigneesUnPaged!.toJson();
    }
    return data;
  }
}

class ListAllAssigneesUnPaged {
  String? sTypename;
  List<Items>? items;

  ListAllAssigneesUnPaged({this.sTypename, this.items});

  ListAllAssigneesUnPaged.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? sTypename;
  int? id;
  String? name;
  String? referenceId;
  String? emailId;
  String? contactNumber;

  Items(
      {this.sTypename,
      this.id,
      this.name,
      this.referenceId,
      this.emailId,
      this.contactNumber});

  Items.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    id = json['id'];
    name = json['name'];
    referenceId = json['referenceId'];
    emailId = json['emailId'];
    contactNumber = json['contactNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    data['id'] = id;
    data['name'] = name;
    data['referenceId'] = referenceId;
    data['emailId'] = emailId;
    data['contactNumber'] = contactNumber;
    return data;
  }
}
