// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:tenex/ui/pages/services/widgets/label_with_container.dart';
// import 'package:tenex/ui/pages/services/widgets/label_with_textfield.dart';
// import 'package:tenex/ui/shared/widgets/build_elevated_button.dart';
// import 'package:tenex/utils/constants/colors.dart';

// class TransferServiceScreen extends StatelessWidget {
//   TransferServiceScreen({super.key});

//   final TextEditingController remarkController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kWhite,
//       appBar: AppBar(
//         title: Text("Transfer"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10.sp),
//         child: Column(
//           children: [
//             buildLabelWithContainerWidget(
//               title: "Vendor",
//               hintText: "Choose Vendor",
//               enableRequired: false,
//               // onTap: null,
//             ),
//             SizedBox(
//               height: 10.sp,
//             ),
//             buildLabelWithTextfieldWidget(
//               title: "Vendor",
//               textEditingController: remarkController,
//               hintText: "Add Remark",
//               maxLines: 5,
//               enabelRequiredText: false,
//             ),
//             Spacer(),
//             BuildElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               title: "TRANSFER",
//             ),
//             SizedBox(
//               height: 15.sp,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
