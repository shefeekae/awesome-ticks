// // import 'package:awesometicks/core/models/listalljobsmodel.dart';
// // import 'package:awesometicks/ui/pages/job/job_details.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bounce/flutter_bounce.dart';
// // import 'package:sizer/sizer.dart';

// // import '../../../../utils/themes/colors.dart';
// // import '../../../shared/functions/get_color_icons.dart';
// // import '../../../shared/widgets/status_widget.dart';

// // class BuildHomeCard extends StatelessWidget {
// //   const BuildHomeCard({
// //     required this.item,
// //     super.key,
// //   });

// //   final Items item;

// //   @override
// //   Widget build(BuildContext context) {
// //     Color statusColor = getStatusColor(item.status ?? "");

//     return Bounce(
//       duration: Duration(milliseconds: 100),
//       onPressed: () {
//         Navigator.of(context).pushNamed(
//           JobDetailsScreen.id,
//           arguments: {
//             "jobId": item.id,
//             // "jobName": item.jobName ?? "N/A",
//             // "status": item.status ?? "",
//             // "criticality": item.criticality ?? "",
//             // "location" : item.resource.
//           },
//         );
//       },
//       child: Card(
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: fwhite,
//           ),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.sp),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 5.sp,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       "Job Inprogress",
//                       style: TextStyle(
//                         color: primaryColor,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Spacer(),
//                     Icon(
//                       Icons.timer,
//                       color: Colors.red.shade700,
//                     )
//                   ],
//                 ),
//                 SizedBox(
//                   height: 5.sp,
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     color: kWhite,
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(vertical: 10.sp),
//                     child: Column(
//                       children: [
//                         IntrinsicHeight(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                   Text(
//                                     item.status ?? "",
//                                     style: TextStyle(
//                                       color: Colors.red.withOpacity(0.3),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                   Text(
//                                     "28 Feb",
//                                     style: TextStyle(
//                                       fontSize: 13.sp,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                   Text(
//                                     "02:58",
//                                     style: TextStyle(
//                                       fontSize: 10.sp,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                 ],
//                               ),
//                               const VerticalDivider(
//                                 width: 0,
//                                 thickness: 2,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                   SizedBox(
//                                     width: 50.w,
//                                     child: Text(
//                                       item.jobName ?? "N/A",
//                                       style: TextStyle(
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                   BuildStatusWidget(
//                                     status: item.status ?? "",
//                                     statusColor: statusColor,
//                                   ),
//                                   SizedBox(
//                                     height: 5.sp,
//                                   ),
//                                   // Text(
//                                   //   "2:58",
//                                   //   style: TextStyle(
//                                   //     fontSize: 10.sp,
//                                   //     fontWeight: FontWeight.bold,
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10.sp,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// // //  =========================================================================================
// // // Get label text.
// // }
