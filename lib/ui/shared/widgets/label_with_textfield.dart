// =============================================================================
// Showing the label with textfield.

import 'package:awesometicks/ui/shared/widgets/build_custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../pages/job/widgets/build_label_textfield.dart';

Widget buildLabelWithTextfieldWidget({
  required String title,
  required TextEditingController textEditingController,
  required String hintText,
  bool enabelRequiredText = true,
  bool enableValidator = true,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildLabelWidget(
        title: title,
        enableRequiredText: enabelRequiredText,
      ),
      // SizedBox(
      //   height: 5.sp,
      // ),
      BuildCustomTextformField(
        hintText: hintText,
        controller: textEditingController,
        maxLines: maxLines,
        enableValidator: enableValidator,
        keyboardType: keyboardType,
        
      ),
    ],
  );
}



Widget buildLabelWidget({
  required String title,
  bool enableRequiredText = true,
}) {
  TextStyle style = TextStyle(
    color: Colors.grey.shade500,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 3.sp),
    child: Builder(builder: (context) {
      if (!enableRequiredText) {
        return Text(
          title,
          style: style,
        );
      }

      return RichText(
        text: TextSpan(text: title, style: style, children: const [
          TextSpan(
            text: " *",
            style: TextStyle(
              color: Colors.red,
            ),
          )
        ]),
      );
    }),
  );
}

