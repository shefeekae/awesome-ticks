// // import 'dart:convert';
// // import 'package:awesometicks/core/models/filter_model.dart';
// // import 'package:awesometicks/core/schemas/jobs_schemas.dart';
// // import 'package:awesometicks/core/services/graphql_services.dart';
// // import 'package:awesometicks/core/services/jobs_services.dart';
// // import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// // import 'package:secure_storage/secure_storage.dart';
// // import 'package:flutter/widgets.dart';
// // // import 'package:nectar_assets/core/blocs/filter/filter%20applied/filter_applied_bloc.dart';
// // // import 'package:nectar_assets/core/blocs/filter/filter_selection/filter_selection_bloc.dart';
// // // import 'package:nectar_assets/core/blocs/filter/payload/payload_management_bloc.dart';
// // // import 'package:nectar_assets/core/services/sharedprefrence_services.dart';
// // import '../blocs/filter/filter applied/filter_applied_bloc.dart';
// // import '../blocs/filter/filter_selection/filter_selection_bloc.dart';
// // import '../blocs/filter/payload/payload_management_bloc.dart';
// // import '../models/filter_value_model.dart';
// // import '../schemas/filter_shemas.dart';
// // import 'package:collection/collection.dart';

// // class FilterServices {
// //   // =================================================================================
// //   // This method is used to show the

// //   UserDataSingleton userData = UserDataSingleton();

//   Map<String, dynamic> getVariables({
//     required FilterSelectionBloc filterSelectionBloc,
//     required FilterModel filterModel,
//     required int pageKey,
//     String searchValue = "",
//   }) {
//     String domain = userData.domain;

//     String key = filterModel.name ?? "";

// //     // List<String> fieldsToClear = filterModel.fieldsToClear;

// //     var list = filterSelectionBloc.state.filterValues;

// //     // print("Fields to clear all data $fieldsToClear");

// //     // for (var element in fieldsToClear) {
// //     //   print("Fields to clear $element");

// //     //   var selectedValues = list
// //     //       .singleWhereOrNull((element) => element.key == key)
// //     //       ?.selectedValues;

// //     //   if (selectedValues != null) {
// //     //     if (selectedValues.isNotEmpty) {
// //     //       filterSelectionBloc.add(
// //     //         ResetAppliedFilter(key: element, screenKey: ""),
// //     //       );
// //     //     }
// //     //   }
// //     // }

// //     switch (key) {
// //       case "clientDomain":
// //         // var list = filterSelectionBloc.state.filterValues;

// //         // ==================================================================
// //         // Clear the already applied assets values

// //         // var selectedValues = list
// //         //     .singleWhereOrNull((element) => element.key == "assets")
// //         //     ?.selectedValues;

// //         // if (selectedValues != null || selectedValues!.isNotEmpty) {
// //         //   filterSelectionBloc
// //         //       .add(ResetAppliedFilter(key: "assets", screenKey: ""));
// //         // }

// //         // ==================================================================

// //         return {
// //           "domain": domain,
// //           "strict": true,
// //           "loop": true,
// //         };

// //       case "community":
// //         return {
// //           "domain": domain,
// //         };

// //       case "subCommunity":
// //         // var list = filterSelectionBloc.state.filterValues;

// //         var selectedValues = list
// //             .singleWhereOrNull((element) => element.key == "community")
// //             ?.selectedValues;

// //         if (selectedValues != null) {
// //           if (selectedValues.isNotEmpty) {
// //             return {
// //               "domain": selectedValues[0].identifier,
// //             };
// //           }
// //         }

// //         return {
// //           "domain": domain,
// //         };

// //       case "building":
// //         var selectedValues = list
// //             .singleWhereOrNull((element) => element.key == "subCommunity")
// //             ?.selectedValues;

// //         if (selectedValues != null) {
// //           if (selectedValues.isNotEmpty) {
// //             var identifiers =
// //                 selectedValues.map((e) => jsonDecode(e.identifier)).toList();

// //             return {
// //               "domain": domain,
// //               "subCommunities": identifiers,
// //             };
// //           }
// //         }

// //         return {
// //           "domain": domain,
// //         };

// //       case "space":
// //         var selectedValues = list
// //             .singleWhereOrNull((element) => element.key == "building")
// //             ?.selectedValues;

// //         if (selectedValues != null) {
// //           if (selectedValues.isNotEmpty) {
// //             var identifiers =
// //                 selectedValues.map((e) => jsonDecode(e.identifier)).toList();

// //             return {
// //               "data": {
// //                 "domain": domain,
// //                 "type": "",
// //                 "site": identifiers,
// //               }
// //             };
// //           }
// //         }

// //         return {
// //           "data": {
// //             "domain": domain,
// //             "type": "",
// //           }
// //         };

// //       case "type":
// //         return {
// //           "domain": domain,
// //           "type": "Asset",
// //         };

// //       case "assets":
// //         var list = filterSelectionBloc.state.filterValues;

// //         var selectedValues = list
// //             .singleWhereOrNull((element) => element.key == "clientDomain")
// //             ?.selectedValues;

// //         if (selectedValues != null) {
// //           if (selectedValues.isNotEmpty) {
// //             var identifiers = selectedValues.map((e) => e.identifier).toList();

// //             return {
// //               "filter": {
// //                 "offset": pageKey,
// //                 "pageSize": 10,
// //                 "order": "asc",
// //                 "sortField": "displayName",
// //                 "searchLabel": searchValue,
// //                 "clients": identifiers,
// //                 "domain": domain,
// //               }
// //             };
// //           }
// //         }

// //         return {
// //           "filter": {
// //             "offset": pageKey,
// //             "pageSize": 10,
// //             "order": "asc",
// //             "sortField": "displayName",
// //             "searchLabel": searchValue,
// //             "domain": domain,
// //           }
// //         };

// //       case "parentType":
// //         return {
// //           "domain": domain,
// //           "name": "Asset",
// //         };

// //       case "documentCategory":
// //         return {
// //           "domain": domain,
// //         };

// //       case "location":
// //         return {
// //           "data": {
// //             "searchFields": {"name": "", "category": "GEOGRAPHIC_SEGMENT"},
// //             "order": "desc",
// //             "sortField": "createdOn",
// //             "domain": domain,
// //           }
// //         };

// //       case "jobType":
// //       case "criticality":
// //       case "priority":
// //       case "jobStatus":
// //         if (key == "jobType") {
// //           return {
// //             "utilTypes": [
// //               "JOBTYPES",
// //             ]
// //           };
// //         } else if (key == "criticality") {
// //           return {
// //             "utilTypes": [
// //               "CRITICALITY",
// //             ]
// //           };
// //         } else if (key == "priority") {
// //           return {
// //             "utilTypes": [
// //               "PRIORITIES",
// //             ]
// //           };
// //         } else if (key == "jobStatus") {
// //           return {
// //             "utilTypes": [
// //               "TICKETSTATUS",
// //             ]
// //           };
// //         }

// //         return {};

// //       case "managedBy":
// //         return {
// //           "domain": domain,
// //           "type": "Manager",
// //         };

// //       case "parts":
// //         return {
// //           "queryParam": {
// //             "page": -1,
// //             "size": 10,
// //             "sort": "name,asc",
// //           },
// //           "body": {
// //             "domain": domain,
// //             "status": "ACTIVE",
// //             "name": "",
// //           }
// //         };

// //       default:
// //         return {};
// //     }
// //   }

// //   // ==========================================================================
// //   // Get the query methods.

// //   String getQueryMethods({required String key}) {
// //     switch (key) {
// //       case "clientDomain":
// //         return FilterSchemas.clientJson;

// //       case "community":
// //         return FilterSchemas.listAllCommunitiesQuery;

// //       case "subCommunity":
// //         return FilterSchemas.listAllSubCommunitiesQuery;

// //       case "building":
// //         return FilterSchemas.listAllBuildingsQuery;

// //       case "space":
// //         return FilterSchemas.listAllSpacesQuery;

// //       case "type":
// //         return FilterSchemas.assetTypesJson;

// //       case "assets":
// //         return FilterSchemas.assetsListQuery;

// //       case "location":
// //         return FilterSchemas.locationJson;

// //       case "parentType":
// //         return FilterSchemas.parentTypeJson;

// //       case "documentCategory":
// //         return FilterSchemas.getDocumentCategoriesQuery;

// //       case "jobType":
// //       case "criticality":
// //       case "priority":
// //       case "jobStatus":
// //         return FilterSchemas.listJobCommonUtilsQuery;

// //       case "managedBy":
// //         return FilterSchemas.listAllassigneesQuery;

// //       case "parts":
// //         return JobsSchemas.listofPartsQuery;

// //       default:
// //         return "";
// //     }
// //   }

// // //  ==================================================================================================
// // // Return The correct data;

// //   List<FilterValueModel>? getSelctedFilterLabelData({
// //     required String key,
// //     required Map<String, dynamic> map,
// //   }) {
// //     // print("getSelctedFilterLabelData called");
// //     // print(map);
// //     List list = [];

// //     switch (key) {
// //       case "clientDomain":
// //         list = map['findAllClients'];

// //         return List.generate(list.length, (index) {
// //           String name = list[index]['data']['clientName'];
// //           String identifier = list[index]['identifier'];

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "community":
// //         list = map['listAllCommunities'];

// //         return List.generate(list.length, (index) {
// //           Map<String, dynamic> map = list[index];

// //           String name = map['data']['clientName'];
// //           String identifier = map['data']['clientId'];

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "subCommunity":
// //         list = map['findAllSubCommunities'];

// //         return List.generate(list.length, (index) {
// //           Map<String, dynamic> map = list[index];

// //           String name = map['data']['name'];
// //           String identifier = jsonEncode({
// //             "data": {
// //               "domain": map['data']['domain'],
// //               "identifier": map['data']['identifier'],
// //             },
// //             "type": map['type'],
// //           });

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "building":
// //         list = map['findAllBuildings'];

// //         return List.generate(
// //           list.length,
// //           (index) {
// //             Map<String, dynamic> map = list[index];

//             String name = map['data']['name'];
//             String identifier = jsonEncode({
//               "data": {
//                 "domain": map['data']['domain'],
//                 "identifier": map['data']['identifier'],
//               },
//               "type": map['type'],
//             });

// //             return FilterValueModel(
// //               identifier: identifier,
// //               title: name,
// //             );
// //           },
// //         );

// //       case "space":
// //         list = map['listAllSpacesPagination'];

// //         return List.generate(
// //           list.length,
// //           (index) {
// //             // Map<String, dynamic> map = list[index];
// //             Map<String, dynamic> data = list[index]['space']['data'];
// //             Map<String, dynamic> space = list[index]['space'];

// //             String name = data['name'];
// //             String identifier = jsonEncode({
// //               "data": {
// //                 "domain": data['domain'],
// //                 "identifier": data['identifier'],
// //               },
// //               "type": space['type'],
// //             });

// //             return FilterValueModel(
// //               identifier: identifier,
// //               title: name,
// //             );
// //           },
// //         );

// //       case "shifts":
// //         list = map['listPaginatedShifts']['items'];

// //         return List.generate(list.length, (index) {
// //           String name = list[index]['name'];
// //           String identifier = list[index]['identifier'];

// //           return FilterValueModel(identifier: identifier, title: name);
// //         });

// //       case "parentType":
// //         list = map['listAllTemplatesSystem'];
// //         return List.generate(list.length, (index) {
// //           String name = list[index]['templateName'];

// //           String identifier = list[index]['name'];

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "type":
// //         list = map['listAllAssetTypes'];
// //         return List.generate(list.length, (index) {
// //           String name = list[index]['templateName'];
// //           String identifier = list[index]['name'];

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "assets":
// //         list = map['getAssetList']['assets'];
// //         return List.generate(list.length, (index) {
// //           Map<String, dynamic> map = list[index];

// //           String name = list[index]['displayName'];
// //           String identifier = jsonEncode(
// //             {
// //               "resourceId": map['identifier'],
// //               "domain": map['domain'],
// //             },
// //           );

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "location":
// //         list = map['listAllGeoFences']['data'];
// //         // print(map);
// //         return List.generate(list.length, (index) {
// //           String type = list[index]['type'];
// //           Map map = list[index]['data'];
// //           String name = map['name'];

// //           print("name : $name");

// //           String identifier = jsonEncode(
// //             {
// //               "type": type,
// //               "data": {
// //                 "domain": map['domain'],
// //                 "identifier": map['identifier'],
// //                 "name": name,
// //               },
// //             },
// //           );

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "documentCategory":
// //         list = map['getDocumentCategories'];

// //         return List.generate(
// //           list.length,
// //           (index) {
// //             String type = list[index]['type'];
// //             Map map = list[index]['data'];

// //             String name = map['name'];
// //             String domain = map['domain'];

// //             String identifier = map['identifier'];

// //             String json = jsonEncode({
// //               "type": type,
// //               "data": {
// //                 "identifier": identifier,
// //                 "domain": domain,
// //               }
// //             });

// //             return FilterValueModel(
// //               identifier: json,
// //               title: name,
// //             );
// //           },
// //         );

// //       case "jobType":
// //       case "criticality":
// //       case "priority":
// //       case "jobStatus":
// //         if (key == "jobType") {
// //           list = map['listJobCommonUtils']["jobTypes"] ?? [];
// //         } else if (key == "criticality") {
// //           list = map['listJobCommonUtils']["criticality"] ?? [];
// //         } else if (key == "priority") {
// //           list = map['listJobCommonUtils']["priorities"] ?? [];
// //         } else if (key == 'jobStatus') {
// //           list = map['listJobCommonUtils']["ticketStatus"] ?? [];
// //         }

// //         // print("JOBTYPES $list");

// //         return List.generate(list.length, (index) {
// //           Map<String, dynamic> map = list[index];

// //           String name = map['value'];
// //           String identifier = map['key'];

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "managedBy":
// //         list = map['listAllAssignees'];

// //         return List.generate(list.length, (index) {
// //           Map<String, dynamic> map = list[index];

// //           String name = map['name'];
// //           String identifier = map['id'].toString();

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       case "parts":
// //         list = map["listAllServiceParts"]['items'];
// //         return List.generate(list.length, (index) {
// //           Map<String, dynamic> map = list[index];

// //           String name = map['name'];
// //           String identifier = jsonEncode({
// //             "identifier": map['identifier'],
// //             "name": name,
// //             "domain": map['domain'],
// //             "partReference": map['partReference'],
// //             "unitCost": map['unitCost'],
// //           });

// //           return FilterValueModel(
// //             identifier: identifier,
// //             title: name,
// //           );
// //         });

// //       default:
// //         return null;
// //     }
// //   }

// // //  =============================================================================
// // // Filter apply payload functiom.
// // // This mehtod updating the current payload to the selected filter.

// //   void applyFilter({
// //     required PayloadManagementBloc payloadManagementBloc,
// //     required FilterSelectionBloc filterSelectionBloc,
// //     required FilterAppliedBloc filterAppliedBloc,
// //     required BuildContext context,
// //   }) {
// //     Map<String, dynamic> payload = payloadManagementBloc.state.payload;

// //     List<FilterValue> appliedFilters = filterSelectionBloc.state.filterValues;

// //     int filterAppliedCount = appliedFilters
// //         .where((element) => element.selectedValues.isNotEmpty)
// //         .length;

// //     print("filter: $filterAppliedCount");

// //     if (filterAppliedCount == 0) {
// //       filterAppliedBloc.add(UpdateFilterAppliedCount(count: 0));

// //       payloadManagementBloc.add(
// //         ChangePayloadEvent(
// //           payload: {
// //             "domain": userData.domain,
// //             "hasInTeam": true,
// //             "status": JobsServices.initialStatusList,
// //           },
// //         ),
// //       );

// //       Navigator.of(context).pop();
// //       return;
// //     }

// //     for (var element in appliedFilters) {
// //       String key = element.key;

// //       List<String> identifiers =
// //           element.selectedValues.map((e) => e.identifier).toList();

// //       if (identifiers.isEmpty) {
// //         switch (key) {
// //           case "clientDomain":
// //           case "community":
// //           case "subCommunity":
// //           case "building":
// //           case "jobType":
// //           case "criticality":
// //           case "priority":
// //           case "managedBy":
// //             payload.remove(key);
// //             break;

// //           case "space":
// //             payload.remove("spaces");
// //             break;

// //           case "assets":
// //             payload.remove("resource");
// //             break;

// //           case "jobStatus":
// //             payload.remove("status");
// //             break;

// //           case "dateRange":
// //             payload.remove("startDate");
// //             payload.remove("endDate");
// //             break;
// //         }

// //         continue;
// //       }

// //       // print("identifiers: $identifiers");

// //       switch (key) {
// //         case "clientDomain":
// //         case "community":
// //           payload['community'] = identifiers;

// //           break;

// //         case "subCommunity":
// //           List<Map<String, dynamic>> list = [];

// //           for (var element in identifiers) {
// //             list.add(jsonDecode(element));
// //           }

// //           payload['subCommunity'] = list;
// //           break;

// //         case "building":
// //           List<Map<String, dynamic>> list = [];

// //           for (var element in identifiers) {
// //             list.add(jsonDecode(element));
// //           }
// //           payload['building'] = list;

// //           break;

// //         case "space":
// //           List<Map<String, dynamic>> list = [];

// //           for (var element in identifiers) {
// //             list.add(jsonDecode(element));
// //           }
// //           payload['spaces'] = list;

// //           break;

// //         case "assets":
// //           List<Map<String, dynamic>> list = [];

// //           for (var element in identifiers) {
// //             list.add(jsonDecode(element));
// //           }
// //           payload['resource'] = list;

// //           break;

// //         case "jobType":
// //           payload['jobType'] = identifiers;
// //           // identifiers.isEmpty ? null : jsonEncode(identifiers);
// //           break;

// //         case "criticality":
// //           payload['criticality'] = identifiers;
// //           // identifiers.isEmpty ? null : jsonEncode(identifiers);
// //           break;

// //         case "priority":
// //           payload['priority'] = identifiers;
// //           // identifiers.isEmpty ? null : jsonEncode(identifiers);
// //           break;

// //         case "jobStatus":
// //           payload['status'] = identifiers;
// //           // identifiers.isEmpty ? null : ["COMPLETED"];
// //           // identifiers.toString();
// //           break;

// //         case "managedBy":
// //           payload['managedBy'] = identifiers.map((e) => int.parse(e)).toList();
// //           // identifiers.isEmpty ? null : jsonEncode(identifiers);
// //           break;

// //         case "dateRange":
// //           Map<String, dynamic> map = jsonDecode(identifiers[0]);
// //           payload['startDate'] = map['start'];
// //           payload['endDate'] = map['end'];

// //           break;

// //         default:
// //       }
// //     }

// //     // int filterAppliedCount = appliedFilters
// //     //     .where((element) => element.selectedValues.isNotEmpty)
// //     //     .length;

// //     filterAppliedBloc.add(UpdateFilterAppliedCount(
// //       count: filterAppliedCount,
// //     ));

// //     payloadManagementBloc.add(
// //       ChangePayloadEvent(
// //         payload: payload,
// //       ),
// //     );

// //     Navigator.of(context).pop();
// //   }

// // // ==========================================================================
// // // This method is used to return the applied filter values identifers.

// //   List<String> getIdentifiers(List<SelectedValue> list) =>
// //       list.map((e) => e.identifier).toList();

// // // ============================================================================
// // // This method is used to remove the applied payload and intilize the already used payload.

// //   void resetFilterApplied({
// //     required PayloadManagementBloc payloadManagementBloc,
// //     // required List<SelectedValue> selectedValues,
// //     required String key,
// //     // required BuildContext context,
// //   }) {
// //     Map<String, dynamic> payload = payloadManagementBloc.state.payload;
// //     String payloadKey = payloadManagementBloc.state.key;

// //     // List<String> identifiers = getIdentifiers(selectedValues);

// //     switch (key) {
// //       case "clientDomain":
// //         // print("client  identifiers $identifiers");

// //         if (payloadKey == "alarms") {
// //           payload['filter']['searchTagIds'] = [];
// //         } else if (payloadKey == "documents") {
// //           payload['data']['clients'] = [];
// //         }

// //         break;

// //       case "type":
// //       case "parentType":
// //         if (payloadKey == 'alarms') {
// //           // print("type identifiers $identifiers");
// //           payload['filter']['types'] = [];
// //         } else if (payloadKey == "documents") {
// //           payload['data']['types'] = [];
// //         }

// //         break;

// //       // case "parentType":
// //       //   if(payloadKey == "documents"){
// //       //    payload['data']
// //       //   }
// //       //   break;

// //       case "category":
// //         payload['filter']['groups'] = [];

// //         break;

// //       case "documentCategory":
// //         payload['data']['documentCategory'] = [];
// //         break;

// //       case "status":
// //         // print("STatus identifiers $identifiers");
// //         if (payloadKey == "alarms") {
// //           payload['filter']['status'] = [];
// //         } else if (payloadKey == "documents") {
// //           payload['data'].remove("status");
// //         }
// //         break;

// //       case "validity":
// //         payload['data'].remove("validity");
// //         break;

// //       case "criticality":
// //         payload['filter']['criticalities'] = [];

// //         break;

// //       case "location":
// //         // List<Map<String, dynamic>> list = [];

// //         // for (var element in identifiers) {
// //         //   list.add(jsonDecode(element));
// //         // }

// //         payload['filter']['segmentFilter'] = [];

// //         break;

// //       default:
// //     }

// //     payloadManagementBloc.add(
// //       ChangePayloadEvent(
// //         payload: payload,
// //       ),
// //     );

// //     // Navigator.of(context).pop();
// //   }

// //   // ========================================================================================
// //   // used for pagination

//   paginatedGraphqlCall({
//     required FilterModel filterModel,
//     required FilterSelectionBloc filterSelectionBloc,
//     required int pageKey,
//     required PagingController<int, FilterValueModel> pagingController,
//     String searchValue = "",
//   }) async {
//     String queryMethod = getQueryMethods(key: filterModel.name ?? "");

//     Map<String, dynamic> variables = getVariables(
//       filterModel: filterModel,
//       filterSelectionBloc: filterSelectionBloc,
//       pageKey: pageKey,
//       searchValue: searchValue,
//     );

//     String itemKey = filterModel.name ?? "";

// //     print('paginated pageKey ${pageKey}');

// //     var result = await GraphqlServices().performQuery(
// //       query: queryMethod,
// //       variables: variables,
// //     );

// //     print(result.data);

// //     if (result.hasException) {
// //       pagingController.error = result.exception;
// //       print("filter paginatedGraphqlCall exception ${result.exception}");
// //       return [];
// //     }

// //     // print(result.data);

//     List<FilterValueModel> filterValueList = getSelctedFilterLabelData(
//           key: filterModel.name ?? "",
//           map: result.data!,
//         ) ??
//         [];

// //     int? totalCount;

//     if (itemKey == "assets") {
//       totalCount = result.data?['getAssetList']?['totalAssetsCount'];
//       // print("paginated result: ${result.data}");
//     } else {
//       filterValueList = filterValueList
//           .where((element) => element.title.toLowerCase().contains(
//                 searchValue.toLowerCase(),
//               ))
//           .toList();
//     }

// //     var totalItems = pagingController.itemList ?? [];

// //     int totalValuesCount = totalItems.length + filterValueList.length;
// //     // [...totalItems, ...filterValueList].length;

// //     if (totalCount == null) {
// //       pagingController.appendLastPage(filterValueList);

// //       return;
// //     }

// //     if (totalValuesCount == totalCount) {
// //       pagingController.appendLastPage(filterValueList);
// //     } else if (filterValueList.isEmpty) {
// //       pagingController.appendLastPage([]);
// //     } else {
// //       pagingController.appendPage(
// //         filterValueList,
// //         pageKey + 1,
// //       );
// //     }

// //     // print("Paginated fetched list length: ${filterValueList.length}");
// //     print(
// //         "paginated controller list lenght ${pagingController.itemList?.length}");
// //     print("paginated total count: $totalCount");

// //     // if (list.length < 10) {
// //     //   pagingController.appendLastPage(filterValueList);
// //     // } else {
// //     //   pagingController.appendPage(
// //     //     filterValueList,
// //     //     pageKey,
// //     //   );
// //     // }

// //     // return filterValueList ?? [];
// //   }
// // }
