class FilterSchemas {
  static const String clientJson = '''
query findAllClients(\$domain: String!, \$type: String, \$loop: Boolean, \$strict: Boolean) {
  findAllClients(domain: \$domain, type: \$type, loop: \$loop, strict: \$strict)
}
''';

  static const String assetTypesJson = '''
query listAllAssetTypes(\$domain: String!, \$type: String!) {
  listAllAssetTypes(domain: \$domain, type: \$type) {
    domain
    name
    parent
    templateName
  }
}
''';

  static const String assetsListQuery = '''
query getAssetList(\$filter: AssetFilter!) {
  getAssetList(filter: \$filter) {
    assets {
      category
      clientDomain
      clientName
      communicationStatus
      createdOn
      criticalAlarm
      dataTime
      displayName
      documentExpire
      documentExpiryTypes
      domain
      highAlarm
      id
      identifier
      lastCommunicated
      location
      locationJson
      lowAlarm
      make
      mediumAlarm
      model
      name
      operationStatus
      overtime
      owners
      ownersJson
      path
      points
      pointsJson
      reason
      recent
      serialNumber
      serviceDue
      sourceId
      thingCode
      thingTagPath
      type
      typeName
      underMaintenance
      warningAlarm
    }
    totalAssetsCount
  }
}
''';

  static const String locationJson = '''
query listAllGeoFences(\$data: geofenceList) {
  listAllGeoFences(data: \$data) {
    data {
      type
      data
    }
    totalCount
  }
}
''';

  static const String parentTypeJson = '''
query listAllTemplatesSystem(\$domain: String!, \$name: String!) {
  listAllTemplatesSystem(domain: \$domain, name: \$name) {
    name
    templateName
    parent
    domain
  }
}
''';

  static const String getDocumentCategoriesQuery = '''
query getDocumentCategories(\$domain: String) {
  getDocumentCategories(domain: \$domain) {
    type
    data
  }
}
''';

  static const String listJobCommonUtilsQuery = '''
query listJobCommonUtils(\$utilTypes: [String]) {
  listJobCommonUtils(utilTypes: \$utilTypes)
}
''';

  static const String listAllassigneesQuery = '''
query listAllAssignees(\$domain: String!, \$type: String) {
  listAllAssignees(domain: \$domain, type: \$type) {
    id
    name
    referenceId
  }
}
''';

  static const String getJobFilterQuery = '''
query getJobFilter(\$brand: String) {
  getJobFilter(brand: \$brand)
}
''';

  static const String listAllCommunitiesQuery = '''
query listAllCommunities(\$domain: String!, \$parentFlag: Boolean) {
  listAllCommunities(domain: \$domain, parentFlag: \$parentFlag) {
    type
    data
  }
}
''';

  static const String listAllSubCommunitiesQuery = '''
query findAllSubCommunities(\$domain: String!) {
  findAllSubCommunities(domain: \$domain) {
    type
    data
  }
}
''';

  static const String listAllBuildingsQuery = '''
query findAllBuildings(\$domain: String!, \$subCommunity: Entity, \$type: String, \$subCommunities: [Entity]) {
  findAllBuildings(
    domain: \$domain
    subCommunity: \$subCommunity
    type: \$type
    subCommunities: \$subCommunities
  ) {
    type
    data
  }
}
''';

  static const String listAllSpacesQuery = '''
query listAllSpacesPagination(\$data: SpacesInput!) {
  listAllSpacesPagination(data: \$data) {
    space {
      type
      data
    }
    site
    subCommunity
  }
}
''';
}
