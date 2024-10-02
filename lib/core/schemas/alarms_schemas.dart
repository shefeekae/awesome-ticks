class AlarmsSchema {
  static const String listAlarmsQuery = '''
query listAlarms(\$filter: AlarmsFilter!) {
  listAlarms(filter: \$filter) {
    count
    eventLogs {
      name
      type
      group
      criticality
      sourceId
      sourceType
      sourceTypeName
      sourceName
      eventTime
      eventDay
      activeMessage
      suspectData
      active
      recurring
      resolved
      resolvedTime
      eventId
      acknowledged
      sourceDomain
      eventDomain
      clientDomain
      clientName
      actionRequired
      actioned
      assetCode
      sourceTagPath
      issue
      action
      suggestion
      configurationId
      delay
      annotations
      tagids
      workOrderId
      workOrderNo
      location
    }
  }
}

''';

  static const String alramsDetailsJson = '''
query getEventDetails(\$identifier: String!, \$multipleAssetAlarms: Boolean) {
  getEventDetails(
    identifier: \$identifier
    multipleAssetAlarms: \$multipleAssetAlarms
  )
}

''';

  static const String alarmsDiagnosisDetailsQuery = '''
query getEventDetailDiagnosis(\$data: AlarmDiagnosisInput!) {
  getEventDetailDiagnosis(data: \$data)
}
''';

  static const String alarmsCountQuery = '''
query getAlarmCount(\$filter: AlarmsFilter!) {
  getAlarmCount(filter: \$filter)
}
''';
}
