// <<<<<<< HEAD
// // // ignore_for_file: public_member_api_docs, sort_constructors_first
// // import 'package:awesometicks/core/models/filter_model.dart';
// // import 'package:awesometicks/core/services/filter_services.dart';
// // import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// // import 'package:sizer/sizer.dart';
// // import '../../../../core/blocs/filter/filter_selection/filter_selection_bloc.dart';
// // import '../../../../core/models/filter_value_model.dart';
// // import '../../../../utils/themes/colors.dart';
// // import '../../../shared/widgets/radio_button_tile.dart';

// // class FilterListBuilderWithPagination extends StatefulWidget {
// //   // final String itemKey;
// //   // final String type;
// //   // final List<FilterValueModel searchList;
// //   // final FilterSelectionBloc filterSelectionBloc;
// //   final FilterModel filterModel;

// //   const FilterListBuilderWithPagination({
// //     Key? key,
// //     // required this.itemKey,
// //     // required this.type,
// //     // required this.searchList,
// //     required this.filterModel,
// //   }) : super(key: key);

// //   @override
// //   State<FilterListBuilderWithPagination> createState() =>
// //       _FilterListBuilderWithPaginationState();
// // }

// // class _FilterListBuilderWithPaginationState
// //     extends State<FilterListBuilderWithPagination> {
// //   late PagingController<int, FilterValueModel> pagingController;

// //   late FilterSelectionBloc filterSelectionBloc;

// //   late String itemKey;
// //   late String type;

// //   final TextEditingController searchTextController = TextEditingController();

// //   @override
// //   void initState() {
// //     itemKey = widget.filterModel.name ?? "";
// //     type = widget.filterModel.type ?? "";

// //     filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);

// //     pagingController = PagingController<int, FilterValueModel>(firstPageKey: 1);

// //     pagingController.addPageRequestListener((pageKey) {
// //       FilterServices().paginatedGraphqlCall(
// //         filterModel: widget.filterModel,
// //         filterSelectionBloc: filterSelectionBloc,
// //         pageKey: pageKey,
// //         pagingController: pagingController,
// //         searchValue: searchTextController.text.trim(),
// //       );
// //     });

// //     // TODO: implement initState
// //     super.initState();
// //   }

// //   @override
// //   void dispose() {
// //     pagingController.dispose();
// //     // TODO: implement dispose
// //     super.dispose();
// //   }

// //   // @override
// //   // void didUpdateWidget(covariant FilterListBuilderWithPagination oldWidget) {
// //   //   if (oldWidget.filterModel != widget.filterModel) {
// //   //     initState();
// //   //   }

// //   //   // TODO: implement didUpdateWidget
// //   //   super.didUpdateWidget(oldWidget);
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         // buildCountWithLabelWidget(
// //         //   count: "",
// //         //   // count: pagingController.itemList?.length.toString() ?? "",
// //         //   label: widget.filterModel.label ?? "",
// //         // ),
// //         buildFilterHeaderWidget(
// //           filterModel: widget.filterModel,
// //         ),
// //         const Divider(
// //           thickness: 1,
// //           height: 1,
// //         ),
// //         Expanded(
// //           child: RefreshIndicator.adaptive(
// //             onRefresh: () => Future.sync(
// //               () => pagingController.refresh(),
// //             ),
// //             child: PagedListView<int, FilterValueModel>.separated(
// //               shrinkWrap: true,
// //               pagingController: pagingController,
// //               separatorBuilder: (context, index) {
// //                 // if (filterModel.name == "status") {
// //                 //   // ==================================================
// //                 //   // When the user select the status tab it's not showing the seperated widget.
// //                 //   // It's used for clean and seperated grouped ui.
// //                 //   return const SizedBox();
// //                 // }

// //                 return const Divider(
// //                   height: 1,
// //                 );
// //               },
// //               builderDelegate: PagedChildBuilderDelegate<FilterValueModel>(
// //                 itemBuilder: (context, FilterValueModel item, index) {
// //                   String name = item.title;
// //                   String identifier = item.identifier;

// //                   // if (type == "checkbox" ||
// //                   //     type == "multiselect" ||
// //                   //     type == "MultiSelect" ||
// //                   //     type == "CheckBox") {
// //                   //   return buildMultiSelectbuilder(
// //                   //     item,
// //                   //     name,
// //                   //     identifier,
// //                   //   );
// //                   // } else if (type == "Select" ||
// //                   //     type == "Radio" ||
// //                   //     type == "select") {
// //                   //   return buildRadioButtonsbuilder(
// //                   //     name,
// //                   //     index,
// //                   //     identifier,
// //                   //   );
// //                   // }

// //                   switch (type) {
// //                     case "checkbox":
// //                     case "multiselect":
// //                     case "MultiSelect":
// //                     case "CheckBox":
// //                       return buildMultiSelectbuilder(
// //                         item,
// //                         name,
// //                         identifier,
// //                       );

// //                     case "Select":
// //                     case "Radio":
// //                     case "select":
// //                       return buildRadioButtonsbuilder(
// //                         name,
// //                         index,
// //                         identifier,
// //                       );

// //                     default:
// //                       return ListTile(
// //                         title: Text(
// //                           item.title,
// //                         ),
// //                       );
// //                   }
// //                 },
// //                 newPageErrorIndicatorBuilder: (context) {
// //                   return ElevatedButton.icon(
// //                     onPressed: () {
// //                       pagingController.retryLastFailedRequest();
// //                     },
// //                     icon: const Icon(Icons.refresh),
// //                     label: const Text("Retry"),
// //                   );
// //                 },
// //                 firstPageProgressIndicatorBuilder: (context) {
// //                   return BuildShimmerLoadingWidget(
// //                     shrinkWrap: true,
// //                     height: 30.sp,
// //                   );
// //                 },
// //                 noItemsFoundIndicatorBuilder: (context) {
// //                   return Padding(
// //                     padding: EdgeInsets.only(top: 15.sp),
// //                     child: Center(
// //                       child: Text(
// //                         "No items found",
// //                         style: TextStyle(
// //                           fontSize: 13.sp,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //                 noMoreItemsIndicatorBuilder: (context) {
// //                   var itemsCount = pagingController.itemList?.length ?? 0;

// //                   if (itemsCount < 10) {
// //                     return const SizedBox();
// //                   }

// //                   return Padding(
// //                     padding: EdgeInsets.symmetric(vertical: 10.sp),
// //                     child: const Center(
// //                       child: Text("No data to show"),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // =================================================================================================
// //   // showing the multi selection ui (CheckBox)

// //   BlocBuilder<FilterSelectionBloc, FilterSelectionState>
// //       buildMultiSelectbuilder(
// //           FilterValueModel item, String name, String identifier) {
// //     return BlocBuilder<FilterSelectionBloc, FilterSelectionState>(
// //       builder: (context, state) {
// //         List<SelectedValue> selectedValues = state.filterValues
// //             .singleWhere(
// //               (element) => element.key == itemKey,
// //             )
// //             .selectedValues;

// //         bool isChecked = selectedValues.any(
// //           (element) => element.identifier == item.identifier,
// //         );

// //         return buildCheckboxListTile(
// //           isChecked: isChecked,
// //           name: name,
// //           identifier: identifier,
// //           key: itemKey,
// //           filterSelectionBloc: filterSelectionBloc,
// //         );
// //       },
// //     );
// //   }

// // // ==================================================================================
// // // Showing the radio buttons list.

// //   BlocBuilder<FilterSelectionBloc, FilterSelectionState>
// //       buildRadioButtonsbuilder(String name, int index, String identifier) {
// //     return BlocBuilder<FilterSelectionBloc, FilterSelectionState>(
// //       builder: (context, state) {
// //         int? groupValue;

// //         List<SelectedValue> selectedValues = state.filterValues
// //             .singleWhere(
// //               (element) => element.key == itemKey,
// //             )
// //             .selectedValues;

// //         if (selectedValues.isNotEmpty) {
// //           groupValue = pagingController.itemList?.indexWhere(
// //             (element) => element.identifier == selectedValues.first.identifier,
// //           );
// //         }

// //         return buildRadiobuttonListTile(
// //           name: name,
// //           index: index,
// //           groupValue: groupValue,
// //           identifier: identifier,
// //           key: itemKey,
// //           filterSelectionBloc: filterSelectionBloc,
// //         );
// //       },
// //     );
// //   }

// // // =========================================================================================
// // // ===================================================================================

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
// //         // print("checkbox onchanged called value is $value");
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

// // // =================================================================================
// // // Build count with label,

// //   Widget buildCountWithLabelWidget({
// //     required String? count,
// //     required String label,
// //   }) {
// //     return Row(
// //       children: [
// //         Visibility(
// //           visible: count != null,
// //           child: Text(
// //             "${count ?? ""} ",
// //             style: TextStyle(
// //               fontSize: 15.sp,
// //               fontWeight: FontWeight.bold,
// //             ),
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

// //   bool searchEnabled = false;

// //   Widget buildFilterHeaderWidget({
// //     // required StateSetter setState,
// //     // required List<FilterValueModel> filterValueList,
// //     bool searchVisible = true,
// //     required FilterModel filterModel,
// //     void Function(String)? onChanged,
// //   }) {
// //     if (!searchVisible) {
// //       return ListTile(
// //         title: buildCountWithLabelWidget(
// //           count: "",
// //           label: filterModel.label ?? "",
// //         ),
// //       );
// //     }

// //     // bool searchEnabled = false;
// //     // String searchValue = "";

// //     return StatefulBuilder(
// //       builder: (context, setState) => ListTile(
// //         // contentPadding: EdgeInsets.,
// //         title: searchEnabled
// //             ? CupertinoTextField(
// //                 controller: searchTextController,
// //                 autofocus: true,
// //                 placeholder: "Search",
// //                 cursorColor: primaryColor,
// //                 onChanged: (value) {
// //                   var list = pagingController.itemList;

// //                   if (list == null) {
// //                     return;
// //                   }

// //                   print(value);

// //                   pagingController.refresh();

// //                   // if (itemKey == "assets") {
// //                   //   pagingController.refresh();
// //                   // } else {
// //                   //   var a = list
// //                   //       .where((element) => element.title
// //                   //           .toLowerCase()
// //                   //           .contains(value.toLowerCase()))
// //                   //       .toList();

// //                   //   pagingController.appendLastPage(
// //                   //     a,
// //                   //   );
// //                   // }
// //                 },
// //               )
// //             : buildCountWithLabelWidget(
// //                 count: "",
// //                 label: filterModel.label ?? "",
// //               ),
// //         trailing: IconButton(
// //           onPressed: () {
// //             if (searchEnabled) {
// //               // print("HEEELLlll");
// //               searchTextController.text = "";
// //               pagingController.refresh();
// //             }
// //             setState(() {
// //               searchEnabled = !searchEnabled;
// //             });
// //           },
// //           icon: Icon(
// //             searchEnabled ? Icons.close : Icons.search,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// =======
// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// import 'package:awesometicks/core/models/filter_model.dart';
// import 'package:awesometicks/core/services/filter_services.dart';
// import 'package:awesometicks/ui/pages/home/functions/job_filter_helpers.dart';
// import 'package:awesometicks/ui/shared/widgets/loading_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/blocs/filter/filter_selection/filter_selection_bloc.dart';
// import '../../../../core/models/filter_value_model.dart';
// import '../../../../utils/themes/colors.dart';
// import '../../../shared/widgets/radio_button_tile.dart';

// class FilterListBuilderWithPagination extends StatefulWidget {
//   // final String itemKey;
//   // final String type;
//   // final List<FilterValueModel searchList;
//   // final FilterSelectionBloc filterSelectionBloc;
//   final FilterModel filterModel;

//   const FilterListBuilderWithPagination({
//     Key? key,
//     // required this.itemKey,
//     // required this.type,
//     // required this.searchList,
//     required this.filterModel,
//   }) : super(key: key);

//   @override
//   State<FilterListBuilderWithPagination> createState() =>
//       _FilterListBuilderWithPaginationState();
// }

// class _FilterListBuilderWithPaginationState
//     extends State<FilterListBuilderWithPagination> {
//   late PagingController<int, FilterValueModel> pagingController;

//   late FilterSelectionBloc filterSelectionBloc;

//   late String itemKey;
//   late String type;

//   final TextEditingController searchTextController = TextEditingController();

//   @override
//   void initState() {
//     itemKey = widget.filterModel.name ?? "";
//     type = widget.filterModel.type ?? "";

//     filterSelectionBloc = BlocProvider.of<FilterSelectionBloc>(context);

//     pagingController = PagingController<int, FilterValueModel>(firstPageKey: 1);

//     pagingController.addPageRequestListener((pageKey) {
//       FilterServices().paginatedGraphqlCall(
//         key: widget.filterModel.name ?? "",
//         filterSelectionBloc: filterSelectionBloc,
//         pageKey: pageKey,
//         pagingController: pagingController,
//         searchValue: searchTextController.text.trim(),
//       );
//     });

//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   void dispose() {
//     pagingController.dispose();
//     // TODO: implement dispose
//     super.dispose();
//   }

//   // @override
//   // void didUpdateWidget(covariant FilterListBuilderWithPagination oldWidget) {
//   //   if (oldWidget.filterModel != widget.filterModel) {
//   //     initState();
//   //   }

//   //   // TODO: implement didUpdateWidget
//   //   super.didUpdateWidget(oldWidget);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Builder(builder: (context) {
//           FilterModel filterModel = widget.filterModel;

//           String label =
//               filterModel.label != null && filterModel.label!.isNotEmpty
//                   ? filterModel.label!
//                   : JobFilterHelpers().getLabel(filterModel.i18nLabel ?? "");

//           return buildFilterHeaderWidget(
//             label: label,
//           );
//         }),
//         const Divider(
//           thickness: 1,
//           height: 1,
//         ),
//         Expanded(
//           child: RefreshIndicator.adaptive(
//             onRefresh: () => Future.sync(
//               () => pagingController.refresh(),
//             ),
//             child: PagedListView<int, FilterValueModel>.separated(
//               shrinkWrap: true,
//               pagingController: pagingController,
//               separatorBuilder: (context, index) {
//                 // if (filterModel.name == "status") {
//                 //   // ==================================================
//                 //   // When the user select the status tab it's not showing the seperated widget.
//                 //   // It's used for clean and seperated grouped ui.
//                 //   return const SizedBox();
//                 // }

//                 return const Divider(
//                   height: 1,
//                 );
//               },
//               builderDelegate: PagedChildBuilderDelegate<FilterValueModel>(
//                 itemBuilder: (context, FilterValueModel item, index) {
//                   String name = item.title;
//                   String identifier = item.identifier;

//                   // if (type == "checkbox" ||
//                   //     type == "multiselect" ||
//                   //     type == "MultiSelect" ||
//                   //     type == "CheckBox") {
//                   //   return buildMultiSelectbuilder(
//                   //     item,
//                   //     name,
//                   //     identifier,
//                   //   );
//                   // } else if (type == "Select" ||
//                   //     type == "Radio" ||
//                   //     type == "select") {
//                   //   return buildRadioButtonsbuilder(
//                   //     name,
//                   //     index,
//                   //     identifier,
//                   //   );
//                   // }

//                   switch (type) {
//                     case "checkbox":
//                     case "multiselect":
//                     case "MultiSelect":
//                     case "CheckBox":
//                       return buildMultiSelectbuilder(
//                         item,
//                       );

//                     case "Select":
//                     case "Radio":
//                     case "select":
//                       return buildRadioButtonsbuilder(
//                         name,
//                         index,
//                         identifier,
//                       );

//                     default:
//                       return ListTile(
//                         title: Text(
//                           item.title,
//                         ),
//                       );
//                   }
//                 },
//                 newPageErrorIndicatorBuilder: (context) {
//                   return ElevatedButton.icon(
//                     onPressed: () {
//                       pagingController.retryLastFailedRequest();
//                     },
//                     icon: const Icon(Icons.refresh),
//                     label: const Text("Retry"),
//                   );
//                 },
//                 firstPageProgressIndicatorBuilder: (context) {
//                   return BuildShimmerLoadingWidget(
//                     shrinkWrap: true,
//                     height: 30.sp,
//                   );
//                 },
//                 noItemsFoundIndicatorBuilder: (context) {
//                   return Padding(
//                     padding: EdgeInsets.only(top: 15.sp),
//                     child: Center(
//                       child: Text(
//                         "No items found",
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//                 noMoreItemsIndicatorBuilder: (context) {
//                   var itemsCount = pagingController.itemList?.length ?? 0;

//                   if (itemsCount < 10) {
//                     return const SizedBox();
//                   }

//                   return Padding(
//                     padding: EdgeInsets.symmetric(vertical: 10.sp),
//                     child: const Center(
//                       child: Text("No data to show"),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // =================================================================================================
//   // showing the multi selection ui (CheckBox)

//   BlocBuilder<FilterSelectionBloc, FilterSelectionState>
//       buildMultiSelectbuilder(FilterValueModel item) {
//     return BlocBuilder<FilterSelectionBloc, FilterSelectionState>(
//       builder: (context, state) {
//         List<SelectedValue> selectedValues = state.filterValues
//             .singleWhere(
//               (element) => element.key == itemKey,
//             )
//             .selectedValues;

//         bool isChecked = selectedValues.any(
//           (element) => element.identifier == item.identifier,
//         );

//         return buildCheckboxListTile(
//           isChecked: isChecked,
//           name: item.title,
//           identifier: item.identifier,
//           filterSelectionBloc: filterSelectionBloc,
//         );
//       },
//     );
//   }

// // ==================================================================================
// // Showing the radio buttons list.

//   BlocBuilder<FilterSelectionBloc, FilterSelectionState>
//       buildRadioButtonsbuilder(String name, int index, String identifier) {
//     return BlocBuilder<FilterSelectionBloc, FilterSelectionState>(
//       builder: (context, state) {
//         int? groupValue;

//         List<SelectedValue> selectedValues = state.filterValues
//             .singleWhere(
//               (element) => element.key == itemKey,
//             )
//             .selectedValues;

//         if (selectedValues.isNotEmpty) {
//           groupValue = pagingController.itemList?.indexWhere(
//             (element) => element.identifier == selectedValues.first.identifier,
//           );
//         }

//         return buildRadiobuttonListTile(
//           name: name,
//           index: index,
//           groupValue: groupValue,
//           identifier: identifier,
//           key: itemKey,
//           filterSelectionBloc: filterSelectionBloc,
//         );
//       },
//     );
//   }

// // =========================================================================================
// // ===================================================================================

//   Widget buildCheckboxListTile({
//     required bool isChecked,
//     required String name,
//     required String identifier,
//     required FilterSelectionBloc filterSelectionBloc,
//   }) {
//     return CheckboxListTile(
//       value: isChecked,
//       // checkColor: primaryColor,
//       activeColor: primaryColor,
//       onChanged: (value) {
//         // print("checkbox onchanged called value is $value");
//         SelectedValue selectedValue = SelectedValue(
//           name: name,
//           identifier: identifier,
//         );

//         if (value!) {
//           filterSelectionBloc.add(
//             AddValueToFilterSelection(
//               selectedValue: selectedValue,
//               key: itemKey,
//             ),
//           );
//         } else {
//           filterSelectionBloc.add(RemoveValueToFilterSelection(
//             selectedValue: selectedValue,
//             key: itemKey,
//           ));
//           // print("else called");
//         }
//       },

//       title: Builder(builder: (context) {
//         bool isBuildings = itemKey == "building";

//         if (isBuildings) {
//           var map = jsonDecode(identifier);

//           var data = map['data'];

//           bool isActive = data['status'] == "ACTIVE";

//           String typeName = data['typeName'] ?? "No Type";

//           return Row(
//             children: [
//               Expanded(
//                 child: Text(name),
//               ),
//               Container(
//                 padding: EdgeInsets.all(5.sp),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4.sp),
//                   color: secondaryColor,
//                 ),
//                 child: Text(
//                   typeName,
//                   style: TextStyle(
//                     color: kWhite,
//                     fontSize: 8.sp,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 5.sp,
//               ),
//               Icon(
//                 Icons.circle,
//                 color: isActive ? Colors.green : Colors.red,
//                 size: 8.sp,
//               ),
//             ],
//           );
//         }

//         return Text(name);
//       }),
//     );
//   }

// // =================================================================================
// // Build count with label,

//   Widget buildCountWithLabelWidget({
//     required String? count,
//     required String label,
//   }) {
//     return Row(
//       children: [
//         Visibility(
//           visible: count != null,
//           child: Text(
//             "${count ?? ""} ",
//             style: TextStyle(
//               fontSize: 15.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 15.sp,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }

//   bool searchEnabled = false;

//   Widget buildFilterHeaderWidget({
//     // required StateSetter setState,
//     // required List<FilterValueModel> filterValueList,
//     bool searchVisible = true,
//     required String label,
//     void Function(String)? onChanged,
//   }) {
//     if (!searchVisible) {
//       return ListTile(
//         title: buildCountWithLabelWidget(
//           count: "",
//           label: label,
//         ),
//       );
//     }

//     // bool searchEnabled = false;
//     // String searchValue = "";

//     return StatefulBuilder(
//       builder: (context, setState) => ListTile(
//         // contentPadding: EdgeInsets.,
//         title: searchEnabled
//             ? CupertinoTextField(
//                 controller: searchTextController,
//                 autofocus: true,
//                 placeholder: "Search",
//                 cursorColor: primaryColor,
//                 onChanged: (value) {
//                   var list = pagingController.itemList;

//                   if (list == null) {
//                     return;
//                   }

//                   print(value);

//                   pagingController.refresh();

//                   // if (itemKey == "assets") {
//                   //   pagingController.refresh();
//                   // } else {
//                   //   var a = list
//                   //       .where((element) => element.title
//                   //           .toLowerCase()
//                   //           .contains(value.toLowerCase()))
//                   //       .toList();

//                   //   pagingController.appendLastPage(
//                   //     a,
//                   //   );
//                   // }
//                 },
//               )
//             : buildCountWithLabelWidget(
//                 count: "",
//                 label: label,
//               ),
//         trailing: IconButton(
//           onPressed: () {
//             if (searchEnabled) {
//               // print("HEEELLlll");
//               searchTextController.text = "";
//               pagingController.refresh();
//             }
//             setState(() {
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
// }
// >>>>>>> b51a7e2855958fd236a8e7745474c835834dfbe0
