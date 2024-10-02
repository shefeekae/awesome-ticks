import 'package:awesometicks/ui/shared/functions/get_color_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/themes/colors.dart';

class BuildStatusWidget extends StatelessWidget {
  BuildStatusWidget({
    required this.status,
    required this.statusColor,
    super.key,
  });

  final Color statusColor;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.sp, horizontal: 5.sp),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getStatusTextColor(status),
        ),
      ),
    );
  }
}
