class AssetSchema {
  static const String getAssetList = '''
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

  static const String getAssetTypeImageQuery = '''
query getAssetTypeImage(\$type: String!) {
  getAssetTypeImage(type: \$type)
}
''';

  static const String getUtilizationData = '''
query getUtilizationData(\$payload: MachineDashboardInput!) {
  getUtilizationData(payload: \$payload)
}
''';

  static const String getNotificationCount = '''
query getNotificationsCount(\$payload: MachineCountInput!) {
  getNotificationsCount(payload: \$payload)
}
''';

  static const String getAssetUtilization = '''
query getAssetUtilization(\$startDate: Float!, \$endDate: Float!, \$assets: [Entity!]) {
  getAssetUtilization(startDate: \$startDate, endDate: \$endDate, assets: \$assets) {
    idleDuration
    offDuration
    onDuration
    overtimeIdleDuration
    overtimeOnDuration
    staleDuration
  }
}
''';

  static const String findAssetSchema = '''
query findAsset(\$identifier: String!, \$domain: String!, \$type: String!) {
  findAsset(identifier: \$identifier, domain: \$domain, type: \$type) {
    asset {
      type
      data {
        domain
        name
        identifier
        make
        model
        displayName
        sourceTagPath
        ddLink
        dddLink
        profileImage
        status
        createdOn
        assetCode
        typeName
        state
      }
    }
    parent
    assetLatest {
      name
      clientName
      serialNumber
      dataTime
      underMaintenance
      points
      operationStatus
      path
      location
      createdOn
    }
    criticalPoints {
      type
      data
    }
    lowPriorityPoints {
      type
      data
    }
    settings
    device {
      type
      data
    }
    sim {
      type
      data
    }
  }
}
''';

  static const String listAllNotesQuery = '''
query listAllNotes(\$data: NotesFilter) {
  listAllNotes(data: \$data)
}
''';

  static const String createNoteMutation = '''
mutation createNote(\$notes: NotesInputData!, \$assetCode: String) {
  createNote(notes: \$notes, assetCode: \$assetCode)
}
''';

  static const String assetSettingManualUpdateMutation = '''
mutation assetSettingManualUpdate(\$data: assetSettingManualUpdateInput) {
  assetSettingManualUpdate(data: \$data)
}
''';

  static const String assetsPartsLiveQuery = '''
query assetPartsLive(\$body: AssetPartsInput, \$queryParam: PaginationQueryParam) {
  assetPartsLive(body: \$body, queryParam: \$queryParam) {
    items {
      name
      identifier
      partNumber
      expiryRunhours
      expiryOdometer
      expiryDuration
      remainingOdometer
      remainingRunhours
      remainingTime
      fittedDate
      fittedRunhours
      fittedOdometer
      usedTime
      usedRunhours
      usedOdometer
      totalTime
      totalRunhours
      totalOdometer
    }
    totalItems
    totalPages
    pageItemCount
    currentPage
  }
}
''';

  static const String assetPartsHistoryQuery = '''
query assetPartsHistory(\$body: AssetPartsInput, \$queryParam: PaginationQueryParam) {
  assetPartsHistory(body: \$body, queryParam: \$queryParam) {
    items {
      name
      identifier
      partNumber
      expiryRunhours
      expiryOdometer
      expiryDuration
      fittedDate
      fittedRunhours
      fittedOdometer
      removedDate
      removedRunhours
      removedOdometer
      usedOdometer
      usedRunhours
      usedTime
    }
    totalItems
    totalPages
    pageItemCount
    currentPage
  }
}
''';

  static const String getAssetListCountQuery = '''
query getAssetListCount(\$filter: AssetFilter!) {
  getAssetListCount(filter: \$filter)
}
''';

  static const String getJobCountCategorisedToDaysQuery = '''
query getJobCountCategorisedToDays(\$data:ListJobPaginationInput){
  getJobCountCategorisedToDays(data:\$data)
}
''';
}
