class ServiceRequestSchemas {
  static const String listServiceRequest = '''
query listServiceRequests(\$filter: ServiceRequestFilter!) {
  listServiceRequests(filter: \$filter) {
    items {
      requestNumber
      requestType
      requestTime
      assignedTime
      requestSubjectLine
      requestDescription
      requestStatus
      requestSourceLocation
      domain
      jobId
      requestee {
        name
        id
        emailId
        contactNumber
      }
      managedBy {
        name
        id
        referenceId
      }
      createdBy
      createdOn
      updatedBy
      updatedOn
    }
    totalItems
  }
}
''';

// ================================================================================

  static const String findServiceRequestQuery = '''
query findServiceRequest(\$requestNumber: String!) {
  findServiceRequest(requestNumber: \$requestNumber)
}
''';

// -----===========================--------------------------------===============

  static const String saveServiceRequestMutation = '''
mutation saveServiceRequest(\$data: ServiceRequestInput!) {
  saveServiceRequest(data: \$data)
}
''';

// ================================================================================

  static const String uploadMultipleFilesMutation = '''
mutation uploadMultipleFiles(\$data : [MultipleFiles]){
  uploadMultipleFiles(data: \$data)
}
''';

// ================================================================================

  static const String listPaginatedTenantsQuery = '''
query listPaginatedTenants(\$query: BillingTenantPaginationInput, \$body: BillingTenantInput) {
  listPaginatedTenants(query: \$query, body: \$body) {
    items {
      id
      domain
      name
      emailId
      contactNumber
    }
    totalItems
  }
}
''';

// =============================================================================

  static const String findAllBuildingsQuery = '''
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

// ===============================================================================================

  static const String getRequstTypecountQuery = '''
  query listServiceRequestTypeCount(\$domain: String!, \$startTime: Float, \$endTime: Float) {
    listServiceRequestTypeCount(domain: \$domain, startTime: \$startTime, endTime: \$endTime)
  }
''';

// ================================================================================================

  static const String listServiceRequestStatusCountQuery = '''
  query listServiceRequestStatusCount(\$domain: String!,\$managedBy:Float, \$startTime: Float, \$endTime: Float) {
    listServiceRequestStatusCount(domain: \$domain,managedBy:\$managedBy, startTime: \$startTime, endTime: \$endTime)
  }
''';

// ===============================================================================================

  static const String getAllFilesFromSamePathQuery = '''
query getAllFilesFromSamePath(\$filePath: String!,\$traverseFiles: Boolean \$isJSON: Boolean, \$sortBy: String, \$sortOrder: String) {
  getAllFilesFromSamePath(
    filePath: \$filePath
    isJSON: \$isJSON
    sortBy: \$sortBy
    sortOrder: \$sortOrder
    traverseFiles: \$traverseFiles
  )
}
''';

// ================================================================================================

  static const String getServiceRequestTransitionsQuery = '''
query getServiceRequestTransitions(\$requestNumber: String!) {
  getServiceRequestTransitions(requestNumber: \$requestNumber) {
    id
    transitionTime
    currentStatus
    previousStatus
    transitionComment
  }
}
''';

// =================================================================================

  static const String closeServiceRequestMutation = '''
mutation closeServiceRequest(\$requestNumber: String!, \$remark: String) {
  closeServiceRequest(requestNumber: \$requestNumber, remark: \$remark)
}
''';

// =================================================================================

  static const String listallAssigneesQuery = '''
query listAllAssignees(\$domain: String!, \$type: String) {
  listAllAssignees(domain: \$domain, type: \$type) {
    id
    name
    referenceId
  }
}
''';

// =================================================================================

  static const String listAllVendorsQuery = '''
query listVendors(\$domain: String!) {
  listVendors(domain: \$domain) {
    type
    data
  }
}
''';

// ===============================================================================

  static const String listJobCommonUtilsQuery = '''
query listJobCommonUtils(\$utilTypes: [String]) {
  listJobCommonUtils(utilTypes: \$utilTypes)
}
''';

// ===================================================================================

  static const String postJobMutation = '''
mutation postJob(\$jobData: jobInput!) {
  postJob(jobData: \$jobData) {
    jobName
  }
}
''';

// ======================================================================================

  static const String updateCustomerSatisfactionMutation = '''
mutation updateCustomerSatisfaction(\$requestNumber: String!, \$rating: Int) {
  updateCustomerSatisfaction(requestNumber: \$requestNumber, rating: \$rating)
}
''';

// ==========================================================================================

  static const String completeserviceRequestMutation = '''
mutation completeServiceRequest(\$requestNumber: String!){
  completeServiceRequest(requestNumber: \$requestNumber)
} 
''';

// ==========================================================================================

  static const String cancelserviceRequestMutation = '''
mutation cancelServiceRequest(\$requestNumber: String!){
  cancelServiceRequest(requestNumber: \$requestNumber)
} 
''';

// ==========================================================================================

  static const String listAllSpacesPagination = '''
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

// ==========================================================================================

  static const String getLastServiceInfoQuery = '''
query getLastServiceInfo(\$identifier:String!,\$jobType:String,\$jobStatus:String){
  getLastServiceInfo(identifier:\$identifier,jobType:\$jobType,jobStatus:\$jobStatus)
}
''';
}
