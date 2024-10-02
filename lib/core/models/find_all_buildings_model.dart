

class FindAllBuildingsModel {
  List<FindAllBuildings>? findAllBuildings;

  FindAllBuildingsModel({this.findAllBuildings});

  FindAllBuildingsModel.fromJson(Map<String, dynamic> json) {
    if (json['findAllBuildings'] != null) {
      findAllBuildings = <FindAllBuildings>[];
      json['findAllBuildings'].forEach((v) {
        findAllBuildings!.add( FindAllBuildings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.findAllBuildings != null) {
      data['findAllBuildings'] =
          this.findAllBuildings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FindAllBuildings {
  String? type;
  Data? data;

  FindAllBuildings({this.type, this.data});

  FindAllBuildings.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    data = json['data'] != null ?  Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = type;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? ownerClientId;
  String? rmsName;
  String? weatherLink;
  String? aqiGraphicsLink;
  String? displayName;
  String? criticality;
  String? typeName;
  String? contactPerson;
  String? profileImage;
  String? createdOn;
  String? deltaCriticalThreshold;
  String? ownerName;
  int? distributedOn;
  String? email;
  String? area;
  String? identifier;
  String? address;
  String? timeZone;
  String? weatherSensor;
  String? system;
  String? createdBy;
  String? phone;
  String? etsGraphicsLink;
  String? domain;
  String? name;
  String? builtYear;
  String? location;
  String? deltaWarningThreshold;
  String? status;

  Data(
      {this.ownerClientId,
      this.rmsName,
      this.weatherLink,
      this.aqiGraphicsLink,
      this.displayName,
      this.criticality,
      this.typeName,
      this.contactPerson,
      this.profileImage,
      this.createdOn,
      this.deltaCriticalThreshold,
      this.ownerName,
      this.distributedOn,
      this.email,
      this.area,
      this.identifier,
      this.address,
      this.timeZone,
      this.weatherSensor,
      this.system,
      this.createdBy,
      this.phone,
      this.etsGraphicsLink,
      this.domain,
      this.name,
      this.builtYear,
      this.location,
      this.deltaWarningThreshold,
      this.status});

  Data.fromJson(Map<String, dynamic> json) {
    ownerClientId = json['ownerClientId'];
    rmsName = json['rmsName'];
    weatherLink = json['weatherLink'];
    aqiGraphicsLink = json['aqiGraphicsLink'];
    displayName = json['displayName'];
    criticality = json['criticality'];
    typeName = json['typeName'];
    contactPerson = json['contactPerson'];
    profileImage = json['profileImage'];
    createdOn = json['createdOn'];
    deltaCriticalThreshold = json['deltaCriticalThreshold'];
    ownerName = json['ownerName'];
    distributedOn = json['distributedOn'];
    email = json['email'];
    area = json['area'];
    identifier = json['identifier'];
    address = json['address'];
    timeZone = json['timeZone'];
    weatherSensor = json['weatherSensor'];
    system = json['system'];
    createdBy = json['createdBy'];
    phone = json['phone'];
    etsGraphicsLink = json['etsGraphicsLink'];
    domain = json['domain'];
    name = json['name'];
    builtYear = json['builtYear'];
    location = json['location'];
    deltaWarningThreshold = json['deltaWarningThreshold'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['ownerClientId'] =ownerClientId;
    data['rmsName'] =rmsName;
    data['weatherLink'] =weatherLink;
    data['aqiGraphicsLink'] =aqiGraphicsLink;
    data['displayName'] =displayName;
    data['criticality'] =criticality;
    data['typeName'] =typeName;
    data['contactPerson'] =contactPerson;
    data['profileImage'] =profileImage;
    data['createdOn'] =createdOn;
    data['deltaCriticalThreshold'] =deltaCriticalThreshold;
    data['ownerName'] =ownerName;
    data['distributedOn'] =distributedOn;
    data['email'] =email;
    data['area'] =area;
    data['identifier'] =identifier;
    data['address'] =address;
    data['timeZone'] =timeZone;
    data['weatherSensor'] =weatherSensor;
    data['system'] =system;
    data['createdBy'] =createdBy;
    data['phone'] =phone;
    data['etsGraphicsLink'] =etsGraphicsLink;
    data['domain'] =domain;
    data['name'] =name;
    data['builtYear'] =builtYear;
    data['location'] =location;
    data['deltaWarningThreshold'] =deltaWarningThreshold;
    data['status'] =status;
    return data;
  }
}
