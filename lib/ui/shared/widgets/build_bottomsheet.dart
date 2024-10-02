import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/themes/colors.dart';

Future<void> buildModalBottomSheet(
  BuildContext context, {
  required String title,
  required Widget child,
  double? height,
}) {
  return showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(top: 40.sp),
        child: Container(
          height: height ?? 50.h,
          decoration: const BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      );
    },
  );
}
