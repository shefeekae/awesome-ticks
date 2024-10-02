class JobFilterHelpers {
// ================================================================================================
// getJObFilter api response doesn't give the correct label because of the i8N implementation.
// get the i8N label and convert to displaying label

  String getLabel(String key) {
    String splitedKey = "";

    try {
      List list = key.split(".");

      splitedKey = list.last;
    } catch (e) {
      print("JobFilterHelpers getLabel catch $e");
      return "";
    }

    switch (splitedKey) {
      case "client":
        return "Clients";

      case "community":
        return "Community";

      case "subCommunities":
        return "Sub Communities";

      case "buildings":
        return "Buildings";

      case "spaces":
        return "Spaces";

      case "assets":
      case "equipments":
        return "Assets";

      case "jobType":
        return "JobType";

      case "criticality":
        return "Criticality";

      case "priority":
        return "Priority";

      case "status":
        return "Job Status";

      case "managedBy":
        return "Managed By";

      case "dateRange":
        return "Date Range";

      default:
        return "";
    }
  }
}
