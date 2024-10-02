class JobsSchemas {
// ===================================================================================================================================

  static const String listAllJobsQuery = '''
query listAllJobsWithPaginationSortSearch(\$queryParam: PaginationQueryParam, \$data: ListJobPaginationInput) {
  listAllJobsWithPaginationSortSearch(queryParam: \$queryParam, data: \$data) {
    items {
      id
      priority
      jobName
      jobStartTime
      expectedEndTime
      expectedDuration
      actualStartTime
      actualEndTime
      actualDuration
      jobLocation
      jobType
      status
      jobNumber
      serviceRequest
      assignee {
        id
        name
      }
      resource {
        domain
        identifier
        displayName
        referenceId
        resourceId
        type
      }
    }
    totalItems
  }
}
''';

// =================================================================================================
// Jobs Details

  static const String findJobWithId = '''
query findJobWithId(\$jobId: Float!) {
  findJobWithId(jobId: \$jobId) {
    checklist {
      item
      id
      description
      commentCount
      checkable
      checked
      executionIndex
      attachments
      choiceType
      choices
      selectedChoice
      type
    }
    signedTechnician
    signedClient
    signedManager
    completionRemark
    costOfJob
    costOfParts
    costOfWork
    priority
    discipline
    customerSatisfaction
    expectedDuration
    expectedEndTime
    generatedFrom
    id
    jobNumber
    domain
    jobDomain
    jobLocation
    jobLocationName
    jobSource
    jobStartTime
    jobType
    jobRemark
    parts {
      name
      identifier: sparePartId
      partReference
      quantity
      totalCost
      unitCost
      domain
    }
    paymentReceived
    requestRemark
    requestTime
    requesteeName
    toolsRequired {
      tool {
        id
        name
        toolCode
        make
        model
        description
      }
    }
    skillsRequired {
      isPrimary
      skill {
        id
        name
        industry
        service
        system
      }
    }
    status
    resource {
      domain
      identifier
      displayName
      referenceId
      resourceId
      type
    }
    jobName
    hasTravelTime
    hasTravelTimeIncluded
    actualStartTime
    assignee {
      name
      id
      emailId
      domain
      costPerHour
      contactNumber
      referenceId
      status
    }
    managedBy {
      name
      id
      domain
      costPerHour
      contactNumber
      referenceId
      status
    }
    requestedBy {
      name
      id
      domain
      costPerHour
      contactNumber
      referenceId
      status
      emailId
    }
    actualEndTime
    lastStatusTime
    jobAssignedTime
    vendor
    community {
      type
      clientName
      domain
      clientId
    }
    subCommunity {
      type
      name
      domain
      identifier
    }
    building {
      type
      name
      domain
      identifier
    }
    spaces {
      type
      name
      domain
      identifier
    }
    transitions
    serviceRequest
    members {
      id
      assignee {
        name
        id
        domain
        costPerHour
        contactNumber
        referenceId
        status
      }
    }
    runhours
    odometer
  }
}
''';

// ==================================================================================

  static const String canecellationQuery = '''
query listServiceCancelationReason(\$domain: String!) {
  listServiceCancelationReason(domain: \$domain) {
    items {
      identifier
      name
    }
  }
}
''';

// ======================================================================================

  static const String jobStatusUpdateMutation = '''
mutation jobStatusUpdate(\$id: Float!, \$statusData: statusDataInput) {
  jobStatusUpdate(id: \$id, statusData: \$statusData) {
    id
  }
}
''';

// ==========================================================================================

  static const String updateCheckListMutation = '''
mutation updateCheckList(\$checkListData: checkListData!) {
  updateCheckList(checkListData: \$checkListData)
}
''';

// =========================================================================================

  static const String jobCompleteMutation = '''
mutation jobComplete(\$id: Float!, \$data: JobCompleteInput) {
  jobComplete(id: \$id, data: \$data)
}
''';

//  =========================================================================================

  static const String checklistCommentsQuery = '''
query listCheckListComments(\$checklistId: Float) {
  listCheckListComments(checklistId: \$checklistId) {
    id
    comment
    commentTime
    commentBy
    attachmentRef
    status
    commentId
    hasReplies
    replyCount
  }
}
''';

// ==============================================================================

  static const String getAllFilesFromSamePath = '''
query getAllFilesFromSamePath(\$filePath: String!,\$traverseFiles: Boolean \$isJSON: Boolean, \$sortBy: String, \$sortOrder: String,\$showHiddenFolder
: Boolean) {
  getAllFilesFromSamePath(
    filePath: \$filePath
    isJSON: \$isJSON
    sortBy: \$sortBy
    sortOrder: \$sortOrder
    traverseFiles: \$traverseFiles
    showHiddenFolder: \$showHiddenFolder
  )
}
''';

// ==============================================================================

//   static const String getAllfilesFromPath = '''
// query getAllFilesFromPath(\$data: FileInput!) {
//   getAllFilesFromPath(data: \$data)
// }
// ''';

// ==============================================================================

  static const String getFileForPreview = '''
query getFileForPreview(
    \$fileName: String!
    \$filePath: String!
    \$isJSON: Boolean
  ) {
    getFileForPreview(fileName: \$fileName, filePath: \$filePath, isJSON: \$isJSON)
  }
''';

//   static const String getAllfilesFromPath = '''
// query getAllFilesFromPath(\$data: FileInput!) {
//   getAllFilesFromPath(data: \$data)
// }
// ''';

// =============================================================================

  static const String cheklictRepliesCommentsQuery = '''
query listCheckListReplies(\$commentId: Float) {
  listCheckListReplies(commentId: \$commentId) {
    id
    comment
    commentTime
    commentBy
    attachmentRef
    status
    commentId
    hasReplies
  }
}
''';

// ===========================================================================

  static const String addCheckListCommentReply = '''
mutation addCheckListCommentReply(\$checkListReply: checkListCommentInput!) {
  addCheckListCommentReply(checkListReply: \$checkListReply)
}
''';

// ===================================================================================

  static const String addChecklistComment = '''
mutation addCheckListComment(\$checkListComment: checkListCommentInput!) {
  addCheckListComment(checkListComment: \$checkListComment)
}
''';

// ================================================================================

  static const String uploadMultipleFilesMutation = '''
mutation uploadMultipleFiles(\$data : [MultipleFiles]){
  uploadMultipleFiles(data: \$data)
}
''';

// ================================================================================

  static const String listAllServicePartsQuery = '''
query listAllServiceParts(\$body: ListAllServicePartsInput, \$queryParam: PaginationQueryParam) {
  listAllServiceParts(body: \$body, queryParam: \$queryParam) {
    items {
      name
      description
      types {
        type
        templateName
        exclusive
      }
      runhours
      odometer
      identifier
      createdBy
      createdOn
      updatedBy
      updatedOn
      status
      duration
      expiryDate
      domain
      unitCost
      partReference
    }
    totalItems
    totalPages
    pageItemCount
    currentPage
  }
}
''';

// ==========================================================================================

  static const String jobCommentsQuery = '''
query getAllComments(\$jobId: Int) {
  getAllComments(jobId: \$jobId) {
    id
    comment
    commentTime
    commentBy
    commentId
    replied
  }
}
''';

// ========================================================================================

  static const String addJobCommentMutation = '''
mutation addJobComment(\$data: AddJobCommentInput) {
  addJobComment(data: \$data)
}
''';

// ============================================================================

  static const String getCommentReplyQuery = '''
query getCommentReply(\$commentId: Int) {
  getCommentReply(commentId: \$commentId) {
    id
    comment
    commentTime
    commentBy
    commentId
    replied
    jobId
  }
}
''';

// =====================================================================================================

  static const String addCommentReplyMutation = '''
mutation addCommentReply(\$data: AddCommentReplyInput) {
  addCommentReply(data: \$data)
}
''';

// ====================================================================================================

  static const String addChecklistMutation = '''
mutation addCheckListToJob(\$checkListData: checkListData!) {
  addCheckListToJob(checkListData: \$checkListData) {
    id
  }
}
''';

//========================================================================================================

  static const String listofPartsQuery = '''
query listAllServiceParts(\$body: ListAllServicePartsInput, \$queryParam: PaginationQueryParam) {
  listAllServiceParts(body: \$body, queryParam: \$queryParam) {
    items {
      name
      description
      types {
        type
        templateName
        exclusive
      }
      runhours
      odometer
      identifier
      createdBy
      createdOn
      updatedBy
      updatedOn
      status
      duration
      expiryDate
      domain
      unitCost
      partReference
    }
    totalItems
    totalPages
    pageItemCount
    currentPage
  }
}
''';

// ===================================================================================================

  static const String addPartsMutation = '''
mutation partsAdd(\$partsData: partsInputData!) {
  partsAdd(partsData: \$partsData) {
    id
  }
}
''';

// ================================================================================

  static const String partsUpdateMutation = '''
mutation partsUpdate(\$partsData: partsInputData!) {
  partsUpdate(partsData: \$partsData) {
    id
    parts {
      name
      identifier: sparePartId
      partReference
      quantity
      totalCost
      unitCost
      domain
    }
  }
}
''';

// ===============================================================================

  static const String removePartsMutation = '''
mutation partsRemove(\$partsData: partsInputData!) {
  partsRemove(partsData: \$partsData) {
    id
    parts {
      name
      identifier: sparePartId
      partReference
      quantity
      totalCost
      unitCost
      domain
    }
  }
}
''';

// ================================================================================================

  static const String listAllJobsWithDetailsForSync = '''
query listAllJobsWithDetailsForSync(\$queryParam: PaginationQueryParam, \$data: ListJobPaginationInput) {
  listAllJobsWithDetailsForSync(queryParam: \$queryParam, data: \$data)
}
''';

// ====================================================================================================

  static const String getJobCountCategorisedToDaysQuery = '''
query getJobCountCategorisedToDays(\$data:ListJobPaginationInput){
  getJobCountCategorisedToDays(data:\$data)
}
''';

// ==================================================================================================

  static const String jobStatusUpdate = '''
mutation jobStatusUpdate(\$id: Float!, \$statusData: statusDataInput) {
  jobStatusUpdate(id: \$id, statusData: \$statusData) {
    id
  }
}
''';

// ==================================================================================================

  static const String findJobComment = '''
query findJobComment(\$commentId:Int){
  findJobComment(commentId: \$commentId){
    comment,
    commentTime,
    id,
    commentBy
  }
}
''';

// ==================================================================================================

  static const String findChecklistJobComment = '''
query findJobChecklistComment(\$commentId:Int){
  findJobChecklistComment(commentId: \$commentId){
    comment,
    commentTime,
    id,
    commentBy
  }
}
''';

// ====================================================================================================================

  static const String addJobCommentToAttachment = '''
mutation addJobCommentToAttachment(\$data:AttachmentWithComment){
    addJobCommentToAttachment(data: \$data)
}
''';

// ========================================================

  static const String addJobCommentWithAttachment = '''
mutation addJobCommentWithAttachment(\$data:JobCommentWithAttachmentInput){
    addJobCommentWithAttachment(data: \$data)
}
''';

  static const String listAllAssigneesUnPaged = '''
query listAllAssigneesUnPaged(\$domain: String!, \$type: String) {
  listAllAssigneesUnPaged(domain: \$domain, type: \$type) {
    items{
    id
    name
    referenceId
    emailId
    contactNumber
    }
  }
}
''';

  static const String startTrip = ''' mutation startTrip(\$data: TripInput) 
{  startTrip(data: \$data) 
   } ''';

  /// query for getting latest state and showing action buttons
  static const String getTimeSheetData = '''
  query getTimeSheetData(\$data: AssigneeTimeSheetInput) {
    getTimeSheetData(data: \$data) {
      assignee {
          id
          name
        }
      startTime
      endTime
      startLocation
      endLocation
      startLocationName
      endLocationName
      timesheetDay
      duration
      activity
      jobTripReference
    }
}
  ''';

  static const String stopTrip = '''  mutation stopTrip(\$data: TripInput) {
    stopTrip(data: \$data) 
  }
 ''';
}
