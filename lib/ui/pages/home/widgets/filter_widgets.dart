// import 'dart:convert';
// import 'package:awesometicks/core/blocs/filter/payload/payload_management_bloc.dart';
// import 'package:awesometicks/core/services/platform_services.dart';
// import 'package:awesometicks/ui/pages/home/widgets/filter_data_builder_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bounce/flutter_bounce.dart';
// import 'package:graphql_config/graphql_config.dart';
// import 'package:intl/intl.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/blocs/filter/filter applied/filter_applied_bloc.dart';
// import '../../../../core/blocs/filter/filter_selection/filter_selection_bloc.dart';
// import '../../../../core/models/filter_model.dart';
// import '../../../../core/models/filter_value_model.dart';
// import '../../../../core/schemas/filter_shemas.dart';
// import '../../../../core/services/filter_services.dart';
// import '../../../../core/services/graphql_services.dart';
// import '../../../../core/services/jobs_services.dart';
// import '../../../../utils/themes/colors.dart';
// import '../../../shared/widgets/loading_widget.dart';
// import 'package:collection/collection.dart';

// class FilterWidgetHelpers {
//   String searchValue = "";
//   bool searchEnabled = false;

// //   Future<void> filterBottomSheet({
// //     required BuildContext context,
// //     required FilterSelectionBloc filterSelectionBloc,
// //     required FilterAppliedBloc filterAppliedBloc,
// //     required PayloadManagementBloc payloadManagementBloc,
// //   }) async {
// //     await showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       // backgroundColor: fwhite,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(
// //           top: Radius.circular(15),
// //         ),
// //       ),
// //       builder: (context) {
// //         return DraggableScrollableSheet(
// //           expand: false,
// //           initialChildSize: 0.5,
// //           maxChildSize: 0.9,
// //           minChildSize: 0.32,
// //           builder: (context, scrollController) {
// //             var filterLabelsList = filterSelectionBloc.state.filterLabelsList;

// //             if (filterLabelsList.isNotEmpty) {
// //               return buildFilterLayout(
// //                 scrollController: scrollController,
// //                 filterSelectionBloc: filterSelectionBloc,
// //                 filterAppliedBloc: filterAppliedBloc,
// //                 payloadManagementBloc: payloadManagementBloc,
// //                 context: context,
// //               );
// //             }

//             return QueryWidget(
//               options: GraphqlServices().getQueryOptions(
//                 query: FilterSchemas.getJobFilterQuery,
//                 variables: {
//                   "appMode": "BUILDING_ONLY",
//                   "brand": "nectar",
//                 },
//               ),
//               builder: (result, {fetchMore, refetch}) {
//                 if (result.isLoading) {
//                   return ListView.separated(
//                     itemCount: 4,
//                     padding: EdgeInsets.all(10.sp),
//                     separatorBuilder: (context, index) {
//                       return SizedBox(
//                         height: 10.sp,
//                       );
//                     },
//                     itemBuilder: (context, index) {
//                       return ShimmerLoadingContainerWidget(height: 10.h);
//                     },
//                   );
//                 }

//                 if (result.hasException) {
//                   return GraphqlServices().handlingGraphqlExceptions(
//                     result: result,
//                     context: context,
//                     refetch: refetch,
//                   );
//                 }

//                 JobsServices().addFilterData(
//                   filterSelectionBloc: filterSelectionBloc,
//                   // filterAppliedBloc: filterAppliedBloc,
//                   data: result.data?["getJobFilter"] ?? [],
//                 );

// //                 return buildFilterLayout(
// //                   scrollController: scrollController,
// //                   filterSelectionBloc: filterSelectionBloc,
// //                   filterAppliedBloc: filterAppliedBloc,
// //                   payloadManagementBloc: payloadManagementBloc,
// //                   context: context,
// //                 );
// //               },
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   // =============================================================================================================================
// // // Filter Widget Layout

// //   Column buildFilterLayout({
// //     required ScrollController scrollController,
// //     required FilterSelectionBloc filterSelectionBloc,
// //     required FilterAppliedBloc filterAppliedBloc,
// //     required PayloadManagementBloc payloadManagementBloc,
// //     required BuildContext context,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: EdgeInsets.all(10.sp),
// //           child: Text(
// //             "Filter",
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //               fontSize: 15.sp,
// //             ),
// //           ),
// //         ),
// //         Divider(
// //           thickness: 3,
// //           height: 3.sp,
// //           color: fwhite,
// //         ),
// //         buildFilterLabelsWidgets(
// //           scrollController: scrollController,
// //           filterSelectionBloc: filterSelectionBloc,
// //         ),
// //         buildApplyandClearButtons(
// //           filterAppliedBloc: filterAppliedBloc,
// //           filterSelectionBloc: filterSelectionBloc,
// //           payloadManagementBloc: payloadManagementBloc,
// //           context: context,
// //         ),
// //         SizedBox(
// //           height: 10.sp,
// //         ),
// //       ],
// //     );
// //   }

// //   // ==============================================================================================================
// //   //

// //   Widget buildFilterLabelsWidgets({
// //     required ScrollController scrollController,
// //     required FilterSelectionBloc filterSelectionBloc,
// //   }) {
// //     List<FilterModel> list = filterSelectionBloc.state.filterLabelsList;
// //     // filterModelFromJson(JobsServices.joblistFilterItems);

// //     for (var element in list) {
// //       if (element.name == "assignee") {
// //         list.remove(element);
// //         break;
// //       }
// //     }

// //     return Expanded(
// //       child: ListView.separated(
// //         itemCount: list.length,
// //         padding: EdgeInsets.all(10.sp),
// //         controller: scrollController,
// //         itemBuilder: (context, index) {
// //           FilterModel filterModel = list[index];

// //           String type = filterModel.type ?? "";

// //           String key = filterModel.name ?? "";

//           String label = filterModel.label ?? "";

// //           String placeHolder =
// //               filterModel.additionalProps?.placeholder ?? "Select $label";

// //           return filterContainerWidget(
// //             label: label,
// //             type: type,
// //             filterSelectionBloc: filterSelectionBloc,
// //             key: key,
// //             filterModel: filterModel,
// //             placeHolder: placeHolder,
// //           );
// //         },
// //         separatorBuilder: (context, index) {
// //           return SizedBox(
// //             height: 20.sp,
// //           );
// //         },
// //       ),
// //     );
// //   }

//   Column filterContainerWidget(
//       {required String label,
//       required String type,
//       required FilterSelectionBloc filterSelectionBloc,
//       required String key,
//       required FilterModel filterModel,
//       required String placeHolder}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10.sp,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(
//           height: 3.sp,
//         ),
//         StatefulBuilder(builder: (context, setState) {
//           return GestureDetector(
//             onTap: () async {
//               FilterValue buildingsSelected = filterSelectionBloc
//                   .state.filterValues
//                   .singleWhere((element) => element.key == "building");

//               bool isSpacesNotEnable =
//                   key == "space" && buildingsSelected.selectedValues.isEmpty;

// //               if (isSpacesNotEnable) {
// //                 return;
// //               }

//               if (type == "rangepicker") {
//                 PlatformServices().showPlatformDateRange(context).then((value) {
//                   if (value != null) {
//                     DateTime start = value.start;
//                     DateTime end = value.end;

// //                     Map<String, dynamic> data = {
// //                       "start": DateFormat("MMM, d - yyyy").format(start),
// //                       "end": DateFormat("MMM, d - yyyy").format(end)
// //                     };

// //                     Map<String, dynamic> identifiers = {
// //                       "start": start.millisecondsSinceEpoch,
// //                       "end": end.millisecondsSinceEpoch,
// //                     };

// //                     filterSelectionBloc.add(
// //                       AddRadioButtonValueEvent(
// //                         selectedValue: SelectedValue(
// //                           name: jsonEncode(data),
// //                           identifier: jsonEncode(identifiers),
// //                         ),
// //                         key: key,
// //                       ),
// //                     );
// //                   }
// //                 });
// //                 return;
// //               }

// //               await showModalBottomSheet(
// //                 context: context,
// //                 isScrollControlled: true,
// //                 backgroundColor: Colors.transparent,
// //                 builder: (context) {
// //                   return Builder(builder: (context) {
// //                     return Container(
// //                       decoration: const BoxDecoration(
// //                         color: kWhite,
// //                         borderRadius: BorderRadius.only(
// //                           topLeft: Radius.circular(7),
// //                           topRight: Radius.circular(7),
// //                         ),
// //                       ),
// //                       height: 70.h,
// //                       child: Builder(builder: (context) {
// //                         // print(filterModel.apiCallNeeded);

// //                         bool apiCallNeeded = filterModel.apiCallNeeded ?? true;

// //                         print("Api CAll Needed $apiCallNeeded");

// //                         if (!apiCallNeeded) {
// //                           List<Option> options = filterModel.options ?? [];

// //                           List<FilterValueModel> filterValueList = options
// //                               .map(
// //                                 (e) => FilterValueModel(
// //                                   identifier: e.value ?? "",
// //                                   title: e.label ?? "",
// //                                 ),
// //                               )
// //                               .toList();

// //                           return Column(
// //                             children: [
// //                               // buildFilterHeader(
// //                               //   count: "",
// //                               //   label: filterModel.label,
// //                               //   onChanged: (value) {},
// //                               //   searchVisible: filterModel.key != "status",
// //                               // ),
// //                               // Visibility(
// //                               //   visible: filterModel.key != "status",
// //                               //   child: const Divider(
// //                               //     thickness: 1,
// //                               //     height: 1,
// //                               //   ),
// //                               // ),
// //                               buildResultsWithFilterHeader(
// //                                 list: filterValueList,
// //                                 searchVisible: true,
// //                                 filterSelectionBloc: filterSelectionBloc,
// //                                 filterModel: filterModel,
// //                               ),
// //                               // buildFooterButtons(context),
// //                             ],
// //                           );
// //                         }

// //                         // String queryMethod = FilterServices()
// //                         //     .getQueryMethods(key: filterModel.name ?? "");

// //                         // Map<String, dynamic> variables =
// //                         //     FilterServices().getVariables(
// //                         //   filterModel: filterModel,
// //                         //   filterSelectionBloc: filterSelectionBloc,
// //                         //   pageKey: -1,
// //                         // );

// //                         // print(queryMethod);
// //                         // print(variables);

// //                         return FilterListBuilderWithPagination(
// //                           filterModel: filterModel,
// //                         );

// //                         // return buildQueryWidget(
// //                         //   queryMethod,
// //                         //   variables,
// //                         //   context,
// //                         //   filterModel: filterModel,
// //                         //   filterSelectionBloc: filterSelectionBloc,
// //                         // );
// //                       }),
// //                     );
// //                   });
// //                 },
// //               );

// //               List<FilterValue> filterValues =
// //                   filterSelectionBloc.state.filterValues;

// //               List<String> fieldsToClear = filterModel.fieldsToClear;

// //               for (var element in fieldsToClear) {
// //                 print("Fields to clear $element");

// //                 var selectedValues = filterValues
// //                     .singleWhereOrNull((element) => element.key == key)
// //                     ?.selectedValues;

// //                 if (selectedValues != null) {
// //                   if (selectedValues.isNotEmpty) {
// //                     filterSelectionBloc.add(
// //                       ResetAppliedFilter(key: element, screenKey: ""),
// //                     );
// //                   }
// //                 }
// //               }
// //             },
// //             child: buildFilterLabelContainer(
// //               filterSelectionBloc,
// //               placeHolder,
// //               filterModel: filterModel,
// //             ),
// //           );
// //         }),
// //       ],
// //     );
// //   }

// //   // ==================================================================================================================
// //   // Filter container

// //   Widget buildFilterLabelContainer(
// //     FilterSelectionBloc filterSelectionBloc,
// //     String placeHolder, {
// //     required FilterModel filterModel,
// //   }) {
// //     String key = filterModel.name ?? "";

// //     return BlocBuilder<FilterSelectionBloc, FilterSelectionState>(
// //       builder: (context, state) {
// //         List<FilterValue> filterValues = state.filterValues;

//         FilterValue buildingsSelected =
//             filterValues.singleWhere((element) => element.key == "building");

//         bool isSpacesNotEnable =
//             key == "space" && buildingsSelected.selectedValues.isEmpty;

// //         return Container(
// //           // height: 30.sp,
// //           width: double.infinity,
// //           padding: EdgeInsets.all(5.sp),
// //           decoration: BoxDecoration(
// //             // color: fwhite,
// //             color: isSpacesNotEnable ? Colors.grey.shade400 : fwhite,
// //             border: Border.all(
// //               width: 0.1,
// //             ),
// //             borderRadius: BorderRadius.circular(5),
// //           ),
// //           child: Builder(
// //             builder: (context) {
// //               FilterValue filterAppliedModel =
// //                   filterValues.singleWhere((element) => element.key == key);

// //               List<SelectedValue> selectedValues =
// //                   filterAppliedModel.selectedValues;

// //               if (selectedValues.isNotEmpty) {
// //                 return Wrap(
// //                     runSpacing: 5.sp,
// //                     spacing: 5.sp,
// //                     children: List.generate(selectedValues.length, (index) {
// //                       SelectedValue value = selectedValues[index];

// //                       String name = "";

// //                       if (key == "dateRange") {
// //                         Map<String, dynamic> data = jsonDecode(value.name);

// //                         name = "${data['start']}  -  ${data['end']}";
// //                       } else {
// //                         name = value.name;
// //                       }

//                       return Container(
//                         decoration: BoxDecoration(
//                           color: secondaryColor,
//                           borderRadius: BorderRadius.circular(7),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                             vertical: 2.sp, horizontal: 5.sp),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               name,
//                               style: const TextStyle(
//                                 color: kWhite,
//                               ),
//                             ),
//                             SizedBox(
//                               width: 5.sp,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 filterSelectionBloc.add(
//                                   RemoveValueToFilterSelection(
//                                     selectedValue: value,
//                                     key: key,
//                                   ),
//                                 );

//                                 List<FilterValue> filterValues =
//                                     filterSelectionBloc.state.filterValues;

//                                 List<String> fieldsToClear =
//                                     filterModel.fieldsToClear;

//                                 for (var element in fieldsToClear) {
//                                   print("Fields to clear $element");

//                                   var selectedValues = filterValues
//                                       .singleWhereOrNull(
//                                           (element) => element.key == key)
//                                       ?.selectedValues;

//                                   if (selectedValues != null) {
//                                     if (selectedValues.isNotEmpty) {
//                                       filterSelectionBloc.add(
//                                         ResetAppliedFilter(
//                                             key: element, screenKey: ""),
//                                       );
//                                     }
//                                   }
//                                 }
//                               },
//                               child: Icon(
//                                 Icons.cancel_outlined,
//                                 color: primaryColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }));
//               }

// //               return Padding(
// //                 padding: EdgeInsets.symmetric(vertical: 3.sp),
// //                 child: Text(
// //                   isSpacesNotEnable ? "Select Building To Enable" : placeHolder,
// //                   style: TextStyle(
// //                     color: isSpacesNotEnable ? kWhite : Colors.black38,
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // =======================================================================================
// //   // Appl

// //   Widget buildApplyandClearButtons({
// //     required FilterAppliedBloc filterAppliedBloc,
// //     required FilterSelectionBloc filterSelectionBloc,
// //     required PayloadManagementBloc payloadManagementBloc,
// //     required BuildContext context,
// //   }) {
// //     return Column(
// //       children: [
// //         const Divider(),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //           children: [
// //             Bounce(
// //               duration: const Duration(milliseconds: 100),
// //               onPressed: () {
// //                 JobsServices().clearFilterData(
// //                   filterSelectionBloc: filterSelectionBloc,
// //                 );
// //               },
// //               child: Container(
// //                 height: 5.h,
// //                 width: 45.w,
// //                 decoration: BoxDecoration(
// //                   border: Border.all(
// //                     color: Theme.of(context).primaryColor,
// //                     width: 0.2,
// //                   ),
// //                   borderRadius: BorderRadius.circular(5),
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     "CLEAR",
// //                     style: TextStyle(
// //                       color: Theme.of(context).primaryColor,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             Bounce(
// //               duration: const Duration(milliseconds: 100),
// //               onPressed: () {
// //                 FilterServices().applyFilter(
// //                   payloadManagementBloc: payloadManagementBloc,
// //                   filterSelectionBloc: filterSelectionBloc,
// //                   filterAppliedBloc: filterAppliedBloc,
// //                   context: context,
// //                 );
// //               },
// //               child: Container(
// //                 height: 5.h,
// //                 width: 45.w,
// //                 decoration: BoxDecoration(
// //                   color: Theme.of(context).primaryColor,
// //                   borderRadius: BorderRadius.circular(5),
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     "APPLY",
// //                     style: TextStyle(
// //                       color: primaryAlt,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         SizedBox(
// //           height: 10.sp,
// //         ),
// //       ],
// //     );
// //   }

// // // ================================================================================
// // // This method is used to show the list of results.
// // // User can single select or multi select as per the filter type.
// // // String searchValue = "";

// //   Widget buildResultsWithFilterHeader({
// //     required List<FilterValueModel> list,
// //     required bool searchVisible,
// //     required FilterSelectionBloc filterSelectionBloc,
// //     required FilterModel filterModel,
// //   }) {
// //     // List<SelectedValue> selectedValues = filterSelectionBloc.state.filterValues
// //     //     .singleWhere(
// //     //       (element) => element.key == filterModel.name,
// //     //     )
// //     //     .selectedValues;

// //     // String key = filterModel.name ?? "";
// //     // String type = filterModel.type ?? "";

// //     return StatefulBuilder(builder: (context, setState) {
// //       // List<FilterValueModel> searchList = list
// //       //     .where((element) =>
// //       //         element.title.toLowerCase().contains(searchValue.toLowerCase()))
// //       //     .toList();

// //       return Expanded(
// //         child: FilterListBuilderWithPagination(
// //           filterModel: filterModel,
// //         ),
// //       );
// //     });
// //   }

// //   // ==========================================================================================================================
// //   // Filter header showing count and search icon.

//   Widget buildFilterHeaderWidget({
//     required StateSetter setState,
//     required List<FilterValueModel> filterValueList,
//     bool searchVisible = true,
//     required FilterModel filterModel,
//     void Function(String)? onChanged,
//   }) {
//     if (!searchVisible) {
//       return ListTile(
//         title: buildCountWithLabelWidget(
//           "",
//           filterModel.label ?? "",
//         ),
//       );
//     }

//     // bool searchEnabled = false;
//     // String searchValue = "";

//     return StatefulBuilder(
//       builder: (context, setStat) => ListTile(
//         // contentPadding: EdgeInsets.,
//         title: searchEnabled
//             ? CupertinoTextField(
//                 autofocus: true,
//                 placeholder: "Search",
//                 cursorColor: primaryColor,
//                 onChanged: (value) {
//                   setState(() {
//                     searchValue = value;
//                   });
//                 },
//               )
//             : buildCountWithLabelWidget(
//                 filterValueList.length.toString(),
//                 filterModel.label ?? "",
//               ),
//         trailing: IconButton(
//           onPressed: () {
//             if (searchEnabled) {
//               // print("HEEELLlll");
//               setState(() {
//                 searchValue = "";
//               });
//             }
//             setStat(() {
//               searchEnabled = !searchEnabled;
//             });
//           },
//           icon: Icon(
//             searchEnabled ? Icons.close : Icons.search,
//           ),
//         ),
//       ),
//     );
//   }

// // // ===============================================================================

// //   Row buildCountWithLabelWidget(String count, String label) {
// //     return Row(
// //       children: [
// //         Text(
// //           "$count ",
// //           style: TextStyle(
// //             fontSize: 15.sp,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 15.sp,
// //             fontWeight: FontWeight.w400,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// // // =========================================================================================
// // // This method is used to show the multiselect typed filters result data.
// // // The user can select the checkbox.

// //   Widget buildCheckboxListTile({
// //     required bool isChecked,
// //     required String name,
// //     required String identifier,
// //     required String key,
// //     required FilterSelectionBloc filterSelectionBloc,
// //   }) {
// //     return CheckboxListTile(
// //       value: isChecked,
// //       // checkColor: primaryColor,
// //       activeColor: primaryColor,
// //       onChanged: (value) {
// //         print("checkbox onchanged called value is $value");
// //         SelectedValue selectedValue = SelectedValue(
// //           name: name,
// //           identifier: identifier,
// //         );

// //         if (value!) {
// //           filterSelectionBloc.add(
// //             AddValueToFilterSelection(
// //               selectedValue: selectedValue,
// //               key: key,
// //             ),
// //           );
// //         } else {
// //           filterSelectionBloc.add(RemoveValueToFilterSelection(
// //             selectedValue: selectedValue,
// //             key: key,
// //           ));
// //           // print("else called");
// //         }
// //       },
// //       title: Text(name),
// //     );
// //   }

// // // =====================================================================
// // // This method is used to show the fetch the selected  data form server .

// //   QueryWidget buildQueryWidget(
// //     String queryMethod,
// //     Map<String, dynamic> variables,
// //     BuildContext context, {
// //     required FilterModel filterModel,
// //     required FilterSelectionBloc filterSelectionBloc,
// //   }) {
// //     // String searchValue = "";
// //     // print(filterModel.key);
// //     // print("filter key");
// //     return QueryWidget(
// //       options: GraphqlServices().getQueryOptions(
// //         query: queryMethod,
// //         variables: variables,
// //       ),
// //       builder: (result, {fetchMore, refetch}) {
// //         if (result.isLoading) {
// //           return BuildShimmerLoadingWidget(
// //             height: 7.h,
// //           );
// //         }

// //         if (result.hasException) {
// //           return GraphqlServices().handlingGraphqlExceptions(
// //             result: result,
// //             context: context,
// //             refetch: refetch,
// //           );
// //         }

// //         // print("filter result data");
// //         // print(result.data);

// //         if (result.data == null) {
// //           return const Center(
// //             child: Text("null called"),
// //           );
// //         }

// //         List<FilterValueModel> filterValueList =
// //             FilterServices().getSelctedFilterLabelData(
// //                   key: filterModel.name ?? "",
// //                   map: result.data!,
// //                 ) ??
// //                 [];

// //         // if (filterValueList == null) {
// //         //   return Text("No called");
// //         // }

// //         // for (var element in filterValueList) {
// //         //   print(element.title);
// //         // }

// //         if (filterValueList.isEmpty) {
// //           return const Center(
// //             child: Text("No Data"),
// //           );
// //         }

// //         return StatefulBuilder(builder: (context, setState) {
// //           // print("\nstate ful builder called\n");

// //           List<FilterValueModel> searchList = filterValueList
// //               .where((element) => element.title
// //                   .toLowerCase()
// //                   .contains(searchValue.toLowerCase()))
// //               .toList();

// //           return Column(
// //             children: [
// //               buildResultsWithFilterHeader(
// //                 list: searchList,
// //                 searchVisible: true,
// //                 filterSelectionBloc: filterSelectionBloc,
// //                 filterModel: filterModel,
// //               ),
// //               // buildFooterButtons(context),
// //             ],
// //           );
// //         });
// //       },
// //     );
// //   }

// //   // // =============================================================================
// //   // // Return radio butotn listTile,

// //   // RadioListTile<int> buildRadiobuttonListTile({
// //   //   required String name,
// //   //   required int index,
// //   //   required int? groupValue,
// //   //   required String identifier,
// //   //   required String key,
// //   //   required FilterSelectionBloc filterSelectionBloc,
// //   // }) {
// //   //   return RadioListTile(
// //   //     activeColor: primaryColor,
// //   //     title: Text(name),
// //   //     value: index,
// //   //     groupValue: groupValue,
// //   //     onChanged: (value) {
// //   //       SelectedValue selectedValue = SelectedValue(
// //   //         name: name,
// //   //         identifier: identifier,
// //   //       );
// //   //       filterSelectionBloc.add(AddRadioButtonValueEvent(
// //   //         selectedValue: selectedValue,
// //   //         key: key,
// //   //       ));
// //   //     },
// //   //   );
// //   // }
// // }
