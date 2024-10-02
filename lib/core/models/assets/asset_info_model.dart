// To parse this JSON data, do
//
//     final assetInfoModel = assetInfoModelFromJson(jsonString);

import 'dart:convert';

AssetInfoModel assetInfoModelFromJson(Map<String, dynamic> map) =>
    AssetInfoModel.fromJson(map);

String assetInfoModelToJson(AssetInfoModel data) => json.encode(data.toJson());

class AssetInfoModel {
  AssetInfoModel({
    this.findAsset,
  });

  FindAsset? findAsset;

  factory AssetInfoModel.fromJson(Map<String, dynamic> json) => AssetInfoModel(
        findAsset: json["findAsset"] == null
            ? null
            : FindAsset.fromJson(json["findAsset"]),
      );

  Map<String, dynamic> toJson() => {
        "findAsset": findAsset?.toJson(),
      };
}

class FindAsset {
  FindAsset({
    this.asset,
    this.parent,
    this.assetLatest,
    // this.criticalPoints,
    // this.lowPriorityPoints,
    // this.settings,
    // this.device,
    // this.sim,
  });

  Asset? asset;
  String? parent;
  AssetLatest? assetLatest;
  // List<CriticalPointElement>? criticalPoints;
  // List<CriticalPointElement>? lowPriorityPoints;
  // Settings? settings;
  // Device? device;
  // dynamic sim;

  factory FindAsset.fromJson(Map<String, dynamic> json) => FindAsset(
        asset: json["asset"] == null ? null : Asset.fromJson(json["asset"]),
        parent: json["parent"],
        assetLatest: json["assetLatest"] == null
            ? null
            : AssetLatest.fromJson(json["assetLatest"]),
        // criticalPoints: json["criticalPoints"] == null
        //     ? []
        //     : List<CriticalPointElement>.from(json["criticalPoints"]
        //         .map((x) => CriticalPointElement.fromJson(x))),
        // lowPriorityPoints: json["lowPriorityPoints"] == null
        //     ? []
        //     : List<CriticalPointElement>.from(json["lowPriorityPoints"]
        //         .map((x) => CriticalPointElement.fromJson(x))),
        // settings: json["settings"] == null
        //     ? null
        //     : Settings.fromJson(json["settings"]),
        // device: json["device"] == null ? null : Device.fromJson(json["device"]),
        // sim: json["sim"],
      );

  Map<String, dynamic> toJson() => {
        "asset": asset?.toJson(),
        "parent": parent,
        "assetLatest": assetLatest?.toJson(),
        // "criticalPoints": criticalPoints == null
        //     ? []
        //     : List<dynamic>.from(criticalPoints!.map((x) => x.toJson())),
        // "lowPriorityPoints": lowPriorityPoints == null
        //     ? []
        //     : List<dynamic>.from(lowPriorityPoints!.map((x) => x.toJson())),
        // "settings": settings?.toJson(),
        // "device": device?.toJson(),
        // "sim": sim,
      };
}

class Asset {
  Asset({
    this.type,
    this.data,
  });

  String? type;
  AssetData? data;

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        type: json["type"],
        data: json["data"] == null ? null : AssetData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
      };
}

class AssetData {
  AssetData({
    this.domain,
    this.name,
    this.identifier,
    this.make,
    this.model,
    this.displayName,
    this.sourceTagPath,
    this.ddLink,
    this.dddLink,
    this.profileImage,
    this.status,
    this.createdOn,
    this.assetCode,
    this.typeName,
    this.state,
  });

  String? domain;
  String? name;
  String? identifier;
  String? make;
  String? model;
  String? displayName;
  dynamic sourceTagPath;
  String? ddLink;
  dynamic dddLink;
  String? profileImage;
  String? status;
  int? createdOn;
  dynamic assetCode;
  String? typeName;
  String? state;

  factory AssetData.fromJson(Map<String, dynamic> json) => AssetData(
        domain: json["domain"],
        name: json["name"],
        identifier: json["identifier"],
        make: json["make"],
        model: json["model"],
        displayName: json["displayName"],
        sourceTagPath: json["sourceTagPath"],
        ddLink: json["ddLink"],
        dddLink: json["dddLink"],
        profileImage: json["profileImage"],
        status: json['status'],
        createdOn: json["createdOn"],
        assetCode: json["assetCode"],
        typeName: json["typeName"],
        state: json['state'],
      );

  Map<String, dynamic> toJson() => {
        "domain": domain,
        "name": name,
        "identifier": identifier,
        "make": make,
        "model": model,
        "displayName": displayName,
        "sourceTagPath": sourceTagPath,
        "ddLink": ddLink,
        "dddLink": dddLink,
        "profileImage": profileImage,
        "status": status,
        "createdOn": createdOn,
        "assetCode": assetCode,
        "typeName": typeName,
        "state": state,
      };
}

class AssetLatest {
  AssetLatest({
    this.name,
    this.clientName,
    this.serialNumber,
    this.dataTime,
    this.underMaintenance,
    this.points,
    this.operationStatus,
    this.path,
    this.location,
    this.createdOn,
  });

  String? name;
  String? clientName;
  dynamic serialNumber;
  int? dataTime;
  int? createdOn;
  bool? underMaintenance;
  List<Point>? points;
  String? operationStatus;
  List<Path>? path;
  String? location;

  factory AssetLatest.fromJson(Map<String, dynamic> json) => AssetLatest(
        name: json["name"],
        clientName: json["clientName"],
        serialNumber: json["serialNumber"],
        dataTime: json["dataTime"],
        underMaintenance: json["underMaintenance"],
        points: json["points"] == null
            ? []
            : List<Point>.from(json["points"]!.map((x) => Point.fromJson(x))),
        operationStatus: json["operationStatus"],
        path: json["path"] == null
            ? []
            : List<Path>.from(json["path"]!.map((x) => Path.fromJson(x))),
        location: json["location"],
        createdOn: json['createdOn'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "clientName": clientName,
        "serialNumber": serialNumber,
        "dataTime": dataTime,
        "underMaintenance": underMaintenance,
        "points": points == null
            ? []
            : List<dynamic>.from(points!.map((x) => x.toJson())),
        "operationStatus": operationStatus,
        "path": path == null
            ? []
            : List<dynamic>.from(path!.map((x) => x.toJson())),
        "location": location,
        "createdOn": createdOn,
      };
}

class Path {
  Path({
    this.name,
    this.entity,
  });

  String? name;
  Entity? entity;

  factory Path.fromJson(Map<String, dynamic> json) => Path(
        name: json["name"],
        entity: json["entity"] == null ? null : Entity.fromJson(json["entity"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "entity": entity?.toJson(),
      };
}

class Entity {
  Entity({
    this.type,
    this.data,
    this.identifier,
    this.domain,
  });

  String? type;
  EntityData? data;
  String? identifier;
  String? domain;

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
        type: json["type"],
        data: json["data"] == null ? null : EntityData.fromJson(json["data"]),
        identifier: json["identifier"],
        domain: json["domain"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
        "identifier": identifier,
        "domain": domain,
      };
}

class EntityData {
  EntityData({
    this.identifier,
    this.domain,
    this.name,
    this.parentType,
  });

  String? identifier;
  String? domain;
  String? name;
  String? parentType;

  factory EntityData.fromJson(Map<String, dynamic> json) => EntityData(
        identifier: json["identifier"],
        domain: json["domain"],
        name: json["name"],
        parentType: json["parentType"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "domain": domain,
        "name": name,
        "parentType": parentType,
      };
}

class Point {
  Point({
    this.unit,
    this.unitSymbol,
    this.data,
    this.pointName,
    this.pointId,
    this.dataType,
    this.displayName,
    this.type,
    this.status,
    this.pointAccessType,
    this.precedence,
    this.expression,
  });

  String? unit;
  String? unitSymbol;
  dynamic data;
  String? pointName;
  String? pointId;
  DataTypeEnum? dataType;
  String? displayName;
  // PurpleType? type;
  String? type;
  PointStatus? status;
  AccessType? pointAccessType;
  String? precedence;
  String? expression;

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        unit: json["unit"],
        unitSymbol: json["unitSymbol"],
        data: json["data"],
        pointName: json["pointName"],
        pointId: json["pointId"],
        dataType: dataTypeEnumValues.map[json["dataType"]],
        displayName: json["displayName"],
        // type: purpleTypeValues.map[json["type"]],
        type: json['type'],
        status: pointStatusValues.map[json["status"]],
        pointAccessType: accessTypeValues.map[json["pointAccessType"]],
        precedence: json["precedence"],
        expression: json["expression"],
      );

  Map<String, dynamic> toJson() => {
        "unit": unit,
        "unitSymbol": unitSymbol,
        "data": data,
        "pointName": pointName,
        "pointId": pointId,
        "dataType": dataTypeEnumValues.reverse[dataType],
        "displayName": displayName,
        "type": purpleTypeValues.reverse[type],
        "status": pointStatusValues.reverse[status],
        "pointAccessType": accessTypeValues.reverse[pointAccessType],
        "precedence": precedence,
        "expression": expression,
      };
}

class DataData {
  DataData({
    this.latitude,
    this.longitude,
  });

  double? latitude;
  double? longitude;

  factory DataData.fromJson(Map<String, dynamic> json) => DataData(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

enum DataTypeEnum { INTEGER, DOUBLE, STRING, GEOPOINT, BOOLEAN, FLOAT, EMPTY }

final dataTypeEnumValues = EnumValues({
  "Boolean": DataTypeEnum.BOOLEAN,
  "Double": DataTypeEnum.DOUBLE,
  "": DataTypeEnum.EMPTY,
  "Float": DataTypeEnum.FLOAT,
  "Geopoint": DataTypeEnum.GEOPOINT,
  "Integer": DataTypeEnum.INTEGER,
  "String": DataTypeEnum.STRING
});

enum AccessType { READONLY }

final accessTypeValues = EnumValues({"READONLY": AccessType.READONLY});

enum PointStatus { HEALTHY }

final pointStatusValues = EnumValues({"healthy": PointStatus.HEALTHY});

enum PurpleType { INTEGER, DOUBLE, STRING, GEOPOINT, BOOLEAN, FLOAT }

final purpleTypeValues = EnumValues({
  "BOOLEAN": PurpleType.BOOLEAN,
  "DOUBLE": PurpleType.DOUBLE,
  "FLOAT": PurpleType.FLOAT,
  "GEOPOINT": PurpleType.GEOPOINT,
  "INTEGER": PurpleType.INTEGER,
  "STRING": PurpleType.STRING
});

class CriticalPointElement {
  CriticalPointElement({
    this.type,
    this.data,
  });

  CriticalPointType? type;
  CriticalPointData? data;

  factory CriticalPointElement.fromJson(Map<String, dynamic> json) =>
      CriticalPointElement(
        type: criticalPointTypeValues.map[json["type"]],
        data: json["data"] == null
            ? null
            : CriticalPointData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "type": criticalPointTypeValues.reverse[type],
        "data": data?.toJson(),
      };
}

class CriticalPointData {
  CriticalPointData({
    this.identifier,
    this.expression,
    this.physicalQuantity,
    this.pointName,
    this.displayName,
    this.dataType,
    this.typeName,
    this.type,
    this.remoteDataType,
    this.createdOn,
    this.precedence,
    this.accessType,
    this.unit,
    this.pointId,
    this.createdBy,
    this.domain,
    this.unitSymbol,
    this.status,
    this.possibleValues,
    this.maxValue,
    this.minValue,
  });

  String? identifier;
  String? expression;
  String? physicalQuantity;
  String? pointName;
  String? displayName;
  DataTypeEnum? dataType;
  TypeName? typeName;
  DataTypeEnum? type;
  DataTypeEnum? remoteDataType;
  String? createdOn;
  String? precedence;
  AccessType? accessType;
  String? unit;
  String? pointId;
  CreatedBy? createdBy;
  Domain? domain;
  String? unitSymbol;
  String? status;
  String? possibleValues;
  String? maxValue;
  String? minValue;

  factory CriticalPointData.fromJson(Map<String, dynamic> json) =>
      CriticalPointData(
        identifier: json["identifier"],
        expression: json["expression"],
        physicalQuantity: json["physicalQuantity"],
        pointName: json["pointName"],
        displayName: json["displayName"],
        dataType: dataTypeEnumValues.map[json["dataType"]],
        typeName: typeNameValues.map[json["typeName"]],
        type: dataTypeEnumValues.map[json["type"]],
        remoteDataType: dataTypeEnumValues.map[json["remoteDataType"]],
        createdOn: json["createdOn"],
        precedence: json["precedence"],
        accessType: accessTypeValues.map[json["accessType"]],
        unit: json["unit"],
        pointId: json["pointId"],
        createdBy: createdByValues.map[json["createdBy"]],
        domain: domainValues.map[json["domain"]],
        unitSymbol: json["unitSymbol"],
        status: json['status'],
        possibleValues: json["possibleValues"],
        maxValue: json["maxValue"],
        minValue: json["minValue"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "expression": expression,
        "physicalQuantity": physicalQuantity,
        "pointName": pointName,
        "displayName": displayName,
        "dataType": dataTypeEnumValues.reverse[dataType],
        "typeName": typeNameValues.reverse[typeName],
        "type": dataTypeEnumValues.reverse[type],
        "remoteDataType": dataTypeEnumValues.reverse[remoteDataType],
        "createdOn": createdOn,
        "precedence": precedence,
        "accessType": accessTypeValues.reverse[accessType],
        "unit": unit,
        "pointId": pointId,
        "createdBy": createdByValues.reverse[createdBy],
        "domain": domainValues.reverse[domain],
        "unitSymbol": unitSymbol,
        "status": status,
        "possibleValues": possibleValues,
        "maxValue": maxValue,
        "minValue": minValue,
      };
}

enum CreatedBy { RIYAS_NECTARIT }

final createdByValues =
    EnumValues({"riyas@nectarit": CreatedBy.RIYAS_NECTARIT});

enum Domain { NECTARIT }

final domainValues = EnumValues({"nectarit": Domain.NECTARIT});

enum TypeName { CONFIG_POINT }

final typeNameValues = EnumValues({"Config Point": TypeName.CONFIG_POINT});

enum CriticalPointType { CONFIG_POINT }

final criticalPointTypeValues =
    EnumValues({"ConfigPoint": CriticalPointType.CONFIG_POINT});

class Device {
  Device({
    this.type,
    this.data,
  });

  String? type;
  DeviceData? data;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        type: json["type"],
        data: json["data"] == null ? null : DeviceData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
      };
}

class DeviceData {
  DeviceData({
    this.sourceId,
    this.deviceIp,
    this.ownerClientId,
    this.configuration,
    this.latitude,
    this.typeName,
    this.slot,
    this.deviceName,
    this.createdOn,
    this.protocol,
    this.password,
    this.ownerName,
    this.model,
    this.datasourceName,
    this.distributedOn,
    this.make,
    this.longitude,
    this.allocated,
    this.deviceType,
    this.identifier,
    this.serialNumber,
    this.writebackPort,
    this.timeZone,
    this.userName,
    this.version,
    this.url,
    this.tags,
    this.createdBy,
    this.publish,
    this.domain,
    this.devicePort,
    this.networkProtocol,
    this.status,
  });

  String? sourceId;
  String? deviceIp;
  String? ownerClientId;
  String? configuration;
  String? latitude;
  String? typeName;
  String? slot;
  String? deviceName;
  String? createdOn;
  String? protocol;
  String? password;
  String? ownerName;
  String? model;
  String? datasourceName;
  int? distributedOn;
  String? make;
  String? longitude;
  String? allocated;
  String? deviceType;
  String? identifier;
  String? serialNumber;
  String? writebackPort;
  String? timeZone;
  String? userName;
  String? version;
  String? url;
  String? tags;
  String? createdBy;
  String? publish;
  Domain? domain;
  String? devicePort;
  String? networkProtocol;
  String? status;

  factory DeviceData.fromJson(Map<String, dynamic> json) => DeviceData(
        sourceId: json["sourceId"],
        deviceIp: json["deviceIp"],
        ownerClientId: json["ownerClientId"],
        configuration: json["configuration"],
        latitude: json["latitude"],
        typeName: json["typeName"],
        slot: json["slot"],
        deviceName: json["deviceName"],
        createdOn: json["createdOn"],
        protocol: json["protocol"],
        password: json["password"],
        ownerName: json["ownerName"],
        model: json["model"],
        datasourceName: json["datasourceName"],
        distributedOn: json["distributedOn"],
        make: json["make"],
        longitude: json["longitude"],
        allocated: json["allocated"],
        deviceType: json["deviceType"],
        identifier: json["identifier"],
        serialNumber: json["serialNumber"],
        writebackPort: json["writebackPort"],
        timeZone: json["timeZone"],
        userName: json["userName"],
        version: json["version"],
        url: json["url"],
        tags: json["tags"],
        createdBy: json["createdBy"],
        publish: json["publish"],
        domain: domainValues.map[json["domain"]],
        devicePort: json["devicePort"],
        networkProtocol: json["networkProtocol"],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        "sourceId": sourceId,
        "deviceIp": deviceIp,
        "ownerClientId": ownerClientId,
        "configuration": configuration,
        "latitude": latitude,
        "typeName": typeName,
        "slot": slot,
        "deviceName": deviceName,
        "createdOn": createdOn,
        "protocol": protocol,
        "password": password,
        "ownerName": ownerName,
        "model": model,
        "datasourceName": datasourceName,
        "distributedOn": distributedOn,
        "make": make,
        "longitude": longitude,
        "allocated": allocated,
        "deviceType": deviceType,
        "identifier": identifier,
        "serialNumber": serialNumber,
        "writebackPort": writebackPort,
        "timeZone": timeZone,
        "userName": userName,
        "version": version,
        "url": url,
        "tags": tags,
        "createdBy": createdBy,
        "publish": publish,
        "domain": domainValues.reverse[domain],
        "devicePort": devicePort,
        "networkProtocol": networkProtocol,
        "status": status,
      };
}

class Settings {
  Settings({
    this.identifier,
    this.actualRunhours,
    this.effectiveRunHours,
    this.expectedRunHours,
    this.odometer,
    this.odometerDailyAvg,
    this.runhours,
    this.runhoursDailyAvg,
    this.runhoursKey,
    this.totalFuelUsed,
    this.updateTime,
  });

  String? identifier;
  int? actualRunhours;
  double? effectiveRunHours;
  double? expectedRunHours;
  double? odometer;
  double? odometerDailyAvg;
  double? runhours;
  double? runhoursDailyAvg;
  String? runhoursKey;
  num? totalFuelUsed;
  int? updateTime;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        identifier: json["identifier"],
        actualRunhours: json["actualRunhours"],
        effectiveRunHours: json["effectiveRunHours"]?.toDouble(),
        expectedRunHours: json["expectedRunHours"],
        odometer: json["odometer"]?.toDouble(),
        odometerDailyAvg: json["odometerDailyAvg"]?.toDouble(),
        runhours: json["runhours"]?.toDouble(),
        runhoursDailyAvg: json["runhoursDailyAvg"]?.toDouble(),
        runhoursKey: json["runhoursKey"],
        totalFuelUsed: json["totalFuelUsed"],
        updateTime: json["updateTime"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "actualRunhours": actualRunhours,
        "effectiveRunHours": effectiveRunHours,
        "expectedRunHours": expectedRunHours,
        "odometer": odometer,
        "odometerDailyAvg": odometerDailyAvg,
        "runhours": runhours,
        "runhoursDailyAvg": runhoursDailyAvg,
        "runhoursKey": runhoursKey,
        "totalFuelUsed": totalFuelUsed,
        "updateTime": updateTime,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
