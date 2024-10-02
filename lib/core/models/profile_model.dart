// To parse this JSON data, do
//
//     final profileLoggedModel = profileLoggedModelFromJson(jsonString);

import 'dart:convert';

ProfileLoggedModel profileLoggedModelFromJson(Map<String,dynamic> map) => ProfileLoggedModel.fromJson(map);

String profileLoggedModelToJson(ProfileLoggedModel data) => json.encode(data.toJson());

class ProfileLoggedModel {
    ProfileLoggedModel({
        this.findLoggedInUser,
    });

    FindLoggedInUser? findLoggedInUser;

    factory ProfileLoggedModel.fromJson(Map<String, dynamic> json) => ProfileLoggedModel(
        findLoggedInUser: json["findLoggedInUser"] == null ? null : FindLoggedInUser.fromJson(json["findLoggedInUser"]),
    );

    Map<String, dynamic> toJson() => {
        "findLoggedInUser": findLoggedInUser?.toJson(),
    };
}

class FindLoggedInUser {
    FindLoggedInUser({
        this.user,
        this.siteGroups,
    });

    User? user;
    List<dynamic>? siteGroups;

    factory FindLoggedInUser.fromJson(Map<String, dynamic> json) => FindLoggedInUser(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        siteGroups: json["siteGroups"] == null ? [] : List<dynamic>.from(json["siteGroups"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "siteGroups": siteGroups == null ? [] : List<dynamic>.from(siteGroups!.map((x) => x)),
    };
}

class User {
    User({
        this.type,
        this.data,
        this.identifier,
        this.domain,
        this.status,
    });

    String? type;
    Data? data;
    String? identifier;
    String? domain;
    String? status;

    factory User.fromJson(Map<String, dynamic> json) => User(
        type: json["type"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        identifier: json["identifier"],
        domain: json["domain"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
        "identifier": identifier,
        "domain": domain,
        "status": status,
    };
}

class Data {
    Data({
        this.lastName,
        this.identifier,
        this.siteGroupAccess,
        this.typeName,
        this.description,
        this.emailId,
        this.profileImage,
        this.type,
        this.locale,
        this.userName,
        this.createdOn,
        this.firstName,
        this.isId,
        this.createdBy,
        this.domain,
        this.contactNumber,
        this.roleName,
        this.name,
        this.appAccess,
        this.status,
    });

    String? lastName;
    String? identifier;
    String? siteGroupAccess;
    String? typeName;
    String? description;
    String? emailId;
    String? profileImage;
    String? type;
    String? locale;
    String? userName;
    String? createdOn;
    String? firstName;
    String? isId;
    String? createdBy;
    String? domain;
    String? contactNumber;
    String? roleName;
    String? name;
    String? appAccess;
    String? status;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        lastName: json["lastName"],
        identifier: json["identifier"],
        siteGroupAccess: json["siteGroupAccess"],
        typeName: json["typeName"],
        description: json["description"],
        emailId: json["emailId"],
        profileImage: json["profileImage"],
        type: json["type"],
        locale: json["locale"],
        userName: json["userName"],
        createdOn: json["createdOn"],
        firstName: json["firstName"],
        isId: json["isId"],
        createdBy: json["createdBy"],
        domain: json["domain"],
        contactNumber: json["contactNumber"],
        roleName: json["roleName"],
        name: json["name"],
        appAccess: json["appAccess"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "lastName": lastName,
        "identifier": identifier,
        "siteGroupAccess": siteGroupAccess,
        "typeName": typeName,
        "description": description,
        "emailId": emailId,
        "profileImage": profileImage,
        "type": type,
        "locale": locale,
        "userName": userName,
        "createdOn": createdOn,
        "firstName": firstName,
        "isId": isId,
        "createdBy": createdBy,
        "domain": domain,
        "contactNumber": contactNumber,
        "roleName": roleName,
        "name": name,
        "appAccess": appAccess,
        "status": status,
    };
}
