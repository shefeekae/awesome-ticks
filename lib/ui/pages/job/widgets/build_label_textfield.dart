// ignore_for_file: public_member_api_docs, sort_constructors_first
// =============================================================================
// Showing the label with textfield.

import 'package:awesometicks/ui/shared/widgets/build_custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../../utils/themes/colors.dart';

Widget buildLabelWithTextfieldWidget({
  required String title,
  required TextEditingController textEditingController,
  required String hintText,
  bool enabelRequiredText = true,
  bool enableValidator = true,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
      ),
      SizedBox(
        height: 7.sp,
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
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
  );

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.sp),
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
